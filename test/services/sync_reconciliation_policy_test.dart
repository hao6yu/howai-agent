import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/sync_reconciliation_policy.dart';

void main() {
  test('remote absence is never treated as a deletion signal', () {
    expect(
      ConversationReconciliationPolicy.shouldDeleteForRemoteAbsence(),
      isFalse,
    );
  });

  test('only an explicit tombstone authorizes a local purge', () {
    expect(
      ConversationReconciliationPolicy.actionForRemoteRecord({
        'id': 'active',
        'deleted_at': null,
      }),
      RemoteConversationAction.merge,
    );
    expect(
      ConversationReconciliationPolicy.actionForRemoteRecord({
        'id': 'deleted',
        'deleted_at': '2026-08-20T23:57:00.000Z',
      }),
      RemoteConversationAction.purge,
    );
  });

  test(
    'stable client ownership is required before reusing a cached mapping',
    () {
      expect(
        ConversationReconciliationPolicy.verifiedRemoteId(
          ownerRemoteId: 'canonical',
          mappedRemoteId: 'stale',
          mappedRemoteClientId: 'different-client',
          localClientId: 'local-client',
        ),
        'canonical',
      );
      expect(
        ConversationReconciliationPolicy.verifiedRemoteId(
          ownerRemoteId: null,
          mappedRemoteId: 'mapped',
          mappedRemoteClientId: 'local-client',
          localClientId: 'local-client',
        ),
        'mapped',
      );
      expect(
        ConversationReconciliationPolicy.verifiedRemoteId(
          ownerRemoteId: null,
          mappedRemoteId: 'stale',
          mappedRemoteClientId: 'different-client',
          localClientId: 'local-client',
        ),
        isNull,
      );
      expect(
        ConversationReconciliationPolicy.verifiedRemoteId(
          ownerRemoteId: null,
          mappedRemoteId: 'legacy-without-client-id',
          mappedRemoteClientId: null,
          localClientId: 'local-client',
        ),
        isNull,
      );
    },
  );
}
