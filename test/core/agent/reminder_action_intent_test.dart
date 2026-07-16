import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/reminder_action_intent.dart';

void main() {
  test('routes explicit one-time and recurring reminder requests', () {
    expect(
      shouldForceReminderCreateTool(
        message: 'Create a reminder in 2 mins for resting',
        history: const [],
      ),
      isTrue,
    );
    expect(
      shouldForceReminderCreateTool(
        message: 'Remind me to pick up Madeline every Tuesday at 3:30pm',
        history: const [],
      ),
      isTrue,
    );
  });

  test('does not route informational questions or cancellations', () {
    expect(
      shouldForceReminderCreateTool(
        message: 'How do I create a reminder?',
        history: const [],
      ),
      isFalse,
    );
    expect(
      shouldForceReminderCreateTool(
        message: "Don't remind me about this",
        history: const [],
      ),
      isFalse,
    );
  });

  test('routes a concise schedule adjustment only in reminder context', () {
    const history = [
      {'role': 'user', 'content': 'Remind me every Tuesday at 3:30pm'},
      {'role': 'assistant', 'content': 'I drafted this reminder.'},
    ];
    expect(
      shouldForceReminderCreateTool(
        message: 'For the next 2 months',
        history: history,
      ),
      isTrue,
    );
    expect(
      shouldForceReminderCreateTool(
        message: 'For the next 2 months',
        history: const [],
      ),
      isFalse,
    );
  });

  test('routes a polite adjustment when a reminder draft is pending', () {
    expect(
      shouldForceReminderCreateTool(
        message: 'Can you change it to every Wed 1:30pm?',
        history: const [],
        hasPendingReminderDraft: true,
      ),
      isTrue,
    );
    expect(
      shouldForceReminderCreateTool(
        message: 'Can you change it to every Wed 1:30pm?',
        history: const [],
      ),
      isFalse,
    );
    expect(
      shouldForceReminderCreateTool(
        message: 'Could you please change it to Wednesday at 1:30?',
        history: const [],
        hasPendingReminderDraft: true,
      ),
      isTrue,
    );
    expect(
      shouldForceReminderCreateTool(
        message: 'What about Wednesday at 1:30 instead?',
        history: const [],
        hasPendingReminderDraft: true,
      ),
      isTrue,
    );
  });

  test('routes a hinted saved-reminder update only with reminder state', () {
    const message =
        'Can you update the Tuesday pm reminder to Wednesday 1:30pm?';
    expect(isExistingReminderUpdateRequest(message), isTrue);
    expect(
      shouldForceReminderUpdateTool(
        message: message,
        history: const [],
        hasExistingReminders: true,
      ),
      isTrue,
    );
    expect(
      shouldForceReminderUpdateTool(
        message: message,
        history: const [],
        hasExistingReminders: false,
      ),
      isFalse,
    );
    expect(
      isExistingReminderUpdateRequest('How do I update a reminder?'),
      isFalse,
    );
    expect(
      shouldForceReminderUpdateTool(
        message: 'Change it to 1:30pm instead',
        history: const [
          {'role': 'assistant', 'content': 'Reminder created.'},
        ],
        hasExistingReminders: true,
      ),
      isTrue,
    );
  });

  test('routes natural paused-reminder resume requests', () {
    const messages = [
      'I have a paused remind can you re enable it',
      'Resume my paused reminder',
      'Can you reactivate the school reminder?',
      'Please turn that reminder back on',
    ];
    for (final message in messages) {
      expect(
        isExistingReminderResumeRequest(message),
        isTrue,
        reason: message,
      );
      expect(
        shouldForceReminderResumeTool(
          message: message,
          hasPausedReminders: true,
        ),
        isTrue,
      );
    }
    expect(
      shouldForceReminderResumeTool(
        message: messages.first,
        hasPausedReminders: false,
      ),
      isFalse,
    );
    expect(
      isExistingReminderResumeRequest('How do I re-enable a reminder?'),
      isFalse,
    );
  });
}
