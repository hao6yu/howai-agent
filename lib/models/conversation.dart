class Conversation {
  final int? id;
  String title;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? archivedAt;
  int? profileId;

  Conversation({
    this.id,
    required this.title,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.profileId,
  });

  bool get isArchived => archivedAt != null;

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
        id: map['id'],
        title: map['title'] ?? '',
        isPinned: (map['is_pinned'] ?? 0) == 1,
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        archivedAt: map['archived_at'] == null
            ? null
            : DateTime.parse(map['archived_at'] as String),
        profileId: map['profile_id'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'is_pinned': isPinned ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'archived_at': archivedAt?.toIso8601String(),
        'profile_id': profileId,
      };
}
