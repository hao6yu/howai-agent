const OPENAI_BASE_URL = "https://api.openai.com";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const PROXY_SHARED_TOKEN = Deno.env.get("PROXY_SHARED_TOKEN") ?? "";
const MAX_BODY_BYTES = 25 * 1024 * 1024; // 25MB
const MAX_REQUEST_SKEW_SECONDS = 300; // 5 minutes

function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers": "authorization, x-howai-proxy-token, x-howai-timestamp, content-type, x-client-info, apikey",
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

function validateProxyToken(req: Request): boolean {
  if (!PROXY_SHARED_TOKEN) {
    return true; // token auth optional for local setup
  }
  const incoming = req.headers.get("x-howai-proxy-token") ?? "";
  return incoming === PROXY_SHARED_TOKEN;
}

function validateRequestTimestamp(req: Request): boolean {
  if (!PROXY_SHARED_TOKEN) {
    return true; // local/dev mode
  }

  const raw = req.headers.get("x-howai-timestamp");
  if (!raw) return false;

  const ts = Number(raw);
  if (!Number.isFinite(ts)) return false;

  const now = Math.floor(Date.now() / 1000);
  return Math.abs(now - ts) <= MAX_REQUEST_SKEW_SECONDS;
}

function targetPath(pathname: string): "/v1/responses" | "/v1/audio/transcriptions" | null {
  if (pathname.endsWith("/v1/responses")) return "/v1/responses";
  if (pathname.endsWith("/v1/audio/transcriptions")) return "/v1/audio/transcriptions";
  return null;
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

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (!OPENAI_API_KEY) {
    return jsonResponse(500, { error: "OPENAI_API_KEY is not configured on proxy" }, origin);
  }

  if (!validateProxyToken(req)) {
    return jsonResponse(401, { error: "Invalid proxy token" }, origin);
  }

  if (!validateRequestTimestamp(req)) {
    return jsonResponse(401, { error: "Invalid or missing timestamp" }, origin);
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" }, origin);
  }

  const url = new URL(req.url);
  const path = targetPath(url.pathname);
  if (!path) {
    return jsonResponse(404, { error: "Unsupported endpoint" }, origin);
  }

  const contentLengthRaw = req.headers.get("content-length");
  if (contentLengthRaw) {
    const contentLength = Number(contentLengthRaw);
    if (Number.isFinite(contentLength) && contentLength > MAX_BODY_BYTES) {
      return jsonResponse(413, { error: "Payload too large" }, origin);
    }
  }

  try {
    const bodyBytes = await req.arrayBuffer();
    if (bodyBytes.byteLength > MAX_BODY_BYTES) {
      return jsonResponse(413, { error: "Payload too large" }, origin);
    }

    const upstream = await fetch(`${OPENAI_BASE_URL}${path}`, {
      method: "POST",
      headers: sanitizeForwardHeaders(req),
      body: bodyBytes,
    });

    const responseHeaders = new Headers(corsHeaders(origin));
    responseHeaders.set("Cache-Control", "no-store");

    const upstreamContentType = upstream.headers.get("content-type");
    if (upstreamContentType) {
      responseHeaders.set("Content-Type", upstreamContentType);
    }

    return new Response(upstream.body, {
      status: upstream.status,
      headers: responseHeaders,
    });
  } catch (error) {
    return jsonResponse(
      502,
      {
        error: "Proxy upstream request failed",
        detail: error instanceof Error ? error.message : String(error),
      },
      origin,
    );
  }
});
