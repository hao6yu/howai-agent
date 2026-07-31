import { createClient } from "npm:@supabase/supabase-js@2.111.0";

import {
  describeAutomation,
  nextAutomationOccurrence,
  normalizeAutomationCreate,
} from "../_shared/automation-contracts.ts";
import { ReminderValidationError } from "../_shared/reminder-recurrence.ts";
import { isStoredEntitlementActive } from "../_shared/entitlement-status.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const MAX_BODY_BYTES = 64 * 1024;
const MAX_PROPOSALS_PER_DAY = Number(
  Deno.env.get("AUTOMATION_ACTIONS_MAX_PROPOSALS_PER_DAY") ?? 20,
);
const ACTION_RUN_COLUMNS =
  "id,user_id,conversation_id,origin,action_type,arguments,human_summary,warnings,status,proposed_at,resource_type,resource_id,result";
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const ACTION_TYPES = new Set([
  "automations_create",
  "automations_update",
  "automations_pause",
  "automations_resume",
  "automations_run_now",
  "automations_delete",
]);

type ActionType =
  | "automations_create"
  | "automations_update"
  | "automations_pause"
  | "automations_resume"
  | "automations_run_now"
  | "automations_delete";

type ActionRun = Readonly<{
  id: string;
  user_id: string;
  conversation_id: string | null;
  origin: "text" | "voice" | "notification" | "system";
  action_type: ActionType;
  arguments: Record<string, unknown>;
  human_summary: string;
  warnings: string[];
  status: string;
  proposed_at: string;
  resource_type: string | null;
  resource_id: string | null;
  result: Record<string, unknown>;
}>;

type AutomationRow = Readonly<{
  id: string;
  kind: "news_briefing" | "market_briefing";
  title: string;
  status: "active" | "paused" | "completed";
  version: number;
  timezone: string;
  start_local: string;
  schedule_rule: Record<string, unknown>;
  next_run_at: string;
  config: Record<string, unknown>;
  source_policy: Record<string, unknown>;
  delivery_preferences: Record<string, unknown>;
}>;

type NormalizedAction = Readonly<{
  arguments: Record<string, unknown>;
  summary: string;
  warnings: readonly string[];
}>;

type AutomationCapability = Readonly<{
  automations: boolean;
  market_automations: boolean;
  requires_paid: boolean;
  rollout_enabled: boolean;
  market_rollout_enabled: boolean;
}>;

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }
  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed." }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required." }, origin);
  }
  if (user.isAnonymous) {
    return jsonResponse(
      403,
      { error: "A signed-in account is required." },
      origin,
    );
  }
  if (!supabaseAdmin) {
    return jsonResponse(
      503,
      { error: "Automation actions are unavailable." },
      origin,
    );
  }

  let body: Record<string, unknown>;
  try {
    body = await readJsonBody(req);
  } catch (error) {
    return jsonResponse(400, {
      error: error instanceof Error ? error.message : "Invalid request.",
    }, origin);
  }

  const capability = await automationCapability(user.id);
  if (body.operation === "capabilities") {
    return jsonResponse(200, capability, origin);
  }
  if (!capability.automations) {
    return jsonResponse(403, {
      error: capability.requires_paid
        ? "Generated Automations require a Pro subscription."
        : "Automations are not enabled for this account yet.",
      code: capability.requires_paid ? "paid_required" : "rollout_disabled",
    }, origin);
  }

  try {
    if (body.operation === "propose") {
      return await propose(user.id, body, origin, capability);
    }
    if (body.operation === "decide") {
      return await decide(user.id, body, origin, capability);
    }
    return jsonResponse(400, { error: "Unsupported operation." }, origin);
  } catch (error) {
    if (error instanceof ReminderValidationError) {
      console.warn("Automation validation rejected", error.code);
      return jsonResponse(
        422,
        { error: error.message, code: error.code },
        origin,
      );
    }
    console.error("Automation action failed", safeErrorCode(error));
    return jsonResponse(503, {
      error: "Automation actions are temporarily unavailable.",
    }, origin);
  }
});

