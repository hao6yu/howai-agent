import {
  nextOccurrence,
  normalizeRecurrence,
  type ReminderRecurrence,
  ReminderValidationError,
} from "./reminder-recurrence.ts";

export type AutomationKind = "news_briefing" | "market_briefing";

export type NormalizedAutomationCreate = Readonly<{
  kind: AutomationKind;
  title: string;
  timezone: string;
  start_local: string;
  schedule_rule: Record<string, unknown>;
  next_run_at: string;
  config: Record<string, unknown>;
  source_policy: Record<string, unknown>;
  delivery_preferences: Record<string, unknown>;
}>;

const LOCAL_DATE_TIME = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2})?$/;
const DOMAIN = /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$/i;
const SYMBOL = /^[A-Z][A-Z0-9.-]{0,9}$/;

export function normalizeAutomationCreate(
  value: unknown,
  now = new Date(),
): NormalizedAutomationCreate {
  if (!isRecord(value)) {
    throw invalid("Automation arguments must be an object.");
  }
  rejectUnknown(
    value,
    new Set([
      "kind",
      "title",
      "timezone",
      "start_local",
      "schedule",
      "config",
      "source_policy",
      "delivery_preferences",
    ]),
  );

  const kind = value.kind;
  if (kind !== "news_briefing" && kind !== "market_briefing") {
    throw invalid("kind must be news_briefing or market_briefing.");
  }
  const title = requiredText(value.title, "title", 200);
  const timezone = requiredText(value.timezone, "timezone", 128);
  validateTimezone(timezone);
  const startLocal = normalizeStartLocal(value.start_local);
  const scheduleRule = normalizeSchedule(value.schedule, timezone);
  const recurrence = recurrenceForSchedule(scheduleRule, timezone);
  const next = nextOccurrence({
    startLocal,
    timezone,
    recurrence,
    after: now,
    includeStart: true,
  });
  if (!next) {
    throw invalid(
      "This Automation has no future occurrence.",
      "schedule_in_past",
    );
  }

  const config = kind === "news_briefing"
    ? normalizeNewsConfig(value.config)
    : normalizeMarketConfig(value.config);
  const sourcePolicy = normalizeSourcePolicy(value.source_policy);
  const deliveryPreferences = normalizeDelivery(value.delivery_preferences);

  return {
    kind,
    title,
    timezone,
    start_local: startLocal,
    schedule_rule: scheduleRule,
    next_run_at: next.toISOString(),
    config,
    source_policy: sourcePolicy,
    delivery_preferences: deliveryPreferences,
  };
}

export function describeAutomation(value: NormalizedAutomationCreate): string {
  const type = value.kind === "news_briefing"
    ? "News briefing"
    : "Market briefing";
  const scope = value.kind === "news_briefing"
    ? (value.config.topics as string[]).join(", ")
    : value.config.scope === "watchlist"
    ? (value.config.symbols as string[]).join(", ")
    : "U.S. market";
  const cadence = describeSchedule(value.schedule_rule);
  return `${type}: ${value.title} — ${scope} — ${cadence} (${value.timezone})`;
}

export function nextAutomationOccurrence(input: {
  startLocal: string;
  timezone: string;
  scheduleRule: Record<string, unknown>;
  after: Date;
}): Date | null {
  return nextOccurrence({
    startLocal: input.startLocal.replace(" ", "T").replace(/\.\d+$/, ""),
    timezone: input.timezone,
    recurrence: recurrenceForSchedule(input.scheduleRule, input.timezone),
    after: input.after,
    includeStart: false,
  });
}

