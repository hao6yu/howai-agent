import { createClient } from "npm:@supabase/supabase-js@2";

import {
  createRealtimeSafetyIdentifier,
  parseRealtimeVoicePolicy,
  REALTIME_VOICE_VISION_INSTRUCTIONS,
  realtimeVoiceAudioInputConfiguration,
  type RealtimeVoiceCohort,
  realtimeVoiceEnabledForUser,
  selectRealtimeVoice,
} from "../_shared/realtime-voice-policy.ts";
import {
  buildRealtimeReminderTools,
  type RealtimeReminder,
  realtimeReminderContext,
} from "../_shared/realtime-reminder-tools.ts";
import {
  buildRealtimeWebSearchTools,
  REALTIME_WEB_SEARCH_TOOL_NAME,
} from "../_shared/realtime-web-search.ts";
import { loadHowAiPersonalContext } from "../_shared/howai-memory-context.ts";
import {
  HOWAI_CORE_INSTRUCTIONS,
  type HowAiPersonalContext,
  renderHowAiUserContext,
} from "../_shared/howai-prompt-policy.ts";
import { isStoredEntitlementActive } from "../_shared/entitlement-status.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const OPENAI_SAFETY_IDENTIFIER_SALT =
  Deno.env.get("OPENAI_SAFETY_IDENTIFIER_SALT") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const OPENAI_CLIENT_SECRETS_URL =
  "https://api.openai.com/v1/realtime/client_secrets";
const OPENAI_REALTIME_CALLS_URL = "https://api.openai.com/v1/realtime/calls";

type AuthenticatedUser = Readonly<{
  id: string;
  isAnonymous: boolean;
}>;

type TrustedEntitlement = Readonly<{
  cohort: RealtimeVoiceCohort;
  internalCanary: boolean;
}>;

type Reservation = Readonly<{
  accepted: boolean;
  sessionId: string | null;
  reason: string | null;
  supersededProviderCallId: string | null;
}>;

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers":
      "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
}

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
  origin: string | null,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(origin),
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}

function bearerToken(req: Request): string | null {
  const match = (req.headers.get("authorization") ?? "").match(
    /^Bearer\s+(.+)$/i,
  );
  return match?.[1] ?? null;
}

async function authenticateUser(
  req: Request,
): Promise<AuthenticatedUser | null> {
  const accessToken = bearerToken(req);
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;

  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.getUser(accessToken);
  if (error || !data.user) return null;

  return {
    id: data.user.id,
    isAnonymous: (data.user as typeof data.user & { is_anonymous?: boolean })
      .is_anonymous === true,
  };
}

async function trustedEntitlement(
  user: AuthenticatedUser,
): Promise<TrustedEntitlement> {
  if (user.isAnonymous) {
    return { cohort: "anonymous", internalCanary: false };
  }
  const { data, error } = await supabaseAdmin!
    .from("app_entitlements")
    .select("tier,source,expires_at,model_policy_canary")
    .eq("user_id", user.id)
    .maybeSingle();
  if (error) throw new Error(`entitlement_lookup_failed:${error.message}`);

  const paid = isStoredEntitlementActive(data);
  return {
    cohort: paid ? "paid" : "free",
    internalCanary: data?.model_policy_canary === true,
  };
}

async function reserveSession(
  userId: string,
  entitlement: TrustedEntitlement,
  model: string,
  voice: string,
  maxDurationSeconds: number,
  dailySessionLimit: number,
): Promise<Reservation> {
  const { data, error } = await supabaseAdmin!.rpc(
    "reserve_realtime_voice_session_v2",
    {
      p_user_id: userId,
      p_cohort: entitlement.cohort,
      p_model: model,
      p_voice: voice,
      p_max_duration_seconds: maxDurationSeconds,
      p_daily_session_limit: dailySessionLimit,
    },
  );
  if (error) throw new Error(`reservation_failed:${error.message}`);
  const row = Array.isArray(data) ? data[0] : data;
  return {
    accepted: row?.accepted === true,
    sessionId: typeof row?.session_id === "string" ? row.session_id : null,
    reason: typeof row?.reason === "string" ? row.reason : null,
    supersededProviderCallId:
      typeof row?.superseded_provider_call_id === "string"
        ? row.superseded_provider_call_id
        : null,
  };
}

async function hangupProviderCall(callId: string): Promise<void> {
  try {
    const response = await fetch(
      `${OPENAI_REALTIME_CALLS_URL}/${encodeURIComponent(callId)}/hangup`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      },
    );
    if (response.ok || response.status === 404 || response.status === 409) {
      return;
    }
    console.error(
      "Could not hang up superseded OpenAI Realtime call",
      response.status,
    );
  } catch (error) {
    console.error(
      "Could not reach OpenAI to hang up superseded Realtime call",
      error,
    );
  }
}

