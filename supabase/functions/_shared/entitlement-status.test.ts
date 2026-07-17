import { assertEquals } from "jsr:@std/assert@1";
import { isStoredEntitlementActive } from "./entitlement-status.ts";

Deno.test("only server-managed paid grants may omit expiry", () => {
  assertEquals(
    isStoredEntitlementActive({ tier: "paid", source: "admin" }, 1_000),
    true,
  );
  assertEquals(
    isStoredEntitlementActive({ tier: "paid", source: "migration" }, 1_000),
    true,
  );
  assertEquals(
    isStoredEntitlementActive({ tier: "paid", source: "app_store" }, 1_000),
    false,
  );
  assertEquals(
    isStoredEntitlementActive({ tier: "paid", source: "play_store" }, 1_000),
    false,
  );
});

Deno.test("future paid entitlement is active", () => {
  assertEquals(
    isStoredEntitlementActive(
      {
        tier: "paid",
        source: "app_store",
        expires_at: "2026-07-17T00:00:02.000Z",
      },
      Date.parse("2026-07-17T00:00:01.000Z"),
    ),
    true,
  );
});

Deno.test("free, expired, and malformed entitlements are inactive", () => {
  const now = Date.parse("2026-07-17T00:00:03.000Z");
  assertEquals(
    isStoredEntitlementActive({ tier: "free", source: "admin" }, now),
    false,
  );
  assertEquals(
    isStoredEntitlementActive(
      {
        tier: "paid",
        source: "app_store",
        expires_at: "2026-07-17T00:00:02.000Z",
      },
      now,
    ),
    false,
  );
  assertEquals(
    isStoredEntitlementActive(
      { tier: "paid", source: "app_store", expires_at: "not-a-date" },
      now,
    ),
    false,
  );
  assertEquals(
    isStoredEntitlementActive(
      {
        tier: "paid",
        source: "unknown",
        expires_at: "2026-07-17T00:00:04.000Z",
      },
      now,
    ),
    false,
  );
});
