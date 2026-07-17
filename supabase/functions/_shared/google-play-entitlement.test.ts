import { assertEquals } from "jsr:@std/assert@1";
import { evaluateGooglePlaySubscription } from "./google-play-entitlement.ts";

const products = new Set([
  "com.hyu.haogpt.premium.monthly",
  "com.haoyu.haogpt.premium.yearly",
]);
const now = Date.parse("2026-07-17T17:00:00.000Z");

Deno.test("accepts active and grace-period matching subscriptions", () => {
  for (
    const state of [
      "SUBSCRIPTION_STATE_ACTIVE",
      "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
      "SUBSCRIPTION_STATE_CANCELED",
    ]
  ) {
    const result = evaluateGooglePlaySubscription(
      {
        subscriptionState: state,
        lineItems: [{
          productId: "com.hyu.haogpt.premium.monthly",
          expiryTime: "2026-08-17T17:00:00.000Z",
        }],
      },
      products,
      "com.hyu.haogpt.premium.monthly",
      now,
    );
    assertEquals(result.active, true);
  }
});

Deno.test("rejects expired, pending, held, and mismatched products", () => {
  for (
    const value of [
      {
        subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
        lineItems: [{
          productId: "com.hyu.haogpt.premium.monthly",
          expiryTime: "2026-07-17T16:59:59.000Z",
        }],
      },
      {
        subscriptionState: "SUBSCRIPTION_STATE_PENDING",
        lineItems: [{
          productId: "com.hyu.haogpt.premium.monthly",
          expiryTime: "2026-08-17T17:00:00.000Z",
        }],
      },
      {
        subscriptionState: "SUBSCRIPTION_STATE_ON_HOLD",
        lineItems: [{
          productId: "com.hyu.haogpt.premium.monthly",
          expiryTime: "2026-08-17T17:00:00.000Z",
        }],
      },
      {
        subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
        lineItems: [{
          productId: "attacker.product",
          expiryTime: "2026-08-17T17:00:00.000Z",
        }],
      },
    ]
  ) {
    assertEquals(
      evaluateGooglePlaySubscription(
        value,
        products,
        "com.hyu.haogpt.premium.monthly",
        now,
      ).active,
      false,
    );
  }
});
