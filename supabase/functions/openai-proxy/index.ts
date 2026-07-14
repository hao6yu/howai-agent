import { createClient } from "npm:@supabase/supabase-js@2";

const OPENAI_BASE_URL = "https://api.openai.com";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const MAX_BODY_BYTES = Number(Deno.env.get("OPENAI_PROXY_MAX_BODY_BYTES") ?? 25 * 1024 * 1024);
const MAX_OUTPUT_TOKENS = Number(Deno.env.get("OPENAI_PROXY_MAX_OUTPUT_TOKENS") ?? 3000);
const MAX_REQUESTS_PER_HOUR = Number(Deno.env.get("OPENAI_PROXY_MAX_REQUESTS_PER_HOUR") ?? 120);
const ANON_MAX_REQUESTS_PER_DAY = Number(Deno.env.get("OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY") ?? 300);
const CHAT_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MODEL") ?? "gpt-5.2";
const CHAT_MINI_MODEL = Deno.env.get("OPENAI_PROXY_CHAT_MINI_MODEL") ?? "gpt-5-nano";
const ALLOWED_MODELS = (`${CHAT_MODEL},${CHAT_MINI_MODEL},${Deno.env.get("OPENAI_PROXY_ALLOWED_MODELS") ?? ""}`)
  .split(",")
  .map((model) => model.trim())
  .filter(Boolean);
const ALLOWED_TOOL_TYPES = new Set(["web_search", "web_search_preview", "image_generation", "function"]);
const ALLOWED_FUNCTION_NAMES = new Set(["generate_pptx"]);

type ProxyPath = "/v1/responses" | "/v1/audio/transcriptions";

type AuthenticatedUser = {
  id: string;
  isAnonymous: boolean;
};

const MODEL_ALIASES = new Map<string, string>([
  ["howai-chat", CHAT_MODEL],
  ["howai-chat-mini", CHAT_MINI_MODEL],
]);

type RequestLog = {
  user_id: string;
  is_anonymous: boolean;
  endpoint: string;
  model: string | null;
  status_code: number;
  request_bytes: number;
  response_id?: string | null;
  input_tokens?: number | null;
  output_tokens?: number | null;
  total_tokens?: number | null;
  error?: string | null;
};

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

