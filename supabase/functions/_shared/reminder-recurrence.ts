export type ReminderFrequency = "daily" | "weekly" | "monthly";

export type ReminderRecurrence = Readonly<{
  frequency: ReminderFrequency;
  interval: number;
  weekdays: readonly number[];
  day_of_month: number | null;
  ends_at: string | null;
}>;

export type NormalizedReminderSchedule = Readonly<{
  title: string;
  notes: string | null;
  timezone: string;
  start_local: string;
  next_fire_at: string;
  recurrence: ReminderRecurrence | null;
}>;

type LocalParts = Readonly<{
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}>;

export class ReminderValidationError extends Error {
  constructor(
    message: string,
    readonly code = "invalid_reminder",
  ) {
    super(message);
    this.name = "ReminderValidationError";
  }
}

const LOCAL_DATE_TIME =
  /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2}))?$/;
const ALLOWED_RECURRENCE_KEYS = new Set([
  "frequency",
  "interval",
  "weekdays",
  "day_of_month",
  "ends_at",
]);

export function normalizeReminderSchedule(
  value: unknown,
  now = new Date(),
): NormalizedReminderSchedule {
  if (!isRecord(value)) {
    throw new ReminderValidationError("Reminder arguments must be an object.");
  }
  rejectUnknownKeys(
    value,
    new Set([
      "title",
      "notes",
      "timezone",
      "start_local",
      "recurrence",
    ]),
  );

  const title = requiredText(value.title, "title", 200);
  const notes = optionalText(value.notes, "notes", 4_000);
  const timezone = requiredText(value.timezone, "timezone", 128);
  validateTimezone(timezone);
  const startLocal = normalizeLocalDateTime(value.start_local);
  const recurrence = normalizeRecurrence(value.recurrence);
  if (!startMatchesRecurrence(parseLocalDateTime(startLocal), recurrence)) {
    throw new ReminderValidationError(
      "start_local must match the selected recurrence weekday or month date.",
      "recurrence_start_mismatch",
    );
  }
  const nextFireAt = nextOccurrence({
    startLocal,
    timezone,
    recurrence,
    after: now,
    includeStart: true,
  });

  if (!nextFireAt) {
    throw new ReminderValidationError(
      recurrence == null
        ? "A one-time reminder must be scheduled in the future."
        : "This recurrence has no future occurrence.",
      "schedule_in_past",
    );
  }

  return {
    title,
    notes,
    timezone,
    start_local: startLocal,
    next_fire_at: nextFireAt.toISOString(),
    recurrence,
  };
}

export function normalizeRecurrence(value: unknown): ReminderRecurrence | null {
  if (value == null) return null;
  if (!isRecord(value)) {
    throw new ReminderValidationError("recurrence must be an object or null.");
  }
  rejectUnknownKeys(value, ALLOWED_RECURRENCE_KEYS);

  const frequency = value.frequency;
  if (
    frequency !== "daily" && frequency !== "weekly" && frequency !== "monthly"
  ) {
    throw new ReminderValidationError(
      "recurrence.frequency must be daily, weekly, or monthly.",
    );
  }

  const interval = integer(value.interval, "recurrence.interval");
  const maxInterval = frequency === "daily"
    ? 365
    : frequency === "weekly"
    ? 52
    : 12;
  if (interval < 1 || interval > maxInterval) {
    throw new ReminderValidationError(
      `recurrence.interval must be between 1 and ${maxInterval}.`,
    );
  }

  if (
    !Array.isArray(value.weekdays) ||
    value.weekdays.some((day) =>
      !Number.isInteger(day) || Number(day) < 1 || Number(day) > 7
    )
  ) {
    throw new ReminderValidationError(
      "recurrence.weekdays must contain ISO weekday numbers from 1 to 7.",
    );
  }
  const weekdays = [...new Set(value.weekdays.map(Number))].sort((a, b) =>
    a - b
  );
  if (frequency === "weekly" && weekdays.length === 0) {
    throw new ReminderValidationError(
      "Weekly reminders require at least one weekday.",
    );
  }
  if (frequency !== "weekly" && weekdays.length > 0) {
    throw new ReminderValidationError(
      "Only weekly reminders may include weekdays.",
    );
  }

  const dayOfMonth = value.day_of_month == null
    ? null
    : integer(value.day_of_month, "recurrence.day_of_month");
  if (frequency === "monthly") {
    if (dayOfMonth == null || dayOfMonth < 1 || dayOfMonth > 31) {
      throw new ReminderValidationError(
        "Monthly reminders require a day_of_month from 1 to 31.",
      );
    }
  } else if (dayOfMonth != null) {
    throw new ReminderValidationError(
      "Only monthly reminders may include day_of_month.",
    );
  }

  const endsAt = value.ends_at == null
    ? null
    : normalizeInstant(value.ends_at, "recurrence.ends_at");

  return {
    frequency,
    interval,
    weekdays,
    day_of_month: dayOfMonth,
    ends_at: endsAt,
  };
}

