import { createClient } from "npm:@supabase/supabase-js@2.111.0";

import {
  AutomationReportError,
  buildVerifiedAutomationReport,
  type AutomationModelPhase,
} from "../_shared/automation-report.ts";
import { nextAutomationOccurrence } from "../_shared/automation-contracts.ts";
import {
  buildAutomationMessage,
  parseServiceAccount,
  sendFcmMessage,
} from "../_shared/firebase-cloud-messaging.ts";
import { estimateModelCostMicrousd } from "../_shared/openai-policy.ts";
import { paidCostBudgetLimits } from "../_shared/paid-cost-budget.ts";
import type { ResponsesUsage } from "../_shared/openai-stream.ts";
import { webSearchToolCostMicrousd } from "../_shared/openai-web-search.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const DISPATCH_SECRET = Deno.env.get("REMINDER_DISPATCH_SECRET") ?? "";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
// Scheduled work is high-volume by nature. Keep paid interactive chat on Sol,
// while Automations use the independently metered GPT-5.6 Luna route plus a
// separate fail-closed verification pass.
const OPENAI_MODEL = Deno.env.get("AUTOMATION_MODEL") ??
  Deno.env.get("OPENAI_PROXY_MODEL_LUNA") ?? "gpt-5.6-luna";
const SERVICE_ACCOUNT_JSON = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";
const RUN_BATCH_SIZE = 2;
const DELIVERY_BATCH_SIZE = 20;
const MAX_RUN_ATTEMPTS = 4;
const MAX_DELIVERY_ATTEMPTS = 5;

const AUTOMATION_RESERVATION_MICROUSD = envNumber(
  "AUTOMATION_RESERVATION_MICROUSD",
  100_000,
);
const AUTOMATION_DAILY_BUDGET_MICROUSD = envNumber(
  "AUTOMATION_DAILY_BUDGET_MICROUSD",
  2_000_000,
);
const AUTOMATION_MONTHLY_BUDGET_MICROUSD = envNumber(
  "AUTOMATION_MONTHLY_BUDGET_MICROUSD",
  40_000_000,
);
const GLOBAL_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_GLOBAL_DAILY_BUDGET_MICROUSD",
  10_000_000,
);
const GLOBAL_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_GLOBAL_MONTHLY_BUDGET_MICROUSD",
  150_000_000,
);
const PAID_COST_BUDGET_LIMITS = paidCostBudgetLimits(
  GLOBAL_DAILY_BUDGET_MICROUSD,
  GLOBAL_MONTHLY_BUDGET_MICROUSD,
);

type ClaimedRun = Readonly<{
  run_id: string;
  automation_id: string;
  user_id: string;
  conversation_id: string | null;
  automation_version: number;
  scheduled_for: string;
  attempt_number: number;
  template_snapshot: Record<string, unknown>;
}>;

type ClaimedDelivery = Readonly<{
  delivery_id: string;
  automation_run_id: string;
  user_id: string;
  conversation_id: string;
  message_id: string;
  title: string;
  preview: string;
  attempt_number: number;
}>;

type PushDevice = Readonly<{
  id: number;
  user_id: string;
  token: string;
  platform: "android" | "ios";
}>;

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed." });
  }
  if (!DISPATCH_SECRET || !constantTimeEqual(
    req.headers.get("x-howai-cron-secret") ?? "",
    DISPATCH_SECRET,
  )) {
    return jsonResponse(401, { error: "Invalid scheduler credentials." });
  }
  if (!supabaseAdmin || !OPENAI_API_KEY) {
    return jsonResponse(503, { error: "Automation dispatch is not configured." });
  }

  const runSummary = await dispatchRuns();
  const deliverySummary = await dispatchNotifications();
  const unavailable = runSummary.unavailable || deliverySummary.unavailable;
  return jsonResponse(unavailable ? 503 : 200, {
    runs: runSummary,
    notifications: deliverySummary,
  });
});

async function dispatchRuns(): Promise<{
  claimed: number;
  completed: number;
  retried: number;
  withheld: number;
  unavailable: boolean;
}> {
  const { data, error } = await supabaseAdmin!.rpc("claim_due_automation_runs", {
    p_limit: RUN_BATCH_SIZE,
  });
  if (error) {
    console.error("Unable to claim Automation runs", error.code ?? "rpc_error");
    return { claimed: 0, completed: 0, retried: 0, withheld: 0, unavailable: true };
  }
  const runs = (data ?? []) as ClaimedRun[];
  let completed = 0;
  let retried = 0;
  let withheld = 0;
  for (const run of runs) {
    const outcome = await executeRun(run);
    completed += outcome.completed ? 1 : 0;
    retried += outcome.retried ? 1 : 0;
    withheld += outcome.withheld ? 1 : 0;
  }
  return { claimed: runs.length, completed, retried, withheld, unavailable: false };
}

