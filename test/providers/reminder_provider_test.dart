import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/agent_action_contracts.dart';
import 'package:haogpt/models/generated_automation.dart';
import 'package:haogpt/models/reminder.dart';
import 'package:haogpt/providers/reminder_provider.dart';
import 'package:haogpt/services/automation_service.dart';
import 'package:haogpt/services/reminder_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('loads generated Automations when reminder capability is unavailable',
      () async {
    final automation = GeneratedAutomation(
      id: 'automation-1',
      userId: 'user-1',
      kind: GeneratedAutomationKind.newsBriefing,
      title: 'Top 5 Stock Market News',
      status: GeneratedAutomationStatus.active,
      version: 1,
      timezone: 'America/Chicago',
      startLocal: DateTime(2026, 7, 16, 12, 22),
      schedule: const GeneratedAutomationSchedule(
        frequency: GeneratedAutomationFrequency.once,
        interval: 1,
        weekdays: [],
      ),
      nextRunAt: DateTime.utc(2026, 7, 16, 17, 22),
      config: const {
        'topics': ['stock market'],
        'item_count': 5
      },
      sourcePolicy: const {
        'preferred_domains': [],
        'excluded_domains': [],
        'freshness_hours': 24,
        'require_primary_sources': true,
      },
      deliveryPreferences: const {'push': true},
      createdAt: DateTime.utc(2026, 7, 16, 17, 17),
      updatedAt: DateTime.utc(2026, 7, 16, 17, 17),
    );
    final provider = ReminderProvider(
      service: _FakeReminderService(),
      automationService: _FakeAutomationService([automation]),
    );

    await provider.ensureInitialized(force: true);

    expect(provider.isAvailable, isTrue);
    expect(provider.reminders, isEmpty);
    expect(provider.automations, [automation]);
    expect(provider.errorMessage, isNull);
  });
}

class _FakeReminderService extends ReminderService {
  _FakeReminderService() : super(client: _testClient());

  @override
  User? get currentUser => const User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-07-16T00:00:00Z',
      );

  @override
  Future<bool> checkAvailability({bool force = false}) async => false;

  @override
  Future<List<Reminder>> fetchReminders() async => const [];

  @override
  Future<List<ActionProposal>> fetchPendingProposals() async => const [];
}

class _FakeAutomationService extends AutomationService {
  _FakeAutomationService(this.rows) : super(client: _testClient());

  final List<GeneratedAutomation> rows;

  @override
  Future<bool> checkAvailability({bool force = false}) async => true;

  @override
  Future<List<GeneratedAutomation>> fetchAutomations() async => rows;
}

SupabaseClient _testClient() => SupabaseClient(
      'https://example.supabase.co',
      'test-anon-key',
    );
