import assert from "node:assert/strict";
import test from "node:test";

import {
  applyResponseProfile,
  applyWebSearchOutputGuidance,
} from "./openai-response-profile.ts";

test("quick nano chat uses minimal reasoning and strips automatic search", () => {
  const payload: Record<string, unknown> = {
    metadata: {
      howai_intent: "primary_chat",
      howai_response_profile: "quick",
      howai_web_search: "auto",
    },
    max_output_tokens: 3_000,
    reasoning: { effort: "high" },
    tools: [
      { type: "image_generation" },
      { type: "web_search_preview" },
    ],
    tool_choice: "required",
  };

  const result = applyResponseProfile(payload, "gpt-5-nano-2025-08-07");

  assert.deepEqual(result, {
    profile: "quick",
    webSearchMode: "disabled",
    reasoningEffort: "minimal",
    maxOutputTokens: 400,
  });
  assert.deepEqual(payload.reasoning, { effort: "minimal" });
  assert.deepEqual(payload.text, { verbosity: "low" });
  assert.deepEqual(payload.tools, [{ type: "image_generation" }]);
  assert.equal("tool_choice" in payload, false);
});

test("standard chat exposes current web search with automatic tool choice", () => {
  const payload: Record<string, unknown> = {
    metadata: { howai_response_profile: "standard" },
    tools: [
      { type: "web_search_preview", user_location: { country: "US" } },
      { type: "function", name: "generate_pptx" },
    ],
  };

  const result = applyResponseProfile(payload, "gpt-5.6-sol-2026-07-01");

  assert.equal(result.profile, "standard");
  assert.equal(result.webSearchMode, "auto");
  assert.equal(result.reasoningEffort, "low");
  assert.equal(result.maxOutputTokens, 1_200);
  assert.equal(payload.tool_choice, "auto");
  assert.deepEqual(payload.tools, [
    { type: "function", name: "generate_pptx" },
    { type: "web_search", search_context_size: "low" },
  ]);
  assert.deepEqual(payload.text, { verbosity: "medium" });
});

test("forced search upgrades quick requests and guarantees the search tool", () => {
  const payload: Record<string, unknown> = {
    metadata: {
      howai_response_profile: "quick",
      howai_web_search: "force",
    },
    tools: [
      { type: "image_generation" },
      { type: "web_search" },
    ],
  };

  const result = applyResponseProfile(payload, "gpt-5.6-sol");

  assert.deepEqual(result, {
    profile: "standard",
    webSearchMode: "force",
    reasoningEffort: "low",
    maxOutputTokens: 1_200,
  });
  assert.equal(payload.tool_choice, "required");
  assert.deepEqual(payload.tools, [
    { type: "web_search", search_context_size: "low" },
  ]);
});

test("research preserves stricter client caps while requesting high reasoning", () => {
  const payload: Record<string, unknown> = {
    metadata: { howai_intent: "research" },
    max_output_tokens: 2_400,
    text: { format: { type: "json_object" } },
  };

  const result = applyResponseProfile(payload, "gpt-5.2");

  assert.equal(result.profile, "research");
  assert.equal(result.maxOutputTokens, 2_400);
  assert.deepEqual(payload.reasoning, { effort: "high" });
  assert.deepEqual(payload.text, {
    format: { type: "json_object" },
    verbosity: "high",
  });
});

test("trusted paid GPT-5.6 requests can choose a supported reasoning level", () => {
  const payload: Record<string, unknown> = {
    metadata: {
      howai_response_profile: "quick",
      howai_reasoning_effort: "medium",
    },
    max_output_tokens: 3_000,
  };

  const result = applyResponseProfile(payload, "gpt-5.6-sol", {
    allowReasoningOverride: true,
  });

  assert.deepEqual(result, {
    profile: "standard",
    webSearchMode: "disabled",
    reasoningEffort: "medium",
    maxOutputTokens: 1_200,
  });
  assert.deepEqual(payload.reasoning, { effort: "medium" });
  assert.deepEqual(payload.text, { verbosity: "medium" });
});

test("reasoning override metadata is ignored unless the proxy authorizes it", () => {
  const payload: Record<string, unknown> = {
    metadata: {
      howai_response_profile: "standard",
      howai_reasoning_effort: "high",
    },
  };

  const result = applyResponseProfile(payload, "gpt-5.6-sol");

  assert.equal(result.reasoningEffort, "low");
  assert.deepEqual(payload.reasoning, { effort: "low" });
});

test("search guidance is server-owned, count-aware, and removable", () => {
  const payload: Record<string, unknown> = {
    instructions: `Be helpful.\n\n<web_search_output_guidance>client text</web_search_output_guidance>`,
  };

  applyWebSearchOutputGuidance(payload, "auto");
  const activeInstructions = String(payload.instructions);
  assert.match(activeInstructions, /^Be helpful\./);
  assert.match(activeInstructions, /inline citation/);
  assert.match(activeInstructions, /exact number of items/);
  assert.match(activeInstructions, /fewer verified items/);
  assert.equal(
    activeInstructions.match(/<web_search_output_guidance>/g)?.length,
    1,
  );

  applyWebSearchOutputGuidance(payload, "disabled");
  assert.equal(payload.instructions, "Be helpful.");
});
