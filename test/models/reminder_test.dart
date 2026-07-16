import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/reminder.dart';

void main() {
  test('parses a recurring reminder and preserves wall-clock intent', () {
    final reminder = Reminder.fromJson({
      'id': 'reminder-1',
      'user_id': 'user-1',
      'conversation_id': null,
      'title': 'Water the plants',
      'notes': 'Use the small can',
      'timezone': 'America/Chicago',
      'start_local': '2026-07-20T08:30:00',
      'next_fire_at': '2026-07-20T13:30:00Z',
      'recurrence_rule': {
        'frequency': 'weekly',
        'interval': 1,
        'weekdays': [1, 4],
        'day_of_month': null,
        'ends_at': null,
      },
      'status': 'active',
      'version': 3,
      'created_at': '2026-07-15T12:00:00Z',
      'updated_at': '2026-07-15T12:01:00Z',
    });

    expect(reminder.isRecurring, isTrue);
    expect(reminder.recurrence!.frequency, ReminderFrequency.weekly);
    expect(reminder.recurrence!.weekdays, [1, 4]);
    expect(reminder.version, 3);
    expect(reminder.scheduleArguments(), {
      'title': 'Water the plants',
      'notes': 'Use the small can',
      'timezone': 'America/Chicago',
      'start_local': '2026-07-20T08:30:00',
      'recurrence': {
        'frequency': 'weekly',
        'interval': 1,
        'weekdays': [1, 4],
        'day_of_month': null,
        'ends_at': null,
      },
    });
    expect(reminder.agentUpdateContext(), {
      'reminder_id': 'reminder-1',
      'expected_version': 3,
      'status': 'active',
      'title': 'Water the plants',
      'notes': 'Use the small can',
      'timezone': 'America/Chicago',
      'start_local': '2026-07-20T08:30:00',
      'recurrence': {
        'frequency': 'weekly',
        'interval': 1,
        'weekdays': [1, 4],
        'day_of_month': null,
        'ends_at': null,
      },
    });
  });

  test('parses a one-time completed reminder', () {
    final reminder = Reminder.fromJson({
      'id': 'reminder-2',
      'user_id': 'user-1',
      'conversation_id': 'conversation-1',
      'title': 'Submit form',
      'notes': null,
      'timezone': 'UTC',
      'start_local': '2026-07-20 09:00:00',
      'next_fire_at': '2026-07-20T09:00:00Z',
      'recurrence_rule': null,
      'status': 'completed',
      'version': 2,
      'created_at': '2026-07-15T12:00:00Z',
      'updated_at': '2026-07-20T09:01:00Z',
    });

    expect(reminder.status, ReminderStatus.completed);
    expect(reminder.recurrence, isNull);
    expect(reminder.conversationId, 'conversation-1');
  });
}
