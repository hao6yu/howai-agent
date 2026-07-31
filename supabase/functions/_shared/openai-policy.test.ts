import assert from "node:assert/strict";
import test from "node:test";

import {
  applyModelPolicyControls,
  applyOutputTokenCeiling,
  DEFAULT_MODEL_POLICY,
  estimateModelCostMicrousd,
  legacyModelAllowlist,
  resolveModelPolicy,
} from "./openai-policy.ts";

const emptyUsage = {
  lunaAnswersToday: 0,
  lunaCostTodayMicrousd: 0,
  lunaCostThisMonthMicrousd: 0,
};

test("a trusted paid primary chat resolves to Sol", () => {
  const result = resolveModelPolicy({
    cohort: "paid",
    entitlementTrusted: true,
    intent: "primary_chat",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 0,
    freeUsage: emptyUsage,
  });

  assert.equal(result.model, "gpt-5.6-sol");
  assert.equal(result.maxOutputTokens, 3_000);
});

test("trusted paid synchronous research uses Sol with high reasoning", () => {
  const result = resolveModelPolicy({
    cohort: "paid",
    entitlementTrusted: true,
    intent: "research",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 0,
    freeUsage: emptyUsage,
  });

  assert.equal(result.role, "research");
  assert.equal(result.model, "gpt-5.6-sol");
  assert.equal(result.reasoningEffort, "high");
});

test("an untrusted paid claim never unlocks Sol", () => {
  const result = resolveModelPolicy({
    cohort: "paid",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 5_000,
    freeUsage: emptyUsage,
  });

  assert.equal(result.model, "gpt-5.6-luna");
});

test("signed-in free users receive three budgeted Luna answers", () => {
  const result = resolveModelPolicy({
    cohort: "free",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 8_000,
    freeUsage: { ...emptyUsage, lunaAnswersToday: 2 },
  });

  assert.equal(result.model, "gpt-5.6-luna");
  assert.equal(result.fallbackReason, null);
});

test("free users fall back to nano when a Luna guardrail is exhausted", () => {
  const result = resolveModelPolicy({
    cohort: "free",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 1,
    freeUsage: {
      ...emptyUsage,
      lunaAnswersToday: DEFAULT_MODEL_POLICY.freeLunaAnswersPerDay,
    },
  });

  assert.equal(result.model, "gpt-5-nano");
  assert.equal(result.fallbackReason, "luna_answer_limit_reached");
});

test("signed-in free users can analyze attachments on Nano", () => {
  const result = resolveModelPolicy({
    cohort: "free",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: true,
    estimatedLunaCostMicrousd: 8_000,
    freeUsage: emptyUsage,
  });

  assert.equal(result.model, "gpt-5-nano");
  assert.equal(result.fallbackReason, "free_attachment_nano");
});

test("anonymous users can analyze attachments on Nano", () => {
  const result = resolveModelPolicy({
    cohort: "anonymous",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: true,
    estimatedLunaCostMicrousd: 8_000,
    freeUsage: emptyUsage,
  });

  assert.equal(result.model, "gpt-5-nano");
  assert.equal(result.maxOutputTokens, 800);
  assert.equal(result.fallbackReason, "anonymous_nano_only");
});

test("anonymous output budget can complete the client's quick response profile", () => {
  const result = resolveModelPolicy({
    cohort: "anonymous",
    entitlementTrusted: false,
    intent: "primary_chat",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 0,
    freeUsage: emptyUsage,
  });
  const payload: Record<string, unknown> = { max_output_tokens: 800 };

  applyModelPolicyControls(payload, result);

  assert.equal(payload.max_output_tokens, 800);
});

test("background checks remain on nano for every tier", () => {
  const result = resolveModelPolicy({
    cohort: "paid",
    entitlementTrusted: true,
    intent: "lightweight",
    hasAttachments: false,
    estimatedLunaCostMicrousd: 0,
    freeUsage: emptyUsage,
  });

  assert.equal(result.model, "gpt-5-nano");
});

test("the server strips client cost-control overrides from policy requests", () => {
  const payload: Record<string, unknown> = {
    model: "gpt-5.6-sol",
    reasoning: { effort: "max", mode: "pro" },
    service_tier: "priority",
    background: true,
    max_output_tokens: 100_000,
    prompt_cache_key: "client-controlled",
    prompt_cache_retention: "24h",
  };

  applyModelPolicyControls(payload, {
    role: "luna",
    model: "gpt-5.6-luna",
    maxOutputTokens: 1_200,
    reasoningEffort: "low",
    fallbackReason: null,
  });

  assert.equal(payload.model, "gpt-5.6-luna");
  assert.deepEqual(payload.reasoning, { effort: "low" });
  assert.equal(payload.service_tier, "default");
  assert.equal(payload.background, false);
  assert.equal(payload.max_output_tokens, 1_200);
  assert.equal("prompt_cache_key" in payload, false);
  assert.equal("prompt_cache_retention" in payload, false);
});

test("the output ceiling preserves a smaller client API request", () => {
  const payload: Record<string, unknown> = { max_output_tokens: 800 };

  const applied = applyOutputTokenCeiling(payload, 3_000);

  assert.equal(applied, 800);
  assert.equal(payload.max_output_tokens, 800);
});

test("the output ceiling supplies a safe default and normalizes integers", () => {
  const missing: Record<string, unknown> = {};
  const fractional: Record<string, unknown> = { max_output_tokens: 1_200.9 };

  assert.equal(applyOutputTokenCeiling(missing, 3_000), 3_000);
  assert.equal(missing.max_output_tokens, 3_000);
  assert.equal(applyOutputTokenCeiling(fractional, 3_000), 1_200);
  assert.equal(fractional.max_output_tokens, 1_200);
});

test("the legacy allowlist excludes new premium roles unless explicitly configured", () => {
  const defaultModels = legacyModelAllowlist("gpt-5.2", "gpt-5-nano");
  assert.deepEqual(defaultModels, ["gpt-5.2", "gpt-5-nano"]);
  assert.equal(defaultModels.includes("gpt-5.6-luna"), false);
  assert.equal(defaultModels.includes("gpt-5.6-sol"), false);

  assert.deepEqual(
    legacyModelAllowlist("gpt-5.2", "gpt-5-nano", "gpt-5.6-luna"),
    ["gpt-5.2", "gpt-5-nano", "gpt-5.6-luna"],
  );
});

test("cost estimation accounts for cached input pricing", () => {
  assert.equal(
    estimateModelCostMicrousd("gpt-5.6-luna", {
      inputTokens: 1_000,
      cachedInputTokens: 400,
      outputTokens: 100,
    }),
    1_240,
  );
  assert.equal(
    estimateModelCostMicrousd("gpt-5.6-sol-2026-07-01", {
      inputTokens: 100,
      outputTokens: 10,
    }),
    800,
  );
  assert.equal(
    estimateModelCostMicrousd("unknown", {
      inputTokens: 1,
      outputTokens: 1,
    }),
    null,
  );
});

test("GPT-5.6 cost estimation includes cache writes and long-context pricing", () => {
  assert.equal(
    estimateModelCostMicrousd("gpt-5.6-luna", {
      inputTokens: 1_000,
      cachedInputTokens: 300,
      cacheWriteInputTokens: 200,
      outputTokens: 0,
    }),
    780,
  );
  assert.equal(
    estimateModelCostMicrousd("gpt-5.6-sol", {
      inputTokens: 272_001,
      outputTokens: 10,
    }),
    2_720_460,
  );
});
