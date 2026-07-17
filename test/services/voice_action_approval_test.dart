import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/voice_action_approval.dart';
import 'package:haogpt/services/voice_session_service.dart';

void main() {
  test('parses model-mediated voice confirmation', () {
    final command = parseVoicePendingActionCommand(
      const VoiceToolCall(
        callId: 'confirm-call',
        name: voiceConfirmPendingActionTool,
        arguments: {'proposal_id': 'proposal-call'},
      ),
    );

    expect(command, isNotNull);
    expect(command!.decision, VoicePendingActionDecision.approve);
    expect(command.proposalId, 'proposal-call');
    expect(command.isRevision, isFalse);
  });

  test('distinguishes a revision from cancellation', () {
    final command = parseVoicePendingActionCommand(
      const VoiceToolCall(
        callId: 'cancel-call',
        name: voiceCancelPendingActionTool,
        arguments: {
          'proposal_id': 'proposal-call',
          'intent': 'revise',
        },
      ),
    );

    expect(command, isNotNull);
    expect(command!.decision, VoicePendingActionDecision.reject);
    expect(command.proposalId, 'proposal-call');
    expect(command.isRevision, isTrue);
  });

  test('ignores ordinary action proposal tools', () {
    final command = parseVoicePendingActionCommand(
      const VoiceToolCall(
        callId: 'proposal-call',
        name: 'reminders_create',
        arguments: {'title': 'Call Mom'},
      ),
    );

    expect(command, isNull);
  });

  test('requires a distinct user turn after the proposal', () {
    expect(
      hasNewUserTurnForPendingAction(
        pendingAtUserTurn: null,
        currentUserTurn: 2,
      ),
      isFalse,
    );
    expect(
      hasNewUserTurnForPendingAction(
        pendingAtUserTurn: 2,
        currentUserTurn: 2,
      ),
      isFalse,
    );
    expect(
      hasNewUserTurnForPendingAction(
        pendingAtUserTurn: 2,
        currentUserTurn: 3,
      ),
      isTrue,
    );
  });
}
