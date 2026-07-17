import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const MAX_BODY_BYTES = 16 * 1024;

const supabaseAdmin = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  : null;

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }
  if (req.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed." }, origin);
  }
  const user = await authenticateUser(req);
  if (!user) {
    return jsonResponse(401, { error: "Authentication required." }, origin);
  }
  if (user.isAnonymous) {
    return jsonResponse(
      403,
      { error: "A signed-in account is required." },
      origin,
    );
  }
  if (!supabaseAdmin) {
    return jsonResponse(
      503,
      { error: "Push registration is unavailable." },
      origin,
    );
  }

  let body: Record<string, unknown>;
  try {
    body = await readBody(req);
  } catch (error) {
    return jsonResponse(400, {
      error: error instanceof Error ? error.message : "Invalid request.",
    }, origin);
  }

  const available = await pushEnabled(user.id);
  if (body.operation === "status") {
    const { count, error } = await supabaseAdmin
      .from("push_devices")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .is("disabled_at", null);
    if (error) {
      return jsonResponse(
        503,
        { error: "Unable to read push status." },
        origin,
      );
    }
    return jsonResponse(200, {
      available,
      registered: (count ?? 0) > 0,
    }, origin);
  }
  if (!available) {
    return jsonResponse(403, {
      error: "Push notifications are not enabled for this account yet.",
    }, origin);
  }

  try {
    if (body.operation === "register") {
      const token = requiredText(body.token, "token", 4096, 20);
      const previousToken = optionalText(
        body.previous_token,
        "previous_token",
        4096,
      );
      const platform = body.platform;
      if (platform !== "android" && platform !== "ios") {
        throw new Error("platform must be android or ios.");
      }
      const timezone = requiredText(body.timezone, "timezone", 128, 1);
      validateTimezone(timezone);
      const locale = optionalText(body.locale, "locale", 32);
      const appVersion = optionalText(body.app_version, "app_version", 64);

      if (previousToken && previousToken !== token) {
        const { error } = await supabaseAdmin
          .from("push_devices")
          .update({
            disabled_at: new Date().toISOString(),
            invalid_reason: "token_rotated",
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", user.id)
          .eq("token", previousToken);
        if (error) throw error;
      }

      const now = new Date().toISOString();
      const { error } = await supabaseAdmin.from("push_devices").upsert({
        user_id: user.id,
        token,
        platform,
        timezone,
        locale,
        app_version: appVersion,
        last_seen_at: now,
        disabled_at: null,
        invalid_reason: null,
        updated_at: now,
      }, { onConflict: "token" });
      if (error) throw error;
      return jsonResponse(200, { registered: true }, origin);
    }

    if (body.operation === "unregister") {
      const token = requiredText(body.token, "token", 4096, 20);
      const now = new Date().toISOString();
      const { error } = await supabaseAdmin
        .from("push_devices")
        .update({
          disabled_at: now,
          invalid_reason: "signed_out",
          updated_at: now,
        })
        .eq("user_id", user.id)
        .eq("token", token);
      if (error) throw error;
      return jsonResponse(200, { registered: false }, origin);
    }

    return jsonResponse(400, { error: "Unsupported operation." }, origin);
  } catch (error) {
    console.error("Push device request failed", safeErrorCode(error));
    return jsonResponse(422, {
      error: error instanceof Error
        ? error.message
        : "Invalid push device request.",
    }, origin);
  }
});

async function pushEnabled(userId: string): Promise<boolean> {
  const { data: flag, error: flagError } = await supabaseAdmin!
    .from("feature_flags")
    .select("enabled,payload")
    .eq("key", "push_notifications")
    .maybeSingle();
  if (flagError || !flag?.enabled) return false;
  const payload = isRecord(flag.payload) ? flag.payload : {};
  if (payload.mode === "full") return true;
  if (payload.mode !== "internal") return false;
  const { data: entitlement, error } = await supabaseAdmin!
    .from("app_entitlements")
    .select("model_policy_canary")
    .eq("user_id", userId)
    .maybeSingle();
  return !error && entitlement?.model_policy_canary === true;
}

async function authenticateUser(
  req: Request,
): Promise<{ id: string; isAnonymous: boolean } | null> {
  const authHeader = req.headers.get("authorization") ?? "";
  const accessToken = authHeader.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;
  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.getUser(accessToken);
  if (error || !data.user) return null;
  const user = data.user as typeof data.user & { is_anonymous?: boolean };
  return { id: user.id, isAnonymous: user.is_anonymous === true };
}

async function readBody(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) {
    throw new Error("Request body is too large.");
  }
  const value = JSON.parse(text);
  if (!isRecord(value)) throw new Error("Request body must be a JSON object.");
  return value;
}

function requiredText(
  value: unknown,
  field: string,
  max: number,
  min: number,
): string {
  if (typeof value !== "string") throw new Error(`${field} must be a string.`);
  const normalized = value.trim();
  if (normalized.length < min || normalized.length > max) {
    throw new Error(`${field} has an invalid length.`);
  }
  return normalized;
}

function optionalText(
  value: unknown,
  field: string,
  max: number,
): string | null {
  if (value == null || value === "") return null;
  if (typeof value !== "string") {
    throw new Error(`${field} must be a string or null.`);
  }
  const normalized = value.trim();
  if (normalized.length > max) throw new Error(`${field} is too long.`);
  return normalized || null;
}

function validateTimezone(timezone: string): void {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: timezone }).format(new Date());
  } catch {
    throw new Error("timezone must be a valid IANA timezone.");
  }
}

function safeErrorCode(error: unknown): string {
  return isRecord(error) && typeof error.code === "string"
    ? error.code
    : error instanceof Error
    ? error.name
    : "unknown_error";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers":
      "authorization, content-type, x-client-info, apikey",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
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
      "Cache-Control": "no-store",
      "Content-Type": "application/json",
    },
  });
}
