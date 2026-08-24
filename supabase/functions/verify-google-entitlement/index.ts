import { createClient } from "npm:@supabase/supabase-js@2.111.0";
import {
  allowGooglePlayTestPurchases,
  evaluateGooglePlaySubscription,
  GooglePlayEntitlementValidationError,
} from "../_shared/google-play-entitlement.ts";
import {
  assertAuthenticatedAccountRequest,
  assertStoreAccountAttribution,
  StoreAccountAttributionError,
} from "../_shared/store-account-attribution.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";
const GOOGLE_PLAY_PACKAGE_NAME = Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME") ??
  "com.hyu.haogpt";
const GOOGLE_PLAY_PRODUCT_IDS = new Set(
  (Deno.env.get("GOOGLE_PLAY_SUBSCRIPTION_PRODUCT_IDS") ??
    "com.hyu.haogpt.premium.monthly,com.haoyu.haogpt.premium.yearly")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean),
);
const SERVICE_ACCOUNT_JSON = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON") ??
  "";
const GOOGLE_PLAY_TEST_PURCHASES_ALLOWED = allowGooglePlayTestPurchases(
  Deno.env.get("GOOGLE_PLAY_ALLOW_TEST_PURCHASES"),
);
const MAX_BODY_BYTES = 8 * 1024;
// Google documents purchase tokens as opaque strings without a small fixed
// limit. Keep a defensive request bound without truncating valid tokens.
const MAX_TOKEN_LENGTH = 4 * 1024;

type ServiceAccount = Readonly<{
  client_email: string;
  private_key: string;
  token_uri: string;
}>;

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
  if (!supabaseAdmin || !SERVICE_ACCOUNT_JSON) {
    return jsonResponse(503, {
      error: "Google Play verification is unavailable.",
    }, origin);
  }

  const rawBody = await req.text();
  if (new TextEncoder().encode(rawBody).byteLength > MAX_BODY_BYTES) {
    return jsonResponse(413, { error: "Request body is too large." }, origin);
  }

  let purchaseToken = "";
  let productId = "";
  let requestedAccountId: unknown;
  try {
    const body = JSON.parse(rawBody) as Record<string, unknown>;
    purchaseToken = typeof body.purchase_token === "string"
      ? body.purchase_token.trim()
      : "";
    productId = typeof body.product_id === "string"
      ? body.product_id.trim()
      : "";
    requestedAccountId = body.account_id;
  } catch {
    return jsonResponse(
      400,
      { error: "Request body must be valid JSON." },
      origin,
    );
  }
  if (
    purchaseToken.length === 0 || purchaseToken.length > MAX_TOKEN_LENGTH ||
    !GOOGLE_PLAY_PRODUCT_IDS.has(productId)
  ) {
    return jsonResponse(400, {
      error: "A valid Google Play purchase is required.",
    }, origin);
  }

  try {
    assertAuthenticatedAccountRequest(user.id, requestedAccountId);
    const serviceAccount = parseServiceAccount(SERVICE_ACCOUNT_JSON);
    const accessToken = await createGoogleAccessToken(serviceAccount);
    const url = new URL(
      `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${
        encodeURIComponent(GOOGLE_PLAY_PACKAGE_NAME)
      }/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`,
    );
    const googleResponse = await fetch(url, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        Accept: "application/json",
      },
    });
    if (!googleResponse.ok) {
      console.warn(
        "Google Play purchase verification failed",
        googleResponse.status,
      );
      return jsonResponse(
        googleResponse.status === 404 ? 422 : 503,
        {
          error: googleResponse.status === 404
            ? "Google Play purchase was not found."
            : "Google Play verification is temporarily unavailable.",
        },
        origin,
      );
    }

    const purchase = await googleResponse.json() as Record<string, unknown>;
    const decision = evaluateGooglePlaySubscription(
      purchase,
      GOOGLE_PLAY_PRODUCT_IDS,
      productId,
    );
    if (decision.testPurchase && !GOOGLE_PLAY_TEST_PURCHASES_ALLOWED) {
      throw new GooglePlayEntitlementValidationError(
        "Google Play test purchases are not accepted by this deployment.",
      );
    }
    assertStoreAccountAttribution(
      user.id,
      decision.obfuscatedExternalAccountId,
      "Google Play",
    );
    const now = new Date().toISOString();
    const metadata = {
      linked_purchase_token: decision.linkedPurchaseToken,
      product_id: decision.productId,
      revoked: false,
      subscription_state: decision.state,
      test_purchase: decision.testPurchase,
      obfuscated_account_id_matches:
        decision.obfuscatedExternalAccountId == null
          ? null
          : decision.obfuscatedExternalAccountId === user.id,
    };

    const { data: reconciliationRows, error: reconciliationError } =
      await supabaseAdmin.rpc("reconcile_store_entitlement", {
        p_user_id: user.id,
        p_source: "play_store",
        p_source_reference: purchaseToken,
        p_linked_source_reference: decision.linkedPurchaseToken,
        p_active: decision.active,
        p_verified_at: now,
        p_expires_at: decision.expiresAt,
        p_revoked: false,
        p_metadata: metadata,
      });
    if (reconciliationError) {
      throw new Error(
        `Entitlement reconciliation failed: ${reconciliationError.message}`,
      );
    }
    const reconciliation = Array.isArray(reconciliationRows)
      ? reconciliationRows[0]
      : null;
    if (!reconciliation || typeof reconciliation !== "object") {
      throw new Error("Entitlement reconciliation returned no result.");
    }

    const effectiveActive = reconciliation.active === true;
    const effectiveExpiresAt =
      typeof reconciliation.effective_expires_at === "string"
        ? reconciliation.effective_expires_at
        : null;
    const effectiveSource = typeof reconciliation.effective_source === "string"
      ? reconciliation.effective_source
      : null;

    return jsonResponse(200, {
      entitlement: {
        active: effectiveActive,
        applied: reconciliation.applied === true,
        expires_at: effectiveExpiresAt,
        product_id: decision.productId,
        source: effectiveSource,
        state: decision.state,
        verified_at: now,
      },
    }, origin);
  } catch (error) {
    if (error instanceof StoreAccountAttributionError) {
      return jsonResponse(409, { error: error.message }, origin);
    }
    if (error instanceof GooglePlayEntitlementValidationError) {
      return jsonResponse(422, { error: error.message }, origin);
    }
    console.error("Google Play entitlement verification failed", error);
    return jsonResponse(
      503,
      { error: "Google Play verification is temporarily unavailable." },
      origin,
    );
  }
});

