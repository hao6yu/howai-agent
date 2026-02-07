import 'dart:convert';

enum MemoryType {
  preference,
  fact,
  goal,
  constraint,
  other,
}

class KnowledgeHubLimits {
  static const int titleMaxLength = 80;
  static const int contentMaxLength = 4000;
}

class KnowledgeItem {
  final int? id;
  final int profileId;
  final int? conversationId;
  final int? sourceMessageId;
  final String title;
  final String content;
  final MemoryType memoryType;
  final List<String> tags;
  final bool isPinned;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const KnowledgeItem({
    this.id,
    required this.profileId,
    this.conversationId,
    this.sourceMessageId,
    required this.title,
    required this.content,
    required this.memoryType,
    this.tags = const [],
    this.isPinned = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'conversation_id': conversationId,
      'source_message_id': sourceMessageId,
      'title': title,
      'content': content,
      'memory_type': memoryType.name,
      'tags_json': jsonEncode(tags),
      'is_pinned': isPinned ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory KnowledgeItem.fromMap(Map<String, dynamic> map) {
    final rawType = (map['memory_type'] as String?) ?? MemoryType.other.name;
    final memoryType = MemoryType.values.firstWhere(
      (type) => type.name == rawType,
      orElse: () => MemoryType.other,
    );

    final rawTags = map['tags_json'] as String?;
    final tags = rawTags == null || rawTags.isEmpty
        ? <String>[]
        : List<String>.from(jsonDecode(rawTags));

    return KnowledgeItem(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int,
      conversationId: map['conversation_id'] as int?,
      sourceMessageId: map['source_message_id'] as int?,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      memoryType: memoryType,
      tags: tags,
      isPinned: (map['is_pinned'] ?? 0) == 1,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt:
          (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt:
          (map['updated_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  KnowledgeItem copyWith({
    int? id,
    int? profileId,
    int? conversationId,
    int? sourceMessageId,
    String? title,
    String? content,
    MemoryType? memoryType,
    List<String>? tags,
    bool? isPinned,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return KnowledgeItem(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      conversationId: conversationId ?? this.conversationId,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      title: title ?? this.title,
      content: content ?? this.content,
      memoryType: memoryType ?? this.memoryType,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
