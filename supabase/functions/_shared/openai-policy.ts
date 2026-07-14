export type UserCohort = "anonymous" | "free" | "paid";
export type RequestIntent = "primary_chat" | "lightweight" | "title" | "research";
export type ModelRole = "nano" | "luna" | "sol";

export type RuntimeModels = Readonly<{
  nano: string;
  luna: string;
  sol: string;
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
  reasoningEffort: "low";
  fallbackReason: string | null;
}>;

export const DEFAULT_MODEL_POLICY: ModelPolicyConfig = Object.freeze({
  models: Object.freeze({
    nano: "gpt-5-nano",
    luna: "gpt-5.6-luna",
    sol: "gpt-5.6-sol",
  }),
  freeLunaAnswersPerDay: 3,
  freeLunaDailyBudgetMicrousd: 30_000,
  freeLunaMonthlyBudgetMicrousd: 300_000,
  anonymousMaxOutputTokens: 400,
  freeNanoMaxOutputTokens: 700,
  freeLunaMaxOutputTokens: 1_200,
  paidMaxOutputTokens: 3_000,
});

const MODEL_PRICE_USD_PER_MILLION = Object.freeze({
  "gpt-5-nano": Object.freeze({ input: 0.05, cachedInput: 0.005, output: 0.4 }),
  "gpt-5.6-luna": Object.freeze({ input: 1, cachedInput: 0.1, output: 6 }),
  "gpt-5.6-sol": Object.freeze({ input: 5, cachedInput: 0.5, output: 30 }),
});

export function resolveModelPolicy(
  request: PolicyRequest,
  config: ModelPolicyConfig = DEFAULT_MODEL_POLICY,
): ModelPolicyDecision {
  if (request.cohort === "paid" && request.entitlementTrusted) {
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
      "free_attachment_requires_separate_quota",
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
  const uncachedInputTokens = inputTokens - cachedInputTokens;
  const outputTokens = nonNegativeInteger(usage.outputTokens);

  // A $1.00 / 1M-token price is exactly one micro-USD per token.
  return Math.ceil(
    uncachedInputTokens * prices.input +
      cachedInputTokens * prices.cachedInput +
      outputTokens * prices.output,
  );
}

function priceForModel(model: string) {
  const exact = MODEL_PRICE_USD_PER_MILLION[
    model as keyof typeof MODEL_PRICE_USD_PER_MILLION
  ];
  if (exact) return exact;
  if (model.startsWith("gpt-5.6-luna-")) return MODEL_PRICE_USD_PER_MILLION["gpt-5.6-luna"];
  if (model.startsWith("gpt-5.6-sol-")) return MODEL_PRICE_USD_PER_MILLION["gpt-5.6-sol"];
  if (model.startsWith("gpt-5-nano-")) return MODEL_PRICE_USD_PER_MILLION["gpt-5-nano"];
  return null;
}

function decision(
  role: ModelRole,
  model: string,
  maxOutputTokens: number,
  fallbackReason: string | null = null,
): ModelPolicyDecision {
  return {
    role,
    model,
    maxOutputTokens,
    reasoningEffort: "low",
    fallbackReason,
  };
}

function nonNegativeInteger(value: number): number {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.floor(value));
}
