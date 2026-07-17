import { assertEquals } from "jsr:@std/assert@1";
import { isStoredEntitlementActive } from "./entitlement-status.ts";

Deno.test("paid entitlement without expiry is active", () => {
  assertEquals(isStoredEntitlementActive({ tier: "paid" }, 1_000), true);
});

Deno.test("future paid entitlement is active", () => {
  assertEquals(
    isStoredEntitlementActive(
      { tier: "paid", expires_at: "2026-07-17T00:00:02.000Z" },
      Date.parse("2026-07-17T00:00:01.000Z"),
    ),
    true,
  );
});

Deno.test("free, expired, and malformed entitlements are inactive", () => {
  const now = Date.parse("2026-07-17T00:00:03.000Z");
  assertEquals(isStoredEntitlementActive({ tier: "free" }, now), false);
  assertEquals(
    isStoredEntitlementActive(
      { tier: "paid", expires_at: "2026-07-17T00:00:02.000Z" },
      now,
    ),
    false,
  );
  assertEquals(
    isStoredEntitlementActive({ tier: "paid", expires_at: "not-a-date" }, now),
    false,
  );
});