export function nextOccurrence(input: {
  startLocal: string;
  timezone: string;
  recurrence: ReminderRecurrence | null;
  after: Date;
  includeStart?: boolean;
}): Date | null {
  const start = parseLocalDateTime(input.startLocal);
  validateTimezone(input.timezone);
  const startInstant = localDateTimeToUtc(start, input.timezone);
  const threshold = input.includeStart
    ? input.after.getTime()
    : input.after.getTime() + 1;

  if (
    startInstant.getTime() >= threshold &&
    startMatchesRecurrence(start, input.recurrence) &&
    withinEnd(startInstant, input.recurrence)
  ) {
    return startInstant;
  }
  if (!input.recurrence) return null;

  const recurrence = input.recurrence;
  let candidate: Date | null = null;

  if (recurrence.frequency === "daily") {
    for (
      let offset = recurrence.interval;
      offset <= 366 * 20;
      offset += recurrence.interval
    ) {
      const local = addLocalDays(start, offset);
      candidate = localDateTimeToUtc(local, input.timezone);
      if (candidate.getTime() >= threshold) break;
    }
  } else if (recurrence.frequency === "weekly") {
    const startDate = Date.UTC(start.year, start.month - 1, start.day);
    const startMonday = startDate - (isoWeekday(start) - 1) * 86_400_000;
    for (let offset = 1; offset <= 366 * 20; offset++) {
      const local = addLocalDays(start, offset);
      const localDate = Date.UTC(local.year, local.month - 1, local.day);
      const localMonday = localDate - (isoWeekday(local) - 1) * 86_400_000;
      const weekOffset = Math.floor(
        (localMonday - startMonday) / (7 * 86_400_000),
      );
      if (
        weekOffset >= 0 &&
        weekOffset % recurrence.interval === 0 &&
        recurrence.weekdays.includes(isoWeekday(local))
      ) {
        const instant = localDateTimeToUtc(local, input.timezone);
        if (instant.getTime() >= threshold) {
          candidate = instant;
          break;
        }
      }
    }
  } else {
    for (
      let monthOffset = recurrence.interval;
      monthOffset <= 12 * 20;
      monthOffset += recurrence.interval
    ) {
      const monthIndex = start.month - 1 + monthOffset;
      const year = start.year + Math.floor(monthIndex / 12);
      const month = ((monthIndex % 12) + 12) % 12 + 1;
      const day = recurrence.day_of_month!;
      if (day > daysInMonth(year, month)) continue;
      const instant = localDateTimeToUtc(
        { ...start, year, month, day },
        input.timezone,
      );
      if (instant.getTime() >= threshold) {
        candidate = instant;
        break;
      }
    }
  }

  return candidate && withinEnd(candidate, recurrence) ? candidate : null;
}

