import '../models/chat_message.dart';

/// Pure reconciliation rules for immutable message rows.
///
/// Message text is immutable after upload, while cloud attachment references
/// can be populated later by a device that still owns the original local file.
class MessageSyncReconciliation {
  const MessageSyncReconciliation._();

  static bool needsAttachmentBackfill(ChatMessage message) {
    final localPaths = message.imagePaths ?? const <String>[];
    final remoteReferences = message.imageUrls ?? const <String>[];
    for (var index = 0; index < localPaths.length; index++) {
      if (localPaths[index].trim().isEmpty) continue;
      if (index >= remoteReferences.length ||
          remoteReferences[index].trim().isEmpty) {
        return true;
      }
    }
    return false;
  }

  /// A non-empty cloud value repairs an existing local message. A blank cloud
  /// value must not erase a local reference that is still waiting to upload.
  static List<String>? mergedImageUrls({
    required ChatMessage local,
    required ChatMessage remote,
  }) {
    final remoteReferences = remote.imageUrls;
    if (remoteReferences != null &&
        remoteReferences.any((reference) => reference.trim().isNotEmpty)) {
      return List<String>.unmodifiable(remoteReferences);
    }
    return local.imageUrls;
  }
}
