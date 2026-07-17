import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/push_notification_destination.dart';

void main() {
  test('parses a conversation-first Automation notification', () {
    final destination = PushNotificationDestination.tryParse({
      'type': 'automation',
      'conversation_id': 'conversation-1',
      'message_id': 'message-1',
    });
    expect(destination?.type, PushNotificationDestinationType.automation);
    expect(destination?.conversationId, 'conversation-1');
    expect(destination?.messageId, 'message-1');
  });

  test('keeps legacy reminder routing', () {
    final destination = PushNotificationDestination.tryParse({
      'type': 'reminder',
      'reminder_id': 'reminder-1',
    });
    expect(destination?.type, PushNotificationDestinationType.reminder);
    expect(destination?.reminderId, 'reminder-1');
  });

  test('rejects incomplete and unknown payloads', () {
    expect(
      PushNotificationDestination.tryParse({
        'type': 'automation',
        'conversation_id': 'conversation-1',
      }),
      isNull,
    );
    expect(PushNotificationDestination.tryParse({'type': 'unknown'}), isNull);
  });
}
