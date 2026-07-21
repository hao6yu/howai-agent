export type UserCohort = "anonymous" | "free" | "paid";
export type RequestIntent =
  | "primary_chat"
  | "lightweight"
  | "title"
  | "research";
export type ModelRole = "nano" | "luna" | "sol" | "research";

export type RuntimeModels = Readonly<{
  nano: string;
  luna: string;
  sol: string;
  research: string;
}>;

export type FreeUsageWindow = Readonly<{
  lunaAnswersToday: number;
  lunaCostTodayMicrousd: number;
  lunaCostThisMonthMicrousd: number;
}>;

export type ModelPolicyConfig = Readonly<{
  models: RuntimeModels;
  freeLunaAnswersPerDay: number;
  freeLunaDailyBudgetMicrousd: number;
  freeLunaMonthlyBudgetMicrousd: number;
  anonymousMaxOutputTokens: number;
  freeNanoMaxOutputTokens: number;
  freeLunaMaxOutputTokens: number;
  paidMaxOutputTokens: number;
}>;

export type PolicyRequest = Readonly<{
  cohort: UserCohort;
  entitlementTrusted: boolean;
  intent: RequestIntent;
  hasAttachments: boolean;
  estimatedLunaCostMicrousd: number;
  freeUsage: FreeUsageWindow;
}>;

export type ModelPolicyDecision = Readonly<{
  role: ModelRole;
  model: string;
  maxOutputTokens: number;
  reasoningEffort: "low" | "high";
  fallbackReason: string | null;
}>;

export const DEFAULT_MODEL_POLICY: ModelPolicyConfig = Object.freeze({
  models: Object.freeze({
    nano: "gpt-5-nano",
    luna: "gpt-5.6-luna",
    sol: "gpt-5.6-sol",
    research: "gpt-5.6-sol",
  }),
  freeLunaAnswersPerDay: 3,
  freeLunaDailyBudgetMicrousd: 30_000,
  freeLunaMonthlyBudgetMicrousd: 300_000,
  anonymousMaxOutputTokens: 400,
  freeNanoMaxOutputTokens: 700,
  freeLunaMaxOutputTokens: 1_200,
  paidMaxOutputTokens: 3_000,
});

export function applyModelPolicyControls(
  payload: Record<string, unknown>,
  decision: ModelPolicyDecision,
): void {
  payload.model = decision.model;
  payload.reasoning = { effort: decision.reasoningEffort };
  payload.service_tier = "default";
  payload.background = false;
  delete payload.prompt_cache_key;
  delete payload.prompt_cache_retention;

  applyOutputTokenCeiling(payload, decision.maxOutputTokens);
}

/**
 * Writes the single output budget forwarded to the OpenAI API.
 *
 * The client chooses its requested limit. The proxy only validates that
 * untrusted value against the model/plan ceiling; it does not run a separate
 * truncation layer.
 */
export function applyOutputTokenCeiling(
  payload: Record<string, unknown>,
  maximumAllowedTokens: number,
): number {
  const ceiling = Math.max(1, Math.floor(maximumAllowedTokens));
  const requested = positiveIntegerOrNull(payload.max_output_tokens) ?? ceiling;
  const applied = Math.min(requested, ceiling);
  payload.max_output_tokens = applied;
  return applied;
}

export function legacyModelAllowlist(
  chatModel: string,
  miniModel: string,
  explicitlyAllowedModels = "",
): string[] {
  return `${chatModel},${miniModel},${explicitlyAllowedModels}`
    .split(",")
    .map((model) => model.trim())
    .filter(Boolean);
}

const MODEL_PRICE_USD_PER_MILLION = Object.freeze({
  "gpt-5-nano": Object.freeze({ input: 0.05, cachedInput: 0.005, output: 0.4 }),
  "gpt-5.6-luna": Object.freeze({
    input: 1,
    cachedInput: 0.1,
    cacheWriteInput: 1.25,
    output: 6,
  }),
  "gpt-5.6-sol": Object.freeze({
    input: 5,
    cachedInput: 0.5,
    cacheWriteInput: 6.25,
    output: 30,
  }),
});

const GPT_5_6_LONG_CONTEXT_THRESHOLD = 272_000;