async function propose(
  userId: string,
  body: Record<string, unknown>,
  origin: string | null,
  capability: AutomationCapability,
): Promise<Response> {
  if (
    typeof body.action_type !== "string" ||
    !ACTION_TYPES.has(body.action_type)
  ) {
    throw validation("A supported Automation action is required.");
  }
  const actionType = body.action_type as ActionType;
  const actionOrigin = body.origin;
  if (
    actionOrigin !== "text" && actionOrigin !== "voice" &&
    actionOrigin !== "notification" && actionOrigin !== "system"
  ) {
    throw validation("A valid action origin is required.");
  }
  const idempotencyKey = requiredText(
    body.idempotency_key,
    "idempotency_key",
    200,
  );
  if (idempotencyKey.length < 8) {
    throw validation("idempotency_key is too short.");
  }
  const conversationId = optionalUuid(body.conversation_id, "conversation_id");
  if (conversationId) await assertConversationOwnership(userId, conversationId);
  const replacesProposalId = optionalUuid(
    body.replaces_proposal_id,
    "replaces_proposal_id",
  );

  const { data: existing, error: existingError } = await supabaseAdmin!
    .from("agent_action_runs").select(ACTION_RUN_COLUMNS)
    .eq("user_id", userId).eq("idempotency_key", idempotencyKey).maybeSingle();
  if (existingError) throw existingError;
  if (existing) {
    if (
      (existing as ActionRun).arguments.kind === "market_briefing" &&
      requiresMarketCapability((existing as ActionRun).action_type) &&
      !capability.market_automations
    ) {
      return marketDataDisabled(origin);
    }
    return jsonResponse(200, {
      proposal: serializeProposal(existing as ActionRun),
    }, origin);
  }

  if (!replacesProposalId) {
    const since = new Date(Date.now() - 86_400_000).toISOString();
    const { count, error } = await supabaseAdmin!.from("agent_action_runs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId).like("action_type", "automations_%").gte(
        "proposed_at",
        since,
      );
    if (error) throw error;
    if ((count ?? 0) >= MAX_PROPOSALS_PER_DAY) {
      return jsonResponse(429, {
        error: "The daily Automation proposal limit has been reached.",
      }, origin);
    }
  }

  const normalized = await normalizeAction(userId, actionType, body.arguments);
  if (
    normalized.arguments.kind === "market_briefing" &&
    requiresMarketCapability(actionType) &&
    !capability.market_automations
  ) {
    return marketDataDisabled(origin);
  }
  const proposal = {
    user_id: userId,
    conversation_id: conversationId,
    origin: actionOrigin,
    action_type: actionType,
    arguments: normalized.arguments,
    human_summary: boundedText(normalized.summary, 500),
    warnings: normalized.warnings,
    idempotency_key: idempotencyKey,
  };

  if (replacesProposalId) {
    const { data, error } = await supabaseAdmin!.from("agent_action_runs")
      .update(proposal).eq("id", replacesProposalId).eq("user_id", userId)
      .eq("status", "proposed").eq("action_type", actionType)
      .select(ACTION_RUN_COLUMNS).maybeSingle();
    if (error) throw error;
    if (!data) {
      throw validation(
        "That Automation draft is no longer awaiting approval.",
        "proposal_not_pending",
      );
    }
    return jsonResponse(
      200,
      { proposal: serializeProposal(data as ActionRun) },
      origin,
    );
  }

  const { data, error } = await supabaseAdmin!.from("agent_action_runs")
    .insert(proposal).select(ACTION_RUN_COLUMNS).single();
  if (error?.code === "23505") {
    const { data: raced, error: racedError } = await supabaseAdmin!.from(
      "agent_action_runs",
    )
      .select(ACTION_RUN_COLUMNS).eq("user_id", userId).eq(
        "idempotency_key",
        idempotencyKey,
      ).single();
    if (racedError || !raced) throw racedError ?? error;
    return jsonResponse(200, {
      proposal: serializeProposal(raced as ActionRun),
    }, origin);
  }
  if (error || !data) throw error ?? new Error("proposal_insert_failed");
  return jsonResponse(
    201,
    { proposal: serializeProposal(data as ActionRun) },
    origin,
  );
}

