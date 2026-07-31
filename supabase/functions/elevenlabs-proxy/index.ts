import { createClient } from "npm:@supabase/supabase-js@2.111.0";
import { isStoredEntitlementActive } from "../_shared/entitlement-status.ts";

const ELEVENLABS_BASE_URL = "https://api.elevenlabs.io";
const ELEVENLABS_API_KEY = Deno.env.get("ELEVENLABS_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";

const MAX_BODY_BYTES = Number(
  Deno.env.get("ELEVENLABS_PROXY_MAX_BODY_BYTES") ?? 256 * 1024,
);
const MAX_TEXT_CHARS = Number(
  Deno.env.get("ELEVENLABS_PROXY_MAX_TEXT_CHARS") ?? 5000,
);
const MAX_REQUESTS_PER_HOUR = Number(
  Deno.env.get("ELEVENLABS_PROXY_MAX_REQUESTS_PER_HOUR") ?? 120,
);
const ANON_MAX_REQUESTS_PER_HOUR = Number(
  Deno.env.get("ELEVENLABS_PROXY_ANON_MAX_REQUESTS_PER_HOUR") ?? 10,
);
const ANON_MAX_REQUESTS_PER_DAY = Number(
  Deno.env.get("ELEVENLABS_PROXY_ANON_MAX_REQUESTS_PER_DAY") ?? 20,
);
const FREE_MAX_REQUESTS_PER_HOUR = Number(
  Deno.env.get("ELEVENLABS_PROXY_FREE_MAX_REQUESTS_PER_HOUR") ?? 30,
);
const FREE_MAX_REQUESTS_PER_DAY = Number(
  Deno.env.get("ELEVENLABS_PROXY_FREE_MAX_REQUESTS_PER_DAY") ?? 60,
);
const PAID_MAX_REQUESTS_PER_DAY = Number(
  Deno.env.get("ELEVENLABS_PROXY_PAID_MAX_REQUESTS_PER_DAY") ?? 1000,
);
const UPSTREAM_TIMEOUT_MS = Number(
  Deno.env.get("ELEVENLABS_PROXY_UPSTREAM_TIMEOUT_MS") ?? 30_000,
);
const ALLOWED_VOICE_IDS = csvSet(
  Deno.env.get("ELEVENLABS_PROXY_ALLOWED_VOICE_IDS"),
);
const ALLOWED_AGENT_IDS = csvSet(
  Deno.env.get("ELEVENLABS_PROXY_ALLOWED_AGENT_IDS"),
);
const ALLOWED_MODELS = csvSet(
  Deno.env.get("ELEVENLABS_PROXY_ALLOWED_MODELS") ??
    "eleven_multilingual_v2,eleven_turbo_v2_5,eleven_flash_v2_5",
);

type ProxyPath =
  | { kind: "voices"; upstreamPath: "/v1/voices" }
  | {
    kind: "signed_url";
    upstreamPath: "/v1/convai/conversation/get-signed-url";
    agentId: string;
  }
  | {
    kind: "tts";
    upstreamPath: string;
    voiceId: string;
    withTimestamps: boolean;
  };

type AuthenticatedUser = {
  id: string;
  isAnonymous: boolean;
};

type RequestLog = {
  voice_id?: string | null;
  agent_id?: string | null;
  status_code: number;
  request_bytes: number;
  response_bytes?: number | null;
  error?: string | null;
};

type UsagePolicy = {
  cohort: "anonymous" | "free" | "paid";
  hourlyLimit: number;
  dailyLimit: number;
};

type Reservation = {
  accepted: boolean;
  reservationId: string | null;
  reason: string | null;
};

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

function csvSet(raw: string | undefined | null): Set<string> {
  return new Set(
    (raw ?? "")
      .split(",")
      .map((value) => value.trim())
      .filter(Boolean),
  );
}

function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers":
      "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
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

function getBearerToken(req: Request): string | null {
  const authHeader = req.headers.get("authorization") ?? "";
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  return match?.[1] ?? null;
}

async function authenticateUser(
  req: Request,
): Promise<AuthenticatedUser | null> {
  const accessToken = getBearerToken(req);
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return null;
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: { Authorization: `Bearer ${accessToken}` },
    },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.auth.getUser(accessToken);
  if (error || !data.user) {
    return null;
  }

  const userWithAnonymousClaim = data.user as typeof data.user & {
    is_anonymous?: boolean;
  };

  return {
    id: data.user.id,
    isAnonymous: userWithAnonymousClaim.is_anonymous === true,
  };
}

