enum KnowledgeSourceType {
  file,
  chatMessage,
}

enum KnowledgeExtractionStatus {
  pending,
  ready,
  failed,
}

class KnowledgeSource {
  final int? id;
  final int profileId;
  final int? knowledgeItemId;
  final KnowledgeSourceType sourceType;
  final String displayName;
  final String? mimeType;
  final String? fileExtension;
  final int? fileSizeBytes;
  final String? localUri;
  final String? storageKey;
  final String? sha256;
  final KnowledgeExtractionStatus extractionStatus;
  final String? extractionError;
  final String createdAt;
  final String updatedAt;

  const KnowledgeSource({
    this.id,
    required this.profileId,
    this.knowledgeItemId,
    required this.sourceType,
    required this.displayName,
    this.mimeType,
    this.fileExtension,
    this.fileSizeBytes,
    this.localUri,
    this.storageKey,
    this.sha256,
    this.extractionStatus = KnowledgeExtractionStatus.pending,
    this.extractionError,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'knowledge_item_id': knowledgeItemId,
      'source_type': sourceType.name,
      'display_name': displayName,
      'mime_type': mimeType,
      'file_extension': fileExtension,
      'file_size_bytes': fileSizeBytes,
      'local_uri': localUri,
      'storage_key': storageKey,
      'sha256': sha256,
      'extraction_status': extractionStatus.name,
      'extraction_error': extractionError,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory KnowledgeSource.fromMap(Map<String, dynamic> map) {
    final sourceTypeRaw = (map['source_type'] as String?) ?? 'file';
    final sourceType = KnowledgeSourceType.values.firstWhere(
      (type) => type.name == sourceTypeRaw,
      orElse: () => KnowledgeSourceType.file,
    );

    final statusRaw = (map['extraction_status'] as String?) ?? 'pending';
    final status = KnowledgeExtractionStatus.values.firstWhere(
      (item) => item.name == statusRaw,
      orElse: () => KnowledgeExtractionStatus.pending,
    );

    return KnowledgeSource(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int,
      knowledgeItemId: map['knowledge_item_id'] as int?,
      sourceType: sourceType,
      displayName: (map['display_name'] as String?) ?? '',
      mimeType: map['mime_type'] as String?,
      fileExtension: map['file_extension'] as String?,
      fileSizeBytes: map['file_size_bytes'] as int?,
      localUri: map['local_uri'] as String?,
      storageKey: map['storage_key'] as String?,
      sha256: map['sha256'] as String?,
      extractionStatus: status,
      extractionError: map['extraction_error'] as String?,
      createdAt:
          (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt:
          (map['updated_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  KnowledgeSource copyWith({
    int? id,
    int? profileId,
    int? knowledgeItemId,
    bool clearKnowledgeItemId = false,
    KnowledgeSourceType? sourceType,
    String? displayName,
    String? mimeType,
    String? fileExtension,
    int? fileSizeBytes,
    String? localUri,
    String? storageKey,
    String? sha256,
    KnowledgeExtractionStatus? extractionStatus,
    String? extractionError,
    bool clearExtractionError = false,
    String? createdAt,
    String? updatedAt,
  }) {
    return KnowledgeSource(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      knowledgeItemId: clearKnowledgeItemId
          ? null
          : (knowledgeItemId ?? this.knowledgeItemId),
      sourceType: sourceType ?? this.sourceType,
      displayName: displayName ?? this.displayName,
      mimeType: mimeType ?? this.mimeType,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      localUri: localUri ?? this.localUri,
      storageKey: storageKey ?? this.storageKey,
      sha256: sha256 ?? this.sha256,
      extractionStatus: extractionStatus ?? this.extractionStatus,
      extractionError: clearExtractionError
          ? null
          : (extractionError ?? this.extractionError),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
