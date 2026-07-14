import { createClient } from "npm:@supabase/supabase-js@2";
import {
  DEFAULT_MODEL_POLICY,
  estimateModelCostMicrousd,
  resolveModelPolicy,
  type ModelPolicyConfig,
  type ModelPolicyDecision,
  type RequestIntent,
  type UserCohort,
} from "../_shared/openai-policy.ts";
import {
  extractResponsesUsage,
  ResponsesSseUsageCollector,
  type ResponsesUsage,
} from "../_shared/openai-stream.ts";

const OPENAI_BASE_URL = "https://api.openai.com";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const MAX_BODY_BYTES = Number(Deno.env.get("OPENAI_PROXY_MAX_BODY_BYTES") ?? 25 * 1024 * 1024);
const MAX_OUTPUT_TOKENS = Number(Deno.env.get("OPENAI_PROXY_MAX_OUTPUT_TOKENS") ?? 3000);
const MAX_REQUESTS_PER_HOUR = Number(Deno.env.get("OPENAI_PROXY_MAX_REQUESTS_PER_HOUR") ?? 120);
const ANON_MAX_REQUESTS_PER_DAY = Number(Deno.env.get("OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY") ?? 300);
const CHAT_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MODEL") ?? "gpt-5.2";
const CHAT_MINI_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MINI_MODEL") ?? "gpt-5-nano";
const MODEL_POLICY_ENV_ENABLED = Deno.env.get("OPENAI_PROXY_POLICY_ENABLED") === "true";
const MODEL_POLICY: ModelPolicyConfig = Object.freeze({
  ...DEFAULT_MODEL_POLICY,
  models: Object.freeze({
    nano: Deno.env.get("OPENAI_PROXY_MODEL_NANO") ?? DEFAULT_MODEL_POLICY.models.nano,
    luna: Deno.env.get("OPENAI_PROXY_MODEL_LUNA") ?? DEFAULT_MODEL_POLICY.models.luna,
    sol: Deno.env.get("OPENAI_PROXY_MODEL_SOL") ?? DEFAULT_MODEL_POLICY.models.sol,
  }),
  freeLunaAnswersPerDay: envNumber(
    "OPENAI_PROXY_FREE_LUNA_ANSWERS_PER_DAY",
    DEFAULT_MODEL_POLICY.freeLunaAnswersPerDay,
  ),
  freeLunaDailyBudgetMicrousd: envNumber(
    "OPENAI_PROXY_FREE_LUNA_DAILY_BUDGET_MICROUSD",
    DEFAULT_MODEL_POLICY.freeLunaDailyBudgetMicrousd,
  ),
  freeLunaMonthlyBudgetMicrousd: envNumber(
    "OPENAI_PROXY_FREE_LUNA_MONTHLY_BUDGET_MICROUSD",
    DEFAULT_MODEL_POLICY.freeLunaMonthlyBudgetMicrousd,
  ),
});
const ANONYMOUS_ANSWER_LIMIT = envNumber("OPENAI_PROXY_ANON_ANSWER_LIMIT", 5);
const ANONYMOUS_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_ANON_DAILY_BUDGET_MICROUSD",
  5_000,
);
const ANONYMOUS_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_ANON_MONTHLY_BUDGET_MICROUSD",
  50_000,
);
const FREE_MAX_ESTIMATED_INPUT_TOKENS = envNumber(
  "OPENAI_PROXY_FREE_MAX_ESTIMATED_INPUT_TOKENS",
  20_000,
);
const ANONYMOUS_MAX_ESTIMATED_INPUT_TOKENS = envNumber(
  "OPENAI_PROXY_ANON_MAX_ESTIMATED_INPUT_TOKENS",
  8_000,
);
const POLICY_WEB_SEARCH_ENABLED = Deno.env.get("OPENAI_PROXY_POLICY_WEB_SEARCH_ENABLED") === "true";
const POLICY_IMAGE_GENERATION_ENABLED =
  Deno.env.get("OPENAI_PROXY_POLICY_IMAGE_GENERATION_ENABLED") === "true";
const ALLOWED_MODELS = (`${CHAT_MODEL},${CHAT_MINI_MODEL},${MODEL_POLICY.models.nano},${MODEL_POLICY.models.luna},${MODEL_POLICY.models.sol},${Deno.env.get("OPENAI_PROXY_ALLOWED_MODELS") ?? ""}`)
  .split(",")
  .map((model) => model.trim())
  .filter(Boolean);