function normalizeSchedule(
  value: unknown,
  timezone: string,
): Record<string, unknown> {
  if (!isRecord(value)) throw invalid("schedule must be an object.");
  rejectUnknown(
    value,
    new Set(["frequency", "interval", "weekdays", "ends_at"]),
  );
  const frequency = value.frequency;
  if (
    typeof frequency === "string" &&
    ["second", "secondly", "minute", "minutely", "hour", "hourly"].includes(
      frequency.toLowerCase(),
    )
  ) {
    throw invalid(
      "Generated Automations can run no more than once per day.",
      "automation_cadence_too_frequent",
    );
  }
  if (
    frequency !== "once" && frequency !== "daily" && frequency !== "weekly" &&
    frequency !== "market_days"
  ) {
    throw invalid(
      "schedule.frequency must be once, daily, weekly, or market_days.",
    );
  }
  const interval = integer(
    value.interval,
    "schedule.interval",
    1,
    frequency === "once" ? 1 : frequency === "weekly" ? 52 : 365,
  );
  const rawWeekdays = value.weekdays;
  if (
    !Array.isArray(rawWeekdays) ||
    rawWeekdays.some((day) =>
      !Number.isInteger(day) || Number(day) < 1 || Number(day) > 7
    )
  ) {
    throw invalid("schedule.weekdays must contain ISO weekdays from 1 to 7.");
  }
  let weekdays = [...new Set(rawWeekdays.map(Number))].sort((a, b) => a - b);
  if (frequency === "weekly" && weekdays.length === 0) {
    throw invalid("Weekly Automations require at least one weekday.");
  }
  if (frequency === "daily" && weekdays.length > 0) {
    throw invalid("Daily Automations cannot include weekdays.");
  }
  if (
    frequency === "once" &&
    (interval !== 1 || weekdays.length > 0 || value.ends_at != null)
  ) {
    throw invalid(
      "One-time Automations require interval 1, no weekdays, and no end date.",
    );
  }
  if (frequency === "market_days") weekdays = [1, 2, 3, 4, 5];
  const endsAt = frequency === "once" || value.ends_at == null
    ? null
    : normalizeRecurrence({
      frequency: frequency === "daily" ? "daily" : "weekly",
      interval,
      weekdays: frequency === "daily" ? [] : weekdays,
      day_of_month: null,
      ends_at: value.ends_at,
    }, timezone)?.ends_at ?? null;
  return { frequency, interval, weekdays, ends_at: endsAt };
}

function recurrenceForSchedule(
  schedule: Record<string, unknown>,
  timezone: string,
): ReminderRecurrence | null {
  if (schedule.frequency === "once") return null;
  const frequency = schedule.frequency === "daily" ? "daily" : "weekly";
  return normalizeRecurrence({
    frequency,
    interval: schedule.interval,
    weekdays: frequency === "daily" ? [] : schedule.weekdays,
    day_of_month: null,
    ends_at: schedule.ends_at,
  }, timezone)!;
}

function normalizeNewsConfig(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) {
    throw invalid("News briefing config must be an object.");
  }
  rejectUnknown(
    value,
    new Set(["topics", "item_count", "region", "language", "summary_style"]),
  );
  const topics = stringList(value.topics, "config.topics", 1, 10, 80);
  const itemCount = integer(value.item_count, "config.item_count", 1, 10);
  const region = optionalText(value.region, "config.region", 40);
  const language = requiredText(value.language, "config.language", 40);
  const style = value.summary_style;
  if (style !== "concise" && style !== "balanced") {
    throw invalid("config.summary_style must be concise or balanced.");
  }
  return {
    topics,
    item_count: itemCount,
    region,
    language,
    summary_style: style,
  };
}

function normalizeMarketConfig(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) {
    throw invalid("Market briefing config must be an object.");
  }
  rejectUnknown(value, new Set(["session", "scope", "symbols", "focus"]));
  const session = value.session;
  if (session !== "open" && session !== "close" && session !== "daily") {
    throw invalid("config.session must be open, close, or daily.");
  }
  const scope = value.scope;
  if (scope !== "us_market" && scope !== "watchlist") {
    throw invalid("config.scope must be us_market or watchlist.");
  }
  const symbols = stringList(
    value.symbols,
    "config.symbols",
    scope === "watchlist" ? 1 : 0,
    20,
    10,
  )
    .map((symbol) => symbol.toUpperCase());
  if (symbols.some((symbol) => !SYMBOL.test(symbol))) {
    throw invalid("config.symbols contains an invalid market symbol.");
  }
  const focus = optionalText(value.focus, "config.focus", 200);
  return { session, scope, symbols, focus };
}

