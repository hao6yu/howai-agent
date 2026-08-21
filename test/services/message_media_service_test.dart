import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/chat_message.dart';
import 'package:haogpt/services/message_media_service.dart';

void main() {
  test(
    'resolves remote and data images without retaining missing local paths',
    () async {
      final message = ChatMessage(
        message: 'attachments',
        isUserMessage: true,
        timestamp: DateTime(2026, 7, 28).toIso8601String(),
        imagePaths: const [
          'https://example.com/image.png',
          'data:image/png;base64,'
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
              'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
          '/path/that/does/not/exist.png',
        ],
        filePaths: const ['/path/that/does/not/exist.pdf'],
      );

      final media = await const MessageMediaService().resolve(message);

      expect(media.visibleImagePaths, hasLength(2));
      expect(media.dataImageBytes, hasLength(1));
      expect(media.fileAvailability['/path/that/does/not/exist.pdf'], isFalse);
    },
  );

  test(
    'falls back to a signed private image when the local file is gone',
    () async {
      final message = ChatMessage(
        message: 'synced attachment',
        isUserMessage: true,
        timestamp: DateTime(2026, 8, 20).toIso8601String(),
        imagePaths: const ['/path/that/does/not/exist.heic'],
        imageUrls: const [
          'storage://chat-attachments/user/message/image_0.heic',
        ],
      );
      final service = MessageMediaService(
        storageUrlResolver: (reference) async {
          expect(
            reference,
            'storage://chat-attachments/user/message/image_0.heic',
          );
          return 'https://signed.example.test/image_0.heic';
        },
      );

      final media = await service.resolve(message);

      expect(media.visibleImagePaths, const [
        'https://signed.example.test/image_0.heic',
      ]);
    },
  );

  test(
    'does not duplicate the cloud copy while the local image is usable',
    () async {
      final message = ChatMessage(
        message: 'attachment',
        isUserMessage: true,
        timestamp: DateTime(2026, 8, 20).toIso8601String(),
        imagePaths: const ['https://local.example.test/image.jpg'],
        imageUrls: const ['https://cloud.example.test/image.jpg'],
      );

      final media = await const MessageMediaService().resolve(message);

      expect(media.visibleImagePaths, const [
        'https://local.example.test/image.jpg',
      ]);
    },
  );
}