function targetPath(pathname: string): ProxyPath | null {
  if (pathname.endsWith("/v1/responses")) return "/v1/responses";
  if (pathname.endsWith("/v1/audio/transcriptions")) return "/v1/audio/transcriptions";
  return null;
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
    .from("openai_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .gte("created_at", hourlySince);

  if (hourlyError) {
    console.error("Hourly rate limit lookup failed", hourlyError);
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
    .from("openai_proxy_requests")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .eq("is_anonymous", true)
    .gte("created_at", dailySince);

  if (dailyError) {
    console.error("Anonymous daily limit lookup failed", dailyError);
    return false;
  }

  return (dailyCount ?? 0) < ANON_MAX_REQUESTS_PER_DAY;
}

async function logRequest(log: RequestLog): Promise<void> {
  if (!supabaseAdmin) {
    console.error("Supabase service role client is not configured; skipping proxy request log.");
    return;
  }

  const { error } = await supabaseAdmin.from("openai_proxy_requests").insert(log);
  if (error) {
    console.error("Failed to write OpenAI proxy request log", error);
  }
}

function sanitizeForwardHeaders(req: Request): Headers {
  const headers = new Headers();
  const contentType = req.headers.get("content-type");
  if (contentType) {
    headers.set("Content-Type", contentType);
  }
  headers.set("Authorization", `Bearer ${OPENAI_API_KEY}`);
  headers.set("Accept", "application/json");
  return headers;
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

function sanitizeTools(tools: unknown): unknown {
  if (!Array.isArray(tools)) {
    return tools;
  }

  return tools.filter((tool) => {
    if (!tool || typeof tool !== "object") {
      return false;
    }

    const candidate = tool as Record<string, unknown>;
    const toolType = typeof candidate.type === "string" ? candidate.type : "";
    if (!ALLOWED_TOOL_TYPES.has(toolType)) {
      return false;
    }

    if (toolType === "function") {
      const name = typeof candidate.name === "string"
        ? candidate.name
        : typeof (candidate.function as Record<string, unknown> | undefined)?.name === "string"
        ? String((candidate.function as Record<string, unknown>).name)
        : "";
      return ALLOWED_FUNCTION_NAMES.has(name);
    }

    return true;
  });
}

function sanitizeResponsesBody(bodyBytes: ArrayBuffer, userId: string): {
  bytes: Uint8Array;
  model: string | null;
  stream: boolean;
} {
  const decoder = new TextDecoder();
  const encoder = new TextEncoder();
  const json = JSON.parse(decoder.decode(bodyBytes)) as Record<string, unknown>;

  const requestedModel = typeof json.model === "string" ? json.model : null;
  const resolvedModel = requestedModel ? MODEL_ALIASES.get(requestedModel) ?? requestedModel : null;
  const isServerSideAlias = requestedModel ? MODEL_ALIASES.has(requestedModel) : false;
  if (!resolvedModel || (!isServerSideAlias && !ALLOWED_MODELS.includes(resolvedModel))) {
    throw new Error(`Model is not allowed: ${requestedModel ?? "missing"}`);
  }
  json.model = resolvedModel;

  if (typeof json.max_output_tokens === "number") {
    json.max_output_tokens = Math.min(json.max_output_tokens, MAX_OUTPUT_TOKENS);
  } else if (json.max_output_tokens == null) {
    json.max_output_tokens = MAX_OUTPUT_TOKENS;
  }

  if (json.tools != null) {
    json.tools = sanitizeTools(json.tools);
  }

  json.user = userId;
  json.metadata = {
    ...(json.metadata && typeof json.metadata === "object" ? json.metadata : {}),
    howai_user_id: userId,
  };

  return {
    bytes: encoder.encode(JSON.stringify(json)),
    model: resolvedModel,
    stream: json.stream === true,
  };
}

function extractUsage(responseJson: Record<string, unknown>): {
  responseId: string | null;
  inputTokens: number | null;
  outputTokens: number | null;
  totalTokens: number | null;
} {
  const usage = responseJson.usage && typeof responseJson.usage === "object"
    ? responseJson.usage as Record<string, unknown>
    : {};

  const inputTokens = typeof usage.input_tokens === "number"
    ? usage.input_tokens
    : typeof usage.prompt_tokens === "number"
    ? usage.prompt_tokens
    : null;
  const outputTokens = typeof usage.output_tokens === "number"
    ? usage.output_tokens
    : typeof usage.completion_tokens === "number"
    ? usage.completion_tokens
    : null;
  const totalTokens = typeof usage.total_tokens === "number"
    ? usage.total_tokens
    : inputTokens != null && outputTokens != null
    ? inputTokens + outputTokens
    : null;

  return {
    responseId: typeof responseJson.id === "string" ? responseJson.id : null,
    inputTokens,
    outputTokens,
    totalTokens,
  };
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (!OPENAI_API_KEY) {
    return jsonResponse(500, { error: "OPENAI_API_KEY is not configured on proxy" }, origin);
  }
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY || !supabaseAdmin) {
    return jsonResponse(500, { error: "Supabase proxy auth/logging secrets are not configured" }, origin);
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" }, origin);
  }

  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required" }, origin);
  }

  if (!(await isWithinRateLimit(user))) {
    return jsonResponse(429, { error: "Temporary usage limit reached" }, origin);
  }

  const url = new URL(req.url);
  const path = targetPath(url.pathname);
  if (!path) {
    return jsonResponse(404, { error: "Unsupported endpoint" }, origin);
  }

  const contentLengthError = validateContentLength(req, origin);
  if (contentLengthError) {
    return contentLengthError;
  }

  try {
    const originalBodyBytes = await req.arrayBuffer();
    if (originalBodyBytes.byteLength > MAX_BODY_BYTES) {
      return jsonResponse(413, { error: "Payload too large" }, origin);
    }

    let forwardBody: ArrayBuffer | Uint8Array = originalBodyBytes;
    let model: string | null = null;
    let isStreaming = false;

    if (path === "/v1/responses") {
      const sanitized = sanitizeResponsesBody(originalBodyBytes, user.id);
      forwardBody = sanitized.bytes;
      model = sanitized.model;
      isStreaming = sanitized.stream;
    } else {
      model = "whisper-1";
    }

    const upstream = await fetch(`${OPENAI_BASE_URL}${path}`, {
      method: "POST",
      headers: sanitizeForwardHeaders(req),
      body: forwardBody,
    });

    const responseHeaders = new Headers(corsHeaders(origin));
    responseHeaders.set("Cache-Control", "no-store");

    const upstreamContentType = upstream.headers.get("content-type");
    if (upstreamContentType) {
      responseHeaders.set("Content-Type", upstreamContentType);
    }

    if (isStreaming) {
      await logRequest({
        user_id: user.id,
        is_anonymous: user.isAnonymous,
        endpoint: path,
        model,
        status_code: upstream.status,
        request_bytes: originalBodyBytes.byteLength,
      });

      return new Response(upstream.body, {
        status: upstream.status,
        headers: responseHeaders,
      });
    }

    const responseText = await upstream.text();
    let responseId: string | null = null;
    let inputTokens: number | null = null;
    let outputTokens: number | null = null;
    let totalTokens: number | null = null;
    let upstreamError: string | null = null;

    try {
      const responseJson = JSON.parse(responseText) as Record<string, unknown>;
      const usage = extractUsage(responseJson);
      responseId = usage.responseId;
      inputTokens = usage.inputTokens;
      outputTokens = usage.outputTokens;
      totalTokens = usage.totalTokens;

      const error = responseJson.error;
      if (error && typeof error === "object" && "message" in error) {
        upstreamError = String((error as Record<string, unknown>).message);
      }
    } catch {
      upstreamError = upstream.ok ? null : responseText.slice(0, 500);
    }

    await logRequest({
      user_id: user.id,
      is_anonymous: user.isAnonymous,
      endpoint: path,
      model,
      status_code: upstream.status,
      request_bytes: originalBodyBytes.byteLength,
      response_id: responseId,
      input_tokens: inputTokens,
      output_tokens: outputTokens,
      total_tokens: totalTokens,
      error: upstreamError,
    });

    return new Response(responseText, {
      status: upstream.status,
      headers: responseHeaders,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await logRequest({
      user_id: user.id,
      is_anonymous: user.isAnonymous,
      endpoint: targetPath(new URL(req.url).pathname) ?? "unknown",
      model: null,
      status_code: message.startsWith("Model is not allowed") ? 400 : 502,
      request_bytes: 0,
      error: message,
    });

    if (message.startsWith("Model is not allowed")) {
      return jsonResponse(400, { error: message }, origin);
    }

    return jsonResponse(502, { error: "Proxy upstream request failed", detail: message }, origin);
  }
});
