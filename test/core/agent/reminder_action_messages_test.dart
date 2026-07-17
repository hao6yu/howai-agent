import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/agent_action_contracts.dart';
import 'package:haogpt/core/agent/reminder_action_messages.dart';

void main() {
  ActionProposal proposal(String actionType, String summary) => ActionProposal(
        proposalId: 'proposal-1',
        actionType: actionType,
        arguments: const {},
        summary: summary,
        warnings: const [],
        origin: AgentActionOrigin.text,
        createdAt: DateTime.utc(2026, 7, 15),
      );

  const success = ActionResult(
    status: AgentActionStatus.succeeded,
    displayMessage: 'Reminder updated.',
    retryable: false,
    auditId: 'audit-1',
  );

  test('turns create and update results into conversational replies', () {
    expect(
      reminderActionDecisionMessage(
        proposal: proposal(
          'reminders_create',
          'Wake up — Thu, Jul 16, 2026, 7:00 AM',
        ),
        decision: AgentActionDecision.approved,
        result: success,
      ),
      'Done — I’ll remind you: Wake up — Thu, Jul 16, 2026, 7:00 AM.',
    );
    expect(
      reminderActionDecisionMessage(
        proposal: proposal(
          'reminders_update',
          'Update reminder: Pick up Madeline — Every Wednesday at 1:30 PM',
        ),
        decision: AgentActionDecision.approved,
        result: success,
      ),
      'Done — I updated the reminder. '
      'Pick up Madeline — Every Wednesday at 1:30 PM.',
    );
  });

  test('summarizes a resumed reminder and a rejection naturally', () {
    expect(
      reminderActionDecisionMessage(
        proposal: proposal(
          'reminders_resume',
          'Resume “Pick up my daughter” for Tue, Jul 21 at 3:30 PM',
        ),
        decision: AgentActionDecision.approved,
        result: success,
      ),
      'Done — “Pick up my daughter” is active again. '
      'Next reminder: Tue, Jul 21 at 3:30 PM.',
    );
    expect(
      reminderActionDecisionMessage(
        proposal: proposal('reminders_update', 'Update reminder: Test'),
        decision: AgentActionDecision.rejected,
      ),
      'No problem — I left the reminder unchanged.',
    );
  });
}