async function executeRun(
  run: ClaimedRun,
): Promise<{ completed: boolean; retried: boolean; withheld: boolean }> {
  const nextRunAt = computeNextRunAt(run);
  if (run.attempt_number > MAX_RUN_ATTEMPTS) {
    await finishWithheldRun(
      run,
      new AutomationReportError(
        "Automation attempts were exhausted.",
        "automation_attempts_exhausted",
        false,
      ),
      nextRunAt,
    );
    return { completed: true, retried: false, withheld: true };
  }
  try {
    const result = await buildVerifiedAutomationReport({
      runId: run.run_id,
      userId: run.user_id,
      scheduledFor: run.scheduled_for,
      template: run.template_snapshot,
    }, {
      apiKey: OPENAI_API_KEY,
      model: OPENAI_MODEL,
      reserve: (phase) => reserveUsage(run.user_id, phase),
      reconcile: (value) => reconcileUsage(value),
    });

    const pushEnabled = isRecord(run.template_snapshot.delivery_preferences) &&
      run.template_snapshot.delivery_preferences.push === true;
    const { error } = await supabaseAdmin!.rpc("finish_automation_run", {
      p_run_id: run.run_id,
      p_status: result.status,
      p_message_content: result.messageContent,
      p_report: result.report,
      p_preview: result.preview,
      p_claims: result.claims,
      p_sources: result.sources,
      p_verification: result.verification,
      p_generation_response_id: result.generationResponseId,
      p_verification_response_id: result.verificationResponseId,
      p_generation_usage_ledger_id: result.generationLedgerId,
      p_verification_usage_ledger_id: result.verificationLedgerId,
      p_next_run_at: nextRunAt,
      // Keep a withheld result in the conversation and Automation history,
      // but do not interrupt the user with a failure push. Only a completed,
      // verified briefing earns a notification.
      p_create_delivery: pushEnabled && result.status === "succeeded",
      p_error_code: null,
      p_error_message: null,
    });
    if (error) {
      console.error("Unable to finish Automation run", error.code ?? "rpc_error");
      await retryRun(run, "finish_rpc_failed", true);
      return { completed: false, retried: true, withheld: false };
    }
    return {
      completed: true,
      retried: false,
      withheld: result.status === "withheld",
    };
  } catch (error) {
    const reportError = error instanceof AutomationReportError
      ? error
      : new AutomationReportError("Automation processing failed.", "automation_processing_failed", true);
    if (reportError.transient && run.attempt_number < MAX_RUN_ATTEMPTS) {
      await retryRun(run, reportError.code, false);
      return { completed: false, retried: true, withheld: false };
    }
    await finishWithheldRun(run, reportError, nextRunAt);
    return { completed: true, retried: false, withheld: true };
  }
}

async function reserveUsage(
  userId: string,
  phase: AutomationModelPhase,
): Promise<{ requestId: string; ledgerId: string }> {
  const requestId = crypto.randomUUID();
  const { data, error } = await supabaseAdmin!.rpc("reserve_ai_usage_v2", {
    p_user_id: userId,
    p_request_id: requestId,
    p_cohort: "paid",
    p_intent: "research",
    p_requested_alias: `automation_${phase}`,
    // Automation has its own budget route. Using the interactive Research
    // route here lets scheduled work exhaust foreground Research (and vice
    // versa), even though they are separate product capabilities.
    p_model_role: "automation",
    p_resolved_model: OPENAI_MODEL,
    p_reasoning_effort: "low",
    p_reservation_microusd: AUTOMATION_RESERVATION_MICROUSD,
    p_route_daily_budget_microusd: AUTOMATION_DAILY_BUDGET_MICROUSD,
    p_route_monthly_budget_microusd: AUTOMATION_MONTHLY_BUDGET_MICROUSD,
    p_user_daily_budget_microusd:
      PAID_COST_BUDGET_LIMITS.userDailyBudgetMicrousd,
    p_user_monthly_budget_microusd:
      PAID_COST_BUDGET_LIMITS.userMonthlyBudgetMicrousd,
    p_global_daily_budget_microusd: GLOBAL_DAILY_BUDGET_MICROUSD,
    p_global_monthly_budget_microusd: GLOBAL_MONTHLY_BUDGET_MICROUSD,
    p_daily_answer_limit: null,
  });
  if (error) {
    throw new AutomationReportError(
      "Unable to reserve Automation model usage.",
      "usage_reservation_failed",
      true,
    );
  }
  const row = Array.isArray(data) ? data[0] : data;
  if (row?.accepted !== true || typeof row?.ledger_id !== "string") {
    throw new AutomationReportError(
      "This Automation reached its current usage limit.",
      typeof row?.reason === "string" ? `usage_${row.reason}` : "usage_limit_reached",
      false,
    );
  }
  return { requestId, ledgerId: row.ledger_id };
}