async function trustedUsagePolicy(
  user: AuthenticatedUser,
): Promise<UsagePolicy> {
  if (user.isAnonymous) {
    return {
      cohort: "anonymous",
      hourlyLimit: ANON_MAX_REQUESTS_PER_HOUR,
      dailyLimit: ANON_MAX_REQUESTS_PER_DAY,
    };
  }
  const { data, error } = await supabaseAdmin!
    .from("app_entitlements")
    .select("tier,source,expires_at")
    .eq("user_id", user.id)
    .maybeSingle();
  if (error) {
    throw new Error(`entitlement_lookup_failed:${error.message}`);
  }
  if (isStoredEntitlementActive(data)) {
    return {
      cohort: "paid",
      hourlyLimit: MAX_REQUESTS_PER_HOUR,
      dailyLimit: PAID_MAX_REQUESTS_PER_DAY,
    };
  }
  return {
    cohort: "free",
    hourlyLimit: FREE_MAX_REQUESTS_PER_HOUR,
    dailyLimit: FREE_MAX_REQUESTS_PER_DAY,
  };
}

async function reserveRequest(
  user: AuthenticatedUser,
  endpoint: string,
  requestBytes: number,
  policy: UsagePolicy,
): Promise<Reservation> {
  const { data, error } = await supabaseAdmin!.rpc(
    "reserve_elevenlabs_proxy_request",
    {
      p_user_id: user.id,
      p_is_anonymous: user.isAnonymous,
      p_endpoint: endpoint,
      p_hourly_limit: policy.hourlyLimit,
      p_daily_limit: policy.dailyLimit,
      p_request_bytes: requestBytes,
    },
  );
  if (error) throw new Error(`reservation_failed:${error.message}`);
  const row = Array.isArray(data) ? data[0] : data;
  return {
    accepted: row?.accepted === true,
    reservationId: typeof row?.reservation_id === "string"
      ? row.reservation_id
      : null,
    reason: typeof row?.reason === "string" ? row.reason : null,
  };
}

async function completeRequest(
  reservationId: string,
  log: RequestLog,
): Promise<void> {
  const { error } = await supabaseAdmin!
    .from("elevenlabs_proxy_requests")
    .update(log)
    .eq("id", reservationId);
  if (error) {
    console.error("Failed to complete ElevenLabs proxy request log", error);
  }
}

function targetPath(req: Request): ProxyPath | null {
  const url = new URL(req.url);
  const pathname = url.pathname;

  if (pathname.endsWith("/v1/voices")) {
    return { kind: "voices", upstreamPath: "/v1/voices" };
  }

  if (pathname.endsWith("/v1/convai/conversation/get-signed-url")) {
    const agentId = url.searchParams.get("agent_id")?.trim();
    if (!agentId) {
      throw new Error("Missing agent_id");
    }
    return {
      kind: "signed_url",
      upstreamPath: "/v1/convai/conversation/get-signed-url",
      agentId,
    };
  }

  const ttsMatch = pathname.match(
    /\/v1\/text-to-speech\/([^/]+)(\/with-timestamps)?$/,
  );
  if (ttsMatch) {
    const voiceId = decodeURIComponent(ttsMatch[1] ?? "").trim();
    return {
      kind: "tts",
      upstreamPath: `/v1/text-to-speech/${encodeURIComponent(voiceId)}${
        ttsMatch[2] ?? ""
      }`,
      voiceId,
      withTimestamps: Boolean(ttsMatch[2]),
    };
  }

  return null;
}

