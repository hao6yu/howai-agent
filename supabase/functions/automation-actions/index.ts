import { createClient } from "npm:@supabase/supabase-js@2";

import {
  describeAutomation,
  normalizeAutomationCreate,
} from "../_shared/automation-contracts.ts";
import { ReminderValidationError } from "../_shared/reminder-recurrence.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const MAX_BODY_BYTES = 64 * 1024;
const MAX_PROPOSALS_PER_DAY = Number(Deno.env.get("AUTOMATION_ACTIONS_MAX_PROPOSALS_PER_DAY") ?? 20);
const ACTION_RUN_COLUMNS =
  "id,user_id,conversation_id,origin,action_type,arguments,human_summary,warnings,status,proposed_at,resource_type,resource_id,result";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type ActionRun = Readonly<{
  id: string;
  user_id: string;
  conversation_id: string | null;
  origin: "text" | "voice" | "notification" | "system";
  action_type: "automations_create";
  arguments: Record<string, unknown>;
  human_summary: string;
  warnings: string[];
  status: string;
  proposed_at: string;
  resource_type: string | null;
  resource_id: string | null;
  result: Record<string, unknown>;
}>;

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders(origin) });
  if (req.method !== "POST") return jsonResponse(405, { error: "Method not allowed." }, origin);

  const user = await authenticateUser(req);
  if (!user) return jsonResponse(401, { error: "Authentication required." }, origin);
  if (user.isAnonymous) return jsonResponse(403, { error: "A signed-in account is required." }, origin);
  if (!supabaseAdmin) return jsonResponse(503, { error: "Automation actions are unavailable." }, origin);

  let body: Record<string, unknown>;
  try {
    body = await readJsonBody(req);
  } catch (error) {
    return jsonResponse(400, { error: error instanceof Error ? error.message : "Invalid request." }, origin);
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
    if (body.operation === "propose") return await propose(user.id, body, origin);
    if (body.operation === "decide") return await decide(user.id, body, origin);
    return jsonResponse(400, { error: "Unsupported operation." }, origin);
  } catch (error) {
    if (error instanceof ReminderValidationError) {
      console.warn("Automation validation rejected", error.code);
      return jsonResponse(422, { error: error.message, code: error.code }, origin);
    }
    console.error("Automation action failed", safeErrorCode(error));
    return jsonResponse(503, { error: "Automation actions are temporarily unavailable." }, origin);
  }
});