function normalizeSourcePolicy(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) throw invalid("source_policy must be an object.");
  rejectUnknown(
    value,
    new Set([
      "preferred_domains",
      "excluded_domains",
      "freshness_hours",
      "require_primary_sources",
    ]),
  );
  const preferred = stringList(
    value.preferred_domains,
    "source_policy.preferred_domains",
    0,
    10,
    253,
  ).map(normalizeDomain);
  const excluded = stringList(
    value.excluded_domains,
    "source_policy.excluded_domains",
    0,
    20,
    253,
  ).map(normalizeDomain);
  const freshness = integer(
    value.freshness_hours,
    "source_policy.freshness_hours",
    1,
    168,
  );
  if (typeof value.require_primary_sources !== "boolean") {
    throw invalid("source_policy.require_primary_sources must be a boolean.");
  }
  return {
    preferred_domains: [...new Set(preferred)],
    excluded_domains: [...new Set(excluded)],
    freshness_hours: freshness,
    require_primary_sources: value.require_primary_sources,
  };
}

function normalizeDelivery(value: unknown): Record<string, unknown> {
  if (!isRecord(value)) {
    throw invalid("delivery_preferences must be an object.");
  }
  rejectUnknown(value, new Set(["push"]));
  if (typeof value.push !== "boolean") {
    throw invalid("delivery_preferences.push must be a boolean.");
  }
  return { push: value.push };
}

function describeSchedule(schedule: Record<string, unknown>): string {
  if (schedule.frequency === "once") return "one time";
  if (schedule.frequency === "daily") {
    return schedule.interval === 1
      ? "daily"
      : `every ${schedule.interval} days`;
  }
  const days = (schedule.weekdays as number[]).map((day) =>
    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day - 1]
  ).join(", ");
  if (schedule.frequency === "market_days") return "on market days";
  return schedule.interval === 1
    ? `every ${days}`
    : `every ${schedule.interval} weeks on ${days}`;
}

function normalizeStartLocal(value: unknown): string {
  if (typeof value !== "string" || !LOCAL_DATE_TIME.test(value)) {
    throw invalid(
      "start_local must use YYYY-MM-DDTHH:mm:ss without an offset.",
    );
  }
  return value.length === 16 ? `${value}:00` : value;
}

function normalizeDomain(value: string): string {
  const domain = value.trim().toLowerCase().replace(/^https?:\/\//, "").replace(
    /\/$/,
    "",
  );
  if (!DOMAIN.test(domain)) {
    throw invalid("Source domains must be host names without paths.");
  }
  return domain;
}

function validateTimezone(timezone: string): void {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: timezone }).format(new Date());
  } catch {
    throw invalid("timezone must be a valid IANA timezone.");
  }
}

function stringList(
  value: unknown,
  field: string,
  min: number,
  max: number,
  itemMax: number,
): string[] {
  if (!Array.isArray(value) || value.length < min || value.length > max) {
    throw invalid(`${field} must contain between ${min} and ${max} items.`);
  }
  return value.map((item) => requiredText(item, field, itemMax));
}

function requiredText(value: unknown, field: string, max: number): string {
  if (
    typeof value !== "string" || value.trim().length === 0 ||
    value.trim().length > max
  ) {
    throw invalid(
      `${field} must be a non-empty string of at most ${max} characters.`,
    );
  }
  return value.trim();
}

function optionalText(
  value: unknown,
  field: string,
  max: number,
): string | null {
  if (value == null) return null;
  return requiredText(value, field, max);
}

function integer(
  value: unknown,
  field: string,
  min: number,
  max: number,
): number {
  if (!Number.isInteger(value) || Number(value) < min || Number(value) > max) {
    throw invalid(`${field} must be an integer from ${min} to ${max}.`);
  }
  return Number(value);
}

function rejectUnknown(
  value: Record<string, unknown>,
  allowed: Set<string>,
): void {
  const unknown = Object.keys(value).filter((key) => !allowed.has(key));
  if (unknown.length) {
    throw invalid(`Unknown Automation fields: ${unknown.join(", ")}.`);
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function invalid(
  message: string,
  code = "invalid_automation",
): ReminderValidationError {
  return new ReminderValidationError(message, code);
}
