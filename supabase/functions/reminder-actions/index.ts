import { createClient } from "npm:@supabase/supabase-js@2.111.0";

import {
  describeReminderSchedule,
  nextOccurrence,
  type NormalizedReminderSchedule,
  normalizeRecurrence,
  normalizeReminderSchedule,
  ReminderValidationError,
} from "../_shared/reminder-recurrence.ts";
import {
  snoozeFromLegacyInstant,
  snoozeFromNextOccurrence,
} from "../_shared/reminder-snooze.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const MAX_BODY_BYTES = 64 * 1024;
const MAX_PROPOSALS_PER_DAY = Number(
  Deno.env.get("REMINDER_ACTIONS_MAX_PROPOSALS_PER_DAY") ?? 100,
);

const ACTION_TYPES = new Set([
  "reminders_create",
  "reminders_update",
  "reminders_complete",
  "reminders_snooze",
  "reminders_pause",
  "reminders_resume",
  "reminders_skip_next",
  "reminders_delete",
]);

type ActionType =
  | "reminders_create"
  | "reminders_update"
  | "reminders_complete"
  | "reminders_snooze"
  | "reminders_pause"
  | "reminders_resume"
  | "reminders_skip_next"
  | "reminders_delete";

type AuthenticatedUser = Readonly<{ id: string; isAnonymous: boolean }>;

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

type ReminderRow = Readonly<{
  id: string;
  title: string;
  notes: string | null;
  timezone: string;
  start_local: string;
  next_fire_at: string;
  recurrence_rule: Record<string, unknown> | null;
  status: "active" | "paused" | "completed";
  version: number;
}>;

type NormalizedAction = Readonly<{
  arguments: Record<string, unknown>;
  summary: string;
  warnings: readonly string[];
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
    console.error("Reminder actions are not configured.");
    return jsonResponse(
      503,
      { error: "Reminder actions are unavailable." },
      origin,
    );
  }

  let body: Record<string, unknown>;
  try {
    body = await readJsonBody(req);
  } catch (error) {
    const message = error instanceof ReminderValidationError
      ? error.message
      : "Request body must be valid JSON.";
    return jsonResponse(400, { error: message }, origin);
  }

  const operation = body.operation;
  const enabled = await reminderActionsEnabled(user.id);
  if (operation === "capabilities") {
    return jsonResponse(200, { reminders: enabled }, origin);
  }
  if (!enabled) {
    return jsonResponse(
      403,
      { error: "Reminder actions are not enabled for this account yet." },
      origin,
    );
  }

  try {
    if (operation === "propose") {
      return await proposeAction(user.id, body, origin);
    }
    if (operation === "decide") {
      return await decideAction(user.id, body, origin);
    }
    return jsonResponse(400, { error: "Unsupported operation." }, origin);
  } catch (error) {
    if (error instanceof ReminderValidationError) {
      // Log only the bounded validation code, never reminder content or model
      // arguments. This makes future 422s diagnosable without leaking user data.
      console.warn("Reminder validation rejected", error.code);
      return jsonResponse(
        422,
        { error: error.message, code: error.code },
        origin,
      );
    }
    console.error("Reminder action request failed", safeErrorCode(error));
    return jsonResponse(
      503,
      { error: "Reminder actions are temporarily unavailable." },
      origin,
    );
  }
});

