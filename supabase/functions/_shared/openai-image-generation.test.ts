import assert from "node:assert/strict";
import test from "node:test";

import {
  applyTrialImageAvailabilityGuidance,
  constrainTrialImageGenerationTools,
  hasImageGenerationTool,
  imageGenerationToolCostMicrousd,
  removeImageGenerationTools,
  requestCostExcludingTrialImageMicrousd,
  shouldOfferTrialImageGeneration,
  trialImageWeeklyQuota,
} from "./openai-image-generation.ts";

test("trial images are available only for enabled primary chat cohorts", () => {
  const base = {
    masterEnabled: true,
    anonymousEnabled: true,
    freeEnabled: true,
    intent: "primary_chat" as const,
  };

  assert.equal(
    shouldOfferTrialImageGeneration({ ...base, cohort: "anonymous" }),
    true,
  );
  assert.equal(
    shouldOfferTrialImageGeneration({ ...base, cohort: "free" }),
    true,
  );
  assert.equal(
    shouldOfferTrialImageGeneration({ ...base, cohort: "paid" }),
    false,
  );
  assert.equal(
    shouldOfferTrialImageGeneration({
      ...base,
      cohort: "free",
      intent: "title",
    }),
    false,
  );
});

test("anonymous and Free image trials use the product's weekly ladder", () => {
  assert.deepEqual(trialImageWeeklyQuota("anonymous", 5, 10), {
    userLimit: 5,
    windowSeconds: 604_800,
  });
  assert.deepEqual(trialImageWeeklyQuota("free", 5, 10), {
    userLimit: 10,
    windowSeconds: 604_800,
  });
});

test("the proxy clamps trial image quality and size", () => {
  const tools = constrainTrialImageGenerationTools([
    {
      type: "image_generation",
      quality: "high",
      size: "3840x2160",
      partial_images: 3,
    },
    { type: "function", name: "reminders_create" },
  ]);

  assert.deepEqual(tools, [
    {
      type: "image_generation",
      quality: "low",
      size: "1024x1024",
    },
    { type: "function", name: "reminders_create" },
  ]);
  assert.equal(hasImageGenerationTool(tools), true);
});

test("image tools can be removed without disturbing other safe tools", () => {
  const payload: Record<string, unknown> = {
    tools: [
      { type: "image_generation" },
      { type: "function", name: "reminders_create" },
    ],
    tool_choice: "auto",
    max_tool_calls: 1,
  };

  removeImageGenerationTools(payload);

  assert.deepEqual(payload.tools, [
    { type: "function", name: "reminders_create" },
  ]);
  assert.equal(payload.tool_choice, "auto");
  assert.equal("max_tool_calls" in payload, false);
});

test("an image-only payload clears stale tool controls when denied", () => {
  const payload: Record<string, unknown> = {
    tools: [{ type: "image_generation" }],
    tool_choice: "required",
    max_tool_calls: 1,
  };

  removeImageGenerationTools(payload);

  assert.equal("tools" in payload, false);
  assert.equal("tool_choice" in payload, false);
  assert.equal("max_tool_calls" in payload, false);
});

test("image cost accounting is conservative and nonnegative", () => {
  assert.equal(imageGenerationToolCostMicrousd(1), 10_000);
  assert.equal(imageGenerationToolCostMicrousd(2, 6_000), 12_000);
  assert.equal(imageGenerationToolCostMicrousd(-1), 0);
});

test("trial image cost is excluded from the general chat ledger", () => {
  assert.equal(
    requestCostExcludingTrialImageMicrousd(10_845, 1, 10_000),
    845,
  );
  assert.equal(
    requestCostExcludingTrialImageMicrousd(500, 1, 10_000),
    0,
  );
  assert.equal(
    requestCostExcludingTrialImageMicrousd(10_845, 0, 10_000),
    10_845,
  );
  assert.equal(
    requestCostExcludingTrialImageMicrousd(null, 1, 10_000),
    null,
  );
});

test("quota guidance is model-readable, scoped, and removable", () => {
  const payload: Record<string, unknown> = {
    instructions: "Be helpful.",
  };

  applyTrialImageAvailabilityGuidance(payload, "anonymous", true);
  assert.match(
    String(payload.instructions),
    /Only mention this if the user asks to create or edit an image/,
  );
  assert.match(String(payload.instructions), /sign in/);

  applyTrialImageAvailabilityGuidance(payload, "free", true);
  assert.equal(
    String(payload.instructions).match(
      /<image_generation_availability>/g,
    )?.length,
    1,
  );
  assert.doesNotMatch(String(payload.instructions), /sign in/);

  applyTrialImageAvailabilityGuidance(payload, "free", false);
  assert.equal(payload.instructions, "Be helpful.");
});
