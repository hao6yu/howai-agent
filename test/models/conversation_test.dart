import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/conversation.dart';

void main() {
  test('conversation archive state round-trips through local storage maps', () {
    final archivedAt = DateTime.utc(2026, 7, 15, 1, 30);
    final conversation = Conversation(
      id: 42,
      title: 'Trip planning',
      isPinned: true,
      createdAt: DateTime.utc(2026, 7, 14),
      updatedAt: archivedAt,
      archivedAt: archivedAt,
      profileId: 1,
    );

    final restored = Conversation.fromMap(conversation.toMap());

    expect(restored.isArchived, isTrue);
    expect(restored.archivedAt, archivedAt);
    expect(restored.title, 'Trip planning');
    expect(restored.isPinned, isTrue);
  });

  test('active conversation has no archive timestamp', () {
    final conversation = Conversation.fromMap({
      'id': 1,
      'title': 'Active chat',
      'is_pinned': 0,
      'created_at': '2026-07-14T12:00:00.000Z',
      'updated_at': '2026-07-14T12:00:00.000Z',
      'archived_at': null,
      'profile_id': 1,
    });

    expect(conversation.isArchived, isFalse);
  });
}