function validateContentLength(
  req: Request,
  origin: string | null,
): Response | null {
  const contentLengthRaw = req.headers.get("content-length");
  if (!contentLengthRaw) {
    return null;
  }

  const contentLength = Number(contentLengthRaw);
  if (Number.isFinite(contentLength) && contentLength > MAX_BODY_BYTES) {
    return jsonResponse(413, { error: "Payload too large" }, origin);
  }

  return null;
}

function isAllowed(id: string, allowed: Set<string>): boolean {
  return allowed.has(id);
}

function sanitizeVoiceSettings(
  settings: unknown,
): Record<string, unknown> | undefined {
  if (!settings || typeof settings !== "object") {
    return undefined;
  }

  const source = settings as Record<string, unknown>;
  const clean: Record<string, unknown> = {};

  for (const field of ["stability", "similarity_boost", "style", "speed"]) {
    const value = source[field];
    if (typeof value === "number" && Number.isFinite(value)) {
      clean[field] = Math.max(0, Math.min(1, value));
    }
  }

  if (typeof source.use_speaker_boost === "boolean") {
    clean.use_speaker_boost = source.use_speaker_boost;
  }

  return clean;
}

function sanitizeTtsBody(bodyBytes: ArrayBuffer): Uint8Array {
  const decoder = new TextDecoder();
  const encoder = new TextEncoder();
  const json = JSON.parse(decoder.decode(bodyBytes)) as Record<string, unknown>;

  const text = typeof json.text === "string" ? json.text : "";
  if (!text.trim()) {
    throw new Error("Missing text");
  }
  if (text.length > MAX_TEXT_CHARS) {
    throw new Error(`Text exceeds ${MAX_TEXT_CHARS} characters`);
  }

  const requestedModel = typeof json.model_id === "string"
    ? json.model_id
    : "eleven_multilingual_v2";
  if (!ALLOWED_MODELS.has(requestedModel)) {
    throw new Error(`Model is not allowed: ${requestedModel}`);
  }

  const clean: Record<string, unknown> = {
    text,
    model_id: requestedModel,
  };

  const voiceSettings = sanitizeVoiceSettings(json.voice_settings);
  if (voiceSettings) {
    clean.voice_settings = voiceSettings;
  }

  return encoder.encode(JSON.stringify(clean));
}

