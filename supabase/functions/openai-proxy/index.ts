import { createClient } from "npm:@supabase/supabase-js@2";
import {
  applyModelPolicyControls,
  DEFAULT_MODEL_POLICY,
  estimateModelCostMicrousd,
  legacyModelAllowlist,
  type ModelPolicyConfig,
  type ModelPolicyDecision,
  type ModelRole,
  type RequestIntent,
  resolveModelPolicy,
  type UserCohort,
} from "../_shared/openai-policy.ts";
import {
  DEFAULT_MODEL_POLICY_ROLLOUT,
  type ModelPolicyRolloutDecision,
  parseModelPolicyRollout,
  resolveModelPolicyRollout,
} from "../_shared/openai-rollout.ts";
import {
  extractResponsesUsage,
  ResponsesSseUsageCollector,
  type ResponsesUsage,
} from "../_shared/openai-stream.ts";
import {
  applyResponseProfile,
  applyWebSearchOutputGuidance,
  type ResponseProfile,
  type WebSearchMode,
} from "../_shared/openai-response-profile.ts";
import {
  extractUpstreamErrorTelemetry,
  nonJsonUpstreamErrorTelemetry,
} from "../_shared/openai-telemetry.ts";
import {
  type AutomationToolAuthorization,
  NO_AUTOMATION_TOOL_AUTHORIZATION,
  requestsAutomationFunction,
  sanitizeResponseTools,
} from "../_shared/openai-tool-policy.ts";
import {
  DEFAULT_FREE_WEB_SEARCH_RESERVATION_MICROUSD,
  type FreeWebSearchRollout,
  resolveFreeWebSearchRollout,
  shouldOfferFreeWebSearch,
  shouldReserveFreeWebSearch,
  webSearchAccountedCostMicrousd,
  webSearchToolCostMicrousd,
} from "../_shared/openai-web-search.ts";

const OPENAI_BASE_URL = "https://api.openai.com";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";

const MAX_BODY_BYTES = Number(
  Deno.env.get("OPENAI_PROXY_MAX_BODY_BYTES") ?? 25 * 1024 * 1024,
);
const MAX_OUTPUT_TOKENS = Number(
  Deno.env.get("OPENAI_PROXY_MAX_OUTPUT_TOKENS") ?? 3000,
);
const MAX_REQUESTS_PER_HOUR = Number(
  Deno.env.get("OPENAI_PROXY_MAX_REQUESTS_PER_HOUR") ?? 120,
);
const ANON_MAX_REQUESTS_PER_DAY = Number(
  Deno.env.get("OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY") ?? 300,
);
const CHAT_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MODEL") ?? "gpt-5.2";
const CHAT_MINI_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MINI_MODEL") ??
  "gpt-5-nano";
const MODEL_POLICY_ENV_ENABLED =
  Deno.env.get("OPENAI_PROXY_POLICY_ENABLED") === "true";
const GPT56_EVAL_VERSION = Deno.env.get("OPENAI_PROXY_EVAL_VERSION") ??
  "gpt56-m1-v1";
const MODEL_POLICY: ModelPolicyConfig = Object.freeze({
  ...DEFAULT_MODEL_POLICY,
  models: Object.freeze({
    nano: Deno.env.get("OPENAI_PROXY_MODEL_NANO") ??
      DEFAULT_MODEL_POLICY.models.nano,
    luna: Deno.env.get("OPENAI_PROXY_MODEL_LUNA") ??
      DEFAULT_MODEL_POLICY.models.luna,
    sol: Deno.env.get("OPENAI_PROXY_MODEL_SOL") ??
      DEFAULT_MODEL_POLICY.models.sol,
    research: Deno.env.get("OPENAI_PROXY_RESEARCH_MODEL") ?? CHAT_MODEL,
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
const FREE_NANO_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_NANO_DAILY_BUDGET_MICROUSD",
  20_000,
);
const FREE_NANO_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_NANO_MONTHLY_BUDGET_MICROUSD",
  500_000,
);
const FREE_USER_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_USER_DAILY_BUDGET_MICROUSD",
  50_000,
);
const FREE_USER_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_USER_MONTHLY_BUDGET_MICROUSD",
  1_000_000,
);
const PAID_SOL_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_PAID_SOL_DAILY_BUDGET_MICROUSD",
  2_000_000,
);
const PAID_SOL_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_PAID_SOL_MONTHLY_BUDGET_MICROUSD",
  30_000_000,
);
const PAID_USER_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_PAID_USER_DAILY_BUDGET_MICROUSD",
  3_000_000,
);
const PAID_USER_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_PAID_USER_MONTHLY_BUDGET_MICROUSD",
  40_000_000,
);
const RESEARCH_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_RESEARCH_DAILY_BUDGET_MICROUSD",
  1_000_000,
);
const RESEARCH_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_RESEARCH_MONTHLY_BUDGET_MICROUSD",
  10_000_000,
);
const RESEARCH_FALLBACK_RESERVATION_MICROUSD = envNumber(
  "OPENAI_PROXY_RESEARCH_RESERVATION_MICROUSD",
  250_000,
);
const GLOBAL_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_GLOBAL_DAILY_BUDGET_MICROUSD",
  10_000_000,
);
const GLOBAL_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_GLOBAL_MONTHLY_BUDGET_MICROUSD",
  150_000_000,
);
const FREE_MAX_ESTIMATED_INPUT_TOKENS = envNumber(
  "OPENAI_PROXY_FREE_MAX_ESTIMATED_INPUT_TOKENS",
  20_000,
);
const ANONYMOUS_MAX_ESTIMATED_INPUT_TOKENS = envNumber(
  "OPENAI_PROXY_ANON_MAX_ESTIMATED_INPUT_TOKENS",
  8_000,
);
const POLICY_WEB_SEARCH_ENABLED =
  Deno.env.get("OPENAI_PROXY_POLICY_WEB_SEARCH_ENABLED") === "true";