async function registerProviderCall(
  user: AuthenticatedUser,
  body: Record<string, unknown>,
  origin: string | null,
): Promise<Response> {
  const sessionId = typeof body.session_id === "string"
    ? body.session_id.trim()
    : "";
  const providerCallId = typeof body.provider_call_id === "string"
    ? body.provider_call_id.trim()
    : "";
  if (
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      .test(sessionId) ||
    !/^rtc_[A-Za-z0-9_-]{1,180}$/.test(providerCallId)
  ) {
    return jsonResponse(400, { error: "Invalid Realtime call" }, origin);
  }

  const { data, error } = await supabaseAdmin!
    .from("realtime_voice_sessions")
    .update({
      provider_call_id: providerCallId,
      updated_at: new Date().toISOString(),
    })
    .eq("id", sessionId)
    .eq("user_id", user.id)
    .eq("status", "active")
    .select("id")
    .maybeSingle();
  if (error) {
    console.error("Could not register OpenAI Realtime call", error);
    return jsonResponse(
      503,
      { error: "Realtime call registration is unavailable" },
      origin,
    );
  }
  if (!data) {
    return jsonResponse(
      409,
      {
        error: "This voice session was replaced by a newer call",
        code: "session_superseded",
      },
      origin,
    );
  }
  return jsonResponse(200, { registered: true }, origin);
}

async function failReservation(
  sessionId: string,
  reason: string,
): Promise<void> {
  const { error } = await supabaseAdmin!
    .from("realtime_voice_sessions")
    .update({
      status: "failed",
      ended_at: new Date().toISOString(),
      end_reason: reason.slice(0, 200),
      updated_at: new Date().toISOString(),
    })
    .eq("id", sessionId)
    .eq("status", "active");
  if (error) console.error("Failed to close Realtime reservation", error);
}

async function completeSession(
  user: AuthenticatedUser,
  body: Record<string, unknown>,
  origin: string | null,
): Promise<Response> {
  const sessionId = typeof body.session_id === "string"
    ? body.session_id.trim()
    : "";
  const duration = typeof body.duration_seconds === "number" &&
      Number.isFinite(body.duration_seconds)
    ? Math.max(0, Math.floor(body.duration_seconds))
    : 0;
  const reason = typeof body.end_reason === "string" &&
      body.end_reason.trim().length > 0
    ? body.end_reason.trim().slice(0, 200)
    : "client_ended";
  if (
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      .test(sessionId)
  ) {
    return jsonResponse(400, { error: "Invalid session id" }, origin);
  }

  const { data: existing, error: lookupError } = await supabaseAdmin!
    .from("realtime_voice_sessions")
    .select("id,status,max_duration_seconds")
    .eq("id", sessionId)
    .eq("user_id", user.id)
    .maybeSingle();
  if (lookupError) {
    return jsonResponse(
      503,
      { error: "Session completion is unavailable" },
      origin,
    );
  }
  if (!existing) {
    return jsonResponse(404, { error: "Session not found" }, origin);
  }
  if (existing.status !== "active") {
    return jsonResponse(200, { completed: true, idempotent: true }, origin);
  }

  const { error } = await supabaseAdmin!
    .from("realtime_voice_sessions")
    .update({
      status: "completed",
      duration_seconds: Math.min(duration, existing.max_duration_seconds),
      ended_at: new Date().toISOString(),
      end_reason: reason,
      updated_at: new Date().toISOString(),
    })
    .eq("id", sessionId)
    .eq("user_id", user.id)
    .eq("status", "active");
  if (error) {
    return jsonResponse(
      503,
      { error: "Session completion is unavailable" },
      origin,
    );
  }
  return jsonResponse(200, { completed: true }, origin);
}

