import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/push_notification_status.dart';

void main() {
  test('requires availability, registration, and permission for delivery', () {
    const enabled = PushNotificationStatus(
      available: true,
      registered: true,
      permission: PushPermissionState.authorized,
    );
    expect(enabled.canDeliver, isTrue);

    const missingPermission = PushNotificationStatus(
      available: true,
      registered: true,
      permission: PushPermissionState.denied,
    );
    expect(missingPermission.canDeliver, isFalse);
    expect(missingPermission.isDenied, isTrue);
  });

  test('parses the sanitized server status contract', () {
    final status = PushNotificationStatus.fromJson(
      const {'available': true, 'registered': false},
      permission: PushPermissionState.notDetermined,
    );
    expect(status.available, isTrue);
    expect(status.registered, isFalse);
    expect(
      () => PushNotificationStatus.fromJson(
        const {'available': 'yes', 'registered': false},
        permission: PushPermissionState.authorized,
      ),
      throwsFormatException,
    );
  });
}
