import 'agent_action_contracts.dart';

/// Builds short, deterministic assistant replies after a reminder proposal is
/// approved or rejected. This keeps the result in the conversation without
/// paying for another model call or allowing the model to overstate execution.
String reminderActionDecisionMessage({
  required ActionProposal proposal,
  required AgentActionDecision decision,
  ActionResult? result,
}) {
  if (decision == AgentActionDecision.rejected) {
    return 'No problem — I left the reminder unchanged.';
  }
  if (result?.isSuccess != true) {
    return 'I couldn’t finish that reminder action. Please try again.';
  }

  final summary = _withoutTrailingPeriod(proposal.summary.trim());
  switch (proposal.actionType) {
    case 'reminders_create':
      return 'Done — I’ll remind you: $summary.';
    case 'reminders_update':
      final details = summary.replaceFirst(
        RegExp(r'^Update reminder:\s*', caseSensitive: false),
        '',
      );
      return 'Done — I updated the reminder. $details.';
    case 'reminders_resume':
      final match = RegExp(
        r'^[Rr]esume\s+[“"](.+?)[”"]\s+for\s+(.+)$',
      ).firstMatch(summary);
      if (match != null) {
        return 'Done — “${match.group(1)}” is active again. '
            'Next reminder: ${match.group(2)}.';
      }
      return 'Done — the reminder is active again. $summary.';
    case 'reminders_pause':
      return 'Done — the reminder is paused.';
    case 'reminders_delete':
      return 'Done — I deleted the reminder.';
    case 'reminders_complete':
      return 'Done — I marked the reminder complete.';
    case 'reminders_snooze':
      return 'Done — I snoozed the reminder. $summary.';
    case 'reminders_skip_next':
      return 'Done — I skipped the next reminder.';
    default:
      return result!.displayMessage;
  }
}

String _withoutTrailingPeriod(String value) =>
    value.endsWith('.') ? value.substring(0, value.length - 1) : value;