async function reconcileUsage(input: {
  phase: AutomationModelPhase;
  requestId: string;
  succeeded: boolean;
  usage: ResponsesUsage | null;
  failureCode: string | null;
}): Promise<void> {
  const usage = input.usage;
  const tokenCost = usage && usage.inputTokens != null && usage.outputTokens != null
    ? estimateModelCostMicrousd(OPENAI_MODEL, {
      inputTokens: usage.inputTokens,
      cachedInputTokens: usage.cachedInputTokens ?? 0,
      cacheWriteInputTokens: usage.cacheWriteInputTokens ?? 0,
      outputTokens: usage.outputTokens,
    })
    : null;
  const actualCost = tokenCost == null
    ? (usage ? AUTOMATION_RESERVATION_MICROUSD : 0)
    : tokenCost + webSearchToolCostMicrousd(usage?.webSearchCalls ?? 0);
  const { error } = await supabaseAdmin!.rpc("reconcile_ai_usage_v2", {
    p_request_id: input.requestId,
    p_succeeded: input.succeeded,
    p_counts_as_answer: input.succeeded && input.phase === "generation",
    p_input_tokens: usage?.inputTokens ?? null,
    p_cached_input_tokens: usage?.cachedInputTokens ?? null,
    p_output_tokens: usage?.outputTokens ?? null,
    p_tool_calls: {
      web_search: usage?.webSearchCalls ?? 0,
      cache_write_tokens: usage?.cacheWriteInputTokens ?? 0,
    },
    p_actual_cost_microusd: actualCost,
    p_failure_code: input.failureCode,
  });
  if (error) {
    console.error("Unable to reconcile Automation usage", error.code ?? "rpc_error");
  }
}

async function retryRun(
  run: ClaimedRun,
  errorCode: string,
  shortDelay: boolean,
): Promise<void> {
  const delay = shortDelay ? 15 : 30 * 2 ** Math.max(0, run.attempt_number - 1);
  const { error } = await supabaseAdmin!.rpc("retry_automation_run", {
    p_run_id: run.run_id,
    p_delay_seconds: Math.min(delay, 600),
    p_error_code: errorCode.slice(0, 100),
    p_error_message: "The Automation will retry automatically.",
  });
  if (error) console.error("Unable to retry Automation run", error.code ?? "rpc_error");
}

async function finishWithheldRun(
  run: ClaimedRun,
  error: AutomationReportError,
  nextRunAt: string | null,
): Promise<void> {
  const title = typeof run.template_snapshot.title === "string"
    ? run.template_snapshot.title
    : "this Automation";
  const message = `I couldn't verify “${title}” well enough to send it. No unverified briefing was delivered. You can try Run now again from Automations.`;
  const { error: finishError } = await supabaseAdmin!.rpc("finish_automation_run", {
    p_run_id: run.run_id,
    p_status: "withheld",
    p_message_content: message,
    p_report: { withheld: true, title },
    p_preview: message.slice(0, 500),
    p_claims: [],
    p_sources: [],
    p_verification: { status: "withhold", issues: [error.code] },
    p_generation_response_id: null,
    p_verification_response_id: null,
    p_generation_usage_ledger_id: null,
    p_verification_usage_ledger_id: null,
    p_next_run_at: nextRunAt,
    p_create_delivery: false,
    p_error_code: error.code.slice(0, 100),
    p_error_message: error.message.slice(0, 500),
  });
  if (finishError) {
    console.error("Unable to withhold Automation run", finishError.code ?? "rpc_error");
  }
}

