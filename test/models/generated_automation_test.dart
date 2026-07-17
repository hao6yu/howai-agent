import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/generated_automation.dart';

void main() {
  test('parses a one-time generated news Automation from Supabase', () {
    final automation = GeneratedAutomation.fromJson({
      'id': 'automation-1',
      'user_id': 'user-1',
      'conversation_id': null,
      'kind': 'news_briefing',
      'title': 'Top 5 Stock Market News',
      'status': 'active',
      'version': 1,
      'timezone': 'America/Chicago',
      'start_local': '2026-07-16T12:22:22',
      'schedule_rule': {
        'frequency': 'once',
        'interval': 1,
        'weekdays': <int>[],
        'ends_at': null,
      },
      'next_run_at': '2026-07-16T17:22:22Z',
      'config': {
        'topics': ['stock market'],
        'item_count': 5,
      },
      'source_policy': {
        'preferred_domains': [],
        'excluded_domains': [],
        'freshness_hours': 24,
        'require_primary_sources': true,
      },
      'delivery_preferences': {'push': true},
      'last_run_at': null,
      'created_at': '2026-07-16T17:17:45Z',
      'updated_at': '2026-07-16T17:17:45Z',
    });

    expect(automation.kind, GeneratedAutomationKind.newsBriefing);
    expect(automation.status, GeneratedAutomationStatus.active);
    expect(automation.schedule.compactLabel, 'One time');
    expect(automation.scopeLabel, '5 stories · stock market');
    expect(automation.deliveryPreferences['push'], isTrue);
    expect(automation.nextRunAt, DateTime.utc(2026, 7, 16, 17, 22, 22));
  });

  test('describes weekly generated Automation schedules', () {
    const schedule = GeneratedAutomationSchedule(
      frequency: GeneratedAutomationFrequency.weekly,
      interval: 2,
      weekdays: [DateTime.monday, DateTime.friday],
    );

    expect(schedule.isRecurring, isTrue);
    expect(schedule.compactLabel, 'Every 2 weeks · Mon, Fri');
  });
}