async function decide(
  userId: string,
  body: Record<string, unknown>,
  origin: string | null,
  capability: AutomationCapability,
): Promise<Response> {
  const proposalId = requiredUuid(body.proposal_id, "proposal_id");
  const decision = body.decision;
  if (decision !== "approved" && decision !== "rejected") {
    throw validation("decision must be approved or rejected.");
  }
  const channel = body.channel;
  if (channel !== "text" && channel !== "voice" && channel !== "notification") {
    throw validation("A valid decision channel is required.");
  }
  const { data, error } = await supabaseAdmin!.from("agent_action_runs")
    .select(ACTION_RUN_COLUMNS).eq("id", proposalId).eq("user_id", userId)
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    return jsonResponse(404, { error: "Action proposal not found." }, origin);
  }
  const run = data as ActionRun;
  if (
    run.arguments.kind === "market_briefing" &&
    requiresMarketCapability(run.action_type) &&
    !capability.market_automations
  ) {
    return marketDataDisabled(origin);
  }

  if (decision === "rejected") {
    if (run.status === "rejected") {
      return jsonResponse(
        200,
        { decision: "rejected", audit_id: run.id },
        origin,
      );
    }
    if (run.status !== "proposed") {
      return jsonResponse(409, {
        error: "This action has already been decided.",
      }, origin);
    }
    const { data: rejected, error: rejectError } = await supabaseAdmin!.from(
      "agent_action_runs",
    )
      .update({ status: "rejected", completed_at: new Date().toISOString() })
      .eq("id", run.id).eq("user_id", userId).eq("status", "proposed").select(
        "id",
      ).maybeSingle();
    if (rejectError) throw rejectError;
    if (!rejected) {
      return jsonResponse(409, {
        error: "This action has already been decided.",
      }, origin);
    }
    return jsonResponse(
      200,
      { decision: "rejected", audit_id: run.id },
      origin,
    );
  }

  const { data: resultData, error: executeError } = await supabaseAdmin!.rpc(
    "execute_automation_action",
    {
      p_action_run_id: run.id,
      p_user_id: userId,
      p_execution: run.arguments,
    },
  );
  if (executeError) {
    if (executeError.code === "54000") {
      return jsonResponse(409, {
        error: "You can have up to two active generated Automations.",
      }, origin);
    }
    if (executeError.code === "54001") {
      return jsonResponse(429, {
        error: "Run now is available once every 10 minutes per Automation.",
      }, origin);
    }
    if (executeError.code === "42501") {
      return jsonResponse(403, {
        error: "A current Pro subscription is required.",
      }, origin);
    }
    if (executeError.code === "40001" || executeError.code === "55000") {
      return jsonResponse(409, {
        error: "This Automation proposal is no longer current.",
      }, origin);
    }
    throw executeError;
  }
  const result = Array.isArray(resultData) ? resultData[0] : resultData;
  return jsonResponse(200, {
    result: {
      status: "succeeded",
      display_message: successMessage(run.action_type),
      retryable: false,
      audit_id: run.id,
      resource_type: result?.resource_type ?? "automation",
      resource_id: result?.resource_id ?? null,
    },
  }, origin);
}

