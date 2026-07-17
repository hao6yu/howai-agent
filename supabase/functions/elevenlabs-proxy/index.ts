import { createClient } from "npm:@supabase/supabase-js@2";

const ELEVENLABS_BASE_URL = "https://api.elevenlabs.io";
const ELEVENLABS_API_KEY = Deno.env.get("ELEVENLABS_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const MAX_BODY_BYTES = Number(Deno.env.get("ELEVENLABS_PROXY_MAX_BODY_BYTES") ?? 256 * 1024);
const MAX_TEXT_CHARS = Number(Deno.env.get("ELEVENLABS_PROXY_MAX_TEXT_CHARS") ?? 5000);
const MAX_REQUESTS_PER_HOUR = Number(Deno.env.get("ELEVENLABS_PROXY_MAX_REQUESTS_PER_HOUR") ?? 120);
const ANON_MAX_REQUESTS_PER_DAY = Number(Deno.env.get("ELEVENLABS_PROXY_ANON_MAX_REQUESTS_PER_DAY") ?? 300);
const ALLOWED_VOICE_IDS = csvSet(Deno.env.get("ELEVENLABS_PROXY_ALLOWED_VOICE_IDS"));
const ALLOWED_AGENT_IDS = csvSet(Deno.env.get("ELEVENLABS_PROXY_ALLOWED_AGENT_IDS"));
const ALLOWED_MODELS = csvSet(
  Deno.env.get("ELEVENLABS_PROXY_ALLOWED_MODELS") ??
    "eleven_multilingual_v2,eleven_turbo_v2_5,eleven_flash_v2_5",
);

type ProxyPath =
  | { kind: "voices"; upstreamPath: "/v1/voices" }
  | { kind: "signed_url"; upstreamPath: "/v1/convai/conversation/get-signed-url"; agentId: string }
  | { kind: "tts"; upstreamPath: string; voiceId: string; withTimestamps: boolean };

type AuthenticatedUser = {
  id: string;
  isAnonymous: boolean;
};

type RequestLog = {
  user_id: string;
  is_anonymous: boolean;
  endpoint: string;
  voice_id?: string | null;
  agent_id?: string | null;
  status_code: number;
  request_bytes: number;
  response_bytes?: number | null;
  error?: string | null;
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
    "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
}

function jsonResponse(status: number, body: Record<string, unknown>, origin: string | null): Response {
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

async function authenticateUser(req: Request): Promise<AuthenticatedUser | null> {
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

async function isWithinRateLimit(user: AuthenticatedUser): Promise<boolean> {
  if (!supabaseAdmin) {
    return false;
  }

  const hourlySince = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count: hourlyCount, error: hourlyError } = await supabaseAdmin
    .from("elevenlabs_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .gte("created_at", hourlySince);

  if (hourlyError) {
    console.error("ElevenLabs hourly rate limit lookup failed", hourlyError);
    return false;
  }

  if ((hourlyCount ?? 0) >= MAX_REQUESTS_PER_HOUR) {
    return false;
  }

  if (!user.isAnonymous) {
    return true;
  }

  const dailySince = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count: dailyCount, error: dailyError } = await supabaseAdmin
    .from("elevenlabs_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .eq("is_anonymous", true)
    .gte("created_at", dailySince);

  if (dailyError) {
    console.error("ElevenLabs anonymous daily limit lookup failed", dailyError);
    return false;
  }

  return (dailyCount ?? 0) < ANON_MAX_REQUESTS_PER_DAY;
}

async function logRequest(log: RequestLog): Promise<void> {
  if (!supabaseAdmin) {
    console.error("Supabase service role client is not configured; skipping ElevenLabs proxy request log.");
    return;
  }

  const { error } = await supabaseAdmin.from("elevenlabs_proxy_requests").insert(log);
  if (error) {
    console.error("Failed to write ElevenLabs proxy request log", error);
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

  const ttsMatch = pathname.match(/\/v1\/text-to-speech\/([^/]+)(\/with-timestamps)?$/);
  if (ttsMatch) {
    const voiceId = decodeURIComponent(ttsMatch[1] ?? "").trim();
    return {
      kind: "tts",
      upstreamPath: `/v1/text-to-speech/${encodeURIComponent(voiceId)}${ttsMatch[2] ?? ""}`,
      voiceId,
      withTimestamps: Boolean(ttsMatch[2]),
    };
  }

  return null;
}

function validateContentLength(req: Request, origin: string | null): Response | null {
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

function sanitizeVoiceSettings(settings: unknown): Record<string, unknown> | undefined {
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

  const requestedModel = typeof json.model_id === "string" ? json.model_id : "eleven_multilingual_v2";
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
    return jsonResponse(500, { error: "ELEVENLABS_API_KEY is not configured on proxy" }, origin);
  }
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY || !supabaseAdmin) {
    return jsonResponse(500, { error: "Supabase proxy auth/logging secrets are not configured" }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  if (!(await isWithinRateLimit(user))) {
    return jsonResponse(429, { error: "Temporary usage limit reached" }, origin);
  }

  let path: ProxyPath | null = null;
  let requestBytes = 0;

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

    if (path.kind === "signed_url" && !isAllowed(path.agentId, ALLOWED_AGENT_IDS)) {
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
      upstreamUrl = `${upstreamUrl}?agent_id=${encodeURIComponent(path.agentId)}`;
    } else if (path.kind === "tts") {
      const originalBodyBytes = await req.arrayBuffer();
      requestBytes = originalBodyBytes.byteLength;
      if (requestBytes > MAX_BODY_BYTES) {
        return jsonResponse(413, { error: "Payload too large" }, origin);
      }
      forwardBody = sanitizeTtsBody(originalBodyBytes);
    }

    const upstream = await fetch(upstreamUrl, {
      method: path.kind === "tts" ? "POST" : "GET",
      headers: forwardHeaders(path),
      body: forwardBody,
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
        const errorJson = JSON.parse(new TextDecoder().decode(responseBytes)) as Record<string, unknown>;
        upstreamError = JSON.stringify(errorJson).slice(0, 500);
      } catch {
        upstreamError = new TextDecoder().decode(responseBytes).slice(0, 500);
      }
    }

    await logRequest({
      user_id: user.id,
      is_anonymous: user.isAnonymous,
      endpoint: path.upstreamPath,
      voice_id: path.kind === "tts" ? path.voiceId : null,
      agent_id: path.kind === "signed_url" ? path.agentId : null,
      status_code: upstream.status,
      request_bytes: requestBytes,
      response_bytes: responseBytes.byteLength,
      error: upstreamError,
    });

    return new Response(responseBytes, {
      status: upstream.status,
      headers: responseHeaders,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await logRequest({
      user_id: user.id,
      is_anonymous: user.isAnonymous,
      endpoint: path?.upstreamPath ?? "unknown",
      voice_id: path?.kind === "tts" ? path.voiceId : null,
      agent_id: path?.kind === "signed_url" ? path.agentId : null,
      status_code: 400,
      request_bytes: requestBytes,
      error: message,
    });

    return jsonResponse(400, { error: message }, origin);
  }
});
