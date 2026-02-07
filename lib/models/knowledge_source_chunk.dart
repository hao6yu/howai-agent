import 'dart:convert';

class KnowledgeSourceChunk {
  final int? id;
  final int sourceId;
  final int profileId;
  final int chunkIndex;
  final String content;
  final String? contentHash;
  final int? tokenEstimate;
  final Map<String, dynamic>? metadata;
  final String createdAt;

  const KnowledgeSourceChunk({
    this.id,
    required this.sourceId,
    required this.profileId,
    required this.chunkIndex,
    required this.content,
    this.contentHash,
    this.tokenEstimate,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_id': sourceId,
      'profile_id': profileId,
      'chunk_index': chunkIndex,
      'content': content,
      'content_hash': contentHash,
      'token_estimate': tokenEstimate,
      'metadata_json': metadata == null ? null : jsonEncode(metadata),
      'created_at': createdAt,
    };
  }

  factory KnowledgeSourceChunk.fromMap(Map<String, dynamic> map) {
    final metadataRaw = map['metadata_json'] as String?;
    Map<String, dynamic>? metadata;
    if (metadataRaw != null && metadataRaw.isNotEmpty) {
      final parsed = jsonDecode(metadataRaw);
      if (parsed is Map<String, dynamic>) {
        metadata = parsed;
      }
    }

    return KnowledgeSourceChunk(
      id: map['id'] as int?,
      sourceId: map['source_id'] as int,
      profileId: map['profile_id'] as int,
      chunkIndex: map['chunk_index'] as int,
      content: (map['content'] as String?) ?? '',
      contentHash: map['content_hash'] as String?,
      tokenEstimate: map['token_estimate'] as int?,
      metadata: metadata,
      createdAt:
          (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  KnowledgeSourceChunk copyWith({
    int? id,
    int? sourceId,
    int? profileId,
    int? chunkIndex,
    String? content,
    String? contentHash,
    int? tokenEstimate,
    Map<String, dynamic>? metadata,
    bool clearMetadata = false,
    String? createdAt,
  }) {
    return KnowledgeSourceChunk(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      profileId: profileId ?? this.profileId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      content: content ?? this.content,
      contentHash: contentHash ?? this.contentHash,
      tokenEstimate: tokenEstimate ?? this.tokenEstimate,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
