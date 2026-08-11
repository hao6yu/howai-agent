import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/message_service.dart';

void main() {
  group('generateConversationTitle', () {
    test('uses the caller fallback for a photo-only conversation', () {
      expect(
        MessageService.generateConversationTitle(
          '',
          fallbackTitle: 'Photo Analysis',
        ),
        'Photo Analysis',
      );
    });

    test('keeps a concise title for a text conversation', () {
      expect(
        MessageService.generateConversationTitle(
          'Can you identify this garden plant?',
        ),
        'Can you identify garden',
      );
    });
  });
}