function computeNextRunAt(run: ClaimedRun): string | null {
  const snapshot = run.template_snapshot;
  if (typeof snapshot.start_local !== "string" || typeof snapshot.timezone !== "string" ||
    !isRecord(snapshot.schedule_rule)) return null;
  try {
    return nextAutomationOccurrence({
      startLocal: snapshot.start_local,
      timezone: snapshot.timezone,
      scheduleRule: snapshot.schedule_rule,
      after: new Date(run.scheduled_for),
    })?.toISOString() ?? null;
  } catch (error) {
    console.error("Stored Automation schedule is invalid", safeErrorCode(error));
    return null;
  }
}

async function dispatchNotifications(): Promise<{
  claimed: number;
  completed: number;
  retried: number;
  unavailable: boolean;
}> {
  if (!SERVICE_ACCOUNT_JSON) {
    return { claimed: 0, completed: 0, retried: 0, unavailable: false };
  }
  let serviceAccount: ReturnType<typeof parseServiceAccount>;
  try {
    serviceAccount = parseServiceAccount(SERVICE_ACCOUNT_JSON);
  } catch (error) {
    console.error("Firebase service account is invalid", safeErrorCode(error));
    return { claimed: 0, completed: 0, retried: 0, unavailable: true };
  }
  const { data, error } = await supabaseAdmin!.rpc("claim_due_automation_deliveries", {
    p_limit: DELIVERY_BATCH_SIZE,
  });
  if (error) {
    console.error("Unable to claim Automation notifications", error.code ?? "rpc_error");
    return { claimed: 0, completed: 0, retried: 0, unavailable: true };
  }
  const deliveries = (data ?? []) as ClaimedDelivery[];
  if (deliveries.length === 0) {
    return { claimed: 0, completed: 0, retried: 0, unavailable: false };
  }

  const targets = await loadDeliveryTargets(deliveries);
  if (!targets) {
    await releaseDeliveryClaims(deliveries, "target_query_failed");
    return { claimed: deliveries.length, completed: 0, retried: deliveries.length, unavailable: true };
  }
  let completed = 0;
  let retried = 0;
  for (const delivery of deliveries) {
    const result = await deliverNotification(
      delivery,
      targets.devicesByUser.get(delivery.user_id) ?? [],
      targets.alreadySent,
      serviceAccount,
    );
    completed += result.completed ? 1 : 0;
    retried += result.retried ? 1 : 0;
  }
  return { claimed: deliveries.length, completed, retried, unavailable: false };
}

async function loadDeliveryTargets(deliveries: readonly ClaimedDelivery[]): Promise<{
  devicesByUser: Map<string, PushDevice[]>;
  alreadySent: Set<string>;
} | null> {
  const userIds = [...new Set(deliveries.map((item) => item.user_id))];
  const deliveryIds = deliveries.map((item) => item.delivery_id);
  const activeSince = new Date(Date.now() - 90 * 86_400_000).toISOString();
  const [deviceResult, successResult] = await Promise.all([
    supabaseAdmin!.from("push_devices").select("id,user_id,token,platform")
      .in("user_id", userIds).is("disabled_at", null).gte("last_seen_at", activeSince),
    supabaseAdmin!.from("automation_delivery_attempts")
      .select("delivery_id,push_device_id").in("delivery_id", deliveryIds).eq("status", "sent"),
  ]);
  if (deviceResult.error || successResult.error) {
    console.error(
      "Unable to load Automation delivery targets",
      deviceResult.error?.code ?? successResult.error?.code ?? "query_error",
    );
    return null;
  }
  const devicesByUser = new Map<string, PushDevice[]>();
  for (const device of (deviceResult.data ?? []) as PushDevice[]) {
    devicesByUser.set(device.user_id, [...(devicesByUser.get(device.user_id) ?? []), device]);
  }
  return {
    devicesByUser,
    alreadySent: new Set((successResult.data ?? []).map((row) => `${row.delivery_id}:${row.push_device_id}`)),
  };
}

