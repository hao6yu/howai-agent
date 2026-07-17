import { ReminderValidationError } from "./reminder-recurrence.ts";

const MIN_SNOOZE_MINUTES = 1;
const MAX_SNOOZE_MINUTES = 7 * 24 * 60;

export function snoozeFromNextOccurrence(input: {
  nextFireAt: string;
  minutes: unknown;
  now?: Date;
}): string {
  const minutes = requiredSnoozeMinutes(input.minutes);
  const now = input.now ?? new Date();
  const nextFireAt = new Date(input.nextFireAt);
  if (!Number.isFinite(nextFireAt.getTime())) {
    throw new ReminderValidationError(
      "The reminder's next scheduled time is invalid.",
    );
  }

  const baseTime = Math.max(now.getTime(), nextFireAt.getTime());
  return new Date(baseTime + minutes * 60_000).toISOString();
}

// Compatibility for installed clients that send `now + delay` as an absolute
// timestamp. Recover the intended delay, then apply it to the reminder's next
// occurrence so a future reminder can never be moved backwards.
export function snoozeFromLegacyInstant(input: {
  nextFireAt: string;
  requestedUntil: unknown;
  now?: Date;
}): string {
  if (typeof input.requestedUntil !== "string") {
    throw new ReminderValidationError(
      "snooze_until must be an ISO-8601 timestamp.",
    );
  }
  const now = input.now ?? new Date();
  const requestedUntil = new Date(input.requestedUntil);
  if (
    !Number.isFinite(requestedUntil.getTime()) ||
    requestedUntil.getTime() <= now.getTime()
  ) {
    throw new ReminderValidationError("snooze_until must be in the future.");
  }

  const inferredMinutes = Math.max(
    MIN_SNOOZE_MINUTES,
    Math.round((requestedUntil.getTime() - now.getTime()) / 60_000),
  );
  return snoozeFromNextOccurrence({
    nextFireAt: input.nextFireAt,
    minutes: inferredMinutes,
    now,
  });
}

function requiredSnoozeMinutes(value: unknown): number {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    value < MIN_SNOOZE_MINUTES ||
    value > MAX_SNOOZE_MINUTES
  ) {
    throw new ReminderValidationError(
      `snooze_minutes must be an integer from ${MIN_SNOOZE_MINUTES} to ${MAX_SNOOZE_MINUTES}.`,
    );
  }
  return value;
}
