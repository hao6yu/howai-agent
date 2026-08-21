import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/chat_message.dart';
import 'package:haogpt/services/location_service.dart';

void main() {
  test('round-trips stable sync identity and rich remote metadata', () {
    final message = ChatMessage(
      clientId: '20000000-0000-4000-8000-000000000001',
      message: 'Try this place',
      isUserMessage: false,
      timestamp: '2026-07-28T12:00:00.000Z',
      profileId: 42,
      conversationId: 9,
      imageUrls: const ['https://example.test/image.png'],
      isWelcomeMessage: true,
      messageType: MessageType.reviewRequest,
      locationResults: [
        PlaceResult(
          placeId: 'test-cafe',
          name: 'Test Cafe',
          address: '1 Test Street',
          rating: 4.5,
          userRatingsTotal: 10,
          latitude: 41,
          longitude: -87,
          distance: 100,
          isOpen: true,
          priceLevel: '\$\$',
          types: const ['cafe'],
          openingHours: const ['Monday: 8:00 AM – 5:00 PM'],
        ),
      ],
    );

    final remote = message.toSupabase('30000000-0000-4000-8000-000000000001');
    remote['id'] = '40000000-0000-4000-8000-000000000001';

    final restored = ChatMessage.fromSupabase(remote, 17, profileId: 84);

    expect(restored.clientId, message.clientId);
    expect(restored.profileId, 84);
    expect(restored.conversationId, 17);
    expect(restored.imageUrls, message.imageUrls);
    expect(restored.isWelcomeMessage, isTrue);
    expect(restored.messageType, MessageType.reviewRequest);
    expect(restored.locationResults?.single.name, 'Test Cafe');
  });

  test('invalid persisted message type falls back without crashing', () {
    final outOfRange = ChatMessage.fromMap({
      'id': 1,
      'message': 'Legacy row',
      'is_user_message': 1,
      'timestamp': '2026-07-28T12:00:00.000Z',
      'message_type': 999,
    });
    final malformed = ChatMessage.fromMap({
      'id': 2,
      'message': 'Malformed legacy row',
      'is_user_message': 0,
      'timestamp': '2026-07-28T12:00:01.000Z',
      'message_type': 'not-an-index',
    });

    expect(outOfRange.messageType, MessageType.normal);
    expect(malformed.messageType, MessageType.normal);
  });

  test('counts paired local and remote attachment slots once', () {
    final message = ChatMessage(
      message: 'Two images',
      isUserMessage: true,
      timestamp: '2026-08-20T12:00:00.000Z',
      imagePaths: const ['/local/first.jpg', ''],
      imageUrls: const [
        'storage://chat-attachments/user/message/image_0.jpg',
        'storage://chat-attachments/user/message/image_1.jpg',
      ],
    );

    expect(message.hasImages, isTrue);
    expect(message.imageCount, 2);
  });
}
