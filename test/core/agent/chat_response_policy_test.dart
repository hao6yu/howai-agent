import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/chat_response_policy.dart';

void main() {
  group('shouldUseStreamingChatResponse', () {
    test('keeps normal chat streaming when enabled', () {
      expect(
        shouldUseStreamingChatResponse(
          streamingEnabled: true,
          hasImageAttachments: false,
        ),
        isTrue,
      );
    });

    test('routes image requests through the complete-response path', () {
      expect(
        shouldUseStreamingChatResponse(
          streamingEnabled: true,
          hasImageAttachments: true,
        ),
        isFalse,
      );
    });

    test('respects a disabled streaming preference', () {
      expect(
        shouldUseStreamingChatResponse(
          streamingEnabled: false,
          hasImageAttachments: false,
        ),
        isFalse,
      );
    });
  });

  group('chatResponseLanguageInstructions', () {
    test('uses the app language only as a multilingual fallback', () {
      final instructions = chatResponseLanguageInstructions('en-US');

      expect(instructions, contains('app interface language is English'));
      expect(instructions, contains('must not force a single-language reply'));
      expect(instructions, contains('intentional mix of languages'));
      expect(
          instructions, contains('respond naturally in the same language mix'));
      expect(instructions, isNot(contains('Reply in English unless')));
      expect(instructions, contains('isolated foreign word'));
      expect(instructions, contains('genuinely ambiguous'));
    });

    test('preserves regional language variants', () {
      expect(
        chatResponseLanguageInstructions('zh_TW'),
        contains('Traditional Chinese'),
      );
    });
  });

  group('redactReminderInternals', () {
    const reminderId = 'afe7dd43-1e8a-42ac-983e-0d8635467aea';
    final reminders = <Map<String, dynamic>>[
      {
        'reminder_id': reminderId,
        'expected_version': 2,
        'title': 'Pick up my daughter',
      },
    ];

    test('removes labelled reminder IDs and versions', () {
      final result = redactReminderInternals(
        'Pick up my daughter (ID: $reminderId) (version 2) — paused',
        reminders,
      );

      expect(result, 'Pick up my daughter — paused');
      expect(result, isNot(contains(reminderId)));
    });

    test('redacts an unlabelled known ID as defense in depth', () {
      final result = redactReminderInternals(
        'The reminder identifier is $reminderId.',
        reminders,
      );

      expect(result, isNot(contains(reminderId)));
      expect(result, contains('reminder'));
    });

    test('does not alter unrelated version text', () {
      final result = redactReminderInternals(
        'The API (version 2) is still supported.',
        reminders,
      );

      expect(result, 'The API (version 2) is still supported.');
    });
  });
}