const ALLOWED_TOOL_TYPES = new Set(["web_search", "web_search_preview", "image_generation", "function"]);
const ALLOWED_FUNCTION_NAMES = new Set(["generate_pptx"]);

type ProxyPath = "/v1/responses" | "/v1/audio/transcriptions";

type AuthenticatedUser = {
  id: string;
  isAnonymous: boolean;
};

type PolicyContext = {
  requestId: string;
  ledgerId: string;
  cohort: UserCohort;
  intent: RequestIntent;
  modelRole: string;
  reasoningEffort: string;
  reservationMicrousd: number;
};

type SanitizedResponse = {
  bytes: Uint8Array;
  requestedAlias: string | null;
  model: string | null;
  stream: boolean;
  policy: PolicyContext | null;
};

const MODEL_ALIASES = new Map<string, string>([
  ["howai-chat", CHAT_MODEL],
  ["howai-chat-mini", CHAT_MINI_MODEL],
]);

type RequestLog = {
  user_id: string;
  is_anonymous: boolean;
  endpoint: string;
  model: string | null;
  status_code: number;
  request_bytes: number;
  response_id?: string | null;
  input_tokens?: number | null;
  output_tokens?: number | null;
  total_tokens?: number | null;
  cached_input_tokens?: number | null;
  intent?: string | null;
  model_role?: string | null;
  reasoning_effort?: string | null;
  latency_ms?: number | null;
  time_to_first_token_ms?: number | null;
  estimated_cost_microusd?: number | null;
  actual_cost_microusd?: number | null;
  usage_ledger_id?: string | null;
  error?: string | null;
};

class ProxyPolicyError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
  }
}

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

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

function jsonResponse(status: number, body: Record<string, unknown>, origin: string | null): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(origin),
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}

function targetPath(pathname: string): ProxyPath | null {
  if (pathname.endsWith("/v1/responses")) return "/v1/responses";
  if (pathname.endsWith("/v1/audio/transcriptions")) return "/v1/audio/transcriptions";
  return null;
}

function getBearerToken(req: Request): string | null {
  const authHeader = req.headers.get("authorization") ?? "";
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  return match?.[1] ?? null;
}

async function authenticateUser(req: Request): Promise<AuthenticatedUser | null> {
  const accessToken = getBearerToken(req);
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return null;
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: { Authorization: `Bearer ${accessToken}` },
    },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.auth.getUser(accessToken);
  if (error || !data.user) {
    return null;
  }

  const userWithAnonymousClaim = data.user as typeof data.user & {
    is_anonymous?: boolean;
  };

  return {
    id: data.user.id,
    isAnonymous: userWithAnonymousClaim.is_anonymous === true,
  };
}

async function isWithinRateLimit(user: AuthenticatedUser): Promise<boolean> {
  if (!supabaseAdmin) {
    return false;
  }

  const hourlySince = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count: hourlyCount, error: hourlyError } = await supabaseAdmin
    .from("openai_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .gte("created_at", hourlySince);

  if (hourlyError) {
    console.error("Hourly rate limit lookup failed", hourlyError);
    return false;
  }

  if ((hourlyCount ?? 0) >= MAX_REQUESTS_PER_HOUR) {
    return false;
  }

  if (!user.isAnonymous) {
    return true;
  }

  const dailySince = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count: dailyCount, error: dailyError } = await supabaseAdmin
    .from("openai_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .eq("is_anonymous", true)
    .gte("created_at", dailySince);

  if (dailyError) {
    console.error("Anonymous daily limit lookup failed", dailyError);
    return false;
  }

  return (dailyCount ?? 0) < ANON_MAX_REQUESTS_PER_DAY;
}

async function logRequest(log: RequestLog): Promise<string | null> {
  if (!supabaseAdmin) {
    console.error("Supabase service role client is not configured; skipping proxy request log.");
    return null;
  }

  const { data, error } = await supabaseAdmin
    .from("openai_proxy_requests")
    .insert(log)
    .select("id")
    .maybeSingle();
  if (error) {
    console.error("Failed to write OpenAI proxy request log", error);
    return null;
  }
  return typeof data?.id === "string" ? data.id : null;
}

