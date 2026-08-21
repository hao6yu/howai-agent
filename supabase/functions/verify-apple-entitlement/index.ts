import { createClient } from "npm:@supabase/supabase-js@2.111.0";

import {
  AppleEntitlementValidationError,
  type AppleTransactionPayload,
  evaluateAppleTransaction,
} from "../_shared/apple-entitlement.ts";
import { APPLE_ROOT_CA_DER_BASE64 } from "../_shared/apple-root-certificates.ts";
import {
  AppleSignedDataVerificationError,
  verifyAndDecodeAppleTransaction,
} from "../_shared/apple-signed-data-verifier.ts";
import { summarizeAppleTransactionJws } from "../_shared/apple-verification-diagnostics.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";

const APPLE_BUNDLE_ID = Deno.env.get("APPLE_APP_BUNDLE_ID") ?? "com.hyu.HaoGPT";
const APPLE_PRODUCT_IDS = new Set(
  (Deno.env.get("APPLE_SUBSCRIPTION_PRODUCT_IDS") ??
    "com.hyu.HaoGPT.premium.monthly,com.haoyu.HaoGPT.premium.yearly")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean),
);
const MAX_BODY_BYTES = 32 * 1024;
const MAX_SIGNED_TRANSACTION_LENGTH = 24 * 1024;

type AuthenticatedUser = Readonly<{
  id: string;
  isAnonymous: boolean;
}>;

type VerifiedTransaction = Readonly<{
  environment: "Production" | "Sandbox";
  payload: AppleTransactionPayload;
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

  if (!supabaseAdmin) {
    console.error("Apple entitlement verification is not configured.");
    return jsonResponse(503, {
      error: "Entitlement verification is unavailable.",
    }, origin);
  }

  const requestBody = await req.text();
  if (new TextEncoder().encode(requestBody).byteLength > MAX_BODY_BYTES) {
    return jsonResponse(413, { error: "Request body is too large." }, origin);
  }

  let signedTransaction: string;
  try {
    const body = JSON.parse(requestBody) as Record<string, unknown>;
    signedTransaction = typeof body.signed_transaction === "string"
      ? body.signed_transaction.trim()
      : "";
  } catch {
    return jsonResponse(
      400,
      { error: "Request body must be valid JSON." },
      origin,
    );
  }

  if (
    signedTransaction.length === 0 ||
    signedTransaction.length > MAX_SIGNED_TRANSACTION_LENGTH ||
    signedTransaction.split(".").length !== 3
  ) {
    return jsonResponse(400, {
      error: "A valid signed App Store transaction is required.",
    }, origin);
  }

  try {
    const verified = await verifySignedTransaction(signedTransaction);
    const decision = evaluateAppleTransaction(
      verified.payload,
      {
        bundleId: APPLE_BUNDLE_ID,
        environment: verified.environment,
        productIds: APPLE_PRODUCT_IDS,
      },
    );
    const now = new Date().toISOString();

    const { data: currentEntitlement, error: currentError } =
      await supabaseAdmin
        .from("app_entitlements")
        .select("source, source_reference")
        .eq("user_id", user.id)
        .maybeSingle();
    if (currentError) {
      throw new Error(
        `Current entitlement lookup failed: ${currentError.message}`,
      );
    }

    const metadata = {
      app_account_token_matches: decision.appAccountToken == null
        ? null
        : decision.appAccountToken === user.id,
      app_account_token_present: decision.appAccountToken != null,
      environment: decision.environment,
      product_id: decision.productId,
      revoked: decision.revoked,
      signed_at: decision.signedAt,
      transaction_id: decision.transactionId,
    };

    if (decision.active) {
      const { error } = await supabaseAdmin.rpc(
        "claim_store_entitlement",
        {
          p_user_id: user.id,
          p_source: "app_store",
          p_source_reference: decision.originalTransactionId,
          p_linked_source_reference: null,
          p_verified_at: now,
          p_expires_at: decision.expiresAt,
          p_metadata: metadata,
        },
      );
      if (error) throw new Error(`Entitlement claim failed: ${error.message}`);
    } else if (
      currentEntitlement?.source === "app_store" &&
      currentEntitlement.source_reference === decision.originalTransactionId
    ) {
      const { error } = await supabaseAdmin
        .from("app_entitlements")
        .update({
          tier: "free",
          verified_at: now,
          expires_at: decision.expiresAt,
          metadata,
          updated_at: now,
        })
        .eq("user_id", user.id)
        .eq("source", "app_store")
        .eq("source_reference", decision.originalTransactionId);
      if (error) {
        throw new Error(`Expired entitlement update failed: ${error.message}`);
      }
    }

    return jsonResponse(
      200,
      {
        entitlement: {
          active: decision.active,
          environment: decision.environment,
          expires_at: decision.expiresAt,
          product_id: decision.productId,
          verified_at: now,
        },
      },
      origin,
    );
  } catch (error) {
    if (error instanceof AppleEntitlementValidationError) {
      console.warn(
        "Apple transaction payload validation rejected",
        JSON.stringify({
          diagnostic_version: "apple_verification_v2",
          rejection: error.message,
          transaction: summarizeAppleTransactionJws(
            signedTransaction,
            APPLE_BUNDLE_ID,
            APPLE_PRODUCT_IDS,
          ),
        }),
      );
      return jsonResponse(422, { error: error.message }, origin);
    }

    if (error instanceof AppleSignedDataVerificationError) {
      console.warn(
        "Apple signed transaction verification failed",
        JSON.stringify({
          diagnostic_version: "apple_verification_v2",
          verification_code: error.code,
          transaction: summarizeAppleTransactionJws(
            signedTransaction,
            APPLE_BUNDLE_ID,
            APPLE_PRODUCT_IDS,
          ),
        }),
      );
      return jsonResponse(422, {
        error: "App Store transaction verification failed.",
      }, origin);
    }

    console.error("Apple entitlement verification failed", error);
    return jsonResponse(503, {
      error: "Entitlement verification is temporarily unavailable.",
    }, origin);
  }
});

async function verifySignedTransaction(
  signedTransaction: string,
): Promise<VerifiedTransaction> {
  const payload = await verifyAndDecodeAppleTransaction(
    signedTransaction,
    APPLE_ROOT_CA_DER_BASE64,
  );
  if (payload.environment === "Production") {
    return { environment: "Production", payload };
  }
  if (payload.environment === "Sandbox") {
    return { environment: "Sandbox", payload };
  }
  throw new AppleEntitlementValidationError(
    "Unexpected App Store environment.",
  );
}

async function authenticateUser(
  req: Request,
): Promise<AuthenticatedUser | null> {
  const authHeader = req.headers.get("authorization") ?? "";
  const accessToken = authHeader.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!accessToken || !SUPABASE_URL || !SUPABASE_ANON_KEY) return null;

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await supabase.auth.getUser(accessToken);
  if (error || !data.user) return null;

  const user = data.user as typeof data.user & { is_anonymous?: boolean };
  return { id: user.id, isAnonymous: user.is_anonymous === true };
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
