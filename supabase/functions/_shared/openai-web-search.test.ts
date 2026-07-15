import assert from "node:assert/strict";
import test from "node:test";

import {
  resolveFreeWebSearchRollout,
  shouldOfferFreeWebSearch,
  webSearchAccountedCostMicrousd,
  webSearchToolCostMicrousd,
} from "./openai-web-search.ts";

test("Free web search fails closed when either server gate is disabled", () => {
  assert.deepEqual(
    resolveFreeWebSearchRollout({
      environmentEnabled: false,
      flagEnabled: true,
      payload: { mode: "on" },
      internalCanary: true,
    }),
    { active: false, mode: "on" },
  );

  assert.deepEqual(
    resolveFreeWebSearchRollout({
      environmentEnabled: true,
      flagEnabled: false,
      payload: { mode: "on" },
      internalCanary: true,
    }),
    { active: false, mode: "on" },
  );
});

test("invalid and off rollout modes fail closed", () => {
  assert.deepEqual(
    resolveFreeWebSearchRollout({
      environmentEnabled: true,
      flagEnabled: true,
      payload: { mode: "percentage" },
      internalCanary: true,
    }),
    { active: false, mode: "off" },
  );
});

test("internal mode selects only private canary accounts", () => {
  assert.equal(
    resolveFreeWebSearchRollout({
      environmentEnabled: true,
      flagEnabled: true,
      payload: { mode: "internal" },
      internalCanary: true,
    }).active,
    true,
  );
  assert.equal(
    resolveFreeWebSearchRollout({
      environmentEnabled: true,
      flagEnabled: true,
      payload: { mode: "internal" },
      internalCanary: false,
    }).active,
    false,
  );
});

test("on mode enables every otherwise eligible account", () => {
  assert.deepEqual(
    resolveFreeWebSearchRollout({
      environmentEnabled: true,
      flagEnabled: true,
      payload: { mode: "on" },
      internalCanary: false,
    }),
    { active: true, mode: "on" },
  );
});

test("only signed-in Free Luna primary chat receives automatic search", () => {
  const eligible = {
    rolloutActive: true,
    cohort: "free" as const,
    modelRole: "luna" as const,
    intent: "primary_chat" as const,
  };
  assert.equal(shouldOfferFreeWebSearch(eligible), true);
  assert.equal(
    shouldOfferFreeWebSearch({ ...eligible, cohort: "paid" }),
    false,
  );
  assert.equal(
    shouldOfferFreeWebSearch({ ...eligible, modelRole: "nano" }),
    false,
  );
  assert.equal(
    shouldOfferFreeWebSearch({ ...eligible, intent: "title" }),
    false,
  );
});

test("tool cost uses actual calls and reconciles the full searched request", () => {
  assert.equal(webSearchToolCostMicrousd(0), 0);
  assert.equal(webSearchToolCostMicrousd(1), 10_000);
  assert.equal(webSearchAccountedCostMicrousd(0, 40_000), 0);
  assert.equal(webSearchAccountedCostMicrousd(1, 40_000), 40_000);
  assert.equal(webSearchAccountedCostMicrousd(1, 40_000, 30_153), 30_153);
  assert.equal(webSearchAccountedCostMicrousd(1, 40_000, 5_000), 10_000);
  assert.equal(webSearchAccountedCostMicrousd(2, 40_000, 30_153), 30_153);
});
