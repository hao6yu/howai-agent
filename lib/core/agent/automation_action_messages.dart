import 'agent_action_contracts.dart';

String automationActionDecisionMessage({
  required ActionProposal proposal,
  required AgentActionDecision decision,
  ActionResult? result,
}) {
  if (decision == AgentActionDecision.rejected) {
    return 'No problem — I didn’t create that Automation.';
  }
  if (result?.isSuccess != true) {
    return 'I couldn’t create that Automation. Please try again.';
  }
  final title = proposal.arguments['title']?.toString().trim();
  return title == null || title.isEmpty
      ? 'Done — your Automation is active. I’ll keep each briefing in Automations history.'
      : 'Done — “$title” is active. I’ll keep each briefing in Automations history.';
}