function sessionInstructions(
  timezone: string,
  localDateTime: string,
  reminderContext: string | null,
  personalContext: HowAiPersonalContext | null,
): string {
  const instructions = [
    HOWAI_CORE_INSTRUCTIONS,
    `<realtime_voice_policy>
# Voice delivery
Speak naturally. Keep ordinary spoken answers compact unless the user asks for detail. Do not narrate hidden reasoning, tool routing, URLs, raw citations, or internal metadata.

# Turn taking
Let the user interrupt naturally. After an interruption, stop the previous thought and respond to the latest complete request. Do not scold or mention the interruption.

# Opening
When the call connects, greet the user in one short sentence and ask how you can help. Do not start with a capability list.
</realtime_voice_policy>`,
    renderHowAiUserContext(personalContext),
    `When an answer depends on current or recently changed information, call ${REALTIME_WEB_SEARCH_TOOL_NAME} before answering. This search is read-only and does not require approval. Do not claim that live search is unavailable until the tool reports that it is unavailable.`,
    "After a live-search result, answer concisely for speech, attribute important claims to source names naturally when useful, and never read URLs or citation syntax aloud.",
    REALTIME_VOICE_VISION_INSTRUCTIONS,
    "For repair, medical, electrical, driving, or other safety-sensitive visual guidance, prioritize immediate safety, give short step-by-step guidance, and recommend qualified help when the frame is insufficient or the task is risky.",
    "Never claim an external action was completed unless its tool result confirms success.",
    "When an action tool returns awaiting_confirmation, briefly repeat only the user-facing proposal details and ask the user to confirm naturally by voice; keep listening.",
    "For action confirmations, say the title, human-friendly schedule, recurrence, and useful notes. Never read raw timezone identifiers, UUIDs, JSON, tool names, field names, or other internal metadata unless the user explicitly asks. Mention a timezone only when the user is scheduling across time zones or the intended time is genuinely ambiguous.",
    "If the user clearly approves the pending proposal, call actions_confirm_pending with its exact proposal_id. Never treat silence, ambiguity, or an unrelated yes as approval.",
    "If the user declines, call actions_cancel_pending. If the user asks to change the proposal, call actions_cancel_pending with intent revise, wait for its result, then prepare a corrected proposal.",
    "A visible approval card is only a secondary control; never require the user to tap it during a voice conversation.",
    `The user's current IANA timezone is ${timezone}; their local date and time is ${localDateTime}.`,
  ];
  if (reminderContext) instructions.push(reminderContext);
  return instructions.filter(Boolean).join("\n\n");
}

function safeTimezone(value: unknown): string {
  return typeof value === "string" &&
      (value === "UTC" ||
        /^[A-Za-z0-9._+-]+(\/[A-Za-z0-9._+-]+)+$/.test(value))
    ? value
    : "UTC";
}

function safeLocalDateTime(value: unknown): string {
  return typeof value === "string" &&
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/.test(value)
    ? value
    : new Date().toISOString().slice(0, 19);
}

