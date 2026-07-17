/// Remotely controlled HowAI 2.0 capabilities.
///
/// Every new capability defaults to off so a missing or malformed response can
/// never accidentally expose unfinished UI or a costly backend route.
class FeatureFlags {
  const FeatureFlags({
    required this.modelPolicyV2,
    required this.reminders,
    required this.pushNotifications,
    required this.realtimeVoice,
    required this.researchWorkspace,
  });

  const FeatureFlags.safeDefaults()
      : modelPolicyV2 = false,
        reminders = false,
        pushNotifications = false,
        realtimeVoice = false,
        researchWorkspace = false;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    bool enabled(String key) => json[key] == true;

    return FeatureFlags(
      modelPolicyV2: enabled('model_policy_v2'),
      reminders: enabled('reminders'),
      pushNotifications: enabled('push_notifications'),
      realtimeVoice: enabled('realtime_voice'),
      researchWorkspace: enabled('research_workspace'),
    );
  }

  final bool modelPolicyV2;
  final bool reminders;
  final bool pushNotifications;
  final bool realtimeVoice;
  final bool researchWorkspace;
}
