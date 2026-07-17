export type RealtimeVoiceCohort = "anonymous" | "free" | "paid";
export type RealtimeVoiceMode = "off" | "internal" | "full";

export type RealtimeVoicePolicy = Readonly<{
  mode: RealtimeVoiceMode;
  model: string;
  defaultVoice: string;
  allowedVoices: ReadonlySet<string>;
  dailySessionLimits: Readonly<Record<RealtimeVoiceCohort, number>>;
  maxSessionSeconds: Readonly<Record<RealtimeVoiceCohort, number>>;
}>;

export const DEFAULT_REALTIME_VOICE_POLICY: RealtimeVoicePolicy = Object.freeze(
  {
    mode: "off",
    model: "gpt-realtime-2.1",
    defaultVoice: "marin",
    allowedVoices: new Set(["marin", "cedar"]),
    dailySessionLimits: Object.freeze({
      anonymous: 2,
      free: 3,
      paid: 20,
    }),
    maxSessionSeconds: Object.freeze({
      anonymous: 120,
      free: 240,
      paid: 600,
    }),
  },
);

export const REALTIME_VOICE_VISION_INSTRUCTIONS = [
  "When camera vision is on, treat it as a live visual conversation and respond as though you are looking alongside the user.",
  "Describe only what is visibly supported now, but do not mention snapshots, frames, sampling, continuous video, or motion limitations unless the user directly asks how the technology works.",
  "If text, objects, hazards, or repair details are unclear, say what you cannot make out and naturally ask the user to move closer, reframe, improve the lighting, or hold the camera steady.",
  "Do not infer sensitive traits about people from camera input.",
].join(" ");

function boundedInteger(
  value: unknown,
  fallback: number,
  minimum: number,
  maximum: number,
): number {
  return typeof value === "number" && Number.isInteger(value) &&
      value >= minimum && value <= maximum
    ? value
    : fallback;
}

function boundedString(
  value: unknown,
  fallback: string,
  maximumLength: number,
): string {
  return typeof value === "string" && value.trim().length > 0 &&
      value.trim().length <= maximumLength
    ? value.trim()
    : fallback;
}

export function parseRealtimeVoicePolicy(
  payload: unknown,
): RealtimeVoicePolicy {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return DEFAULT_REALTIME_VOICE_POLICY;
  }

  const record = payload as Record<string, unknown>;
  const mode: RealtimeVoiceMode = record.mode === "internal" ||
      record.mode === "full"
    ? record.mode
    : "off";
  const model = boundedString(
    record.model,
    DEFAULT_REALTIME_VOICE_POLICY.model,
    100,
  );

  const rawVoices = Array.isArray(record.allowed_voices)
    ? record.allowed_voices
      .filter((value): value is string =>
        typeof value === "string" && /^[a-z][a-z0-9_-]{1,49}$/.test(value)
      )
      .slice(0, 12)
    : [];
  const allowedVoices = new Set(
    rawVoices.length > 0
      ? rawVoices
      : DEFAULT_REALTIME_VOICE_POLICY.allowedVoices,
  );
  const requestedDefault = boundedString(
    record.default_voice,
    DEFAULT_REALTIME_VOICE_POLICY.defaultVoice,
    50,
  );
  const defaultVoice = allowedVoices.has(requestedDefault)
    ? requestedDefault
    : [...allowedVoices][0] ?? DEFAULT_REALTIME_VOICE_POLICY.defaultVoice;

  return Object.freeze({
    mode,
    model,
    defaultVoice,
    allowedVoices,
    dailySessionLimits: Object.freeze({
      anonymous: boundedInteger(
        record.anonymous_daily_sessions,
        DEFAULT_REALTIME_VOICE_POLICY.dailySessionLimits.anonymous,
        1,
        100,
      ),
      free: boundedInteger(
        record.free_daily_sessions,
        DEFAULT_REALTIME_VOICE_POLICY.dailySessionLimits.free,
        1,
        100,
      ),
      paid: boundedInteger(
        record.paid_daily_sessions,
        DEFAULT_REALTIME_VOICE_POLICY.dailySessionLimits.paid,
        1,
        100,
      ),
    }),
    maxSessionSeconds: Object.freeze({
      anonymous: boundedInteger(
        record.anonymous_max_session_seconds,
        DEFAULT_REALTIME_VOICE_POLICY.maxSessionSeconds.anonymous,
        30,
        3600,
      ),
      free: boundedInteger(
        record.free_max_session_seconds,
        DEFAULT_REALTIME_VOICE_POLICY.maxSessionSeconds.free,
        30,
        3600,
      ),
      paid: boundedInteger(
        record.paid_max_session_seconds,
        DEFAULT_REALTIME_VOICE_POLICY.maxSessionSeconds.paid,
        30,
        3600,
      ),
    }),
  });
}

export function realtimeVoiceEnabledForUser(
  flagEnabled: boolean,
  policy: RealtimeVoicePolicy,
  internalCanary: boolean,
): boolean {
  if (!flagEnabled) return false;
  if (policy.mode === "full") return true;
  return policy.mode === "internal" && internalCanary;
}

export function selectRealtimeVoice(
  requestedVoice: unknown,
  policy: RealtimeVoicePolicy,
): string {
  if (typeof requestedVoice !== "string") return policy.defaultVoice;
  const normalized = requestedVoice.trim().toLowerCase();
  return policy.allowedVoices.has(normalized)
    ? normalized
    : policy.defaultVoice;
}

export function realtimeVoiceAudioInputConfiguration() {
  return {
    noise_reduction: { type: "far_field" },
    transcription: { model: "gpt-4o-mini-transcribe" },
    turn_detection: {
      type: "server_vad",
      threshold: 0.6,
      prefix_padding_ms: 300,
      silence_duration_ms: 450,
      create_response: true,
      interrupt_response: true,
    },
  } as const;
}

export async function createRealtimeSafetyIdentifier(
  userId: string,
  salt: string,
): Promise<string> {
  const bytes = new TextEncoder().encode(`${salt}:${userId}`);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((value) => value.toString(16).padStart(2, "0"))
    .join("");
}
