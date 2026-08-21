import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/chat_message.dart';
import 'package:haogpt/services/message_sync_reconciliation.dart';

ChatMessage _message({List<String>? imagePaths, List<String>? imageUrls}) =>
    ChatMessage(
      id: 1,
      clientId: 'client-id',
      message: 'hello',
      isUserMessage: true,
      timestamp: '2026-08-21T00:00:00Z',
      conversationId: 2,
      imagePaths: imagePaths,
      imageUrls: imageUrls,
    );

void main() {
  test('only messages with an unbacked local image need cloud repair', () {
    expect(
      MessageSyncReconciliation.needsAttachmentBackfill(
        _message(imagePaths: ['/tmp/photo.jpg']),
      ),
      isTrue,
    );
    expect(
      MessageSyncReconciliation.needsAttachmentBackfill(
        _message(
          imagePaths: ['/tmp/photo.jpg'],
          imageUrls: ['storage://chat-attachments/user/message/image_0.jpg'],
        ),
      ),
      isFalse,
    );
    expect(
      MessageSyncReconciliation.needsAttachmentBackfill(_message()),
      isFalse,
    );
  });

  test('remote attachment repair updates an already-downloaded message', () {
    final local = _message(imageUrls: null);
    final remote = _message(
      imageUrls: ['storage://chat-attachments/user/message/image_0.jpg'],
    );

    expect(
      MessageSyncReconciliation.mergedImageUrls(local: local, remote: remote),
      remote.imageUrls,
    );
  });

  test('blank remote media cannot erase a pending local reference', () {
    final local = _message(
      imageUrls: ['storage://chat-attachments/user/message/image_0.jpg'],
    );
    final remote = _message(imageUrls: const []);

    expect(
      MessageSyncReconciliation.mergedImageUrls(local: local, remote: remote),
      local.imageUrls,
    );
  });
}