async function propose(userId: string, body: Record<string, unknown>, origin: string | null): Promise<Response> {
  if (body.action_type !== "automations_create") throw validation("A supported Automation action is required.");
  const actionOrigin = body.origin;
  if (actionOrigin !== "text" && actionOrigin !== "voice" && actionOrigin !== "notification" && actionOrigin !== "system") {
    throw validation("A valid action origin is required.");
  }
  const idempotencyKey = requiredText(body.idempotency_key, "idempotency_key", 200);
  if (idempotencyKey.length < 8) throw validation("idempotency_key is too short.");
  const conversationId = optionalUuid(body.conversation_id, "conversation_id");
  if (conversationId) await assertConversationOwnership(userId, conversationId);
  const replacesProposalId = optionalUuid(body.replaces_proposal_id, "replaces_proposal_id");

  const { data: existing, error: existingError } = await supabaseAdmin!
    .from("agent_action_runs").select(ACTION_RUN_COLUMNS)
    .eq("user_id", userId).eq("idempotency_key", idempotencyKey).maybeSingle();
  if (existingError) throw existingError;
  if (existing) return jsonResponse(200, { proposal: serializeProposal(existing as ActionRun) }, origin);

  if (!replacesProposalId) {
    const since = new Date(Date.now() - 86_400_000).toISOString();
    const { count, error } = await supabaseAdmin!.from("agent_action_runs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId).like("action_type", "automations_%").gte("proposed_at", since);
    if (error) throw error;
    if ((count ?? 0) >= MAX_PROPOSALS_PER_DAY) {
      return jsonResponse(429, { error: "The daily Automation proposal limit has been reached." }, origin);
    }
  }

  const normalized = normalizeAutomationCreate(body.arguments);
  const argumentsValue = normalized as unknown as Record<string, unknown>;
  const proposal = {
    user_id: userId,
    conversation_id: conversationId,
    origin: actionOrigin,
    action_type: "automations_create",
    arguments: argumentsValue,
    human_summary: boundedText(describeAutomation(normalized), 500),
    warnings: [
      "Generated briefings require Pro and will run only after this approval.",
      "HowAI will withhold a run when its claims or sources cannot be verified.",
    ],
    idempotency_key: idempotencyKey,
  };

  if (replacesProposalId) {
    const { data, error } = await supabaseAdmin!.from("agent_action_runs")
      .update(proposal).eq("id", replacesProposalId).eq("user_id", userId)
      .eq("status", "proposed").eq("action_type", "automations_create")
      .select(ACTION_RUN_COLUMNS).maybeSingle();
    if (error) throw error;
    if (!data) throw validation("That Automation draft is no longer awaiting approval.", "proposal_not_pending");
    return jsonResponse(200, { proposal: serializeProposal(data as ActionRun) }, origin);
  }

  const { data, error } = await supabaseAdmin!.from("agent_action_runs")
    .insert(proposal).select(ACTION_RUN_COLUMNS).single();
  if (error?.code === "23505") {
    const { data: raced, error: racedError } = await supabaseAdmin!.from("agent_action_runs")
      .select(ACTION_RUN_COLUMNS).eq("user_id", userId).eq("idempotency_key", idempotencyKey).single();
    if (racedError || !raced) throw racedError ?? error;
    return jsonResponse(200, { proposal: serializeProposal(raced as ActionRun) }, origin);
  }
  if (error || !data) throw error ?? new Error("proposal_insert_failed");
  return jsonResponse(201, { proposal: serializeProposal(data as ActionRun) }, origin);
}

async function decide(userId: string, body: Record<string, unknown>, origin: string | null): Promise<Response> {
  const proposalId = requiredUuid(body.proposal_id, "proposal_id");
  const decision = body.decision;
  if (decision !== "approved" && decision !== "rejected") throw validation("decision must be approved or rejected.");
  const channel = body.channel;
  if (channel !== "text" && channel !== "voice" && channel !== "notification") {
    throw validation("A valid decision channel is required.");
  }
  const { data, error } = await supabaseAdmin!.from("agent_action_runs")
    .select(ACTION_RUN_COLUMNS).eq("id", proposalId).eq("user_id", userId).maybeSingle();
  if (error) throw error;
  if (!data) return jsonResponse(404, { error: "Action proposal not found." }, origin);
  const run = data as ActionRun;

  if (decision === "rejected") {
    if (run.status === "rejected") return jsonResponse(200, { decision: "rejected", audit_id: run.id }, origin);
    if (run.status !== "proposed") return jsonResponse(409, { error: "This action has already been decided." }, origin);
    const { data: rejected, error: rejectError } = await supabaseAdmin!.from("agent_action_runs")
      .update({ status: "rejected", completed_at: new Date().toISOString() })
      .eq("id", run.id).eq("user_id", userId).eq("status", "proposed").select("id").maybeSingle();
    if (rejectError) throw rejectError;
    if (!rejected) return jsonResponse(409, { error: "This action has already been decided." }, origin);
    return jsonResponse(200, { decision: "rejected", audit_id: run.id }, origin);
  }

  const { data: resultData, error: executeError } = await supabaseAdmin!.rpc("execute_automation_action", {
    p_action_run_id: run.id,
    p_user_id: userId,
    p_execution: run.arguments,
  });
  if (executeError) {
    if (executeError.code === "54000") return jsonResponse(409, { error: "You can have up to two active generated Automations." }, origin);
    if (executeError.code === "42501") return jsonResponse(403, { error: "A current Pro subscription is required." }, origin);
    if (executeError.code === "55000") return jsonResponse(409, { error: "This Automation proposal is no longer current." }, origin);
    throw executeError;
  }
  const result = Array.isArray(resultData) ? resultData[0] : resultData;
  return jsonResponse(200, {
    result: {
      status: "succeeded",
      display_message: "Automation created.",
      retryable: false,
      audit_id: run.id,
      resource_type: result?.resource_type ?? "automation",
      resource_id: result?.resource_id ?? null,
    },
  }, origin);
}

async function automationCapability(userId: string): Promise<Record<string, boolean>> {
  const [{ data: flag }, { data: entitlement }] = await Promise.all([
    supabaseAdmin!.from("feature_flags").select("enabled,payload").eq("key", "automations").maybeSingle(),
    supabaseAdmin!.from("app_entitlements").select("tier,expires_at,model_policy_canary").eq("user_id", userId).maybeSingle(),
  ]);
  const paid = entitlement?.tier === "paid" && (!entitlement.expires_at || new Date(entitlement.expires_at).getTime() > Date.now());
  const payload = isRecord(flag?.payload) ? flag.payload : {};
  const rollout = flag?.enabled === true && (
    payload.mode === "full" || (payload.mode === "internal" && entitlement?.model_policy_canary === true)
  );
  return { automations: paid && rollout, requires_paid: rollout && !paid, rollout_enabled: rollout };
}

async function authenticateUser(req: Request): Promise<{ id: string; isAnonymous: boolean } | null> {
  const token = (req.headers.get("authorization") ?? "").match(/^Bearer\s+(.+)$/i)?.[1];
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

async function assertConversationOwnership(userId: string, id: string): Promise<void> {
  const { data, error } = await supabaseAdmin!.from("conversations").select("id").eq("id", id).eq("user_id", userId).maybeSingle();
  if (error) throw error;
  if (!data) throw validation("Conversation not found.", "conversation_not_found");
}

async function readJsonBody(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) throw validation("Request body is too large.");
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
  if (typeof value !== "string" || !UUID.test(value)) throw validation(`${field} must be a UUID.`);
  return value.toLowerCase();
}
function optionalUuid(value: unknown, field: string): string | null {
  return value == null ? null : requiredUuid(value, field);
}
function requiredText(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || !value.trim() || value.trim().length > max) throw validation(`${field} is invalid.`);
  return value.trim();
}
function boundedText(value: string, max: number): string {
  return value.length <= max ? value : `${value.substring(0, max - 1).trimEnd()}…`;
}
function validation(message: string, code = "invalid_automation"): ReminderValidationError {
  return new ReminderValidationError(message, code);
}
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
function safeErrorCode(error: unknown): string {
  return isRecord(error) && typeof error.code === "string" ? error.code : error instanceof Error ? error.name : "unknown_error";
}
function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
}
function jsonResponse(status: number, body: Record<string, unknown>, origin: string | null): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(origin), "Cache-Control": "no-store", "Content-Type": "application/json" },
  });
}
