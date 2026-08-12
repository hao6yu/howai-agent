class ConversationDeletionCandidate {
  final int localId;
  final String remoteId;

  const ConversationDeletionCandidate({
    required this.localId,
    required this.remoteId,
  });

  bool isStillMappedTo(String? currentRemoteId) => currentRemoteId == remoteId;
}

/// The remotely-backed local conversations that existed before a remote
/// conversation snapshot started downloading.
///
/// Only rows in this baseline may be treated as remotely deleted by that
/// snapshot. A local conversation uploaded while the download is in flight
/// receives its mapping too late to enter the baseline, so an older server
/// snapshot cannot delete it.
class ConversationDeletionBaseline {
  final Map<int, String> _remoteIdsByLocalId;

  ConversationDeletionBaseline._(Map<int, String> remoteIdsByLocalId)
    : _remoteIdsByLocalId = Map.unmodifiable(remoteIdsByLocalId);

  factory ConversationDeletionBaseline.capture({
    required Iterable<int> localIds,
    required String? Function(int localId) remoteIdForLocalId,
  }) {
    final mappings = <int, String>{};
    for (final localId in localIds) {
      final remoteId = remoteIdForLocalId(localId);
      if (remoteId != null && remoteId.isNotEmpty) {
        mappings[localId] = remoteId;
      }
    }
    return ConversationDeletionBaseline._(mappings);
  }

  Iterable<ConversationDeletionCandidate> absentFrom(
    Set<String> remoteConversationIds,
  ) sync* {
    for (final entry in _remoteIdsByLocalId.entries) {
      if (!remoteConversationIds.contains(entry.value)) {
        yield ConversationDeletionCandidate(
          localId: entry.key,
          remoteId: entry.value,
        );
      }
    }
  }
}