function parseServiceAccount(value: string): ServiceAccount {
  const parsed = JSON.parse(value) as Record<string, unknown>;
  const clientEmail = typeof parsed.client_email === "string"
    ? parsed.client_email.trim()
    : "";
  const privateKey = typeof parsed.private_key === "string"
    ? parsed.private_key.trim()
    : "";
  const tokenUri = typeof parsed.token_uri === "string"
    ? parsed.token_uri.trim()
    : "https://oauth2.googleapis.com/token";
  if (
    !clientEmail || !privateKey.includes("BEGIN PRIVATE KEY") ||
    tokenUri !== "https://oauth2.googleapis.com/token"
  ) {
    throw new Error("Invalid Google Play service account configuration.");
  }
  return {
    client_email: clientEmail,
    private_key: privateKey,
    token_uri: tokenUri,
  };
}

async function createGoogleAccessToken(
  account: ServiceAccount,
): Promise<string> {
  const now = Math.floor(Date.now() / 1_000);
  const header = base64UrlJson({ alg: "RS256", typ: "JWT" });
  const claims = base64UrlJson({
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: account.token_uri,
    iat: now,
    exp: now + 3_600,
  });
  const unsigned = `${header}.${claims}`;
  const keyData = pemToBytes(account.private_key);
  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const assertion = `${unsigned}.${base64UrlBytes(new Uint8Array(signature))}`;
  const response = await fetch(account.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const body = await response.json() as Record<string, unknown>;
  const token = typeof body.access_token === "string" ? body.access_token : "";
  if (!response.ok || !token) {
    throw new Error("Google access token request failed.");
  }
  return token;
}

function pemToBytes(value: string): ArrayBuffer {
  const base64 = value
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");
  return Uint8Array.from(
    atob(base64),
    (character) => character.charCodeAt(0),
  ).buffer as ArrayBuffer;
}

function base64UrlJson(value: Record<string, unknown>): string {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(value: Uint8Array): string {
  let binary = "";
  for (const byte of value) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(
    /=+$/g,
    "",
  );
}

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
      "Cache-Control": "no-store",
      "Content-Type": "application/json",
    },
  });
}
