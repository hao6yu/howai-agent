export type StoredEntitlement = Readonly<{
  tier?: unknown;
  source?: unknown;
  expires_at?: unknown;
}>;

export function isStoredEntitlementActive(
  entitlement: StoredEntitlement | null,
  nowMs = Date.now(),
): boolean {
  if (entitlement?.tier !== "paid") return false;
  const source = entitlement.source;
  if (
    source !== "app_store" && source !== "play_store" &&
    source !== "admin" && source !== "migration"
  ) {
    return false;
  }
  if (entitlement.expires_at == null) {
    // Store subscriptions are time-bound. Only explicit server-managed grants
    // may be lifetime entitlements.
    return source === "admin" || source === "migration";
  }
  if (typeof entitlement.expires_at !== "string") return false;

  const expiresAtMs = Date.parse(entitlement.expires_at);
  return Number.isFinite(expiresAtMs) && expiresAtMs > nowMs;
}
