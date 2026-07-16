import assert from "node:assert/strict";
import test from "node:test";
import {
  describeAutomation,
  nextAutomationOccurrence,
  normalizeAutomationCreate,
} from "./automation-contracts.ts";

test("normalizes a scheduled news briefing", () => {
  const value = normalizeAutomationCreate({
    kind: "news_briefing",
    title: "Morning AI briefing",
    timezone: "America/Chicago",
    start_local: "2026-07-17T07:00:00",
    schedule: { frequency: "daily", interval: 1, weekdays: [], ends_at: null },
    config: {
      topics: ["AI", "robotics"],
      item_count: 5,
      region: "US",
      language: "auto",
      summary_style: "concise",
    },
    source_policy: {
      preferred_domains: ["openai.com"],
      excluded_domains: [],
      freshness_hours: 24,
      require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T12:00:00Z"));
  assert.equal(value.kind, "news_briefing");
  assert.equal(value.config.item_count, 5);
  assert.match(value.next_run_at, /^2026-07-17/);
  assert.match(describeAutomation(value), /AI, robotics/);
});

test("normalizes a one-time news briefing and does not repeat it", () => {
  const value = normalizeAutomationCreate({
    kind: "news_briefing",
    title: "Market news in five minutes",
    timezone: "America/Chicago",
    start_local: "2026-07-16T11:49:00",
    schedule: { frequency: "once", interval: 1, weekdays: [], ends_at: null },
    config: {
      topics: ["stock-market news"],
      item_count: 5,
      region: "US",
      language: "auto",
      summary_style: "concise",
    },
    source_policy: {
      preferred_domains: [],
      excluded_domains: [],
      freshness_hours: 24,
      require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T16:44:00Z"));

  assert.equal(value.schedule_rule.frequency, "once");
  assert.equal(value.next_run_at, "2026-07-16T16:49:00.000Z");
  assert.match(describeAutomation(value), /one time/);
  assert.equal(
    nextAutomationOccurrence({
      startLocal: value.start_local,
      timezone: value.timezone,
      scheduleRule: value.schedule_rule,
      after: new Date(value.next_run_at),
    }),
    null,
  );
});

test("normalizes market days to weekdays", () => {
  const value = normalizeAutomationCreate({
    kind: "market_briefing",
    title: "Market close",
    timezone: "America/New_York",
    start_local: "2026-07-17T15:30:00",
    schedule: {
      frequency: "market_days",
      interval: 1,
      weekdays: [],
      ends_at: null,
    },
    config: {
      session: "close",
      scope: "watchlist",
      symbols: ["aapl", "MSFT"],
      focus: null,
    },
    source_policy: {
      preferred_domains: [],
      excluded_domains: [],
      freshness_hours: 24,
      require_primary_sources: true,
    },
    delivery_preferences: { push: true },
  }, new Date("2026-07-16T12:00:00Z"));
  assert.deepEqual(value.schedule_rule.weekdays, [1, 2, 3, 4, 5]);
  assert.deepEqual(value.config.symbols, ["AAPL", "MSFT"]);
});

test("rejects arbitrary scheduled prompts and unknown fields", () => {
  assert.throws(() =>
    normalizeAutomationCreate({ kind: "prompt", extra: "run code" })
  );
});

test("rejects minute and hourly generated schedules", () => {
  for (const frequency of ["minute", "hourly"]) {
    assert.throws(() =>
      normalizeAutomationCreate({
        kind: "news_briefing",
        title: "Over-frequent briefing",
        timezone: "America/Chicago",
        start_local: "2026-07-17T07:00:00",
        schedule: { frequency, interval: 1, weekdays: [], ends_at: null },
        config: {
          topics: ["AI"],
          item_count: 5,
          region: "US",
          language: "auto",
          summary_style: "concise",
        },
        source_policy: {
          preferred_domains: [],
          excluded_domains: [],
          freshness_hours: 24,
          require_primary_sources: true,
        },
        delivery_preferences: { push: true },
      }, new Date("2026-07-16T12:00:00Z")), /no more than once per day/);
  }
});

test("rejects recurrence fields on one-time schedules", () => {
  assert.throws(() =>
    normalizeAutomationCreate({
      kind: "news_briefing",
      title: "Invalid one-time briefing",
      timezone: "UTC",
      start_local: "2026-07-17T07:00:00",
      schedule: {
        frequency: "once",
        interval: 1,
        weekdays: [1],
        ends_at: null,
      },
      config: {
        topics: ["AI"],
        item_count: 5,
        region: null,
        language: "auto",
        summary_style: "concise",
      },
      source_policy: {
        preferred_domains: [],
        excluded_domains: [],
        freshness_hours: 24,
        require_primary_sources: true,
      },
      delivery_preferences: { push: true },
    }, new Date("2026-07-16T12:00:00Z")), /One-time Automations/);
});

test("requires a watchlist symbol", () => {
  assert.throws(() =>
    normalizeAutomationCreate({
      kind: "market_briefing",
      title: "Watchlist",
      timezone: "UTC",
      start_local: "2026-07-17T15:30:00",
      schedule: {
        frequency: "daily",
        interval: 1,
        weekdays: [],
        ends_at: null,
      },
      config: {
        session: "close",
        scope: "watchlist",
        symbols: [],
        focus: null,
      },
      source_policy: {
        preferred_domains: [],
        excluded_domains: [],
        freshness_hours: 24,
        require_primary_sources: true,
      },
      delivery_preferences: { push: true },
    }, new Date("2026-07-16T12:00:00Z"))
  );
});

test("computes the next stored Automation occurrence", () => {
  const next = nextAutomationOccurrence({
    startLocal: "2026-07-17T07:00:00",
    timezone: "America/Chicago",
    scheduleRule: {
      frequency: "weekly",
      interval: 2,
      weekdays: [1, 5],
      ends_at: null,
    },
    after: new Date("2026-07-17T12:00:01Z"),
  });
  assert.equal(next?.toISOString(), "2026-07-27T12:00:00.000Z");
});
