enum RemoteConversationAction { merge, purge }

/// Destructive reconciliation requires an explicit server tombstone.
///
/// A row can be absent from a snapshot because of pagination races, transient
/// API behavior, or an incomplete response. Absence is therefore never a
/// deletion signal.
class ConversationReconciliationPolicy {
  const ConversationReconciliationPolicy._();

  static RemoteConversationAction actionForRemoteRecord(
    Map<String, dynamic> remote,
  ) => remote['deleted_at'] == null
      ? RemoteConversationAction.merge
      : RemoteConversationAction.purge;

  static bool shouldDeleteForRemoteAbsence() => false;

  /// A stable client ID is the only safe proof that a cached mapping still
  /// points to the same cloud conversation. An owner lookup takes precedence;
  /// a mismatched or legacy-null mapped row is never overwritten in place.
  static String? verifiedRemoteId({
    required String? ownerRemoteId,
    required String? mappedRemoteId,
    required String? mappedRemoteClientId,
    required String localClientId,
  }) {
    if (ownerRemoteId != null && ownerRemoteId.isNotEmpty) {
      return ownerRemoteId;
    }
    if (mappedRemoteId != null &&
        mappedRemoteId.isNotEmpty &&
        mappedRemoteClientId == localClientId) {
      return mappedRemoteId;
    }
    return null;
  }
}