async function updateRequestLog(
  id: string | null,
  changes: Partial<RequestLog>,
): Promise<void> {
  if (!id || !supabaseAdmin) return;
  const { error } = await supabaseAdmin
    .from("openai_proxy_requests")
    .update(changes)
    .eq("id", id);
  if (error) console.error("Failed to update OpenAI proxy request log", error);
}

function sanitizeForwardHeaders(req: Request): Headers {
  const headers = new Headers();
  const contentType = req.headers.get("content-type");
  if (contentType) {
    headers.set("Content-Type", contentType);
  }
  headers.set("Authorization", `Bearer ${OPENAI_API_KEY}`);
  headers.set("Accept", "application/json");
  return headers;
}

function validateContentLength(req: Request, origin: string | null): Response | null {
  const contentLengthRaw = req.headers.get("content-length");
  if (!contentLengthRaw) {
    return null;
  }

  const contentLength = Number(contentLengthRaw);
  if (Number.isFinite(contentLength) && contentLength > MAX_BODY_BYTES) {
    return jsonResponse(413, { error: "Payload too large" }, origin);
  }

  return null;
}

function sanitizeTools(tools: unknown): unknown {
  if (!Array.isArray(tools)) {
    return tools;
  }

  return tools.filter((tool) => {
    if (!tool || typeof tool !== "object") {
      return false;
    }

    const candidate = tool as Record<string, unknown>;
    const toolType = typeof candidate.type === "string" ? candidate.type : "";
    if (!ALLOWED_TOOL_TYPES.has(toolType)) {
      return false;
    }

    if (toolType === "function") {
      const name = typeof candidate.name === "string"
        ? candidate.name
        : typeof (candidate.function as Record<string, unknown> | undefined)?.name === "string"
        ? String((candidate.function as Record<string, unknown>).name)
        : "";
      return ALLOWED_FUNCTION_NAMES.has(name);
    }

    return true;
  });
}

