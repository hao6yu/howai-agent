import assert from "node:assert/strict";
import test from "node:test";

import {
  DEFAULT_MODEL_POLICY_ROLLOUT,
  modelPolicyRolloutBucket,
  parseModelPolicyRollout,
  resolveModelPolicyRollout,
} from "./openai-rollout.ts";

test("rollout configuration fails closed", () => {
  assert.deepEqual(parseModelPolicyRollout(null), DEFAULT_MODEL_POLICY_ROLLOUT);
  assert.deepEqual(
    parseModelPolicyRollout({
      mode: "percentage",
      rollout_percent: 101,
      rollout_salt: "",
    }),
    {
      mode: "percentage",
      rolloutPercent: 0,
      rolloutSalt: "gpt56-m1-v1",
    },
  );
  assert.equal(parseModelPolicyRollout({ mode: "surprise" }).mode, "off");
});

test("the same user stays in the same rollout bucket", () => {
  const first = modelPolicyRolloutBucket("user-123", "gpt56-m1-v1");
  const second = modelPolicyRolloutBucket("user-123", "gpt56-m1-v1");

  assert.equal(first, second);
  assert.ok(first >= 0 && first <= 9_999);
  assert.notEqual(first, modelPolicyRolloutBucket("user-456", "gpt56-m1-v1"));
});

test("internal mode selects only private allowlisted accounts", () => {
  const config = parseModelPolicyRollout({
    mode: "internal",
    rollout_percent: 0,
    rollout_salt: "gpt56-m1-v1",
  });

  assert.equal(resolveModelPolicyRollout("user-1", true, config).cohort, "internal");
  assert.equal(resolveModelPolicyRollout("user-1", true, config).active, true);
  assert.equal(resolveModelPolicyRollout("user-2", false, config).active, false);
});

test("percentage mode uses deterministic basis-point buckets", () => {
  const userId = "user-123";
  const bucket = modelPolicyRolloutBucket(userId, "gpt56-m1-v1");
  const minimumIncludingPercent = Math.floor(bucket / 100) + 1;

  const excluded = resolveModelPolicyRollout(
    userId,
    false,
    parseModelPolicyRollout({
      mode: "percentage",
      rollout_percent: Math.max(0, minimumIncludingPercent - 1),
      rollout_salt: "gpt56-m1-v1",
    }),
  );
  const included = resolveModelPolicyRollout(
    userId,
    false,
    parseModelPolicyRollout({
      mode: "percentage",
      rollout_percent: minimumIncludingPercent,
      rollout_salt: "gpt56-m1-v1",
    }),
  );

  assert.equal(excluded.active, false);
  assert.equal(included.active, true);
  assert.equal(included.cohort, "percentage");
});

test("off mode and zero-percent percentage mode are instant rollback paths", () => {
  assert.equal(
    resolveModelPolicyRollout("user-1", true, DEFAULT_MODEL_POLICY_ROLLOUT).active,
    false,
  );
  assert.equal(
    resolveModelPolicyRollout(
      "user-1",
      true,
      parseModelPolicyRollout({
        mode: "percentage",
        rollout_percent: 0,
        rollout_salt: "gpt56-m1-v1",
      }),
    ).active,
    false,
  );
});