async function normalizeAction(
  userId: string,
  actionType: ActionType,
  rawArguments: unknown,
): Promise<NormalizedAction> {
  if (actionType === "automations_create") {
    const automation = normalizeAutomationCreate(rawArguments);
    return {
      arguments: automation as unknown as Record<string, unknown>,
      summary: describeAutomation(automation),
      warnings: [
        "Generated briefings require Pro and will run only after this approval.",
        "HowAI will withhold a run when its claims or sources cannot be verified.",
      ],
    };
  }

  if (!isRecord(rawArguments)) {
    throw validation("Automation action arguments must be an object.");
  }
  const automationId = requiredUuid(
    rawArguments.automation_id,
    "automation_id",
  );
  const expectedVersion = requiredInteger(
    rawArguments.expected_version,
    "expected_version",
  );
  const automation = await getAutomation(userId, automationId);
  if (automation.version !== expectedVersion) {
    throw validation(
      "This Automation changed. Refresh it before proposing another action.",
      "automation_conflict",
    );
  }

  const base = {
    automation_id: automationId,
    expected_version: expectedVersion,
    kind: automation.kind,
  };
  switch (actionType) {
    case "automations_update": {
      if (automation.status === "completed") {
        throw validation("A completed one-time Automation cannot be edited.");
      }
      rejectUnknownKeys(
        rawArguments,
        new Set([
          "automation_id",
          "expected_version",
          "title",
          "timezone",
          "start_local",
          "schedule",
          "config",
          "source_policy",
          "delivery_preferences",
        ]),
      );
      const updated = normalizeAutomationCreate({
        kind: automation.kind,
        title: rawArguments.title,
        timezone: rawArguments.timezone,
        start_local: rawArguments.start_local,
        schedule: rawArguments.schedule,
        config: rawArguments.config,
        source_policy: rawArguments.source_policy,
        delivery_preferences: rawArguments.delivery_preferences,
      });
      return {
        arguments: {
          ...base,
          ...updated,
        },
        summary: `Update Automation: ${describeAutomation(updated)}`,
        warnings: [],
      };
    }
    case "automations_pause":
      rejectManagementKeys(rawArguments);
      if (automation.status !== "active") {
        throw validation("Only an active Automation can be paused.");
      }
      return {
        arguments: base,
        summary: `Pause Automation “${automation.title}”`,
        warnings: [],
      };
    case "automations_resume": {
      rejectManagementKeys(rawArguments);
      if (automation.status !== "paused") {
        throw validation("Only a paused Automation can be resumed.");
      }
      const nextRunAt = nextRunForExisting(automation, new Date());
      return {
        arguments: { ...base, next_run_at: nextRunAt },
        summary: `Resume Automation “${automation.title}” for ${
          formatInstant(nextRunAt, automation.timezone)
        }`,
        warnings: [],
      };
    }
    case "automations_run_now":
      rejectManagementKeys(rawArguments);
      if (automation.status === "completed") {
        throw validation("A completed one-time Automation cannot run again.");
      }
      return {
        arguments: base,
        summary: `Run Automation “${automation.title}” now`,
        warnings: [
          "This creates one immediate report and does not change the saved schedule.",
        ],
      };
    case "automations_delete":
      rejectManagementKeys(rawArguments);
      return {
        arguments: base,
        summary: `Delete Automation “${automation.title}”`,
        warnings: [
          "Deleting removes the Automation and its run history permanently.",
        ],
      };
    default:
      throw validation("Unsupported Automation action.");
  }
}

async function getAutomation(
  userId: string,
  automationId: string,
): Promise<AutomationRow> {
  const { data, error } = await supabaseAdmin!
    .from("automations")
    .select(
      "id,kind,title,status,version,timezone,start_local,schedule_rule,next_run_at,config,source_policy,delivery_preferences",
    )
    .eq("id", automationId)
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    throw validation("Automation not found.", "automation_not_found");
  }
  return data as AutomationRow;
}

function nextRunForExisting(automation: AutomationRow, now: Date): string {
  const existing = new Date(automation.next_run_at);
  if (existing.getTime() > now.getTime()) return existing.toISOString();
  const next = nextAutomationOccurrence({
    startLocal: normalizeStoredLocal(automation.start_local),
    timezone: automation.timezone,
    scheduleRule: automation.schedule_rule,
    after: now,
  });
  if (!next) {
    throw validation(
      "This Automation has no future occurrence to resume.",
      "schedule_in_past",
    );
  }
  return next.toISOString();
}

function rejectManagementKeys(value: Record<string, unknown>): void {
  rejectUnknownKeys(
    value,
    new Set(["automation_id", "expected_version"]),
  );
}

function rejectUnknownKeys(
  value: Record<string, unknown>,
  allowed: ReadonlySet<string>,
): void {
  const unknown = Object.keys(value).filter((key) => !allowed.has(key));
  if (unknown.length > 0) {
    throw validation(`Unknown action fields: ${unknown.join(", ")}.`);
  }
}

function successMessage(actionType: ActionType): string {
  switch (actionType) {
    case "automations_create":
      return "Automation created.";
    case "automations_update":
      return "Automation updated.";
    case "automations_pause":
      return "Automation paused.";
    case "automations_resume":
      return "Automation resumed.";
    case "automations_run_now":
      return "Automation queued to run now.";
    case "automations_delete":
      return "Automation deleted.";
  }
}

function requiresMarketCapability(actionType: ActionType): boolean {
  // A rollout rollback must never trap an existing market Automation in an
  // active state. Users may always pause or delete it; generation and edits
  // continue to require the separate market capability.
  return actionType !== "automations_pause" &&
    actionType !== "automations_delete";
}

function formatInstant(value: string, timezone: string): string {
  return new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    weekday: "short",
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(value));
}

function normalizeStoredLocal(value: string): string {
  return value.replace(" ", "T").replace(/\.\d+$/, "");
}