async function sanitizeResponsesBody(
  bodyBytes: ArrayBuffer,
  user: AuthenticatedUser,
  policyEnabled: boolean,
): Promise<SanitizedResponse> {
  const decoder = new TextDecoder();
  const encoder = new TextEncoder();
  const json = JSON.parse(decoder.decode(bodyBytes)) as Record<string, unknown>;

  const requestedModel = typeof json.model === "string" ? json.model : null;
  let resolvedModel = requestedModel ? MODEL_ALIASES.get(requestedModel) ?? requestedModel : null;
  let policyContext: PolicyContext | null = null;

  if (policyEnabled) {
    const entitlement = await getTrustedEntitlement(user);
    const intent = requestIntent(json.metadata);
    const hasAttachments = containsAttachment(json.input);
    const estimatedInputTokens = Math.ceil(bodyBytes.byteLength / 4);
    const maxEstimatedInputTokens = entitlement.cohort === "anonymous"
      ? ANONYMOUS_MAX_ESTIMATED_INPUT_TOKENS
      : entitlement.cohort === "free"
      ? FREE_MAX_ESTIMATED_INPUT_TOKENS
      : Number.MAX_SAFE_INTEGER;

    if (estimatedInputTokens > maxEstimatedInputTokens) {
      throw new ProxyPolicyError("This request is too large for the current plan.", 413);
    }
    if (hasAttachments && entitlement.cohort !== "paid") {
      throw new ProxyPolicyError("Attachments require a paid plan during the HowAI 2.0 beta.", 403);
    }

    const lunaEstimate = estimateModelCostMicrousd(MODEL_POLICY.models.luna, {
      inputTokens: estimatedInputTokens,
      outputTokens: MODEL_POLICY.freeLunaMaxOutputTokens,
    }) ?? MODEL_POLICY.freeLunaDailyBudgetMicrousd;
    let decision = resolveModelPolicy({
      cohort: entitlement.cohort,
      entitlementTrusted: entitlement.trusted,
      intent,
      hasAttachments,
      estimatedLunaCostMicrousd: lunaEstimate,
      freeUsage: {
        lunaAnswersToday: 0,
        lunaCostTodayMicrousd: 0,
        lunaCostThisMonthMicrousd: 0,
      },
    }, MODEL_POLICY);

    let reservation = decision.role === "luna"
      ? await reserveBudgetedUsage(
        user.id,
        entitlement.cohort,
        intent,
        requestedModel,
        decision,
        lunaEstimate,
        MODEL_POLICY.freeLunaDailyBudgetMicrousd,
        MODEL_POLICY.freeLunaMonthlyBudgetMicrousd,
        MODEL_POLICY.freeLunaAnswersPerDay,
      )
      : null;

    if (decision.role === "luna" && !reservation?.accepted) {
      decision = nanoFallbackDecision(reservation?.reason ?? "luna_reservation_failed");
      reservation = null;
    }

    const estimate = estimateModelCostMicrousd(decision.model, {
      inputTokens: estimatedInputTokens,
      outputTokens: decision.maxOutputTokens,
    }) ?? 0;

    if (!reservation && entitlement.cohort === "anonymous") {
      reservation = await reserveBudgetedUsage(
        user.id,
        entitlement.cohort,
        intent,
        requestedModel,
        decision,
        estimate,
        ANONYMOUS_DAILY_BUDGET_MICROUSD,
        ANONYMOUS_MONTHLY_BUDGET_MICROUSD,
        ANONYMOUS_ANSWER_LIMIT,
      );
      if (!reservation.accepted) {
        throw new ProxyPolicyError("The anonymous daily answer limit has been reached.", 429);
      }
    }

    if (!reservation) {
      reservation = await insertUsageReservation(
        user.id,
        entitlement.cohort,
        intent,
        requestedModel,
        decision,
        estimate,
      );
    }

    resolvedModel = decision.model;
    json.reasoning = {
      ...(json.reasoning && typeof json.reasoning === "object" ? json.reasoning : {}),
      effort: decision.reasoningEffort,
    };
    const requestedMaxOutput = typeof json.max_output_tokens === "number"
      ? json.max_output_tokens
      : decision.maxOutputTokens;
    json.max_output_tokens = Math.min(requestedMaxOutput, decision.maxOutputTokens);
    if (entitlement.cohort === "paid") {
      const safeTools = sanitizeTools(json.tools);
      json.tools = Array.isArray(safeTools)
        ? safeTools.filter((tool) => {
          const type = (tool as Record<string, unknown>).type;
          if (type === "web_search" || type === "web_search_preview") {
            return POLICY_WEB_SEARCH_ENABLED;
          }
          if (type === "image_generation") return POLICY_IMAGE_GENERATION_ENABLED;
          return true;
        })
        : safeTools;
      if (Array.isArray(json.tools) && json.tools.length === 0) delete json.tool_choice;
    } else {
      delete json.tools;
      delete json.tool_choice;
    }
    policyContext = {
      requestId: reservation.requestId,
      ledgerId: reservation.ledgerId,
      cohort: entitlement.cohort,
      intent,
      modelRole: decision.role,
      reasoningEffort: decision.reasoningEffort,
      reservationMicrousd: reservation.reservationMicrousd,
    };
  } else {
    const isServerSideAlias = requestedModel ? MODEL_ALIASES.has(requestedModel) : false;
    if (!resolvedModel || (!isServerSideAlias && !ALLOWED_MODELS.includes(resolvedModel))) {
      throw new ProxyPolicyError(`Model is not allowed: ${requestedModel ?? "missing"}`, 400);
    }

    if (typeof json.max_output_tokens === "number") {
      json.max_output_tokens = Math.min(json.max_output_tokens, MAX_OUTPUT_TOKENS);
    } else if (json.max_output_tokens == null) {
      json.max_output_tokens = MAX_OUTPUT_TOKENS;
    }

    if (json.tools != null) json.tools = sanitizeTools(json.tools);
  }
  json.model = resolvedModel;
  json.user = user.id;
  json.metadata = {
    ...(json.metadata && typeof json.metadata === "object" ? json.metadata : {}),
    howai_user_id: user.id,
  };

  return {
    bytes: encoder.encode(JSON.stringify(json)),
    requestedAlias: requestedModel,
    model: resolvedModel,
    stream: json.stream === true,
    policy: policyContext,
  };
}

async function isModelPolicyEnabled(): Promise<boolean> {
  if (!MODEL_POLICY_ENV_ENABLED || !supabaseAdmin) return false;
  const { data, error } = await supabaseAdmin
    .from("feature_flags")
    .select("enabled")
    .eq("key", "model_policy_v2")
    .maybeSingle();
  if (error) {
    console.error("Model policy feature-flag lookup failed", error);
    return false;
  }
  return data?.enabled === true;
}

