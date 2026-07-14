import assert from "node:assert/strict";
import test from "node:test";

import {
  DEFAULT_MODEL_POLICY,
  estimateModelCostMicrousd,
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
