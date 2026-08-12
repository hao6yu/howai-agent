import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/sync_reconciliation_policy.dart';

void main() {
  test('an in-flight upload is not deleted by an older remote snapshot', () {
    final mappings = <int, String>{1: 'remote-existing'};
    final baseline = ConversationDeletionBaseline.capture(
      localIds: const [1, 2],
      remoteIdForLocalId: (localId) => mappings[localId],
    );

    // Conversation 2 uploads after the remote download began. The server
    // response was captured before that upload and therefore contains neither
    // conversation.
    mappings[2] = 'remote-uploaded-during-download';
    final candidates = baseline.absentFrom(<String>{}).toList();

    expect(candidates.map((candidate) => candidate.localId), contains(1));
    expect(
      candidates.map((candidate) => candidate.localId),
      isNot(contains(2)),
    );
  });

  test('only baseline mappings absent from the server are candidates', () {
    final mappings = <int, String>{1: 'remote-present', 2: 'remote-deleted'};
    final baseline = ConversationDeletionBaseline.capture(
      localIds: const [1, 2, 3],
      remoteIdForLocalId: (localId) => mappings[localId],
    );

    final candidates = baseline.absentFrom({'remote-present'}).toList();

    expect(candidates, hasLength(1));
    expect(candidates.single.localId, 2);
    expect(candidates.single.remoteId, 'remote-deleted');
  });

  test('a mapping rebound during download no longer matches its candidate', () {
    final baseline = ConversationDeletionBaseline.capture(
      localIds: const [7],
      remoteIdForLocalId: (_) => 'remote-before-merge',
    );
    final candidate = baseline.absentFrom(<String>{}).single;

    expect(candidate.isStillMappedTo('remote-before-merge'), isTrue);
    expect(candidate.isStillMappedTo('remote-after-merge'), isFalse);
    expect(candidate.isStillMappedTo(null), isFalse);
  });
}