async function deliverNotification(
  delivery: ClaimedDelivery,
  devices: readonly PushDevice[],
  alreadySent: ReadonlySet<string>,
  serviceAccount: ReturnType<typeof parseServiceAccount>,
): Promise<{ completed: boolean; retried: boolean }> {
  if (delivery.attempt_number > MAX_DELIVERY_ATTEMPTS) {
    await finishDelivery(delivery.delivery_id, "failed", { reason: "attempts_exhausted" });
    return { completed: true, retried: false };
  }
  if (devices.length === 0) {
    await finishDelivery(delivery.delivery_id, "no_devices", { reason: "no_active_registered_devices" });
    return { completed: true, retried: false };
  }
  let sent = 0;
  let transientFailures = 0;
  let permanentFailures = 0;
  for (const device of devices) {
    if (alreadySent.has(`${delivery.delivery_id}:${device.id}`)) {
      sent += 1;
      continue;
    }
    const result = await sendFcmMessage(serviceAccount, buildAutomationMessage({
      token: device.token,
      automationRunId: delivery.automation_run_id,
      deliveryId: delivery.delivery_id,
      conversationId: delivery.conversation_id,
      messageId: delivery.message_id,
      title: delivery.title,
      preview: delivery.preview,
    }));
    if (result.ok) sent += 1;
    else if (result.transient) transientFailures += 1;
    else permanentFailures += 1;
    const { error } = await supabaseAdmin!.from("automation_delivery_attempts").upsert({
      delivery_id: delivery.delivery_id,
      push_device_id: device.id,
      attempt_number: delivery.attempt_number,
      status: result.ok ? "sent" : result.transient ? "transient_failure" : "permanent_failure",
      provider_message_id: result.messageId,
      error_code: result.errorCode,
      error_message: result.errorMessage,
    }, { onConflict: "delivery_id,push_device_id,attempt_number" });
    if (error) console.error("Unable to record Automation push attempt", error.code ?? "insert_error");
    if (result.invalidToken) await disableDevice(device.id);
  }

  if (transientFailures > 0 && delivery.attempt_number < MAX_DELIVERY_ATTEMPTS) {
    const delay = 30 * 2 ** Math.max(0, delivery.attempt_number - 1);
    const { error } = await supabaseAdmin!.rpc("retry_automation_delivery", {
      p_delivery_id: delivery.delivery_id,
      p_delay_seconds: Math.min(delay, 600),
      p_summary: { sent, transient_failures: transientFailures, permanent_failures: permanentFailures },
    });
    if (error) console.error("Unable to retry Automation push", error.code ?? "rpc_error");
    return { completed: false, retried: true };
  }
  const outcome = sent === devices.length ? "sent" : sent > 0 ? "partial" : "failed";
  await finishDelivery(delivery.delivery_id, outcome, {
    sent,
    transient_failures: transientFailures,
    permanent_failures: permanentFailures,
  });
  return { completed: true, retried: false };
}

async function disableDevice(deviceId: number): Promise<void> {
  const now = new Date().toISOString();
  const { error } = await supabaseAdmin!.from("push_devices").update({
    disabled_at: now,
    invalid_reason: "fcm_unregistered",
    updated_at: now,
  }).eq("id", deviceId);
  if (error) console.error("Unable to disable invalid FCM token", error.code ?? "update_error");
}

async function finishDelivery(
  deliveryId: string,
  outcome: string,
  summary: Record<string, unknown>,
): Promise<void> {
  const { error } = await supabaseAdmin!.rpc("finish_automation_delivery", {
    p_delivery_id: deliveryId,
    p_outcome: outcome,
    p_summary: summary,
  });
  if (error) console.error("Unable to finish Automation push", error.code ?? "rpc_error");
}

async function releaseDeliveryClaims(
  deliveries: readonly ClaimedDelivery[],
  reason: string,
): Promise<void> {
  await Promise.all(deliveries.map((delivery) =>
    supabaseAdmin!.rpc("retry_automation_delivery", {
      p_delivery_id: delivery.delivery_id,
      p_delay_seconds: 30,
      p_summary: { reason },
    })
  ));
}

function constantTimeEqual(left: string, right: string): boolean {
  const leftBytes = new TextEncoder().encode(left);
  const rightBytes = new TextEncoder().encode(right);
  const length = Math.max(leftBytes.length, rightBytes.length);
  let difference = leftBytes.length ^ rightBytes.length;
  for (let index = 0; index < length; index++) {
    difference |= (leftBytes[index] ?? 0) ^ (rightBytes[index] ?? 0);
  }
  return difference === 0;
}

function envNumber(name: string, fallback: number): number {
  const value = Number(Deno.env.get(name));
  return Number.isFinite(value) && value >= 0 ? Math.floor(value) : fallback;
}

function safeErrorCode(error: unknown): string {
  return error instanceof Error ? error.name : "unknown_error";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function jsonResponse(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Cache-Control": "no-store",
      "Content-Type": "application/json",
    },
  });
}
