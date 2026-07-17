import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/agent_action_contracts.dart';
import 'package:haogpt/core/agent/automation_action_messages.dart';

void main() {
  final proposal = ActionProposal(
    proposalId: 'proposal-1',
    actionType: 'automations_create',
    arguments: const {'title': 'Morning AI briefing'},
    summary: 'News briefing: Morning AI briefing',
    warnings: const [],
    origin: AgentActionOrigin.text,
    createdAt: DateTime.utc(2026, 7, 16),
  );
  const success = ActionResult(
    status: AgentActionStatus.succeeded,
    displayMessage: 'Automation created.',
    retryable: false,
    auditId: 'audit-1',
    resourceType: 'automation',
    resourceId: 'automation-1',
  );

  test('confirms approval conversationally', () {
    expect(
      automationActionDecisionMessage(
        proposal: proposal,
        decision: AgentActionDecision.approved,
        result: success,
      ),
      'Done — “Morning AI briefing” is active. '
      'I’ll keep each briefing in Automations history.',
    );
  });

  test('confirms rejection without implying a mutation', () {
    expect(
      automationActionDecisionMessage(
        proposal: proposal,
        decision: AgentActionDecision.rejected,
      ),
      'No problem — I didn’t create that Automation.',
    );
  });
}
