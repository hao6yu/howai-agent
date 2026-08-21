class Conversation {
  final int? id;
  final String? clientId;
  String title;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? archivedAt;
  DateTime? deletedAt;
  int? profileId;

  Conversation({
    this.id,
    this.clientId,
    required this.title,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.deletedAt,
    this.profileId,
  });

  bool get isArchived => archivedAt != null;
  bool get isDeleted => deletedAt != null;

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
    id: map['id'],
    clientId: map['client_id'] as String?,
    title: map['title'] ?? '',
    isPinned: (map['is_pinned'] ?? 0) == 1,
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
    archivedAt: map['archived_at'] == null
        ? null
        : DateTime.parse(map['archived_at'] as String),
    deletedAt: map['deleted_at'] == null
        ? null
        : DateTime.parse(map['deleted_at'] as String),
    profileId: map['profile_id'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'client_id': clientId,
    'title': title,
    'is_pinned': isPinned ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'archived_at': archivedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'profile_id': profileId,
  };
}