async function proposeAction(
  userId: string,
  body: Record<string, unknown>,
  origin: string | null,
): Promise<Response> {
  const actionType = body.action_type;
  if (typeof actionType !== "string" || !ACTION_TYPES.has(actionType)) {
    throw new ReminderValidationError(
      "A supported reminder action is required.",
    );
  }
  const typedAction = actionType as ActionType;
  const actionOrigin = body.origin;
  if (
    actionOrigin !== "text" && actionOrigin !== "voice" &&
    actionOrigin !== "notification" && actionOrigin !== "system"
  ) {
    throw new ReminderValidationError("A valid action origin is required.");
  }
  const idempotencyKey = requiredText(
    body.idempotency_key,
    "idempotency_key",
    200,
  );
  if (idempotencyKey.length < 8) {
    throw new ReminderValidationError("idempotency_key is too short.");
  }
  const conversationId = optionalUuid(body.conversation_id, "conversation_id");
  if (conversationId) await assertConversationOwnership(userId, conversationId);
  const replacesProposalId = optionalUuid(
    body.replaces_proposal_id,
    "replaces_proposal_id",
  );

  const { data: existing, error: existingError } = await supabaseAdmin!
    .from("agent_action_runs")
    .select(ACTION_RUN_COLUMNS)
    .eq("user_id", userId)
    .eq("idempotency_key", idempotencyKey)
    .maybeSingle();
  if (existingError) throw existingError;
  if (existing) {
    return jsonResponse(200, {
      proposal: serializeProposal(existing as ActionRun),
    }, origin);
  }

  if (!replacesProposalId) {
    const since = new Date(Date.now() - 86_400_000).toISOString();
    const { count, error: countError } = await supabaseAdmin!
      .from("agent_action_runs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("proposed_at", since);
    if (countError) throw countError;
    if ((count ?? 0) >= MAX_PROPOSALS_PER_DAY) {
      return jsonResponse(
        429,
        { error: "The daily reminder-action limit has been reached." },
        origin,
      );
    }
  }

  const normalized = await normalizeAction(userId, typedAction, body.arguments);
  if (replacesProposalId) {
    const { data: replaced, error: replaceError } = await supabaseAdmin!
      .from("agent_action_runs")
      .update({
        origin: actionOrigin,
        arguments: normalized.arguments,
        human_summary: normalized.summary,
        warnings: normalized.warnings,
        idempotency_key: idempotencyKey,
        proposed_at: new Date().toISOString(),
      })
      .eq("id", replacesProposalId)
      .eq("user_id", userId)
      .eq("action_type", typedAction)
      .eq("status", "proposed")
      .select(ACTION_RUN_COLUMNS)
      .maybeSingle();
    if (replaceError?.code === "23505") {
      const { data: raced, error: racedError } = await supabaseAdmin!
        .from("agent_action_runs")
        .select(ACTION_RUN_COLUMNS)
        .eq("user_id", userId)
        .eq("idempotency_key", idempotencyKey)
        .single();
      if (racedError || !raced) throw racedError ?? replaceError;
      return jsonResponse(200, {
        proposal: serializeProposal(raced as ActionRun),
      }, origin);
    }
    if (replaceError) throw replaceError;
    if (!replaced) {
      throw new ReminderValidationError(
        "That reminder draft is no longer awaiting approval.",
        "proposal_not_pending",
      );
    }
    return jsonResponse(200, {
      proposal: serializeProposal(replaced as ActionRun),
    }, origin);
  }

  const { data, error } = await supabaseAdmin!
    .from("agent_action_runs")
    .insert({
      user_id: userId,
      conversation_id: conversationId,
      origin: actionOrigin,
      action_type: typedAction,
      arguments: normalized.arguments,
      human_summary: normalized.summary,
      warnings: normalized.warnings,
      idempotency_key: idempotencyKey,
    })
    .select(ACTION_RUN_COLUMNS)
    .single();

  if (error?.code === "23505") {
    const { data: raced, error: racedError } = await supabaseAdmin!
      .from("agent_action_runs")
      .select(ACTION_RUN_COLUMNS)
      .eq("user_id", userId)
      .eq("idempotency_key", idempotencyKey)
      .single();
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

async function decideAction(
  userId: string,
  body: Record<string, unknown>,
  origin: string | null,
): Promise<Response> {
  const proposalId = requiredUuid(body.proposal_id, "proposal_id");
  const decision = body.decision;
  if (decision !== "approved" && decision !== "rejected") {
    throw new ReminderValidationError("decision must be approved or rejected.");
  }
  const channel = body.channel;
  if (channel !== "text" && channel !== "voice" && channel !== "notification") {
    throw new ReminderValidationError("A valid decision channel is required.");
  }

  const { data: runData, error: runError } = await supabaseAdmin!
    .from("agent_action_runs")
    .select(ACTION_RUN_COLUMNS)
    .eq("id", proposalId)
    .eq("user_id", userId)
    .maybeSingle();
  if (runError) throw runError;
  if (!runData) {
    return jsonResponse(404, { error: "Action proposal not found." }, origin);
  }
  const run = runData as ActionRun;

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
    const { data: rejected, error } = await supabaseAdmin!
      .from("agent_action_runs")
      .update({ status: "rejected", completed_at: new Date().toISOString() })
      .eq("id", run.id)
      .eq("user_id", userId)
      .eq("status", "proposed")
      .select("id")
      .maybeSingle();
    if (error) throw error;
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

  const { data, error } = await supabaseAdmin!.rpc("execute_reminder_action", {
    p_action_run_id: run.id,
    p_user_id: userId,
    p_execution: run.arguments,
  });
  if (error) {
    if (error.code === "40001" || error.code === "55000") {
      await markActionFailed(run.id, userId, "reminder_conflict");
      return jsonResponse(
        409,
        {
          error: "This reminder changed. Refresh and review the action again.",
        },
        origin,
      );
    }
    throw error;
  }

  const result = Array.isArray(data) ? data[0] : data;
  return jsonResponse(200, {
    result: {
      status: "succeeded",
      display_message: successMessage(run.action_type),
      retryable: false,
      audit_id: run.id,
      resource_type: result?.resource_type ?? "reminder",
      resource_id: result?.resource_id ?? null,
    },
  }, origin);
}

async function normalizeAction(
  userId: string,
  actionType: ActionType,
  rawArguments: unknown,
): Promise<NormalizedAction> {
  if (actionType === "reminders_create") {
    const schedule = normalizeReminderSchedule(rawArguments);
    return {
      arguments: schedule as unknown as Record<string, unknown>,
      summary: describeReminderSchedule(schedule),
      warnings:
        schedule.next_fire_at !== localStartInstant(schedule)?.toISOString()
          ? [
            `The first future occurrence is ${
              formatInstant(schedule.next_fire_at, schedule.timezone)
            }.`,
          ]
          : [],
    };
  }

  if (!isRecord(rawArguments)) {
    throw new ReminderValidationError(
      "Reminder action arguments must be an object.",
    );
  }
  const reminderId = requiredUuid(rawArguments.reminder_id, "reminder_id");
  const expectedVersion = requiredInteger(
    rawArguments.expected_version,
    "expected_version",
  );
  const reminder = await getReminder(userId, reminderId);
  if (reminder.version !== expectedVersion) {
    throw new ReminderValidationError(
      "This reminder changed. Refresh it before proposing another action.",
      "reminder_conflict",
    );
  }

  const base = { reminder_id: reminderId, expected_version: expectedVersion };
  switch (actionType) {
    case "reminders_update": {
      rejectUnknownKeys(
        rawArguments,
        new Set([
          "reminder_id",
          "expected_version",
          "title",
          "notes",
          "timezone",
          "start_local",
          "recurrence",
        ]),
      );
      const schedule = normalizeReminderSchedule({
        title: rawArguments.title,
        notes: rawArguments.notes,
        timezone: rawArguments.timezone,
        start_local: rawArguments.start_local,
        recurrence: rawArguments.recurrence,
      });
      return {
        arguments: { ...base, ...schedule },
        summary: `Update reminder: ${describeReminderSchedule(schedule)}`,
        warnings: [],
      };
    }
    case "reminders_snooze": {
      rejectUnknownKeys(
        rawArguments,
        new Set([
          "reminder_id",
          "expected_version",
          "snooze_minutes",
          "snooze_until",
        ]),
      );
      const hasMinutes = rawArguments.snooze_minutes !== undefined;
      const hasLegacyInstant = rawArguments.snooze_until !== undefined;
      if (hasMinutes === hasLegacyInstant) {
        throw new ReminderValidationError(
          "Provide exactly one snooze duration.",
        );
      }
      const now = new Date();
      const nextFireAt = hasMinutes
        ? snoozeFromNextOccurrence({
          nextFireAt: reminder.next_fire_at,
          minutes: rawArguments.snooze_minutes,
          now,
        })
        : snoozeFromLegacyInstant({
          nextFireAt: reminder.next_fire_at,
          requestedUntil: rawArguments.snooze_until,
          now,
        });
      return {
        arguments: { ...base, next_fire_at: nextFireAt },
        summary: `Snooze “${reminder.title}” until ${
          formatInstant(nextFireAt, reminder.timezone)
        }`,
        warnings: [],
      };
    }
    case "reminders_resume": {
      rejectUnknownKeys(
        rawArguments,
        new Set(["reminder_id", "expected_version"]),
      );
      if (reminder.status !== "paused") {
        throw new ReminderValidationError(
          "Only a paused reminder can be resumed.",
        );
      }
      const nextFireAt = nextFireForExisting(reminder, new Date());
      return {
        arguments: { ...base, next_fire_at: nextFireAt },
        summary: `Resume “${reminder.title}” for ${
          formatInstant(nextFireAt, reminder.timezone)
        }`,
        warnings: [],
      };
    }
    case "reminders_skip_next": {
      rejectUnknownKeys(
        rawArguments,
        new Set(["reminder_id", "expected_version"]),
      );
      if (!reminder.recurrence_rule) {
        throw new ReminderValidationError(
          "Only a recurring reminder can skip an occurrence.",
        );
      }
      const recurrence = normalizeRecurrence(reminder.recurrence_rule)!;
      const next = nextOccurrence({
        startLocal: normalizeStoredLocal(reminder.start_local),
        timezone: reminder.timezone,
        recurrence,
        after: new Date(reminder.next_fire_at),
        includeStart: false,
      });
      if (!next) {
        throw new ReminderValidationError(
          "This recurrence has no later occurrence.",
        );
      }
      return {
        arguments: { ...base, next_fire_at: next.toISOString() },
        summary: `Skip the next “${reminder.title}” occurrence; resume ${
          formatInstant(next.toISOString(), reminder.timezone)
        }`,
        warnings: [],
      };
    }
    case "reminders_complete":
    case "reminders_pause":
    case "reminders_delete": {
      rejectUnknownKeys(
        rawArguments,
        new Set(["reminder_id", "expected_version"]),
      );
      const verb = actionType === "reminders_complete"
        ? "Complete"
        : actionType === "reminders_pause"
        ? "Pause"
        : "Delete";
      return {
        arguments: base,
        summary: `${verb} reminder “${reminder.title}”`,
        warnings: actionType === "reminders_delete"
          ? ["Deleting removes the reminder permanently."]
          : [],
      };
    }
    default:
      throw new ReminderValidationError("Unsupported reminder action.");
  }
}

function localStartInstant(schedule: NormalizedReminderSchedule): Date | null {
  return nextOccurrence({
    startLocal: schedule.start_local,
    timezone: schedule.timezone,
    recurrence: schedule.recurrence,
    after: new Date(0),
    includeStart: true,
  });
}

function nextFireForExisting(reminder: ReminderRow, now: Date): string {
  const existing = new Date(reminder.next_fire_at);
  if (existing.getTime() > now.getTime()) return existing.toISOString();
  const recurrence = normalizeRecurrence(reminder.recurrence_rule);
  const next = nextOccurrence({
    startLocal: normalizeStoredLocal(reminder.start_local),
    timezone: reminder.timezone,
    recurrence,
    after: now,
    includeStart: true,
  });
  if (!next) {
    throw new ReminderValidationError(
      "This reminder has no future occurrence to resume.",
      "schedule_in_past",
    );
  }
  return next.toISOString();
}

async function getReminder(
  userId: string,
  reminderId: string,
): Promise<ReminderRow> {
  const { data, error } = await supabaseAdmin!
    .from("reminders")
    .select(
      "id,title,notes,timezone,start_local,next_fire_at,recurrence_rule,status,version",
    )
    .eq("id", reminderId)
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    throw new ReminderValidationError(
      "Reminder not found.",
      "reminder_not_found",
    );
  }
  return data as ReminderRow;
}

async function assertConversationOwnership(
  userId: string,
  id: string,
): Promise<void> {
  const { data, error } = await supabaseAdmin!
    .from("conversations")
    .select("id")
    .eq("id", id)
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    throw new ReminderValidationError(
      "Conversation not found.",
      "conversation_not_found",
    );
  }
}

async function reminderActionsEnabled(userId: string): Promise<boolean> {
  const { data: flag, error: flagError } = await supabaseAdmin!
    .from("feature_flags")
    .select("enabled,payload")
    .eq("key", "reminders")
    .maybeSingle();
  if (flagError || !flag?.enabled) return false;
  const payload = isRecord(flag.payload) ? flag.payload : {};
  if (payload.mode === "full") return true;
  if (payload.mode !== "internal") return false;

  const { data: entitlement, error } = await supabaseAdmin!
    .from("app_entitlements")
    .select("model_policy_canary")
    .eq("user_id", userId)
    .maybeSingle();
  return !error && entitlement?.model_policy_canary === true;
}

async function authenticateUser(
  req: Request,
): Promise<AuthenticatedUser | null> {
  const authHeader = req.headers.get("authorization") ?? "";
  const accessToken = authHeader.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await supabase.auth.getUser(accessToken);
  if (error || !data.user) return null;
  const user = data.user as typeof data.user & { is_anonymous?: boolean };
  return { id: user.id, isAnonymous: user.is_anonymous === true };
}

async function readJsonBody(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) {
    throw new ReminderValidationError("Request body is too large.");
  }
  const value = JSON.parse(text);
  if (!isRecord(value)) {
    throw new ReminderValidationError("Request body must be a JSON object.");
  }
  return value;
}

