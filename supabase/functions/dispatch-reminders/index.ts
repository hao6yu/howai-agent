import { createClient } from "npm:@supabase/supabase-js@2";

import {
  buildReminderMessage,
  parseServiceAccount,
  sendFcmMessage,
} from "../_shared/firebase-cloud-messaging.ts";
import {
  nextOccurrence,
  normalizeRecurrence,
} from "../_shared/reminder-recurrence.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const DISPATCH_SECRET = Deno.env.get("REMINDER_DISPATCH_SECRET") ?? "";
const SERVICE_ACCOUNT_JSON = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ??
  "";
const MAX_DELIVERY_ATTEMPTS = 4;

type ClaimedDelivery = Readonly<{
  delivery_id: string;
  reminder_id: string;
  user_id: string;
  title: string;
  notes: string | null;
  timezone: string;
  start_local: string;
  scheduled_for: string;
  recurrence_rule: Record<string, unknown> | null;
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
  if (
    !DISPATCH_SECRET || !constantTimeEqual(
      req.headers.get("x-howai-cron-secret") ?? "",
      DISPATCH_SECRET,
    )
  ) {
    return jsonResponse(401, { error: "Invalid scheduler credentials." });
  }
  if (!supabaseAdmin || !SERVICE_ACCOUNT_JSON) {
    return jsonResponse(503, { error: "Reminder dispatch is not configured." });
  }

  let serviceAccount;
  try {
    serviceAccount = parseServiceAccount(SERVICE_ACCOUNT_JSON);
  } catch (error) {
    console.error("Firebase service account is invalid", safeErrorCode(error));
    return jsonResponse(503, { error: "Reminder dispatch is not configured." });
  }

  const { data, error } = await supabaseAdmin.rpc(
    "claim_due_reminder_deliveries",
    { p_limit: 25 },
  );
  if (error) {
    console.error(
      "Unable to claim reminder deliveries",
      error.code ?? "rpc_error",
    );
    return jsonResponse(503, { error: "Unable to claim reminder deliveries." });
  }
  const deliveries = (data ?? []) as ClaimedDelivery[];
  if (deliveries.length === 0) {
    return jsonResponse(200, { claimed: 0, completed: 0, retried: 0 });
  }

  const userIds = [...new Set(deliveries.map((item) => item.user_id))];
  const deliveryIds = deliveries.map((item) => item.delivery_id);
  const activeSince = new Date(Date.now() - 90 * 86_400_000).toISOString();
  const [deviceResult, successResult] = await Promise.all([
    supabaseAdmin
      .from("push_devices")
      .select("id,user_id,token,platform")
      .in("user_id", userIds)
      .is("disabled_at", null)
      .gte("last_seen_at", activeSince),
    supabaseAdmin
      .from("reminder_delivery_attempts")
      .select("delivery_id,push_device_id")
      .in("delivery_id", deliveryIds)
      .eq("status", "sent"),
  ]);
  if (deviceResult.error || successResult.error) {
    console.error(
      "Unable to load delivery targets",
      deviceResult.error?.code ?? successResult.error?.code ?? "query_error",
    );
    await releaseClaims(deliveries, "target_query_failed");
    return jsonResponse(503, { error: "Unable to load delivery targets." });
  }

  const devicesByUser = new Map<string, PushDevice[]>();
  for (const device of (deviceResult.data ?? []) as PushDevice[]) {
    devicesByUser.set(device.user_id, [
      ...(devicesByUser.get(device.user_id) ?? []),
      device,
    ]);
  }
  const alreadySent = new Set(
    (successResult.data ?? []).map((row) =>
      `${row.delivery_id}:${row.push_device_id}`
    ),
  );

  let completed = 0;
  let retried = 0;
  for (const delivery of deliveries) {
    const devices = devicesByUser.get(delivery.user_id) ?? [];
    const result = await deliverOccurrence(
      delivery,
      devices,
      alreadySent,
      serviceAccount,
    );
    completed += result.completed ? 1 : 0;
    retried += result.retried ? 1 : 0;
  }

  return jsonResponse(200, {
    claimed: deliveries.length,
    completed,
    retried,
  });
});

