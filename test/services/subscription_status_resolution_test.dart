import 'package:flutter_test/flutter_test.dart';
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
}
