export type StoredEntitlement = Readonly<{
  tier?: unknown;
  expires_at?: unknown;
}>;

export function isStoredEntitlementActive(
  entitlement: StoredEntitlement | null,
  nowMs = Date.now(),
): boolean {
  if (entitlement?.tier !== "paid") return false;
  if (entitlement.expires_at == null) return true;
  if (typeof entitlement.expires_at !== "string") return false;

  const expiresAtMs = Date.parse(entitlement.expires_at);
  return Number.isFinite(expiresAtMs) && expiresAtMs > nowMs;
}