const FREE_WEB_SEARCH_ENV_ENABLED =
  Deno.env.get("OPENAI_PROXY_FREE_WEB_SEARCH_ENABLED") === "true";
const FREE_WEB_SEARCH_ANSWERS_PER_DAY = envNumber(
  "OPENAI_PROXY_FREE_WEB_SEARCH_ANSWERS_PER_DAY",
  2,
);
const FREE_WEB_SEARCH_ANSWERS_PER_MONTH = envNumber(
  "OPENAI_PROXY_FREE_WEB_SEARCH_ANSWERS_PER_MONTH",
  20,
);
const FREE_WEB_SEARCH_RESERVATION_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_WEB_SEARCH_RESERVATION_MICROUSD",
  DEFAULT_FREE_WEB_SEARCH_RESERVATION_MICROUSD,
);
const FREE_WEB_SEARCH_GLOBAL_DAILY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_WEB_SEARCH_GLOBAL_DAILY_BUDGET_MICROUSD",
  1_000_000,
);
const FREE_WEB_SEARCH_GLOBAL_MONTHLY_BUDGET_MICROUSD = envNumber(
  "OPENAI_PROXY_FREE_WEB_SEARCH_GLOBAL_MONTHLY_BUDGET_MICROUSD",
  10_000_000,
);
const POLICY_IMAGE_GENERATION_ENABLED =
  Deno.env.get("OPENAI_PROXY_POLICY_IMAGE_GENERATION_ENABLED") === "true";
const ALLOWED_MODELS = legacyModelAllowlist(
  CHAT_MODEL,
  CHAT_MINI_MODEL,
  Deno.env.get("OPENAI_PROXY_ALLOWED_MODELS") ?? "",
);
type ProxyPath = "/v1/responses" | "/v1/audio/transcriptions";

type AuthenticatedUser = {
  id: string;
  isAnonymous: boolean;
};

type TrustedEntitlement = {
  cohort: UserCohort;
  trusted: boolean;
  internalCanary: boolean;
};

type ModelPolicyRolloutContext = ModelPolicyRolloutDecision & {
  entitlement: TrustedEntitlement | null;
  freeWebSearch: FreeWebSearchRollout;
};

type FreeWebSearchReservation = Readonly<{
  reserved: boolean;
  reservationMicrousd: number;
  quotaDenied: boolean;
  reason: string | null;
  resetAt: string | null;
}>;

type PolicyContext = {
  requestId: string;
  ledgerId: string;
  cohort: UserCohort;
  intent: RequestIntent;
  modelRole: ModelRole;
  reasoningEffort: string;
  reservationMicrousd: number;
  freeWebSearch: FreeWebSearchReservation;
};

type ReservationLimits = Readonly<{
  routeDailyBudgetMicrousd: number;
  routeMonthlyBudgetMicrousd: number;
  userDailyBudgetMicrousd: number;
  userMonthlyBudgetMicrousd: number;
  globalDailyBudgetMicrousd: number;
  globalMonthlyBudgetMicrousd: number;
  dailyAnswerLimit: number | null;
}>;

type SanitizedResponse = {
  bytes: Uint8Array;
  requestedAlias: string | null;
  model: string | null;
  stream: boolean;
  intent: RequestIntent;
  responseProfile: ResponseProfile;
  webSearchMode: WebSearchMode;
  reasoningEffort: string;
  webSearchOffered: boolean;
  webSearchQuotaDenied: boolean;
  policy: PolicyContext | null;
  rollout: ModelPolicyRolloutDecision;
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
  actual_model?: string | null;
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
  requested_alias?: string | null;
  rollout_cohort?: string | null;
  rollout_bucket?: number | null;
  rollout_percent?: number | null;
  eval_version?: string | null;
  error_category?: string | null;
  error_code?: string | null;
  error_param?: string | null;
  web_search_offered?: boolean;
  web_search_calls?: number | null;
  web_search_quota_denied?: boolean;
  web_search_citations_present?: boolean | null;
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

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
  origin: string | null,
): Response {
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
  if (pathname.endsWith("/v1/audio/transcriptions")) {
    return "/v1/audio/transcriptions";
  }
  return null;
}

function getBearerToken(req: Request): string | null {
  const authHeader = req.headers.get("authorization") ?? "";
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  return match?.[1] ?? null;
}

