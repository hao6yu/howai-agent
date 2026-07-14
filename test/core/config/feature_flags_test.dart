import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/config/feature_flags.dart';

void main() {
  test('safe defaults keep every HowAI 2.0 capability disabled', () {
    const flags = FeatureFlags.safeDefaults();

    expect(flags.modelPolicyV2, isFalse);
    expect(flags.reminders, isFalse);
    expect(flags.pushNotifications, isFalse);
    expect(flags.realtimeVoice, isFalse);
    expect(flags.researchWorkspace, isFalse);
  });

  test('only literal true values enable a feature', () {
    final flags = FeatureFlags.fromJson({
      'model_policy_v2': true,
      'reminders': 'true',
      'push_notifications': 1,
      'realtime_voice': false,
    });

    expect(flags.modelPolicyV2, isTrue);
    expect(flags.reminders, isFalse);
    expect(flags.pushNotifications, isFalse);
    expect(flags.realtimeVoice, isFalse);
    expect(flags.researchWorkspace, isFalse);
  });
}
