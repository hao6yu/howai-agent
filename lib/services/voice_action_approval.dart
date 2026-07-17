import 'voice_session_service.dart';

const String voiceConfirmPendingActionTool = 'actions_confirm_pending';
const String voiceCancelPendingActionTool = 'actions_cancel_pending';

enum VoicePendingActionDecision {
  approve,
  reject,
}

class VoicePendingActionCommand {
  const VoicePendingActionCommand({
    required this.decision,
    required this.proposalId,
    required this.isRevision,
  });

  final VoicePendingActionDecision decision;
  final String proposalId;
  final bool isRevision;
}

VoicePendingActionCommand? parseVoicePendingActionCommand(
  VoiceToolCall call,
) {
  final name = call.name.trim();
  if (name != voiceConfirmPendingActionTool &&
      name != voiceCancelPendingActionTool) {
    return null;
  }

  final proposalId = call.arguments['proposal_id']?.toString().trim() ?? '';
  final intent = call.arguments['intent']?.toString().trim();
  return VoicePendingActionCommand(
    decision: name == voiceConfirmPendingActionTool
        ? VoicePendingActionDecision.approve
        : VoicePendingActionDecision.reject,
    proposalId: proposalId,
    isRevision: name == voiceCancelPendingActionTool && intent == 'revise',
  );
}

bool hasNewUserTurnForPendingAction({
  required int? pendingAtUserTurn,
  required int currentUserTurn,
}) {
  return pendingAtUserTurn != null && currentUserTurn > pendingAtUserTurn;
}
