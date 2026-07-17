export type ModelPolicyRolloutMode = "off" | "internal" | "percentage";
export type ModelPolicyRolloutCohort = "legacy" | "internal" | "percentage";

export type ModelPolicyRolloutConfig = Readonly<{
  mode: ModelPolicyRolloutMode;
  rolloutPercent: number;
  rolloutSalt: string;
}>;

export type ModelPolicyRolloutDecision = Readonly<{
  active: boolean;
  cohort: ModelPolicyRolloutCohort;
  bucket: number;
  rolloutPercent: number;
}>;

export const DEFAULT_MODEL_POLICY_ROLLOUT: ModelPolicyRolloutConfig = Object.freeze({
  mode: "off",
  rolloutPercent: 0,
  rolloutSalt: "gpt56-m1-v1",
});

export function parseModelPolicyRollout(
  payload: unknown,
): ModelPolicyRolloutConfig {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return DEFAULT_MODEL_POLICY_ROLLOUT;
  }

  const record = payload as Record<string, unknown>;
  const mode = record.mode === "internal" || record.mode === "percentage"
    ? record.mode
    : "off";
  const rawPercent = record.rollout_percent;
  const rolloutPercent = typeof rawPercent === "number" &&
      Number.isInteger(rawPercent) && rawPercent >= 0 && rawPercent <= 100
    ? rawPercent
    : 0;
  const rawSalt = record.rollout_salt;
  const rolloutSalt = typeof rawSalt === "string" &&
      rawSalt.length >= 1 && rawSalt.length <= 64
    ? rawSalt
    : DEFAULT_MODEL_POLICY_ROLLOUT.rolloutSalt;

  return Object.freeze({ mode, rolloutPercent, rolloutSalt });
}

export function modelPolicyRolloutBucket(userId: string, salt: string): number {
  const bytes = new TextEncoder().encode(`${salt}:${userId}`);
  let hash = 0x811c9dc5;

  for (const byte of bytes) {
    hash ^= byte;
    hash = Math.imul(hash, 0x01000193);
  }

  return (hash >>> 0) % 10_000;
}

export function resolveModelPolicyRollout(
  userId: string,
  internalCanary: boolean,
  config: ModelPolicyRolloutConfig,
): ModelPolicyRolloutDecision {
  const bucket = modelPolicyRolloutBucket(userId, config.rolloutSalt);

  if (config.mode === "internal") {
    return Object.freeze({
      active: internalCanary,
      cohort: internalCanary ? "internal" : "legacy",
      bucket,
      rolloutPercent: 0,
    });
  }

  if (config.mode === "percentage") {
    const active = bucket < config.rolloutPercent * 100;
    return Object.freeze({
      active,
      cohort: active ? "percentage" : "legacy",
      bucket,
      rolloutPercent: config.rolloutPercent,
    });
  }

  return Object.freeze({
    active: false,
    cohort: "legacy",
    bucket,
    rolloutPercent: 0,
  });
}
