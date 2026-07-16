import assert from "node:assert/strict";
import test from "node:test";

import {
  describeReminderSchedule,
  localDateTimeToUtc,
  nextOccurrence,
  normalizeReminderSchedule,
  ReminderValidationError,
} from "./reminder-recurrence.ts";

test("normalizes a one-time reminder in an IANA timezone", () => {
  const schedule = normalizeReminderSchedule({
    title: "  Call Mom  ",
    notes: null,
    timezone: "America/Chicago",
    start_local: "2026-07-16T09:30:00",
    recurrence: null,
  }, new Date("2026-07-15T12:00:00Z"));

  assert.equal(schedule.title, "Call Mom");
  assert.equal(schedule.next_fire_at, "2026-07-16T14:30:00.000Z");
  assert.match(describeReminderSchedule(schedule), /Call Mom/);
  assert.match(describeReminderSchedule(schedule), /America\/Chicago/);
});

test("removes model-facing reminder draft suffixes from action titles", () => {
  const schedule = normalizeReminderSchedule({
    title: "Rest reminder draft",
    notes: null,
    timezone: "America/Chicago",
    start_local: "2026-07-16T09:30:00",
    recurrence: null,
  }, new Date("2026-07-15T12:00:00Z"));

  assert.equal(schedule.title, "Rest");
  assert.doesNotMatch(describeReminderSchedule(schedule), /reminder draft/i);
});

test("describes recurring reminders without exposing recurrence JSON", () => {
  const schedule = normalizeReminderSchedule({
    title: "Pick up Madeline",
    notes: null,
    timezone: "America/Chicago",
    start_local: "2026-07-21T15:30:00",
    recurrence: {
      frequency: "weekly",
      interval: 1,
      weekdays: [2],
      day_of_month: null,
      ends_at: "2026-09-21T23:59:59-05:00",
    },
  }, new Date("2026-07-15T12:00:00Z"));

  assert.equal(
    describeReminderSchedule(schedule),
    "Pick up Madeline — every Tue at 3:30 PM until Sep 21, 2026 (America/Chicago)",
  );
});

test("interprets a model-provided local recurrence end in its timezone", () => {
  const dateOnly = normalizeReminderSchedule({
    title: "Pick up my daughter",
    notes: null,
    timezone: "America/Chicago",
    start_local: "2026-07-21T15:30:00",
    recurrence: {
      frequency: "weekly",
      interval: 1,
      weekdays: [2],
      day_of_month: null,
      ends_at: "2026-09-21",
    },
  }, new Date("2026-07-15T18:00:00Z"));
  const localDateTime = normalizeReminderSchedule({
    title: "Pick up my daughter",
    notes: null,
    timezone: "America/Chicago",
    start_local: "2026-07-21T15:30:00",
    recurrence: {
      frequency: "weekly",
      interval: 1,
      weekdays: [2],
      day_of_month: null,
      ends_at: "2026-09-21T15:30:00",
    },
  }, new Date("2026-07-15T18:00:00Z"));

  assert.equal(dateOnly.recurrence?.ends_at, "2026-09-22T04:59:59.000Z");
  assert.equal(
    localDateTime.recurrence?.ends_at,
    "2026-09-21T20:30:00.000Z",
  );
});

test("daily recurrence preserves local wall-clock time across DST", () => {
  const next = nextOccurrence({
    startLocal: "2026-03-07T08:00:00",
    timezone: "America/Chicago",
    recurrence: {
      frequency: "daily",
      interval: 1,
      weekdays: [],
      day_of_month: null,
      ends_at: null,
    },
    after: new Date("2026-03-07T15:00:00Z"),
  });

  assert.equal(next?.toISOString(), "2026-03-08T13:00:00.000Z");
});

test("weekly recurrence honors ISO weekdays and its week interval", () => {
  const next = nextOccurrence({
    startLocal: "2026-07-13T08:00:00",
    timezone: "UTC",
    recurrence: {
      frequency: "weekly",
      interval: 2,
      weekdays: [1, 3],
      day_of_month: null,
      ends_at: null,
    },
    after: new Date("2026-07-13T09:00:00Z"),
  });

  assert.equal(next?.toISOString(), "2026-07-15T08:00:00.000Z");
});

test("monthly recurrence skips months that do not contain the requested day", () => {
  const next = nextOccurrence({
    startLocal: "2026-01-31T08:00:00",
    timezone: "UTC",
    recurrence: {
      frequency: "monthly",
      interval: 1,
      weekdays: [],
      day_of_month: 31,
      ends_at: null,
    },
    after: new Date("2026-01-31T09:00:00Z"),
  });

  assert.equal(next?.toISOString(), "2026-03-31T08:00:00.000Z");
});

test("rejects a local time skipped by a daylight-saving transition", () => {
  assert.throws(
    () =>
      localDateTimeToUtc({
        year: 2026,
        month: 3,
        day: 8,
        hour: 2,
        minute: 30,
        second: 0,
      }, "America/Chicago"),
    (error: unknown) =>
      error instanceof ReminderValidationError &&
      error.code === "nonexistent_local_time",
  );
});

test("rejects unknown fields and invalid recurrence shapes", () => {
  assert.throws(
    () =>
      normalizeReminderSchedule({
        title: "Call Mom",
        notes: null,
        timezone: "UTC",
        start_local: "2026-07-16T09:30:00",
        recurrence: null,
        execute_without_approval: true,
      }, new Date("2026-07-15T12:00:00Z")),
    /Unknown reminder fields/,
  );

  assert.throws(
    () =>
      normalizeReminderSchedule({
        title: "Call Mom",
        notes: null,
        timezone: "UTC",
        start_local: "2026-07-16T09:30:00",
        recurrence: {
          frequency: "weekly",
          interval: 1,
          weekdays: [],
          day_of_month: null,
          ends_at: null,
        },
      }, new Date("2026-07-15T12:00:00Z")),
    /at least one weekday/,
  );

  assert.throws(
    () =>
      normalizeReminderSchedule({
        title: "Weekly review",
        notes: null,
        timezone: "UTC",
        start_local: "2026-07-16T09:30:00",
        recurrence: {
          frequency: "weekly",
          interval: 1,
          weekdays: [1],
          day_of_month: null,
          ends_at: null,
        },
      }, new Date("2026-07-15T12:00:00Z")),
    /must match the selected recurrence/,
  );
});
