import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/subscription_entitlement_policy.dart';
import 'package:haogpt/services/subscription_service.dart';

void main() {
  group('resolvePremiumStatus', () {
    test('release builds ignore a stale free debug override', () {
      expect(
        resolvePremiumStatus(
          realStatus: true,
          isDebugBuild: false,
          debugOverride: false,
        ),
        isTrue,
      );
    });

    test('release builds ignore a stale premium debug override', () {
      expect(
        resolvePremiumStatus(
          realStatus: false,
          isDebugBuild: false,
          debugOverride: true,
        ),
        isFalse,
      );
    });

    test('debug builds can force free or premium', () {
      expect(
        resolvePremiumStatus(
          realStatus: true,
          isDebugBuild: true,
          debugOverride: false,
        ),
        isFalse,
      );
      expect(
        resolvePremiumStatus(
          realStatus: false,
          isDebugBuild: true,
          debugOverride: true,
        ),
        isTrue,
      );
    });
  });

  group('offline entitlement cache', () {
    const now = 1000000;

    test('is valid only for the same signed-in HowAI account', () {
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: 'paid-user',
          cachedUserId: 'paid-user',
          validUntilMs: now + 1,
          nowMs: now,
        ),
        isTrue,
      );
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: 'free-user',
          cachedUserId: 'paid-user',
          validUntilMs: now + 1,
          nowMs: now,
        ),
        isFalse,
      );
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: null,
          cachedUserId: 'paid-user',
          validUntilMs: now + 1,
          nowMs: now,
        ),
        isFalse,
      );
    });

    test('rejects expired, missing-owner, and missing-expiry caches', () {
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: 'user',
          cachedUserId: null,
          validUntilMs: now + 1,
          nowMs: now,
        ),
        isFalse,
      );
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: 'user',
          cachedUserId: 'user',
          validUntilMs: null,
          nowMs: now,
        ),
        isFalse,
      );
      expect(
        isUserBoundEntitlementCacheActive(
          currentUserId: 'user',
          cachedUserId: 'user',
          validUntilMs: now,
          nowMs: now,
        ),
        isFalse,
      );
    });

    test('caps offline trust before a later store expiration', () {
      expect(
        boundedEntitlementCacheExpiry(
          nowMs: now,
          maximumOfflineAgeMs: 24,
          entitlementExpiresAtMs: now + 100,
        ),
        now + 24,
      );
      expect(
        boundedEntitlementCacheExpiry(
          nowMs: now,
          maximumOfflineAgeMs: 24,
          entitlementExpiresAtMs: now + 10,
        ),
        now + 10,
      );
      expect(
        boundedEntitlementCacheExpiry(
          nowMs: now,
          maximumOfflineAgeMs: 24,
        ),
        now + 24,
      );
    });
  });
}