export function resolveModelPolicy(
  request: PolicyRequest,
  config: ModelPolicyConfig = DEFAULT_MODEL_POLICY,
): ModelPolicyDecision {
  if (request.cohort === "paid" && request.entitlementTrusted) {
    if (request.intent === "research") {
      return decision(
        "research",
        config.models.research,
        config.paidMaxOutputTokens,
        null,
        "high",
      );
    }

    if (request.intent === "primary_chat") {
      return decision("sol", config.models.sol, config.paidMaxOutputTokens);
    }

    return decision("nano", config.models.nano, config.freeNanoMaxOutputTokens);
  }

  if (request.cohort === "anonymous") {
    return decision(
      "nano",
      config.models.nano,
      config.anonymousMaxOutputTokens,
      "anonymous_nano_only",
    );
  }

  if (request.intent !== "primary_chat") {
    return decision(
      "nano",
      config.models.nano,
      config.freeNanoMaxOutputTokens,
      "lightweight_intent",
    );
  }

  if (request.hasAttachments) {
    return decision(
      "nano",
      config.models.nano,
      config.freeNanoMaxOutputTokens,
      "free_attachment_nano",
    );
  }

  if (request.freeUsage.lunaAnswersToday >= config.freeLunaAnswersPerDay) {
    return decision(
      "nano",
      config.models.nano,
      config.freeNanoMaxOutputTokens,
      "luna_answer_limit_reached",
    );
  }

  const estimatedCost = Math.max(0, request.estimatedLunaCostMicrousd);
  if (
    request.freeUsage.lunaCostTodayMicrousd + estimatedCost >
      config.freeLunaDailyBudgetMicrousd
  ) {
    return decision(
      "nano",
      config.models.nano,
      config.freeNanoMaxOutputTokens,
      "luna_daily_budget_reached",
    );
  }

  if (
    request.freeUsage.lunaCostThisMonthMicrousd + estimatedCost >
      config.freeLunaMonthlyBudgetMicrousd
  ) {
    return decision(
      "nano",
      config.models.nano,
      config.freeNanoMaxOutputTokens,
      "luna_monthly_budget_reached",
    );
  }

  return decision("luna", config.models.luna, config.freeLunaMaxOutputTokens);
}

export function estimateModelCostMicrousd(
  model: string,
  usage: Readonly<{
    inputTokens: number;
    cachedInputTokens?: number;
    cacheWriteInputTokens?: number;
    outputTokens: number;
  }>,
): number | null {
  const prices = priceForModel(model);
  if (!prices) return null;

  const inputTokens = nonNegativeInteger(usage.inputTokens);
  const cachedInputTokens = Math.min(
    inputTokens,
    nonNegativeInteger(usage.cachedInputTokens ?? 0),
  );
  const cacheWriteInputTokens = Math.min(
    inputTokens - cachedInputTokens,
    nonNegativeInteger(usage.cacheWriteInputTokens ?? 0),
  );
  const uncachedInputTokens = inputTokens - cachedInputTokens -
    cacheWriteInputTokens;
  const outputTokens = nonNegativeInteger(usage.outputTokens);
  const isLongContext = isGpt56Model(model) &&
    inputTokens > GPT_5_6_LONG_CONTEXT_THRESHOLD;
  const inputMultiplier = isLongContext ? 2 : 1;
  const outputMultiplier = isLongContext ? 1.5 : 1;

  // A $1.00 / 1M-token price is exactly one micro-USD per token.
  return Math.ceil(
    inputMultiplier * (
          uncachedInputTokens * prices.input +
          cachedInputTokens * prices.cachedInput +
          cacheWriteInputTokens *
            ("cacheWriteInput" in prices
              ? prices.cacheWriteInput
              : prices.input)
        ) +
      outputMultiplier * outputTokens * prices.output,
  );
}

function isGpt56Model(model: string): boolean {
  return model === "gpt-5.6-luna" || model.startsWith("gpt-5.6-luna-") ||
    model === "gpt-5.6-sol" || model.startsWith("gpt-5.6-sol-");
}

function priceForModel(model: string) {
  const exact = MODEL_PRICE_USD_PER_MILLION[
    model as keyof typeof MODEL_PRICE_USD_PER_MILLION
  ];
  if (exact) return exact;
  if (model.startsWith("gpt-5.6-luna-")) {
    return MODEL_PRICE_USD_PER_MILLION["gpt-5.6-luna"];
  }
  if (model.startsWith("gpt-5.6-sol-")) {
    return MODEL_PRICE_USD_PER_MILLION["gpt-5.6-sol"];
  }
  if (model.startsWith("gpt-5-nano-")) {
    return MODEL_PRICE_USD_PER_MILLION["gpt-5-nano"];
  }
  return null;
}

function decision(
  role: ModelRole,
  model: string,
  maxOutputTokens: number,
  fallbackReason: string | null = null,
  reasoningEffort: "low" | "high" = "low",
): ModelPolicyDecision {
  return {
    role,
    model,
    maxOutputTokens,
    reasoningEffort,
    fallbackReason,
  };
}

function nonNegativeInteger(value: number): number {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.floor(value));
}

function positiveIntegerOrNull(value: unknown): number | null {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 1) {
    return null;
  }
  return Math.floor(value);
}