async function automationCapability(
  userId: string,
): Promise<AutomationCapability> {
  const [{ data: flag }, { data: marketFlag }, { data: entitlement }] =
    await Promise.all([
      supabaseAdmin!.from("feature_flags").select("enabled,payload").eq(
        "key",
        "automations",
      ).maybeSingle(),
      supabaseAdmin!.from("feature_flags").select("enabled,payload").eq(
        "key",
        "automation_market_data",
      ).maybeSingle(),
      supabaseAdmin!.from("app_entitlements").select(
        "tier,source,expires_at,model_policy_canary",
      ).eq("user_id", userId).maybeSingle(),
    ]);
  const paid = isStoredEntitlementActive(entitlement);
  const canary = entitlement?.model_policy_canary === true;
  const rollout = flagEnabledForUser(flag, canary);
  const marketRollout = flagEnabledForUser(marketFlag, canary);
  return {
    automations: paid && rollout,
    market_automations: paid && rollout && marketRollout,
    requires_paid: rollout && !paid,
    rollout_enabled: rollout,
    market_rollout_enabled: marketRollout,
  };
}

function flagEnabledForUser(
  flag: { enabled?: boolean; payload?: unknown } | null,
  canary: boolean,
): boolean {
  const payload = isRecord(flag?.payload) ? flag.payload : {};
  return flag?.enabled === true && (
    payload.mode === "full" || (payload.mode === "internal" && canary)
  );
}

async function authenticateUser(
  req: Request,
): Promise<{ id: string; isAnonymous: boolean } | null> {
  const token = (req.headers.get("authorization") ?? "").match(
    /^Bearer\s+(.+)$/i,
  )?.[1];
  if (!token || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;
  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.getUser(token);
  if (error || !data.user) return null;
  const user = data.user as typeof data.user & { is_anonymous?: boolean };
  return { id: user.id, isAnonymous: user.is_anonymous === true };
}

async function assertConversationOwnership(
  userId: string,
  id: string,
): Promise<void> {
  const { data, error } = await supabaseAdmin!.from("conversations").select(
    "id",
  ).eq("id", id).eq("user_id", userId).maybeSingle();
  if (error) throw error;
  if (!data) {
    throw validation("Conversation not found.", "conversation_not_found");
  }
}

async function readJsonBody(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) {
    throw validation("Request body is too large.");
  }
  const value = JSON.parse(text);
  if (!isRecord(value)) throw validation("Request body must be a JSON object.");
  return value;
}

function serializeProposal(run: ActionRun): Record<string, unknown> {
  return {
    proposal_id: run.id,
    action_type: run.action_type,
    arguments: run.arguments,
    summary: run.human_summary,
    warnings: run.warnings ?? [],
    origin: run.origin,
    created_at: run.proposed_at,
  };
}

function requiredUuid(value: unknown, field: string): string {
  if (typeof value !== "string" || !UUID.test(value)) {
    throw validation(`${field} must be a UUID.`);
  }
  return value.toLowerCase();
}
function optionalUuid(value: unknown, field: string): string | null {
  return value == null ? null : requiredUuid(value, field);
}
function requiredText(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || !value.trim() || value.trim().length > max) {
    throw validation(`${field} is invalid.`);
  }
  return value.trim();
}
function requiredInteger(value: unknown, field: string): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw validation(`${field} must be a positive integer.`);
  }
  return Number(value);
}
function boundedText(value: string, max: number): string {
  return value.length <= max
    ? value
    : `${value.substring(0, max - 1).trimEnd()}…`;
}
function validation(
  message: string,
  code = "invalid_automation",
): ReminderValidationError {
  return new ReminderValidationError(message, code);
}
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
function safeErrorCode(error: unknown): string {
  return isRecord(error) && typeof error.code === "string"
    ? error.code
    : error instanceof Error
    ? error.name
    : "unknown_error";
}
function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers":
      "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
}
function jsonResponse(
  status: number,
  body: Record<string, unknown>,
  origin: string | null,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(origin),
      "Cache-Control": "no-store",
      "Content-Type": "application/json",
    },
  });
}

function marketDataDisabled(origin: string | null): Response {
  return jsonResponse(403, {
    error:
      "Structured market-data Automations are not enabled yet. News briefings about markets are available.",
    code: "market_data_disabled",
  }, origin);
}
