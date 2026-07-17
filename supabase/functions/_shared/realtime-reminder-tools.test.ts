import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  buildRealtimeReminderTools,
  type RealtimeReminder,
  realtimeReminderContext,
} from "./realtime-reminder-tools.ts";

const reminder = (
  id: string,
  status: RealtimeReminder["status"],
): RealtimeReminder => ({
  id,
  title: `Reminder ${id}`,
  notes: null,
  timezone: "America/Chicago",
  start_local: "2026-07-17T08:00:00",
  recurrence_rule: null,
  status,
  version: 2,
});

Deno.test("voice always offers create and only relevant management tools", () => {
  const tools = buildRealtimeReminderTools([
    reminder("active", "active"),
    reminder("paused", "paused"),
    reminder("done", "completed"),
  ]);
  assertEquals(
    tools.map((tool) => tool.name),
    [
      "reminders_create",
      "reminders_update",
      "reminders_resume",
      "actions_confirm_pending",
      "actions_cancel_pending",
    ],
  );
  const encoded = JSON.stringify(tools);
  assert(encoded.includes("active"));
  assert(encoded.includes("paused"));
  assert(!encoded.includes("done"));
});

Deno.test("voice with no saved reminders exposes only safe proposal creation", () => {
  const tools = buildRealtimeReminderTools([]);
  assertEquals(tools.map((tool) => tool.name), [
    "reminders_create",
    "actions_confirm_pending",
    "actions_cancel_pending",
  ]);
  assertEquals(
    realtimeReminderContext([]),
    "The user has no active or paused reminders.",
  );
});

Deno.test("voice confirmation tools require the exact pending proposal id", () => {
  const tools = buildRealtimeReminderTools([]);
  const confirm = tools.find((tool) => tool.name === "actions_confirm_pending");
  const cancel = tools.find((tool) => tool.name === "actions_cancel_pending");
  assertEquals(
    (confirm?.parameters as Record<string, unknown>)?.required,
    ["proposal_id"],
  );
  assertEquals(
    (cancel?.parameters as Record<string, unknown>)?.required,
    ["proposal_id", "intent"],
  );
});

Deno.test("trusted reminder context excludes completed reminders", () => {
  const context = realtimeReminderContext([
    reminder("active", "active"),
    reminder("done", "completed"),
  ]);
  assert(context.includes("active"));
  assert(!context.includes("done"));
  assert(context.includes('"version":2'));
});