function forwardHeaders(path: ProxyPath): Headers {
  const headers = new Headers();
  headers.set("xi-api-key", ELEVENLABS_API_KEY);

  if (path.kind === "tts" && path.withTimestamps) {
    headers.set("Accept", "application/json");
  } else if (path.kind === "tts") {
    headers.set("Accept", "audio/mpeg");
  } else {
    headers.set("Accept", "application/json");
  }

  if (path.kind === "tts") {
    headers.set("Content-Type", "application/json");
  }

  return headers;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (!ELEVENLABS_API_KEY) {
    return jsonResponse(500, {
      error: "ELEVENLABS_API_KEY is not configured on proxy",
    }, origin);
  }
  if (
    !SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY ||
    !supabaseAdmin
  ) {
    return jsonResponse(500, {
      error: "Supabase proxy auth/logging secrets are not configured",
    }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  let path: ProxyPath | null = null;
  let requestBytes = 0;
  let reservationId: string | null = null;

  try {
    path = targetPath(req);
    if (!path) {
      return jsonResponse(404, { error: "Unsupported endpoint" }, origin);
    }

    if (path.kind === "voices" || path.kind === "signed_url") {
      if (req.method !== "GET") {
        return jsonResponse(405, { error: "Method not allowed" }, origin);
      }
    } else if (req.method !== "POST") {
      return jsonResponse(405, { error: "Method not allowed" }, origin);
    }

    if (
      path.kind === "signed_url" && !isAllowed(path.agentId, ALLOWED_AGENT_IDS)
    ) {
      return jsonResponse(403, { error: "Agent is not allowed" }, origin);
    }
    if (path.kind === "tts" && !isAllowed(path.voiceId, ALLOWED_VOICE_IDS)) {
      return jsonResponse(403, { error: "Voice is not allowed" }, origin);
    }

    const contentLengthError = validateContentLength(req, origin);
    if (contentLengthError) {
      return contentLengthError;
    }

    let upstreamUrl = `${ELEVENLABS_BASE_URL}${path.upstreamPath}`;
    let forwardBody: Uint8Array | undefined;

    if (path.kind === "signed_url") {
      upstreamUrl = `${upstreamUrl}?agent_id=${
        encodeURIComponent(path.agentId)
      }`;
    } else if (path.kind === "tts") {
      const originalBodyBytes = await req.arrayBuffer();
      requestBytes = originalBodyBytes.byteLength;
      if (requestBytes > MAX_BODY_BYTES) {
        return jsonResponse(413, { error: "Payload too large" }, origin);
      }
      forwardBody = sanitizeTtsBody(originalBodyBytes);
    }

    const policy = await trustedUsagePolicy(user);
    const reservation = await reserveRequest(
      user,
      path.upstreamPath,
      requestBytes,
      policy,
    );
    if (!reservation.accepted || !reservation.reservationId) {
      return jsonResponse(
        429,
        {
          error: "Temporary usage limit reached",
          reason: reservation.reason ?? "usage_limit",
        },
        origin,
      );
    }
    reservationId = reservation.reservationId;

    const upstream = await fetch(upstreamUrl, {
      method: path.kind === "tts" ? "POST" : "GET",
      headers: forwardHeaders(path),
      body: forwardBody,
      signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
    });

    const responseHeaders = new Headers(corsHeaders(origin));
    responseHeaders.set("Cache-Control", "no-store");
    const upstreamContentType = upstream.headers.get("content-type");
    if (upstreamContentType) {
      responseHeaders.set("Content-Type", upstreamContentType);
    }

    const responseBytes = await upstream.arrayBuffer();
    let upstreamError: string | null = null;

    if (!upstream.ok) {
      try {
        const errorJson = JSON.parse(
          new TextDecoder().decode(responseBytes),
        ) as Record<string, unknown>;
        upstreamError = JSON.stringify(errorJson).slice(0, 500);
      } catch {
        upstreamError = new TextDecoder().decode(responseBytes).slice(0, 500);
      }
    }

    await completeRequest(reservationId, {
      voice_id: path.kind === "tts" ? path.voiceId : null,
      agent_id: path.kind === "signed_url" ? path.agentId : null,
      status_code: upstream.status,
      request_bytes: requestBytes,
      response_bytes: responseBytes.byteLength,
      error: upstreamError,
    });

    if (!upstream.ok) {
      return jsonResponse(
        502,
        { error: "Voice provider request failed" },
        origin,
      );
    }

    return new Response(responseBytes, {
      status: upstream.status,
      headers: responseHeaders,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (reservationId) {
      await completeRequest(reservationId, {
        voice_id: path?.kind === "tts" ? path.voiceId : null,
        agent_id: path?.kind === "signed_url" ? path.agentId : null,
        status_code: error instanceof DOMException &&
            error.name === "TimeoutError"
          ? 504
          : 400,
        request_bytes: requestBytes,
        error: message.slice(0, 500),
      });
    }
    if (
      message.startsWith("entitlement_lookup_failed:") ||
      message.startsWith("reservation_failed:")
    ) {
      console.error("ElevenLabs authorization failed", message);
      return jsonResponse(
        503,
        { error: "Voice authorization is temporarily unavailable" },
        origin,
      );
    }
    if (error instanceof DOMException && error.name === "TimeoutError") {
      return jsonResponse(504, { error: "Voice provider timed out" }, origin);
    }
    return jsonResponse(400, { error: "Invalid voice request" }, origin);
  }
});