async function getTrustedEntitlement(user: AuthenticatedUser): Promise<{
  cohort: UserCohort;
  trusted: boolean;
}> {
  if (user.isAnonymous) return { cohort: "anonymous", trusted: false };
  if (!supabaseAdmin) throw new Error("Supabase admin client is unavailable");

  const { data, error } = await supabaseAdmin
    .from("app_entitlements")
    .select("tier, expires_at")
    .eq("user_id", user.id)
    .maybeSingle();
  if (error) throw new Error(`Verified entitlement lookup failed: ${error.message}`);

  const expiry = typeof data?.expires_at === "string" ? Date.parse(data.expires_at) : null;
  const active = data?.tier === "paid" && (expiry == null || expiry > Date.now());
  return active
    ? { cohort: "paid", trusted: true }
    : { cohort: "free", trusted: false };
}

function requestIntent(metadata: unknown): RequestIntent {
  const candidate = metadata && typeof metadata === "object"
    ? (metadata as Record<string, unknown>).howai_intent
    : null;
  return candidate === "lightweight" || candidate === "title" || candidate === "research"
    ? candidate
    : "primary_chat";
}

function containsAttachment(value: unknown): boolean {
  if (Array.isArray(value)) return value.some(containsAttachment);
  if (!value || typeof value !== "object") return false;
  const record = value as Record<string, unknown>;
  if (record.type === "input_image" || record.type === "input_file") return true;
  return Object.values(record).some(containsAttachment);
}

function nanoFallbackDecision(reason: string): ModelPolicyDecision {
  return {
    role: "nano",
    model: MODEL_POLICY.models.nano,
    maxOutputTokens: MODEL_POLICY.freeNanoMaxOutputTokens,
    reasoningEffort: "low",
    fallbackReason: reason,
  };
}

async function reserveBudgetedUsage(
  userId: string,
  cohort: UserCohort,
  intent: RequestIntent,
  requestedAlias: string | null,
  decision: ModelPolicyDecision,
  reservationMicrousd: number,
  dailyBudgetMicrousd: number,
  monthlyBudgetMicrousd: number,
  dailyAnswerLimit: number,
): Promise<{
  accepted: boolean;
  requestId: string;
  ledgerId: string;
  reason: string | null;
  reservationMicrousd: number;
}> {
  if (!supabaseAdmin) throw new Error("Supabase admin client is unavailable");
  const requestId = crypto.randomUUID();
  const { data, error } = await supabaseAdmin.rpc("reserve_ai_usage", {
    p_user_id: userId,
    p_request_id: requestId,
    p_cohort: cohort,
    p_intent: intent,
    p_requested_alias: requestedAlias,
    p_model_role: decision.role,
    p_resolved_model: decision.model,
    p_reasoning_effort: decision.reasoningEffort,
    p_reservation_microusd: reservationMicrousd,
    p_daily_budget_microusd: dailyBudgetMicrousd,
    p_monthly_budget_microusd: monthlyBudgetMicrousd,
    p_daily_answer_limit: dailyAnswerLimit,
  });
  if (error) throw new Error(`Usage reservation failed: ${error.message}`);
  const row = Array.isArray(data) ? data[0] : data;
  return {
    accepted: row?.accepted === true,
    requestId,
    ledgerId: typeof row?.ledger_id === "string" ? row.ledger_id : "",
    reason: typeof row?.reason === "string" ? row.reason : null,
    reservationMicrousd,
  };
}

async function insertUsageReservation(
  userId: string,
  cohort: UserCohort,
  intent: RequestIntent,
  requestedAlias: string | null,
  decision: ModelPolicyDecision,
  reservationMicrousd: number,
): Promise<{
  accepted: true;
  requestId: string;
  ledgerId: string;
  reason: null;
  reservationMicrousd: number;
}> {
  if (!supabaseAdmin) throw new Error("Supabase admin client is unavailable");
  const requestId = crypto.randomUUID();
  const { data, error } = await supabaseAdmin
    .from("ai_usage_ledger")
    .insert({
      request_id: requestId,
      user_id: userId,
      cohort,
      intent,
      requested_alias: requestedAlias,
      model_role: decision.role,
      resolved_model: decision.model,
      reasoning_effort: decision.reasoningEffort,
      reservation_microusd: reservationMicrousd,
    })
    .select("id")
    .single();
  if (error) throw new Error(`Usage ledger insert failed: ${error.message}`);
  return {
    accepted: true,
    requestId,
    ledgerId: String(data.id),
    reason: null,
    reservationMicrousd,
  };
}

