import assert from "node:assert/strict";
import test from "node:test";

import {
  AppleEntitlementValidationError,
  evaluateAppleTransaction,
  parseAllowedAppleStoreEnvironments,
} from "./apple-entitlement.ts";

const now = Date.parse("2026-07-15T00:00:00.000Z");
const config = {
  bundleId: "com.hyu.HaoGPT",
  environments: new Set(["Production" as const]),
  productIds: new Set([
    "com.hyu.HaoGPT.premium.monthly",
    "com.haoyu.HaoGPT.premium.yearly",
  ]),
};

function transaction(overrides: Record<string, unknown> = {}) {
  return {
    appAccountToken: "d6910c15-f197-4ac7-ac2f-5991ccf537eb",
    bundleId: "com.hyu.HaoGPT",
    environment: "Production",
    expiresDate: now + 30 * 24 * 60 * 60 * 1_000,
    originalTransactionId: "2000000123456789",
    productId: "com.hyu.HaoGPT.premium.monthly",
    purchaseDate: now - 60_000,
    signedDate: now - 60_000,
    transactionId: "2000000123456790",
    type: "Auto-Renewable Subscription",
    ...overrides,
  };
}

test("accepts an active verified HowAI subscription", () => {
  const result = evaluateAppleTransaction(transaction(), config, now);

  assert.equal(result.active, true);
  assert.equal(result.revoked, false);
  assert.equal(result.originalTransactionId, "2000000123456789");
  assert.equal(result.purchaseAt, "2026-07-14T23:59:00.000Z");
  assert.equal(result.expiresAt, "2026-08-14T00:00:00.000Z");
});

test("expired and revoked transactions do not grant paid access", () => {
  assert.equal(
    evaluateAppleTransaction(transaction({ expiresDate: now - 1 }), config, now)
      .active,
    false,
  );
  assert.equal(
    evaluateAppleTransaction(
      transaction({ revocationDate: now - 1 }),
      config,
      now,
    ).active,
    false,
  );
});

test("rejects a transaction for another app, product, or environment", () => {
  for (
    const invalid of [
      transaction({ bundleId: "com.example.attacker" }),
      transaction({ productId: "com.example.premium" }),
      transaction({ environment: "Sandbox" }),
    ]
  ) {
    assert.throws(
      () => evaluateAppleTransaction(invalid, config, now),
      AppleEntitlementValidationError,
    );
  }
});

test("production is the safe default Apple environment", () => {
  assert.deepEqual(
    [...parseAllowedAppleStoreEnvironments(undefined)],
    ["Production"],
  );
  assert.deepEqual(
    [...parseAllowedAppleStoreEnvironments("Sandbox")],
    ["Sandbox"],
  );
  assert.deepEqual(
    [...parseAllowedAppleStoreEnvironments("invalid")],
    ["Production"],
  );
});

test("rejects malformed identifiers, timestamps, and future signatures", () => {
  for (
    const invalid of [
      transaction({ originalTransactionId: "" }),
      transaction({ expiresDate: "tomorrow" }),
      transaction({ purchaseDate: now + 11 * 60 * 1_000 }),
      transaction({ expiresDate: now - 120_000 }),
      transaction({ signedDate: now + 11 * 60 * 1_000 }),
    ]
  ) {
    assert.throws(
      () => evaluateAppleTransaction(invalid, config, now),
      AppleEntitlementValidationError,
    );
  }
});
