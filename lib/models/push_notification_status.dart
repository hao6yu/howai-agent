enum PushPermissionState {
  unknown,
  notDetermined,
  denied,
  provisional,
  authorized,
}

class PushNotificationStatus {
  const PushNotificationStatus({
    required this.available,
    required this.registered,
    required this.permission,
  });

  factory PushNotificationStatus.fromJson(
    Map<String, dynamic> json, {
    required PushPermissionState permission,
  }) {
    final available = json['available'];
    final registered = json['registered'];
    if (available is! bool || registered is! bool) {
      throw const FormatException('Invalid push notification status.');
    }
    return PushNotificationStatus(
      available: available,
      registered: registered,
      permission: permission,
    );
  }

  final bool available;
  final bool registered;
  final PushPermissionState permission;

  bool get canDeliver =>
      available &&
      registered &&
      (permission == PushPermissionState.authorized ||
          permission == PushPermissionState.provisional);

  bool get isDenied => permission == PushPermissionState.denied;
}