export function describeReminderSchedule(
  schedule: NormalizedReminderSchedule,
): string {
  const next = new Date(schedule.next_fire_at);
  const date = new Intl.DateTimeFormat("en-US", {
    timeZone: schedule.timezone,
    weekday: "short",
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(next);

  if (!schedule.recurrence) {
    return `${schedule.title} — ${date} (${schedule.timezone})`;
  }

  const recurrence = schedule.recurrence;
  const time = new Intl.DateTimeFormat("en-US", {
    timeZone: schedule.timezone,
    hour: "numeric",
    minute: "2-digit",
  }).format(next);
  let cadence: string;
  if (recurrence.frequency === "daily") {
    cadence = recurrence.interval === 1
      ? "every day"
      : `every ${recurrence.interval} days`;
  } else if (recurrence.frequency === "weekly") {
    const names = recurrence.weekdays.map(weekdayName).join(", ");
    cadence = recurrence.interval === 1
      ? `every ${names}`
      : `every ${recurrence.interval} weeks on ${names}`;
  } else {
    cadence = recurrence.interval === 1
      ? `monthly on day ${recurrence.day_of_month}`
      : `every ${recurrence.interval} months on day ${recurrence.day_of_month}`;
  }
  return `${schedule.title} — ${cadence} at ${time} (${schedule.timezone})`;
}

export function localDateTimeToUtc(
  local: LocalParts,
  timezone: string,
): Date {
  validateLocalParts(local);
  let guess = Date.UTC(
    local.year,
    local.month - 1,
    local.day,
    local.hour,
    local.minute,
    local.second,
  );
  const desired = guess;

  for (let attempt = 0; attempt < 5; attempt++) {
    const rendered = partsInTimezone(new Date(guess), timezone);
    const renderedAsUtc = Date.UTC(
      rendered.year,
      rendered.month - 1,
      rendered.day,
      rendered.hour,
      rendered.minute,
      rendered.second,
    );
    const correction = desired - renderedAsUtc;
    if (correction === 0) {
      const result = new Date(guess);
      if (sameLocalParts(partsInTimezone(result, timezone), local)) {
        return result;
      }
      break;
    }
    guess += correction;
  }

  throw new ReminderValidationError(
    "The selected local time does not exist in that timezone because of a clock change.",
    "nonexistent_local_time",
  );
}

function normalizeLocalDateTime(value: unknown): string {
  if (typeof value !== "string") {
    throw new ReminderValidationError(
      "start_local must use YYYY-MM-DDTHH:mm:ss without a timezone offset.",
    );
  }
  const parts = parseLocalDateTime(value);
  return [
    String(parts.year).padStart(4, "0"),
    "-",
    String(parts.month).padStart(2, "0"),
    "-",
    String(parts.day).padStart(2, "0"),
    "T",
    String(parts.hour).padStart(2, "0"),
    ":",
    String(parts.minute).padStart(2, "0"),
    ":",
    String(parts.second).padStart(2, "0"),
  ].join("");
}

function parseLocalDateTime(value: string): LocalParts {
  const match = LOCAL_DATE_TIME.exec(value);
  if (!match) {
    throw new ReminderValidationError(
      "start_local must use YYYY-MM-DDTHH:mm:ss without a timezone offset.",
    );
  }
  const parts = {
    year: Number(match[1]),
    month: Number(match[2]),
    day: Number(match[3]),
    hour: Number(match[4]),
    minute: Number(match[5]),
    second: Number(match[6] ?? 0),
  };
  validateLocalParts(parts);
  return parts;
}

function validateLocalParts(parts: LocalParts): void {
  const utc = new Date(Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
  ));
  if (
    utc.getUTCFullYear() !== parts.year ||
    utc.getUTCMonth() + 1 !== parts.month ||
    utc.getUTCDate() !== parts.day ||
    utc.getUTCHours() !== parts.hour ||
    utc.getUTCMinutes() !== parts.minute ||
    utc.getUTCSeconds() !== parts.second
  ) {
    throw new ReminderValidationError(
      "start_local is not a valid calendar time.",
    );
  }
}

function validateTimezone(timezone: string): void {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: timezone }).format(new Date());
  } catch {
    throw new ReminderValidationError(
      "timezone must be a valid IANA timezone identifier.",
      "invalid_timezone",
    );
  }
}

