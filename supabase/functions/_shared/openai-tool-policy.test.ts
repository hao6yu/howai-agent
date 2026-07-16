import assert from "node:assert/strict";
import test from "node:test";

import {
  MARKET_AUTOMATION_FUNCTION,
  NEWS_AUTOMATION_FUNCTION,
  requestsAutomationFunction,
  sanitizeResponseTools,
} from "./openai-tool-policy.ts";

const newsTool = { type: "function", name: NEWS_AUTOMATION_FUNCTION };
const marketTool = { type: "function", name: MARKET_AUTOMATION_FUNCTION };

test("generated Automation tools are stripped without trusted authorization", () => {
  assert.deepEqual(
    sanitizeResponseTools([
      newsTool,
      marketTool,
      { type: "function", name: "client_defined_unsafe_tool" },
      { type: "function", name: "reminders_create" },
    ]),
    [
      { type: "function", name: "reminders_create" },
    ],
  );
});

test("authorized generated Automations retain news but not disabled market data", () => {
  assert.deepEqual(
    sanitizeResponseTools([
      { type: "web_search" },
      newsTool,
      marketTool,
    ], {
      generatedAutomations: true,
      marketAutomations: false,
    }),
    [
      { type: "web_search" },
      newsTool,
    ],
  );
});

test("market Automation requires both generated and market authorization", () => {
  assert.deepEqual(
    sanitizeResponseTools([newsTool, marketTool], {
      generatedAutomations: true,
      marketAutomations: true,
    }),
    [newsTool, marketTool],
  );
  assert.deepEqual(
    sanitizeResponseTools([marketTool], {
      generatedAutomations: false,
      marketAutomations: true,
    }),
    [],
  );
});

test("Automation capability lookup is based on tool identity, not prompt text", () => {
  assert.equal(requestsAutomationFunction([newsTool]), true);
  assert.equal(requestsAutomationFunction([marketTool]), true);
  assert.equal(
    requestsAutomationFunction([
      { type: "function", name: "reminders_create" },
      { type: "web_search" },
    ]),
    false,
  );
});

test("nested legacy function shape is sanitized by the same allowlist", () => {
  assert.deepEqual(
    sanitizeResponseTools([
      { type: "function", function: { name: NEWS_AUTOMATION_FUNCTION } },
      { type: "function", function: { name: "unknown_function" } },
    ], {
      generatedAutomations: true,
      marketAutomations: false,
    }),
    [
      { type: "function", function: { name: NEWS_AUTOMATION_FUNCTION } },
    ],
  );
});