async function authenticateUser(
  req: Request,
): Promise<AuthenticatedUser | null> {
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
    console.error(
      "Supabase service role client is not configured; skipping proxy request log.",
    );
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

function validateContentLength(
  req: Request,
  origin: string | null,
): Response | null {
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

function removeWebSearchTools(payload: Record<string, unknown>): void {
  if (Array.isArray(payload.tools)) {
    payload.tools = payload.tools.filter((tool) => {
      if (!tool || typeof tool !== "object") return false;
      const type = (tool as Record<string, unknown>).type;
      return type !== "web_search" && type !== "web_search_preview";
    });
  }
  if (Array.isArray(payload.tools) && payload.tools.length === 0) {
    delete payload.tools;
  }
  delete payload.tool_choice;
  delete payload.max_tool_calls;
}

function emptyFreeWebSearchReservation(
  overrides: Partial<FreeWebSearchReservation> = {},
): FreeWebSearchReservation {
  return {
    reserved: false,
    reservationMicrousd: 0,
    quotaDenied: false,
    reason: null,
    resetAt: null,
    ...overrides,
  };
}

async function sanitizeResponsesBody(
  bodyBytes: ArrayBuffer,
  user: AuthenticatedUser,
  rollout: ModelPolicyRolloutContext,
): Promise<SanitizedResponse> {
  const decoder = new TextDecoder();
  const encoder = new TextEncoder();
  const json = JSON.parse(decoder.decode(bodyBytes)) as Record<string, unknown>;

  const requestedModel = typeof json.model === "string" ? json.model : null;
  let resolvedModel = requestedModel
    ? MODEL_ALIASES.get(requestedModel) ?? requestedModel
    : null;
  let policyContext: PolicyContext | null = null;
  const intent = requestIntent(json.metadata);
  const requiredFunctionName = requestedActionFunction(json.metadata);
  const automationAuthorization = await getAutomationToolAuthorization(
    user,
    rollout.entitlement,
    json.tools,
  );

  if (rollout.active) {
    const entitlement = rollout.entitlement;
    if (!entitlement) {
      throw new ProxyPolicyError(
        "Model policy entitlement is temporarily unavailable.",
        503,
      );
    }
    const hasAttachments = containsAttachment(json.input);
    const estimatedInputTokens = Math.ceil(bodyBytes.byteLength / 4);
    const maxEstimatedInputTokens = entitlement.cohort === "anonymous"
      ? ANONYMOUS_MAX_ESTIMATED_INPUT_TOKENS
      : entitlement.cohort === "free"
      ? FREE_MAX_ESTIMATED_INPUT_TOKENS
      : Number.MAX_SAFE_INTEGER;

    if (estimatedInputTokens > maxEstimatedInputTokens) {
      throw new ProxyPolicyError(
        "This request is too large for the current plan.",
        413,
      );
    }
    if (hasAttachments && entitlement.cohort !== "paid") {
      throw new ProxyPolicyError(
        "Attachments require a paid plan during the HowAI 2.0 beta.",
        403,
      );
    }

    const lunaEstimate = estimateModelCostMicrousd(MODEL_POLICY.models.luna, {
      inputTokens: estimatedInputTokens,
      // GPT-5.6 does not currently expose cache-write tokens in Responses usage.
      // Reserve the worst case, then reconcile from the returned usage below.
      cacheWriteInputTokens: estimatedInputTokens,
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

    let estimate = reservationEstimateMicrousd(decision, estimatedInputTokens);
    let reservation = await reserveBudgetedUsage(
      user.id,
      entitlement.cohort,
      intent,
      requestedModel,
      decision,
      estimate,
      reservationLimits(entitlement.cohort, decision),
    );

    if (decision.role === "luna" && !reservation.accepted) {
      decision = nanoFallbackDecision(
        reservation.reason ?? "luna_reservation_failed",
      );
      estimate = reservationEstimateMicrousd(decision, estimatedInputTokens);
      reservation = await reserveBudgetedUsage(
        user.id,
        entitlement.cohort,
        intent,
        requestedModel,
        decision,
        estimate,
        reservationLimits(entitlement.cohort, decision),
      );
    }

    if (!reservation.accepted) {
      const message = entitlement.cohort === "anonymous"
        ? "The anonymous daily answer or cost limit has been reached."
        : "The AI usage limit for the current plan has been reached.";
      throw new ProxyPolicyError(message, 429);
    }

    resolvedModel = decision.model;
    applyModelPolicyControls(json, decision);
    if (entitlement.cohort === "paid") {
      const safeTools = sanitizeResponseTools(
        json.tools,
        automationAuthorization,
      );
      json.tools = Array.isArray(safeTools)
        ? safeTools.filter((tool) => {
          const type = (tool as Record<string, unknown>).type;
          if (type === "web_search" || type === "web_search_preview") {
            return POLICY_WEB_SEARCH_ENABLED;
          }
          if (type === "image_generation") {
            return POLICY_IMAGE_GENERATION_ENABLED;
          }
          return true;
        })
        : safeTools;
      if (Array.isArray(json.tools) && json.tools.length === 0) {
        delete json.tool_choice;
      }
    } else {
      const safeTools = sanitizeResponseTools(
        json.tools,
        automationAuthorization,
      );
      const safeFunctionTools = Array.isArray(safeTools)
        ? safeTools.filter((tool) =>
          (tool as Record<string, unknown>).type === "function"
        )
        : [];
      if (safeFunctionTools.length > 0) {
        json.tools = safeFunctionTools;
      } else {
        delete json.tools;
      }
      delete json.tool_choice;
      delete json.max_tool_calls;
      if (
        shouldOfferFreeWebSearch({
          rolloutActive: rollout.freeWebSearch.active,
          cohort: entitlement.cohort,
          modelRole: decision.role,
          intent,
        })
      ) {
        json.tools = [
          ...(Array.isArray(json.tools) ? json.tools : []),
          { type: "web_search" },
        ];
      }
    }
    policyContext = {
      requestId: reservation.requestId,
      ledgerId: reservation.ledgerId,
      cohort: entitlement.cohort,
      intent,
      modelRole: decision.role,
      reasoningEffort: decision.reasoningEffort,
      reservationMicrousd: reservation.reservationMicrousd,
      freeWebSearch: emptyFreeWebSearchReservation(),
    };
  } else {
    const isServerSideAlias = requestedModel
      ? MODEL_ALIASES.has(requestedModel)
      : false;
    if (
      !resolvedModel ||
      (!isServerSideAlias && !ALLOWED_MODELS.includes(resolvedModel))
    ) {
      throw new ProxyPolicyError(
        `Model is not allowed: ${requestedModel ?? "missing"}`,
        400,
      );
    }

    if (typeof json.max_output_tokens === "number") {
      json.max_output_tokens = Math.min(
        json.max_output_tokens,
        MAX_OUTPUT_TOKENS,
      );
    } else if (json.max_output_tokens == null) {
      json.max_output_tokens = MAX_OUTPUT_TOKENS;
    }

    if (json.tools != null) {
      json.tools = sanitizeResponseTools(json.tools, automationAuthorization);
    }
  }

  if (!resolvedModel) {
    throw new ProxyPolicyError("A model is required.", 400);
  }
  let appliedProfile = applyResponseProfile(json, resolvedModel, {
    allowReasoningOverride: rollout.active &&
      rollout.entitlement?.cohort === "paid" &&
      rollout.entitlement.trusted &&
      isGpt56Model(resolvedModel),
    requiredFunctionName,
  });
  if (policyContext) {
    if (
      shouldReserveFreeWebSearch({
        cohort: policyContext.cohort,
        modelRole: policyContext.modelRole,
        webSearchMode: appliedProfile.webSearchMode,
      })
    ) {
      json.max_tool_calls = 1;
      const searchReservation = await reserveFreeWebSearch(
        user.id,
        policyContext.requestId,
      );
      if (searchReservation.accepted) {
        policyContext = {
          ...policyContext,
          freeWebSearch: {
            reserved: true,
            reservationMicrousd: FREE_WEB_SEARCH_RESERVATION_MICROUSD,
            quotaDenied: false,
            reason: null,
            resetAt: null,
          },
        };
      } else {
        removeWebSearchTools(json);
        appliedProfile = applyResponseProfile(json, resolvedModel, {
          allowReasoningOverride: false,
          requiredFunctionName,
        });
        policyContext = {
          ...policyContext,
          freeWebSearch: emptyFreeWebSearchReservation({
            quotaDenied: true,
            reason: searchReservation.reason,
            resetAt: searchReservation.resetAt,
          }),
        };
      }
    }
    policyContext = {
      ...policyContext,
      reasoningEffort: appliedProfile.reasoningEffort,
    };
  }
  applyWebSearchOutputGuidance(json, appliedProfile.webSearchMode);
  json.model = resolvedModel;
  delete json.user;
  json.safety_identifier = user.id;
  if (json.metadata && typeof json.metadata === "object") {
    delete (json.metadata as Record<string, unknown>).howai_user_id;
    delete (json.metadata as Record<string, unknown>).howai_action;
  }

  return {
    bytes: encoder.encode(JSON.stringify(json)),
    requestedAlias: requestedModel,
    model: resolvedModel,
    stream: json.stream === true,
    intent,
    responseProfile: appliedProfile.profile,
    webSearchMode: appliedProfile.webSearchMode,
    reasoningEffort: appliedProfile.reasoningEffort,
    webSearchOffered: appliedProfile.webSearchMode !== "disabled",
    webSearchQuotaDenied: policyContext?.freeWebSearch.quotaDenied ?? false,
    policy: policyContext,
    rollout,
  };
}

function legacyRollout(userId: string): ModelPolicyRolloutContext {
  return {
    ...resolveModelPolicyRollout(
      userId,
      false,
      DEFAULT_MODEL_POLICY_ROLLOUT,
    ),
    entitlement: null,
    freeWebSearch: { active: false, mode: "off" },
  };
}

async function getModelPolicyRollout(
  user: AuthenticatedUser,
): Promise<ModelPolicyRolloutContext> {
  if (!MODEL_POLICY_ENV_ENABLED || !supabaseAdmin) {
    return legacyRollout(user.id);
  }
  const { data, error } = await supabaseAdmin
    .from("feature_flags")
    .select("key, enabled, payload")
    .in("key", ["model_policy_v2", "free_web_search"]);
  if (error) {
    console.error("Model policy feature-flag lookup failed", error);
    throw new ProxyPolicyError("Model policy is temporarily unavailable.", 503);
  }
  const modelFlag = data?.find((row) => row.key === "model_policy_v2");
  const freeSearchFlag = data?.find((row) => row.key === "free_web_search");
  if (modelFlag?.enabled !== true) return legacyRollout(user.id);

  const config = parseModelPolicyRollout(modelFlag.payload);
  if (
    config.mode === "off" ||
    (config.mode === "percentage" && config.rolloutPercent === 0)
  ) {
    return {
      ...resolveModelPolicyRollout(user.id, false, config),
      entitlement: null,
      freeWebSearch: { active: false, mode: "off" },
    };
  }

  const entitlement = await getTrustedEntitlement(user);
  const modelRollout = resolveModelPolicyRollout(
    user.id,
    entitlement.internalCanary,
    config,
  );
  return {
    ...modelRollout,
    entitlement,
    freeWebSearch: resolveFreeWebSearchRollout({
      environmentEnabled: FREE_WEB_SEARCH_ENV_ENABLED && modelRollout.active,
      flagEnabled: freeSearchFlag?.enabled === true,
      payload: freeSearchFlag?.payload,
      internalCanary: entitlement.internalCanary,
    }),
  };
}

async function getTrustedEntitlement(
  user: AuthenticatedUser,
): Promise<TrustedEntitlement> {
  if (user.isAnonymous) {
    return { cohort: "anonymous", trusted: false, internalCanary: false };
  }
  if (!supabaseAdmin) throw new Error("Supabase admin client is unavailable");

  const { data, error } = await supabaseAdmin
    .from("app_entitlements")
    .select("tier, expires_at, model_policy_canary")
    .eq("user_id", user.id)
    .maybeSingle();
  if (error) {
    throw new Error(`Verified entitlement lookup failed: ${error.message}`);
  }

  const expiry = typeof data?.expires_at === "string"
    ? Date.parse(data.expires_at)
    : null;
  const active = data?.tier === "paid" &&
    (expiry == null || expiry > Date.now());
  return active
    ? {
      cohort: "paid",
      trusted: true,
      internalCanary: data?.model_policy_canary === true,
    }
    : {
      cohort: "free",
      trusted: false,
      internalCanary: data?.model_policy_canary === true,
    };
}

async function getAutomationToolAuthorization(
  user: AuthenticatedUser,
  existingEntitlement: TrustedEntitlement | null,
  requestedTools: unknown,
): Promise<AutomationToolAuthorization> {
  if (!requestsAutomationFunction(requestedTools) || user.isAnonymous) {
    return NO_AUTOMATION_TOOL_AUTHORIZATION;
  }
  if (!supabaseAdmin) {
    throw new ProxyPolicyError(
      "Automation capabilities are temporarily unavailable.",
      503,
    );
  }

  const entitlement = existingEntitlement ?? await getTrustedEntitlement(user);
  if (entitlement.cohort !== "paid" || !entitlement.trusted) {
    return NO_AUTOMATION_TOOL_AUTHORIZATION;
  }

  const { data, error } = await supabaseAdmin
    .from("feature_flags")
    .select("key, enabled, payload")
    .in("key", ["automations", "automation_market_data"]);
  if (error) {
    console.error("Automation tool feature-flag lookup failed", error);
    throw new ProxyPolicyError(
      "Automation capabilities are temporarily unavailable.",
      503,
    );
  }

  const automations = data?.find((row) => row.key === "automations");
  const market = data?.find((row) => row.key === "automation_market_data");
  const generatedAutomations = automationFlagEnabledForUser(
    automations,
    entitlement.internalCanary,
  );
  return {
    generatedAutomations,
    marketAutomations: generatedAutomations && automationFlagEnabledForUser(
      market,
      entitlement.internalCanary,
    ),
  };
}

function automationFlagEnabledForUser(
  flag: { enabled?: boolean; payload?: unknown } | undefined,
  internalCanary: boolean,
): boolean {
  const payload = flag?.payload && typeof flag.payload === "object"
    ? flag.payload as Record<string, unknown>
    : {};
  return flag?.enabled === true && (
    payload.mode === "full" ||
    (payload.mode === "internal" && internalCanary)
  );
}

function requestIntent(metadata: unknown): RequestIntent {
  const candidate = metadata && typeof metadata === "object"
    ? (metadata as Record<string, unknown>).howai_intent
    : null;
  return candidate === "lightweight" || candidate === "title" ||
      candidate === "research"
    ? candidate
    : "primary_chat";
}

function requestedActionFunction(metadata: unknown): string | null {
  const candidate = metadata && typeof metadata === "object"
    ? (metadata as Record<string, unknown>).howai_action
    : null;
  // Reminder execution still requires a separate approval endpoint. Do not
  // generalize this metadata switch to functions with immediate side effects.
  if (candidate === "reminder_create") return "reminders_create";
  if (candidate === "reminder_update") return "reminders_update";
  if (candidate === "reminder_resume") return "reminders_resume";
  return null;
}

function containsAttachment(value: unknown): boolean {
  if (Array.isArray(value)) return value.some(containsAttachment);
  if (!value || typeof value !== "object") return false;
  const record = value as Record<string, unknown>;
  if (record.type === "input_image" || record.type === "input_file") {
    return true;
  }
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

function reservationEstimateMicrousd(
  decision: ModelPolicyDecision,
  estimatedInputTokens: number,
): number {
  const pricedEstimate = estimateModelCostMicrousd(decision.model, {
    inputTokens: estimatedInputTokens,
    cacheWriteInputTokens: isGpt56Model(decision.model)
      ? estimatedInputTokens
      : 0,
    outputTokens: decision.maxOutputTokens,
  });
  if (pricedEstimate != null) return pricedEstimate;
  return decision.role === "research"
    ? RESEARCH_FALLBACK_RESERVATION_MICROUSD
    : 0;
}

function reservationLimits(
  cohort: UserCohort,
  decision: ModelPolicyDecision,
): ReservationLimits {
  const userDailyBudgetMicrousd = cohort === "anonymous"
    ? ANONYMOUS_DAILY_BUDGET_MICROUSD
    : cohort === "free"
    ? FREE_USER_DAILY_BUDGET_MICROUSD
    : PAID_USER_DAILY_BUDGET_MICROUSD;
  const userMonthlyBudgetMicrousd = cohort === "anonymous"
    ? ANONYMOUS_MONTHLY_BUDGET_MICROUSD
    : cohort === "free"
    ? FREE_USER_MONTHLY_BUDGET_MICROUSD
    : PAID_USER_MONTHLY_BUDGET_MICROUSD;

  if (cohort === "anonymous") {
    return {
      routeDailyBudgetMicrousd: ANONYMOUS_DAILY_BUDGET_MICROUSD,
      routeMonthlyBudgetMicrousd: ANONYMOUS_MONTHLY_BUDGET_MICROUSD,
      userDailyBudgetMicrousd,
      userMonthlyBudgetMicrousd,
      globalDailyBudgetMicrousd: GLOBAL_DAILY_BUDGET_MICROUSD,
      globalMonthlyBudgetMicrousd: GLOBAL_MONTHLY_BUDGET_MICROUSD,
      dailyAnswerLimit: ANONYMOUS_ANSWER_LIMIT,
    };
  }

  if (decision.role === "luna") {
    return {
      routeDailyBudgetMicrousd: MODEL_POLICY.freeLunaDailyBudgetMicrousd,
      routeMonthlyBudgetMicrousd: MODEL_POLICY.freeLunaMonthlyBudgetMicrousd,
      userDailyBudgetMicrousd,
      userMonthlyBudgetMicrousd,
      globalDailyBudgetMicrousd: GLOBAL_DAILY_BUDGET_MICROUSD,
      globalMonthlyBudgetMicrousd: GLOBAL_MONTHLY_BUDGET_MICROUSD,
      dailyAnswerLimit: MODEL_POLICY.freeLunaAnswersPerDay,
    };
  }

  const routeDailyBudgetMicrousd = decision.role === "sol"
    ? PAID_SOL_DAILY_BUDGET_MICROUSD
    : decision.role === "research"
    ? RESEARCH_DAILY_BUDGET_MICROUSD
    : FREE_NANO_DAILY_BUDGET_MICROUSD;
  const routeMonthlyBudgetMicrousd = decision.role === "sol"
    ? PAID_SOL_MONTHLY_BUDGET_MICROUSD
    : decision.role === "research"
    ? RESEARCH_MONTHLY_BUDGET_MICROUSD
    : FREE_NANO_MONTHLY_BUDGET_MICROUSD;

  return {
    routeDailyBudgetMicrousd,
    routeMonthlyBudgetMicrousd,
    userDailyBudgetMicrousd,
    userMonthlyBudgetMicrousd,
    globalDailyBudgetMicrousd: GLOBAL_DAILY_BUDGET_MICROUSD,
    globalMonthlyBudgetMicrousd: GLOBAL_MONTHLY_BUDGET_MICROUSD,
    dailyAnswerLimit: null,
  };
}

async function reserveBudgetedUsage(
  userId: string,
  cohort: UserCohort,
  intent: RequestIntent,
  requestedAlias: string | null,
  decision: ModelPolicyDecision,
  reservationMicrousd: number,
  limits: ReservationLimits,
): Promise<{
  accepted: boolean;
  requestId: string;
  ledgerId: string;
  reason: string | null;
  reservationMicrousd: number;
}> {
  if (!supabaseAdmin) throw new Error("Supabase admin client is unavailable");
  const requestId = crypto.randomUUID();
  const { data, error } = await supabaseAdmin.rpc("reserve_ai_usage_v2", {
    p_user_id: userId,
    p_request_id: requestId,
    p_cohort: cohort,
    p_intent: intent,
    p_requested_alias: requestedAlias,
    p_model_role: decision.role,
    p_resolved_model: decision.model,
    p_reasoning_effort: decision.reasoningEffort,
    p_reservation_microusd: reservationMicrousd,
    p_route_daily_budget_microusd: limits.routeDailyBudgetMicrousd,
    p_route_monthly_budget_microusd: limits.routeMonthlyBudgetMicrousd,
    p_user_daily_budget_microusd: limits.userDailyBudgetMicrousd,
    p_user_monthly_budget_microusd: limits.userMonthlyBudgetMicrousd,
    p_global_daily_budget_microusd: limits.globalDailyBudgetMicrousd,
    p_global_monthly_budget_microusd: limits.globalMonthlyBudgetMicrousd,
    p_daily_answer_limit: limits.dailyAnswerLimit,
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

async function reserveFreeWebSearch(
  userId: string,
  requestId: string,
): Promise<{
  accepted: boolean;
  reason: string | null;
  resetAt: string | null;
}> {
  if (!supabaseAdmin) {
    return {
      accepted: false,
      reason: "reservation_unavailable",
      resetAt: null,
    };
  }

  const { data, error } = await supabaseAdmin.rpc("reserve_free_web_search", {
    p_user_id: userId,
    p_request_id: requestId,
    p_reservation_microusd: FREE_WEB_SEARCH_RESERVATION_MICROUSD,
    p_user_daily_answer_limit: FREE_WEB_SEARCH_ANSWERS_PER_DAY,
    p_user_monthly_answer_limit: FREE_WEB_SEARCH_ANSWERS_PER_MONTH,
    p_global_daily_budget_microusd:
      FREE_WEB_SEARCH_GLOBAL_DAILY_BUDGET_MICROUSD,
    p_global_monthly_budget_microusd:
      FREE_WEB_SEARCH_GLOBAL_MONTHLY_BUDGET_MICROUSD,
  });
  if (error) {
    console.error("Free web-search reservation failed", error);
    return {
      accepted: false,
      reason: "reservation_unavailable",
      resetAt: null,
    };
  }

  const row = Array.isArray(data) ? data[0] : data;
  return {
    accepted: row?.accepted === true,
    reason: typeof row?.reason === "string" ? row.reason : null,
    resetAt: typeof row?.reset_at === "string" ? row.reset_at : null,
  };
}

async function reconcilePolicyUsage(
  policy: PolicyContext | null,
  succeeded: boolean,
  countsAsAnswer: boolean,
  usage: ResponsesUsage | null,
  actualCostMicrousd: number | null,
  failureCode: string | null = null,
): Promise<void> {
  if (!policy || !supabaseAdmin) return;
  const webSearchCalls = Math.max(0, usage?.webSearchCalls ?? 0);
  const operations = [
    supabaseAdmin.rpc("reconcile_ai_usage_v2", {
      p_request_id: policy.requestId,
      p_succeeded: succeeded,
      p_counts_as_answer: countsAsAnswer,
      p_input_tokens: usage?.inputTokens ?? null,
      p_cached_input_tokens: usage?.cachedInputTokens ?? null,
      p_output_tokens: usage?.outputTokens ?? null,
      p_tool_calls: { web_search: webSearchCalls },
      p_actual_cost_microusd: actualCostMicrousd,
      p_failure_code: failureCode,
    }),
  ];

  if (policy.freeWebSearch.reserved) {
    operations.push(supabaseAdmin.rpc("reconcile_free_web_search", {
      p_request_id: policy.requestId,
      p_succeeded: succeeded && countsAsAnswer &&
        usage?.hasWebSearchCitations === true,
      p_web_search_calls: Math.min(1, webSearchCalls),
      p_accounted_cost_microusd: webSearchAccountedCostMicrousd(
        webSearchCalls,
        policy.freeWebSearch.reservationMicrousd,
        actualCostMicrousd,
      ),
    }));
  }

  const results = await Promise.all(operations);
  for (const result of results) {
    if (result.error) {
      console.error("Usage reconciliation failed", result.error);
    }
  }
}

function monitorStreamingBody(
  body: ReadableStream<Uint8Array>,
  startedAt: number,
  onFinished: (
    usage: ResponsesUsage | null,
    firstTokenMs: number | null,
  ) => Promise<void>,
  onCancelled: () => Promise<void>,
): ReadableStream<Uint8Array> {
  const reader = body.getReader();
  const collector = new ResponsesSseUsageCollector();
  let firstTokenMs: number | null = null;
  let settled = false;

  async function finish(usage: ResponsesUsage | null): Promise<void> {
    if (settled) return;
    settled = true;
    await onFinished(usage, firstTokenMs);
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
          collector.push(value);
          if (collector.sawVisibleOutputDelta) {
            firstTokenMs ??= Math.round(performance.now() - startedAt);
          }
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

function isGpt56Model(model: string): boolean {
  return model === "gpt-5.6-luna" || model.startsWith("gpt-5.6-luna-") ||
    model === "gpt-5.6-sol" || model.startsWith("gpt-5.6-sol-");
}

function estimateActualCostMicrousd(
  model: string | null,
  usage: ResponsesUsage | null,
  fallback: number | null,
): number | null {
  if (!model || !usage) return fallback;
  if (usage.inputTokens == null || usage.outputTokens == null) return fallback;
  const inputTokens = usage.inputTokens;
  const cachedInputTokens = usage.cachedInputTokens ?? 0;
  const estimated = estimateModelCostMicrousd(model, {
    inputTokens,
    cachedInputTokens,
    // Until OpenAI returns this breakdown, treat uncached GPT-5.6 input as a
    // cache write so free-plan budgets remain conservative.
    cacheWriteInputTokens: isGpt56Model(model)
      ? Math.max(0, inputTokens - cachedInputTokens)
      : 0,
    outputTokens: usage.outputTokens,
  });
  return estimated == null
    ? fallback
    : estimated + webSearchToolCostMicrousd(usage.webSearchCalls);
}

function rolloutTelemetry(
  sanitized: SanitizedResponse | null,
): Pick<
  RequestLog,
  | "requested_alias"
  | "rollout_cohort"
  | "rollout_bucket"
  | "rollout_percent"
  | "eval_version"
> {
  return {
    requested_alias: sanitized?.requestedAlias ?? null,
    rollout_cohort: sanitized?.rollout.cohort ?? null,
    rollout_bucket: sanitized?.rollout.bucket ?? null,
    rollout_percent: sanitized?.rollout.rolloutPercent ?? null,
    eval_version: sanitized ? GPT56_EVAL_VERSION : null,
  };
}

function proxyErrorCategory(error: unknown): string {
  if (error instanceof ProxyPolicyError) {
    return error.status >= 500 ? "policy_unavailable" : "policy_rejected";
  }
  return "proxy_error";
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
    return jsonResponse(500, {
      error: "OPENAI_API_KEY is not configured on proxy",
    }, origin);
  }
  if (
    !SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY ||
    !supabaseAdmin
  ) {
    return jsonResponse(500, {
      error: "Supabase proxy auth/logging secrets are not configured",
    }, origin);
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  if (!(await isWithinRateLimit(user))) {
    return jsonResponse(
      429,
      { error: "Temporary usage limit reached" },
      origin,
    );
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
        await getModelPolicyRollout(user),
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
      body: forwardBody as BodyInit,
    });

    const responseHeaders = new Headers(corsHeaders(origin));
    responseHeaders.set("Cache-Control", "no-store");

    const upstreamContentType = upstream.headers.get("content-type");
    if (upstreamContentType) {
      responseHeaders.set("Content-Type", upstreamContentType);
    }

    if (isStreaming && upstream.ok && upstream.body) {
      const streamLogId = await logRequest({
        ...rolloutTelemetry(sanitized),
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model,
        status_code: upstream.status,
        request_bytes: originalBodyBytes.byteLength,
        intent: sanitized?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.reasoningEffort ?? null,
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
        web_search_offered: sanitized?.webSearchOffered ?? false,
        web_search_quota_denied: sanitized?.webSearchQuotaDenied ?? false,
      });

      const monitoredBody = monitorStreamingBody(
        upstream.body,
        requestStartedAt,
        async (usage, firstTokenMs) => {
          const streamSucceeded = usage?.terminalEvent === "response.completed";
          const countsAsAnswer = streamSucceeded &&
            usage?.hasFinalOutput === true;
          const actualCost = estimateActualCostMicrousd(
            usage?.model ?? model,
            usage,
            sanitized?.policy?.reservationMicrousd ?? null,
          );
          const telemetryError = !usage
            ? "stream_completed_without_terminal_usage"
            : streamSucceeded
            ? null
            : usage.terminalEvent ?? "stream_terminal_error";
          await Promise.all([
            updateRequestLog(streamLogId, {
              response_id: usage?.responseId ?? null,
              actual_model: usage?.model ?? null,
              input_tokens: usage?.inputTokens ?? null,
              cached_input_tokens: usage?.cachedInputTokens ?? null,
              output_tokens: usage?.outputTokens ?? null,
              total_tokens: usage?.totalTokens ?? null,
              web_search_calls: usage?.webSearchCalls ?? null,
              web_search_citations_present: usage?.hasWebSearchCitations ??
                null,
              latency_ms: Math.round(performance.now() - requestStartedAt),
              time_to_first_token_ms: firstTokenMs,
              actual_cost_microusd: actualCost,
              error_category: telemetryError ? "stream_terminal_error" : null,
              error: telemetryError,
            }),
            reconcilePolicyUsage(
              sanitized?.policy ?? null,
              streamSucceeded,
              countsAsAnswer,
              usage,
              actualCost,
              telemetryError,
            ),
          ]);
        },
        async () => {
          const cancellationCost = sanitized?.policy?.reservationMicrousd ??
            null;
          await Promise.all([
            updateRequestLog(streamLogId, {
              latency_ms: Math.round(performance.now() - requestStartedAt),
              actual_cost_microusd: cancellationCost,
              error_category: "stream_cancelled",
              error: "stream_cancelled",
            }),
            reconcilePolicyUsage(
              sanitized?.policy ?? null,
              false,
              false,
              null,
              cancellationCost,
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
    let upstreamError = nonJsonUpstreamErrorTelemetry(true);
    let responseStatus: string | null = null;

    try {
      const responseJson = JSON.parse(responseText) as Record<string, unknown>;
      usage = extractResponsesUsage(responseJson);
      responseStatus = typeof responseJson.status === "string"
        ? responseJson.status
        : null;
      upstreamError = extractUpstreamErrorTelemetry(responseJson);
    } catch {
      upstreamError = nonJsonUpstreamErrorTelemetry(upstream.ok);
    }

    const responseSucceeded = path === "/v1/responses"
      ? upstream.ok && responseStatus === "completed"
      : upstream.ok;
    const countsAsAnswer = path === "/v1/responses" && responseSucceeded &&
      usage?.hasFinalOutput === true;
    const reconciliationError = responseSucceeded
      ? null
      : upstream.ok && responseStatus
      ? `response_${responseStatus}`
      : "upstream_error";
    const actualCost = usage
      ? estimateActualCostMicrousd(
        usage?.model ?? model,
        usage,
        upstream.ok ? sanitized?.policy?.reservationMicrousd ?? null : null,
      )
      : null;

    await Promise.all([
      logRequest({
        ...rolloutTelemetry(sanitized),
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model,
        status_code: upstream.status,
        request_bytes: originalBodyBytes.byteLength,
        response_id: usage?.responseId ?? null,
        actual_model: usage?.model ?? null,
        input_tokens: usage?.inputTokens ?? null,
        cached_input_tokens: usage?.cachedInputTokens ?? null,
        output_tokens: usage?.outputTokens ?? null,
        total_tokens: usage?.totalTokens ?? null,
        intent: sanitized?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.reasoningEffort ?? null,
        latency_ms: Math.round(performance.now() - requestStartedAt),
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        actual_cost_microusd: actualCost,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
        web_search_offered: sanitized?.webSearchOffered ?? false,
        web_search_calls: usage?.webSearchCalls ?? null,
        web_search_quota_denied: sanitized?.webSearchQuotaDenied ?? false,
        web_search_citations_present: usage?.hasWebSearchCitations ?? null,
        error_category: upstreamError.present || !responseSucceeded
          ? "upstream_error"
          : null,
        error_code: upstreamError.code,
        error_param: upstreamError.param,
        error: responseSucceeded ? null : reconciliationError,
      }),
      reconcilePolicyUsage(
        sanitized?.policy ?? null,
        responseSucceeded,
        countsAsAnswer,
        usage,
        actualCost,
        reconciliationError,
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
        ...rolloutTelemetry(sanitized),
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model: sanitized?.model ?? null,
        status_code: status,
        request_bytes: requestBytes,
        intent: sanitized?.intent ?? null,
        model_role: sanitized?.policy?.modelRole ?? null,
        reasoning_effort: sanitized?.reasoningEffort ?? null,
        latency_ms: Math.round(performance.now() - requestStartedAt),
        estimated_cost_microusd: sanitized?.policy?.reservationMicrousd ?? null,
        usage_ledger_id: sanitized?.policy?.ledgerId ?? null,
        web_search_offered: sanitized?.webSearchOffered ?? false,
        web_search_quota_denied: sanitized?.webSearchQuotaDenied ?? false,
        error_category: proxyErrorCategory(error),
        error: proxyErrorCategory(error),
      }),
      reconcilePolicyUsage(
        sanitized?.policy ?? null,
        false,
        false,
        null,
        0,
        "proxy_error",
      ),
    ]);

    if (error instanceof ProxyPolicyError) {
      return jsonResponse(status, { error: message }, origin);
    }
    return jsonResponse(
      502,
      { error: "Proxy upstream request failed" },
      origin,
    );
  }
});
