enum PushNotificationDestinationType { reminder, automation }

class PushNotificationDestination {
  const PushNotificationDestination._({
    required this.type,
    this.reminderId,
    this.conversationId,
    this.messageId,
  });

  final PushNotificationDestinationType type;
  final String? reminderId;
  final String? conversationId;
  final String? messageId;

  static PushNotificationDestination? tryParse(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'reminder':
        final reminderId = _nonEmpty(data['reminder_id']);
        if (reminderId == null) return null;
        return PushNotificationDestination._(
          type: PushNotificationDestinationType.reminder,
          reminderId: reminderId,
        );
      case 'automation':
        final conversationId = _nonEmpty(data['conversation_id']);
        final messageId = _nonEmpty(data['message_id']);
        if (conversationId == null || messageId == null) return null;
        return PushNotificationDestination._(
          type: PushNotificationDestinationType.automation,
          conversationId: conversationId,
          messageId: messageId,
        );
      default:
        return null;
    }
  }

  static String? _nonEmpty(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
