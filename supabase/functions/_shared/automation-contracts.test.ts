import assert from "node:assert/strict";
import test from "node:test";
import { describeAutomation, normalizeAutomationCreate } from "./automation-contracts.ts";

test("normalizes a scheduled news briefing", () => {
  const value = normalizeAutomationCreate({
    kind: "news_briefing",
    title: "Morning AI briefing",
    timezone: "America/Chicago",
    start_local: "2026-07-17T07:00:00",
    schedule: { frequency: "daily", interval: 1, weekdays: [], ends_at: null },
    config: {
      topics: ["AI", "robotics"], item_count: 5, region: "US",
      language: "auto", summary_style: "concise",
    },
    source_policy: {
      preferred_domains: ["openai.com"], excluded_domains: [],
      freshness_hours: 24, require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T12:00:00Z"));
  assert.equal(value.kind, "news_briefing");
  assert.equal(value.config.item_count, 5);
  assert.match(value.next_run_at, /^2026-07-17/);
  assert.match(describeAutomation(value), /AI, robotics/);
});

test("normalizes market days to weekdays", () => {
  const value = normalizeAutomationCreate({
    kind: "market_briefing",
    title: "Market close",
    timezone: "America/New_York",
    start_local: "2026-07-17T15:30:00",
    schedule: { frequency: "market_days", interval: 1, weekdays: [], ends_at: null },
    config: { session: "close", scope: "watchlist", symbols: ["aapl", "MSFT"], focus: null },
    source_policy: {
      preferred_domains: [], excluded_domains: [], freshness_hours: 24,
      require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T12:00:00Z"));
  assert.deepEqual(value.schedule_rule.weekdays, [1, 2, 3, 4, 5]);
  assert.deepEqual(value.config.symbols, ["AAPL", "MSFT"]);
});

test("rejects arbitrary scheduled prompts and unknown fields", () => {
  assert.throws(() => normalizeAutomationCreate({ kind: "prompt", extra: "run code" }));
});

test("requires a watchlist symbol", () => {
  assert.throws(() => normalizeAutomationCreate({
    kind: "market_briefing",
    title: "Watchlist",
    timezone: "UTC",
    start_local: "2026-07-17T15:30:00",
    schedule: { frequency: "daily", interval: 1, weekdays: [], ends_at: null },
    config: { session: "close", scope: "watchlist", symbols: [], focus: null },
    source_policy: {
      preferred_domains: [], excluded_domains: [], freshness_hours: 24,
      require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T12:00:00Z")));
});
