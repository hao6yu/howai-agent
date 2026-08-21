import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { summarizeAppleTransactionJws } from "./apple-verification-diagnostics.ts";

const EXPECTED_BUNDLE_ID = "com.hyu.HaoGPT";
const EXPECTED_PRODUCT_ID = "com.haoyu.HaoGPT.premium.yearly";

Deno.test("summarizes non-sensitive Apple transaction claims", () => {
  const signedTransaction = compactJws(
    { alg: "ES256", x5c: ["leaf", "intermediate"] },
    {
      bundleId: EXPECTED_BUNDLE_ID,
      environment: "Production",
      expiresDate: 1_800_000_000_000,
      originalTransactionId: "original-secret-id",
      productId: EXPECTED_PRODUCT_ID,
      transactionId: "secret-id",
    },
  );

  assertEquals(
    summarizeAppleTransactionJws(
      signedTransaction,
      EXPECTED_BUNDLE_ID,
      new Set([EXPECTED_PRODUCT_ID]),
    ),
    {
      certificate_chain_length: 2,
      compact_parts: 3,
      header_algorithm: "ES256",
      payload_bundle_id: EXPECTED_BUNDLE_ID,
      payload_environment: "Production",
      payload_has_expiration: true,
      payload_has_original_transaction_id: true,
      payload_has_transaction_id: true,
      payload_product_id: EXPECTED_PRODUCT_ID,
      bundle_id_matches_expected: true,
      product_id_allowed: true,
      signed_transaction_length: signedTransaction.length,
    },
  );
});

Deno.test("reports malformed data without exposing receipt identifiers", () => {
  const diagnostic = summarizeAppleTransactionJws(
    "not-json.payload.signature",
    EXPECTED_BUNDLE_ID,
    new Set([EXPECTED_PRODUCT_ID]),
  );

  assertEquals(diagnostic.compact_parts, 3);
  assertEquals(diagnostic.payload_bundle_id, null);
  assertEquals(diagnostic.payload_product_id, null);
  assertEquals(diagnostic.payload_has_original_transaction_id, false);
  assertEquals(diagnostic.payload_has_transaction_id, false);
});

function compactJws(
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
): string {
  return `${base64Url(header)}.${base64Url(payload)}.signature`;
}

function base64Url(value: Record<string, unknown>): string {
  return btoa(JSON.stringify(value))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}
