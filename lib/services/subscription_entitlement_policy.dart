/// A locally cached entitlement is only a temporary offline optimization.
///
/// It must never cross HowAI account boundaries, and it must have a finite
/// validity window established by a successful server verification.
bool isUserBoundEntitlementCacheActive({
  required String? currentUserId,
  required String? cachedUserId,
  required int? validUntilMs,
  required int nowMs,
}) {
  if (currentUserId == null || currentUserId.isEmpty) return false;
  if (cachedUserId == null || cachedUserId != currentUserId) return false;
  if (validUntilMs == null) return false;
  return validUntilMs > nowMs;
}

/// Limits how long a verified entitlement may be trusted without contacting
/// the server again. Store expiration can be farther away, but revocations and
/// account changes need to be observed promptly.
int boundedEntitlementCacheExpiry({
  required int nowMs,
  required int maximumOfflineAgeMs,
  int? entitlementExpiresAtMs,
}) {
  final maximum = nowMs + maximumOfflineAgeMs;
  final expiry = entitlementExpiresAtMs;
  if (expiry == null) return maximum;
  return expiry < maximum ? expiry : maximum;
}