async function reconcilePolicyUsage(
  policy: PolicyContext | null,
  succeeded: boolean,
  usage: ResponsesUsage | null,
  actualCostMicrousd: number | null,
  failureCode: string | null = null,
): Promise<void> {
  if (!policy || !supabaseAdmin) return;
  const { error } = await supabaseAdmin.rpc("reconcile_ai_usage", {
    p_request_id: policy.requestId,
    p_succeeded: succeeded,
    p_input_tokens: usage?.inputTokens ?? null,
    p_cached_input_tokens: usage?.cachedInputTokens ?? null,
    p_output_tokens: usage?.outputTokens ?? null,
    p_actual_cost_microusd: actualCostMicrousd,
    p_failure_code: failureCode,
  });
  if (error) console.error("Usage reconciliation failed", error);
}

function monitorStreamingBody(
  body: ReadableStream<Uint8Array>,
  startedAt: number,
  onFinished: (usage: ResponsesUsage | null, firstByteMs: number | null) => Promise<void>,
  onCancelled: () => Promise<void>,
): ReadableStream<Uint8Array> {
  const reader = body.getReader();
  const collector = new ResponsesSseUsageCollector();
  let firstByteMs: number | null = null;
  let settled = false;

  async function finish(usage: ResponsesUsage | null): Promise<void> {
    if (settled) return;
    settled = true;
    await onFinished(usage, firstByteMs);
  }

  async function cancel(): Promise<void> {
    if (settled) return;
    settled = true;
    await onCancelled();
  }

  return new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const { done, value } = await reader.read();
        if (done) {
          await finish(collector.finish());
          controller.close();
          return;
        }
        if (value) {
          firstByteMs ??= Math.round(performance.now() - startedAt);
          collector.push(value);
          controller.enqueue(value);
        }
      } catch (error) {
        await cancel();
        controller.error(error);
      }
    },
    async cancel(reason) {
      await reader.cancel(reason);
      await cancel();
    },
  });
}

