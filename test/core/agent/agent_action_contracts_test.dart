import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/agent_action_contracts.dart';

void main() {
  test('action proposal round-trips normalized reminder arguments', () {
    final proposal = ActionProposal.fromJson({
      'proposal_id': 'proposal-1',
      'action_type': 'reminders_create',
      'arguments': {
        'title': 'Take medication',
        'timezone': 'America/Chicago',
      },
      'summary': 'Every weekday at 8:00 AM',
      'warnings': <String>[],
      'origin': 'voice',
      'created_at': '2026-07-14T14:00:00-05:00',
    });

    expect(proposal.actionType, 'reminders_create');
    expect(proposal.origin, AgentActionOrigin.voice);
    expect(proposal.createdAt.toIso8601String(), '2026-07-14T19:00:00.000Z');
    expect(proposal.toJson()['proposal_id'], 'proposal-1');
  });

  test('action proposal rejects incomplete approval summaries', () {
    expect(
      () => ActionProposal.fromJson({
        'proposal_id': 'proposal-1',
        'action_type': 'reminders_create',
        'arguments': <String, dynamic>{},
        'summary': '',
        'origin': 'text',
        'created_at': '2026-07-14T19:00:00Z',
      }),
      throwsFormatException,
    );
  });

  test('action proposal rejects unknown fields', () {
    expect(
      () => ActionProposal.fromJson({
        'proposal_id': 'proposal-1',
        'action_type': 'reminders_create',
        'arguments': <String, dynamic>{},
        'summary': 'Tomorrow at 8:00 AM',
        'origin': 'text',
        'created_at': '2026-07-14T19:00:00Z',
        'execute_without_approval': true,
      }),
      throwsFormatException,
    );
  });

  test('agent tools require strict object schemas', () {
    expect(
      () => AgentToolDefinition(
        name: 'reminders_create',
        description: 'Create a reminder',
        inputSchema: {'type': 'object'},
        risk: AgentActionRisk.medium,
      ),
      throwsArgumentError,
    );
  });

  test('action results distinguish successful and retryable outcomes', () {
    const result = ActionResult(
      status: AgentActionStatus.failed,
      displayMessage: 'Notification delivery will be retried.',
      retryable: true,
      auditId: 'audit-1',
    );

    expect(result.isSuccess, isFalse);
    expect(result.toJson()['retryable'], isTrue);
  });
}