function partsInTimezone(date: Date, timezone: string): LocalParts {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const value = (type: Intl.DateTimeFormatPartTypes) =>
    Number(parts.find((part) => part.type === type)?.value);
  return {
    year: value("year"),
    month: value("month"),
    day: value("day"),
    hour: value("hour"),
    minute: value("minute"),
    second: value("second"),
  };
}

function addLocalDays(parts: LocalParts, days: number): LocalParts {
  const date = new Date(
    Date.UTC(parts.year, parts.month - 1, parts.day + days),
  );
  return {
    ...parts,
    year: date.getUTCFullYear(),
    month: date.getUTCMonth() + 1,
    day: date.getUTCDate(),
  };
}

function isoWeekday(parts: Pick<LocalParts, "year" | "month" | "day">): number {
  const day = new Date(Date.UTC(parts.year, parts.month - 1, parts.day))
    .getUTCDay();
  return day === 0 ? 7 : day;
}

function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

function withinEnd(date: Date, recurrence: ReminderRecurrence | null): boolean {
  return recurrence?.ends_at == null ||
    date.getTime() <= Date.parse(recurrence.ends_at);
}

function startMatchesRecurrence(
  start: LocalParts,
  recurrence: ReminderRecurrence | null,
): boolean {
  if (!recurrence || recurrence.frequency === "daily") return true;
  if (recurrence.frequency === "weekly") {
    return recurrence.weekdays.includes(isoWeekday(start));
  }
  return recurrence.day_of_month === start.day;
}

function normalizeInstant(value: unknown, field: string): string {
  if (typeof value !== "string") {
    throw new ReminderValidationError(
      `${field} must be an ISO-8601 timestamp or null.`,
    );
  }
  const date = new Date(value);
  if (!Number.isFinite(date.getTime()) || !/(Z|[+-]\d{2}:\d{2})$/.test(value)) {
    throw new ReminderValidationError(
      `${field} must include a timezone offset.`,
    );
  }
  return date.toISOString();
}

function requiredText(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new ReminderValidationError(`${field} must be a non-empty string.`);
  }
  const normalized = value.trim();
  if (normalized.length > max) {
    throw new ReminderValidationError(`${field} is too long.`);
  }
  return normalized;
}

function optionalText(
  value: unknown,
  field: string,
  max: number,
): string | null {
  if (value == null || value === "") return null;
  if (typeof value !== "string") {
    throw new ReminderValidationError(`${field} must be a string or null.`);
  }
  const normalized = value.trim();
  if (normalized.length > max) {
    throw new ReminderValidationError(`${field} is too long.`);
  }
  return normalized || null;
}

function integer(value: unknown, field: string): number {
  if (!Number.isInteger(value)) {
    throw new ReminderValidationError(`${field} must be an integer.`);
  }
  return Number(value);
}

function rejectUnknownKeys(
  value: Record<string, unknown>,
  allowed: ReadonlySet<string>,
): void {
  const unknown = Object.keys(value).filter((key) => !allowed.has(key));
  if (unknown.length > 0) {
    throw new ReminderValidationError(
      `Unknown reminder fields: ${unknown.join(", ")}.`,
    );
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

function sameLocalParts(left: LocalParts, right: LocalParts): boolean {
  return left.year === right.year && left.month === right.month &&
    left.day === right.day && left.hour === right.hour &&
    left.minute === right.minute && left.second === right.second;
}

function weekdayName(day: number): string {
  return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day - 1];
}