function envNumber(name: string, fallback: number): number {
  const parsed = Number(Deno.env.get(name));
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (!OPENAI_API_KEY) {
    return jsonResponse(500, { error: "OPENAI_API_KEY is not configured on proxy" }, origin);
  }
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY || !supabaseAdmin) {
    return jsonResponse(500, { error: "Supabase proxy auth/logging secrets are not configured" }, origin);
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  if (!(await isWithinRateLimit(user))) {
    return jsonResponse(429, { error: "Temporary usage limit reached" }, origin);
  }

  const url = new URL(req.url);
  const path = targetPath(url.pathname);
  if (!path) {
    return jsonResponse(404, { error: "Unsupported endpoint" }, origin);
  }

  const contentLengthError = validateContentLength(req, origin);
  if (contentLengthError) {
    return contentLengthError;
  }

  let requestBytes = 0;
  let sanitized: SanitizedResponse | null = null;
  const requestStartedAt = performance.now();

  try {
    const originalBodyBytes = await req.arrayBuffer();
    requestBytes = originalBodyBytes.byteLength;
    if (originalBodyBytes.byteLength > MAX_BODY_BYTES) {
      return jsonResponse(413, { error: "Payload too large" }, origin);
    }

    let forwardBody: ArrayBuffer | Uint8Array = originalBodyBytes;
    let model: string | null = null;
    let isStreaming = false;

    if (path === "/v1/responses") {
      sanitized = await sanitizeResponsesBody(
        originalBodyBytes,
        user,
        await isModelPolicyEnabled(),
      );
      forwardBody = sanitized.bytes;
      model = sanitized.model;
      isStreaming = sanitized.stream;
    } else {
      model = "whisper-1";
    }

    const upstream = await fetch(`${OPENAI_BASE_URL}${path}`, {
      method: "POST",
      headers: sanitizeForwardHeaders(req),
      body: forwardBody,
    });

    const responseHeaders = new Headers(corsHeaders(origin));
    responseHeaders.set("Cache-Control", "no-store");

    const upstreamContentType = upstream.headers.get("content-type");
    if (upstreamContentType) {
      responseHeaders.set("Content-Type", upstreamContentType);
    }

    if (isStreaming && upstream.ok && upstream.body) {
      const streamLogId = await logRequest({
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model,
        status_code: upstream.status,
        request_bytes: originalBodyBytes.byteLength,
        intent: sanitized?.policy?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.policy?.reasoningEffort ?? null,
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
      });

      const monitoredBody = monitorStreamingBody(
        upstream.body,
        requestStartedAt,
        async (usage, firstByteMs) => {
          const streamSucceeded = usage?.terminalEvent === "response.completed";
          const actualCost = usage && model
            ? estimateModelCostMicrousd(model, {
              inputTokens: usage.inputTokens ?? 0,
              cachedInputTokens: usage.cachedInputTokens ?? 0,
              outputTokens: usage.outputTokens ?? 0,
            })
            : sanitized?.policy?.reservationMicrousd ?? null;
          const telemetryError = !usage
            ? "stream_completed_without_terminal_usage"
            : streamSucceeded
            ? null
            : usage.terminalEvent ?? "stream_terminal_error";
          await Promise.all([
            updateRequestLog(streamLogId, {
              response_id: usage?.responseId ?? null,
              input_tokens: usage?.inputTokens ?? null,
              cached_input_tokens: usage?.cachedInputTokens ?? null,
              output_tokens: usage?.outputTokens ?? null,
              total_tokens: usage?.totalTokens ?? null,
              latency_ms: Math.round(performance.now() - requestStartedAt),
              time_to_first_token_ms: firstByteMs,
              actual_cost_microusd: actualCost,
              error: telemetryError,
            }),
            reconcilePolicyUsage(
              sanitized?.policy ?? null,
              streamSucceeded,
              usage,
              actualCost,
              telemetryError,
            ),
          ]);
        },
        async () => {
          await Promise.all([
            updateRequestLog(streamLogId, {
              latency_ms: Math.round(performance.now() - requestStartedAt),
              error: "stream_cancelled",
            }),
            reconcilePolicyUsage(
              sanitized?.policy ?? null,
              false,
              null,
              0,
              "stream_cancelled",
            ),
          ]);
        },
      );

      return new Response(monitoredBody, {
        status: upstream.status,
        headers: responseHeaders,
      });
    }

    const responseText = await upstream.text();
    let usage: ResponsesUsage | null = null;
    let upstreamError: string | null = null;

    try {
      const responseJson = JSON.parse(responseText) as Record<string, unknown>;
      usage = extractResponsesUsage(responseJson);

      const error = responseJson.error;
      if (error && typeof error === "object" && "message" in error) {
        upstreamError = String((error as Record<string, unknown>).message);
      }
    } catch {
      upstreamError = upstream.ok ? null : responseText.slice(0, 500);
    }

    const actualCost = usage && model
      ? estimateModelCostMicrousd(model, {
        inputTokens: usage.inputTokens ?? 0,
        cachedInputTokens: usage.cachedInputTokens ?? 0,
        outputTokens: usage.outputTokens ?? 0,
      })
      : null;

    await Promise.all([
      logRequest({
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model,
        status_code: upstream.status,
        request_bytes: originalBodyBytes.byteLength,
        response_id: usage?.responseId ?? null,
        input_tokens: usage?.inputTokens ?? null,
        cached_input_tokens: usage?.cachedInputTokens ?? null,
        output_tokens: usage?.outputTokens ?? null,
        total_tokens: usage?.totalTokens ?? null,
        intent: sanitized?.policy?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.policy?.reasoningEffort ?? null,
        latency_ms: Math.round(performance.now() - requestStartedAt),
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        actual_cost_microusd: actualCost,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
        error: upstreamError,
      }),
      reconcilePolicyUsage(
        sanitized?.policy ?? null,
        upstream.ok,
        usage,
        actualCost,
        upstream.ok ? null : "upstream_error",
      ),
    ]);

    return new Response(responseText, {
      status: upstream.status,
      headers: responseHeaders,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const status = error instanceof ProxyPolicyError ? error.status : 502;
    await Promise.all([
      logRequest({
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model: sanitized?.model ?? null,
        status_code: status,
        request_bytes: requestBytes,
        intent: sanitized?.policy?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.policy?.reasoningEffort ?? null,
        latency_ms: Math.round(performance.now() - requestStartedAt),
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
        error: message.slice(0, 500),
      }),
      reconcilePolicyUsage(
        sanitized?.policy ?? null,
        false,
        null,
        0,
        "proxy_error",
      ),
    ]);

    if (error instanceof ProxyPolicyError) {
      return jsonResponse(status, { error: message }, origin);
    }
    return jsonResponse(502, { error: "Proxy upstream request failed" }, origin);
  }
});