async function markActionFailed(
  actionRunId: string,
  userId: string,
  code: string,
): Promise<void> {
  await supabaseAdmin!
    .from("agent_action_runs")
    .update({
      status: "failed",
      error_code: code,
      error_message: "The reminder changed before this action executed.",
      completed_at: new Date().toISOString(),
    })
    .eq("id", actionRunId)
    .eq("user_id", userId)
    .eq("status", "proposed");
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

function successMessage(actionType: ActionType): string {
  switch (actionType) {
    case "reminders_create":
      return "Reminder created.";
    case "reminders_update":
      return "Reminder updated.";
    case "reminders_complete":
      return "Reminder completed.";
    case "reminders_snooze":
      return "Reminder snoozed.";
    case "reminders_pause":
      return "Reminder paused.";
    case "reminders_resume":
      return "Reminder resumed.";
    case "reminders_skip_next":
      return "The next occurrence was skipped.";
    case "reminders_delete":
      return "Reminder deleted.";
  }
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

function requiredUuid(value: unknown, field: string): string {
  if (typeof value !== "string" || !UUID.test(value)) {
    throw new ReminderValidationError(`${field} must be a UUID.`);
  }
  return value.toLowerCase();
}

function optionalUuid(value: unknown, field: string): string | null {
  if (value == null) return null;
  return requiredUuid(value, field);
}

function requiredInteger(value: unknown, field: string): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new ReminderValidationError(`${field} must be a positive integer.`);
  }
  return Number(value);
}

function requiredText(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new ReminderValidationError(`${field} must be a non-empty string.`);
  }
  const normalized = value.trim();
  if (normalized.length > max) {
    throw new ReminderValidationError(`${field} is too long.`);
  }
  return normalized;
}

function rejectUnknownKeys(
  value: Record<string, unknown>,
  allowed: ReadonlySet<string>,
): void {
  const unknown = Object.keys(value).filter((key) => !allowed.has(key));
  if (unknown.length > 0) {
    throw new ReminderValidationError(
      `Unknown action fields: ${unknown.join(", ")}.`,
    );
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

function safeErrorCode(error: unknown): string {
  if (isRecord(error) && typeof error.code === "string") return error.code;
  return error instanceof Error ? error.name : "unknown_error";
}

const ACTION_RUN_COLUMNS =
  "id,user_id,conversation_id,origin,action_type,arguments,human_summary,warnings,status,proposed_at,resource_type,resource_id,result";
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

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
