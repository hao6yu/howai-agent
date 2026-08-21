import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/chat_attachment_service.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('preserves image selection and PDF workflow behavior', () {
    final first = XFile('/tmp/first.jpg');
    final second = XFile('/tmp/second.jpg');

    final selected = ChatAttachmentService.applyImageSelection(
      currentPendingImages: [first],
      newImages: [second],
      forPdf: true,
    );

    expect(selected.pendingImages, [first, second]);
    expect(selected.isPdfWorkflowActive, isTrue);
    expect(selected.shouldStartPdfTimer, isTrue);

    final removed = ChatAttachmentService.removePendingImage(
      currentPendingImages: selected.pendingImages,
      index: 1,
      isPdfWorkflowActive: selected.isPdfWorkflowActive,
    );
    expect(removed.pendingImages, [first]);
    expect(removed.isPdfWorkflowActive, isTrue);
    expect(removed.shouldRestartPdfTimer, isTrue);
  });

  test(
    'private storage references round-trip without becoming public URLs',
    () {
      final reference = ChatAttachmentService.storageReference(
        ChatAttachmentService.bucket,
        'user-id/message-id/image_0.heic',
      );

      expect(
        reference,
        'storage://chat-attachments/user-id/message-id/image_0.heic',
      );
      final parsed = ChatAttachmentService.parseStorageReference(reference);
      expect(parsed?.bucket, ChatAttachmentService.bucket);
      expect(parsed?.objectPath, 'user-id/message-id/image_0.heic');
    },
  );

  test('rejects non-storage and malformed attachment references', () {
    expect(
      ChatAttachmentService.parseStorageReference(
        'https://example.com/image.jpg',
      ),
      isNull,
    );
    expect(
      ChatAttachmentService.parseStorageReference('storage://chat-attachments'),
      isNull,
    );
  });

  test('attachment cleanup only targets private chat storage objects', () {
    expect(
      ChatAttachmentService.objectPathsForRemoval([
        'storage://chat-attachments/user/message/image_0.jpg',
        'https://example.com/image.jpg',
        'storage://another-bucket/user/message/image_1.jpg',
        'storage://chat-attachments/user/message/image_0.jpg',
      ]),
      ['user/message/image_0.jpg'],
    );
  });

  test('attachment cleanup is bounded to the Storage API batch limit', () {
    final references = List.generate(
      2005,
      (index) => 'storage://chat-attachments/user/message/image_$index.jpg',
    );

    final batches = ChatAttachmentService.objectPathBatchesForRemoval(
      references,
    );
    expect(batches.map((batch) => batch.length), [1000, 1000, 5]);
    expect(batches.expand((batch) => batch).toSet(), hasLength(2005));
  });
}