async function reminderToolConfiguration(
  user: AuthenticatedUser,
  internalCanary: boolean,
): Promise<{
  tools: readonly Readonly<Record<string, unknown>>[];
  context: string | null;
}> {
  if (user.isAnonymous) return { tools: [], context: null };
  const { data: flag, error: flagError } = await supabaseAdmin!
    .from("feature_flags")
    .select("enabled,payload")
    .eq("key", "reminders")
    .maybeSingle();
  if (flagError) {
    console.error("Realtime reminder flag lookup failed", flagError);
    return { tools: [], context: null };
  }
  const payload = flag?.payload && typeof flag.payload === "object"
    ? flag.payload as Record<string, unknown>
    : {};
  const enabled = flag?.enabled === true &&
    (payload.mode === "full" ||
      (payload.mode === "internal" && internalCanary));
  if (!enabled) return { tools: [], context: null };

  const { data, error } = await supabaseAdmin!
    .from("reminders")
    .select(
      "id,title,notes,timezone,start_local,recurrence_rule,status,version",
    )
    .eq("user_id", user.id)
    .in("status", ["active", "paused"])
    .order("next_fire_at")
    .limit(50);
  if (error) {
    console.error("Realtime reminder context lookup failed", error);
    return { tools: [], context: null };
  }
  const reminders = (data ?? []) as RealtimeReminder[];
  return {
    tools: buildRealtimeReminderTools(reminders),
    context: realtimeReminderContext(reminders),
  };
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }
  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" }, origin);
  }
  if (
    !OPENAI_API_KEY || !OPENAI_SAFETY_IDENTIFIER_SALT || !SUPABASE_URL ||
    !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY || !supabaseAdmin
  ) {
    return jsonResponse(
      500,
      { error: "Realtime voice is not configured" },
      origin,
    );
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  let body: Record<string, unknown>;
  try {
    const parsed = await req.json();
    body = parsed && typeof parsed === "object" && !Array.isArray(parsed)
      ? parsed as Record<string, unknown>
      : {};
  } catch {
    return jsonResponse(400, { error: "Invalid JSON body" }, origin);
  }

  if (body.operation === "complete") {
    return await completeSession(user, body, origin);
  }
  if (body.operation === "register_call") {
    return await registerProviderCall(user, body, origin);
  }
  if (body.operation !== "create") {
    return jsonResponse(400, { error: "Unsupported operation" }, origin);
  }

  let reservationId: string | null = null;
  try {
    const [{ data: flag, error: flagError }, entitlement] = await Promise.all([
      supabaseAdmin.from("feature_flags")
        .select("enabled,payload")
        .eq("key", "realtime_voice")
        .maybeSingle(),
      trustedEntitlement(user),
    ]);
    if (flagError) throw new Error(`feature_flag_failed:${flagError.message}`);

    const policy = parseRealtimeVoicePolicy(flag?.payload);
    if (
      !realtimeVoiceEnabledForUser(
        flag?.enabled === true,
        policy,
        entitlement.internalCanary,
      )
    ) {
      return jsonResponse(
        403,
        {
          error: "Realtime voice is not enabled for this account",
          code: "rollout_inactive",
        },
        origin,
      );
    }

    const voice = selectRealtimeVoice(body.voice, policy);
    const timezone = safeTimezone(body.timezone);
    const localDateTime = safeLocalDateTime(body.local_datetime);
    const maxDurationSeconds = policy.maxSessionSeconds[entitlement.cohort];
    const dailySessionLimit = policy.dailySessionLimits[entitlement.cohort];
    const reservation = await reserveSession(
      user.id,
      entitlement,
      policy.model,
      voice,
      maxDurationSeconds,
      dailySessionLimit,
    );
    if (!reservation.accepted || !reservation.sessionId) {
      const active = reservation.reason === "active_session";
      return jsonResponse(
        active ? 409 : 429,
        {
          error: active
            ? "Another voice session is already active"
            : "Daily voice session limit reached",
          code: reservation.reason ?? "reservation_denied",
        },
        origin,
      );
    }
    reservationId = reservation.sessionId;
    if (reservation.supersededProviderCallId) {
      await hangupProviderCall(reservation.supersededProviderCallId);
    }

    const safetyIdentifier = await createRealtimeSafetyIdentifier(
      user.id,
      OPENAI_SAFETY_IDENTIFIER_SALT,
    );
    const reminderConfiguration = await reminderToolConfiguration(
      user,
      entitlement.internalCanary,
    );
    const personalContext = user.isAnonymous
      ? null
      : await loadHowAiPersonalContext(supabaseAdmin, user.id);
    const realtimeTools = [
      ...buildRealtimeWebSearchTools(!user.isAnonymous),
      ...reminderConfiguration.tools,
    ];
    const audioInputConfiguration = realtimeVoiceAudioInputConfiguration();
    const upstream = await fetch(OPENAI_CLIENT_SECRETS_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
        "OpenAI-Safety-Identifier": safetyIdentifier,
      },
      body: JSON.stringify({
        session: {
          type: "realtime",
          model: policy.model,
          instructions: sessionInstructions(
            timezone,
            localDateTime,
            reminderConfiguration.context,
            personalContext,
          ),
          tools: realtimeTools,
          tool_choice: "auto",
          audio: {
            input: audioInputConfiguration,
            output: { voice },
          },
        },
      }),
    });
    const upstreamBody = await upstream.json().catch(() => null) as
      | Record<string, unknown>
      | null;
    if (!upstream.ok) {
      console.error(
        "OpenAI Realtime client-secret request failed",
        upstream.status,
        upstreamBody?.error,
      );
      await failReservation(reservationId, `openai_${upstream.status}`);
      return jsonResponse(
        upstream.status === 429 ? 429 : 502,
        {
          error: upstream.status === 429
            ? "Realtime voice is temporarily busy"
            : "Could not start Realtime voice",
          code: "provider_error",
        },
        origin,
      );
    }

    const clientSecret = typeof upstreamBody?.value === "string"
      ? upstreamBody.value
      : null;
    const clientSecretExpiresAt = typeof upstreamBody?.expires_at === "number"
      ? upstreamBody.expires_at
      : null;
    if (!clientSecret || !clientSecretExpiresAt) {
      await failReservation(reservationId, "invalid_provider_response");
      return jsonResponse(
        502,
        {
          error: "Could not start Realtime voice",
          code: "invalid_provider_response",
        },
        origin,
      );
    }

    const { error: updateError } = await supabaseAdmin
      .from("realtime_voice_sessions")
      .update({
        client_secret_expires_at: new Date(
          clientSecretExpiresAt * 1000,
        ).toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", reservationId)
      .eq("user_id", user.id);
    if (updateError) {
      console.error("Failed to record client-secret expiry", updateError);
    }

    return jsonResponse(200, {
      session_id: reservationId,
      client_secret: clientSecret,
      client_secret_expires_at: clientSecretExpiresAt,
      model: policy.model,
      voice,
      cohort: entitlement.cohort,
      max_duration_seconds: maxDurationSeconds,
      turn_detection: audioInputConfiguration.turn_detection,
      provider: "openai",
    }, origin);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error("Realtime session broker failed", message);
    if (reservationId) {
      await failReservation(reservationId, "broker_failure");
    }
    return jsonResponse(
      503,
      {
        error: "Realtime voice is temporarily unavailable",
        code: "broker_failure",
      },
      origin,
    );
  }
});
