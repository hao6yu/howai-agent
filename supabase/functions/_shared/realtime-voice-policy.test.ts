import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  createRealtimeSafetyIdentifier,
  parseRealtimeVoicePolicy,
  REALTIME_VOICE_VISION_INSTRUCTIONS,
  realtimeVoiceAudioInputConfiguration,
  realtimeVoiceEnabledForUser,
  selectRealtimeVoice,
} from "./realtime-voice-policy.ts";

Deno.test("Realtime voice defaults fail closed", () => {
  const policy = parseRealtimeVoicePolicy(null);
  assertEquals(policy.mode, "off");
  assertEquals(realtimeVoiceEnabledForUser(true, policy, true), false);
  assertEquals(policy.model, "gpt-realtime-2.1");
});

Deno.test("internal rollout allows only the private canary", () => {
  const policy = parseRealtimeVoicePolicy({
    mode: "internal",
    allowed_voices: ["marin", "cedar"],
    default_voice: "cedar",
  });
  assert(realtimeVoiceEnabledForUser(true, policy, true));
  assertEquals(realtimeVoiceEnabledForUser(true, policy, false), false);
  assertEquals(selectRealtimeVoice("marin", policy), "marin");
  assertEquals(selectRealtimeVoice("unknown", policy), "cedar");
});

Deno.test("policy rejects unsafe and out-of-range configuration", () => {
  const policy = parseRealtimeVoicePolicy({
    mode: "full",
    model: "",
    allowed_voices: ["marin", "../bad", 42],
    free_daily_sessions: 1000,
    paid_max_session_seconds: 99_999,
  });
  assertEquals(policy.model, "gpt-realtime-2.1");
  assertEquals([...policy.allowedVoices], ["marin"]);
  assertEquals(policy.dailySessionLimits.free, 3);
  assertEquals(policy.maxSessionSeconds.paid, 600);
});

Deno.test("safety identifiers are stable, opaque, and user-specific", async () => {
  const first = await createRealtimeSafetyIdentifier("user-a", "salt");
  const again = await createRealtimeSafetyIdentifier("user-a", "salt");
  const second = await createRealtimeSafetyIdentifier("user-b", "salt");
  assertEquals(first, again);
  assert(first !== second);
  assertEquals(first.length, 64);
  assert(!first.includes("user-a"));
});

Deno.test("Realtime audio keeps native barge-in with far-field filtering", () => {
  const input = realtimeVoiceAudioInputConfiguration();
  assertEquals(input.noise_reduction.type, "far_field");
  assertEquals(input.turn_detection, {
    type: "server_vad",
    threshold: 0.6,
    prefix_padding_ms: 300,
    silence_duration_ms: 450,
    create_response: true,
    interrupt_response: true,
  });
});

Deno.test("Realtime vision sounds live without exposing frame sampling", () => {
  assert(
    REALTIME_VOICE_VISION_INSTRUCTIONS.includes("live visual conversation"),
  );
  assert(
    !/snapshot-based|latest shared frame|cannot see motion/i.test(
      REALTIME_VOICE_VISION_INSTRUCTIONS,
    ),
  );
  assert(REALTIME_VOICE_VISION_INSTRUCTIONS.includes("hold the camera steady"));
});
