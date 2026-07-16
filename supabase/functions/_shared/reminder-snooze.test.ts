import {
  assertEquals,
  assertThrows,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  snoozeFromLegacyInstant,
  snoozeFromNextOccurrence,
} from "./reminder-snooze.ts";

Deno.test("snooze delays a future reminder from its next occurrence", () => {
  const result = snoozeFromNextOccurrence({
    now: new Date("2026-07-16T00:18:00.000Z"),
    nextFireAt: "2026-07-16T13:00:00.000Z",
    minutes: 10,
  });

  assertEquals(result, "2026-07-16T13:10:00.000Z");
});

Deno.test("snooze delays an overdue reminder from now", () => {
  const result = snoozeFromNextOccurrence({
    now: new Date("2026-07-16T00:18:00.000Z"),
    nextFireAt: "2026-07-16T00:00:00.000Z",
    minutes: 10,
  });

  assertEquals(result, "2026-07-16T00:28:00.000Z");
});

Deno.test("legacy now-plus-ten payload still delays the next occurrence", () => {
  const result = snoozeFromLegacyInstant({
    now: new Date("2026-07-16T00:18:00.000Z"),
    nextFireAt: "2026-07-16T13:00:00.000Z",
    requestedUntil: "2026-07-16T00:28:00.000Z",
  });

  assertEquals(result, "2026-07-16T13:10:00.000Z");
});

Deno.test("snooze rejects invalid minute values", () => {
  assertThrows(() =>
    snoozeFromNextOccurrence({
      now: new Date("2026-07-16T00:18:00.000Z"),
      nextFireAt: "2026-07-16T13:00:00.000Z",
      minutes: 0,
    })
  );
});
