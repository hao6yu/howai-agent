import assert from "node:assert/strict";
import test from "node:test";

import {
  assertAuthenticatedAccountRequest,
  assertStoreAccountAttribution,
  StoreAccountAttributionError,
} from "./store-account-attribution.ts";

const userId = "d6910c15-f197-4ac7-ac2f-5991ccf537eb";

test("accepts matching and legacy store account attribution", () => {
  assert.doesNotThrow(() =>
    assertStoreAccountAttribution(userId, userId, "Store")
  );
  assert.doesNotThrow(() =>
    assertStoreAccountAttribution(userId, userId.toUpperCase(), "Store")
  );
  assert.doesNotThrow(() =>
    assertStoreAccountAttribution(userId, null, "Store")
  );
});

test("rejects a store purchase attributed to another HowAI account", () => {
  assert.throws(
    () =>
      assertStoreAccountAttribution(
        userId,
        "91000000-0000-4000-8000-000000000002",
        "Store",
      ),
    StoreAccountAttributionError,
  );
});

test("binds new verification requests while allowing legacy clients", () => {
  assert.doesNotThrow(() => assertAuthenticatedAccountRequest(userId, userId));
  assert.doesNotThrow(() =>
    assertAuthenticatedAccountRequest(userId, userId.toUpperCase())
  );
  assert.doesNotThrow(() => assertAuthenticatedAccountRequest(userId, null));
  assert.throws(
    () =>
      assertAuthenticatedAccountRequest(
        userId,
        "91000000-0000-4000-8000-000000000002",
      ),
    StoreAccountAttributionError,
  );
});
