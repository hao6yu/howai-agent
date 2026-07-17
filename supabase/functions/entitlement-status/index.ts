import { createClient } from "npm:@supabase/supabase-js@2";
import { isStoredEntitlementActive } from "../_shared/entitlement-status.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";

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
      200,
      {
        entitlement: {
          active: false,
          tier: "free",
          source: "anonymous",
          expires_at: null,
        },
      },
      origin,
    );
  }
  if (!supabaseAdmin) {
    return jsonResponse(
      503,
      { error: "Entitlement lookup is unavailable." },
      origin,
    );
  }

  const { data, error } = await supabaseAdmin
    .from("app_entitlements")
    .select("tier,source,expires_at,verified_at")
    .eq("user_id", user.id)
    .maybeSingle();
  if (error) {
    console.error("Entitlement lookup failed", error);
    return jsonResponse(
      503,
      { error: "Entitlement lookup is temporarily unavailable." },
      origin,
    );
  }

  const active = isStoredEntitlementActive(data);
  return jsonResponse(
    200,
    {
      entitlement: {
        active,
        tier: active ? "paid" : "free",
        source: typeof data?.source === "string" ? data.source : null,
        expires_at: typeof data?.expires_at === "string"
          ? data.expires_at
          : null,
        verified_at: typeof data?.verified_at === "string"
          ? data.verified_at
          : null,
      },
    },
    origin,
  );
});

async function authenticateUser(
  req: Request,
): Promise<{ id: string; isAnonymous: boolean } | null> {
  const token = (req.headers.get("authorization") ?? "").match(
    /^Bearer\s+(.+)$/i,
  )?.[1];
  if (!token || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;

  const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.getUser(token);
  if (error || !data.user) return null;

  return {
    id: data.user.id,
    isAnonymous: (data.user as typeof data.user & {
      is_anonymous?: boolean;
    }).is_anonymous === true,
  };
}

function corsHeaders(origin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Content-Type": "application/json",
    "Cache-Control": "no-store",
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
    headers: corsHeaders(origin),
  });
}