async function deliverOccurrence(
  delivery: ClaimedDelivery,
  devices: readonly PushDevice[],
  alreadySent: ReadonlySet<string>,
  serviceAccount: ReturnType<typeof parseServiceAccount>,
): Promise<{ completed: boolean; retried: boolean }> {
  const nextFireAt = computeNextFireAt(delivery);
  if (delivery.attempt_number > MAX_DELIVERY_ATTEMPTS) {
    await finish(delivery, "failed", {
      reason: "delivery_attempts_exhausted",
      sent: 0,
      failed: devices.length,
    }, nextFireAt);
    return { completed: true, retried: false };
  }
  if (devices.length === 0) {
    await finish(delivery, "no_devices", {
      reason: "no_active_registered_devices",
      sent: 0,
      failed: 0,
    }, nextFireAt);
    return { completed: true, retried: false };
  }

  let sent = 0;
  let permanentFailures = 0;
  let transientFailures = 0;
  for (const device of devices) {
    if (alreadySent.has(`${delivery.delivery_id}:${device.id}`)) {
      sent += 1;
      continue;
    }
    const result = await sendFcmMessage(
      serviceAccount,
      buildReminderMessage({
        token: device.token,
        reminderId: delivery.reminder_id,
        deliveryId: delivery.delivery_id,
        title: delivery.title,
        scheduledFor: delivery.scheduled_for,
      }),
    );
    if (result.ok) sent += 1;
    else if (result.transient) transientFailures += 1;
    else permanentFailures += 1;

    const { error: attemptError } = await supabaseAdmin!
      .from("reminder_delivery_attempts")
      .upsert({
        delivery_id: delivery.delivery_id,
        push_device_id: device.id,
        attempt_number: delivery.attempt_number,
        status: result.ok
          ? "sent"
          : result.transient
          ? "transient_failure"
          : "permanent_failure",
        provider_message_id: result.messageId,
        error_code: result.errorCode,
        error_message: result.errorMessage,
      }, { onConflict: "delivery_id,push_device_id,attempt_number" });
    if (attemptError) {
      console.error(
        "Unable to record FCM attempt",
        attemptError.code ?? "insert_error",
      );
    }
    if (result.invalidToken) {
      const now = new Date().toISOString();
      const { error: disableError } = await supabaseAdmin!
        .from("push_devices")
        .update({
          disabled_at: now,
          invalid_reason: "fcm_unregistered",
          updated_at: now,
        })
        .eq("id", device.id);
      if (disableError) {
        console.error(
          "Unable to disable invalid FCM token",
          disableError.code ?? "update_error",
        );
      }
    }
  }

  if (
    transientFailures > 0 &&
    delivery.attempt_number < MAX_DELIVERY_ATTEMPTS
  ) {
    const delay = 30 * 2 ** (delivery.attempt_number - 1);
    const { error } = await supabaseAdmin!.rpc("retry_reminder_delivery", {
      p_delivery_id: delivery.delivery_id,
      p_delay_seconds: delay,
      p_summary: {
        reason: "transient_fcm_failure",
        sent,
        transient_failures: transientFailures,
        permanent_failures: permanentFailures,
      },
    });
    if (error) {
      console.error(
        "Unable to release reminder retry",
        error.code ?? "rpc_error",
      );
    }
    return { completed: false, retried: true };
  }

  const outcome = sent === devices.length
    ? "sent"
    : sent > 0
    ? "partial"
    : "failed";
  await finish(delivery, outcome, {
    sent,
    transient_failures: transientFailures,
    permanent_failures: permanentFailures,
  }, nextFireAt);
  return { completed: true, retried: false };
}

function computeNextFireAt(delivery: ClaimedDelivery): string | null {
  if (!delivery.recurrence_rule) return null;
  try {
    const recurrence = normalizeRecurrence(delivery.recurrence_rule);
    const next = nextOccurrence({
      startLocal: delivery.start_local.replace(" ", "T").replace(/\.\d+$/, ""),
      timezone: delivery.timezone,
      recurrence,
      after: new Date(),
      includeStart: false,
    });
    return next?.toISOString() ?? null;
  } catch (error) {
    console.error(
      "Stored reminder recurrence is invalid",
      safeErrorCode(error),
    );
    return null;
  }
}

async function finish(
  delivery: ClaimedDelivery,
  outcome: string,
  summary: Record<string, unknown>,
  nextFireAt: string | null,
): Promise<void> {
  const { error } = await supabaseAdmin!.rpc("finish_reminder_delivery", {
    p_delivery_id: delivery.delivery_id,
    p_outcome: outcome,
    p_summary: summary,
    p_next_fire_at: nextFireAt,
  });
  if (error) {
    console.error(
      "Unable to finish reminder delivery",
      error.code ?? "rpc_error",
    );
  }
}

async function releaseClaims(
  deliveries: readonly ClaimedDelivery[],
  reason: string,
): Promise<void> {
  await Promise.all(
    deliveries.map((delivery) =>
      supabaseAdmin!.rpc("retry_reminder_delivery", {
        p_delivery_id: delivery.delivery_id,
        p_delay_seconds: 30,
        p_summary: { reason },
      })
    ),
  );
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

function safeErrorCode(error: unknown): string {
  return error instanceof Error ? error.name : "unknown_error";
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
