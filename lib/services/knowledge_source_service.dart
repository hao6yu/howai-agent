import 'package:file_picker/file_picker.dart';

import '../models/knowledge_source.dart';
import '../models/knowledge_source_chunk.dart';
import 'database_service.dart';
import 'file_service.dart';
import 'knowledge_hub_service.dart';
import 'subscription_service.dart';

class KnowledgeSourceService {
  static final KnowledgeSourceService _instance =
      KnowledgeSourceService._internal();
  factory KnowledgeSourceService() => _instance;
  KnowledgeSourceService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  static const int defaultChunkSize = 1000;
  static const int defaultChunkOverlap = 120;
  static const int maxExtractionChars = 24000;

  void _ensurePremiumAccess() {
    if (!_subscriptionService.isPremium) {
      throw const PremiumRequiredException();
    }
  }

  Future<KnowledgeSource> createSourceFromFile({
    required int profileId,
    required PlatformFile file,
    int? knowledgeItemId,
  }) async {
    _ensurePremiumAccess();

    final now = DateTime.now().toIso8601String();
    final filePath = file.path;
    final extension =
        (file.extension ?? FileService.getFileExtension(file.name))
            .toLowerCase();
    final mimeType =
        extension.isEmpty ? null : FileService.getMimeType(extension);
    final fingerprint = _computeFileFingerprint(file);

    final source = KnowledgeSource(
      profileId: profileId,
      knowledgeItemId: knowledgeItemId,
      sourceType: KnowledgeSourceType.file,
      displayName: file.name,
      mimeType: mimeType,
      fileExtension: extension.isEmpty ? null : extension,
      fileSizeBytes: file.size > 0 ? file.size : null,
      localUri: filePath,
      sha256: fingerprint,
      extractionStatus: KnowledgeExtractionStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _databaseService.insertKnowledgeSource(source);
    return source.copyWith(id: id);
  }

  Future<KnowledgeSource> ingestFileSource({
    required int profileId,
    required PlatformFile file,
    int? knowledgeItemId,
    int chunkSize = defaultChunkSize,
    int chunkOverlap = defaultChunkOverlap,
  }) async {
    _ensurePremiumAccess();

    final source = await createSourceFromFile(
      profileId: profileId,
      file: file,
      knowledgeItemId: knowledgeItemId,
    );

    try {
      final extractedText = (await FileService.extractTextFromFile(file)) ?? '';
      final normalizedText = _normalizeExtractedText(extractedText);

      if (normalizedText.isEmpty) {
        await markExtractionFailed(
          sourceId: source.id!,
          reason: 'No readable text could be extracted.',
        );
        return (await _databaseService.getKnowledgeSourceById(source.id!)) ??
            source.copyWith(
              extractionStatus: KnowledgeExtractionStatus.failed,
              extractionError: 'No readable text could be extracted.',
            );
      }

      final clipped = normalizedText.length > maxExtractionChars
          ? normalizedText.substring(0, maxExtractionChars)
          : normalizedText;
      final chunks = _buildChunks(
        sourceId: source.id!,
        profileId: profileId,
        text: clipped,
        chunkSize: chunkSize,
        chunkOverlap: chunkOverlap,
      );

      await _databaseService.replaceKnowledgeSourceChunks(source.id!, chunks);
      await updateExtractionStatus(
        sourceId: source.id!,
        status: KnowledgeExtractionStatus.ready,
        clearError: true,
      );

      return (await _databaseService.getKnowledgeSourceById(source.id!)) ??
          source.copyWith(extractionStatus: KnowledgeExtractionStatus.ready);
    } catch (e) {
      await markExtractionFailed(
        sourceId: source.id!,
        reason: 'Extraction failed. Please try another file.',
      );
      rethrow;
    }
  }

  Future<void> updateExtractionStatus({
    required int sourceId,
    required KnowledgeExtractionStatus status,
    String? extractionError,
    bool clearError = false,
  }) async {
    _ensurePremiumAccess();
    final source = await _databaseService.getKnowledgeSourceById(sourceId);
    if (source == null) return;

    final updated = source.copyWith(
      extractionStatus: status,
      extractionError: extractionError,
      clearExtractionError: clearError,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _databaseService.updateKnowledgeSource(updated);
  }

  Future<void> markExtractionFailed({
    required int sourceId,
    required String reason,
  }) async {
    await updateExtractionStatus(
      sourceId: sourceId,
      status: KnowledgeExtractionStatus.failed,
      extractionError: reason,
    );
  }

  Future<List<KnowledgeSource>> getSourcesForProfile(
    int profileId, {
    int? knowledgeItemId,
    KnowledgeExtractionStatus? extractionStatus,
    int? limit,
  }) async {
    _ensurePremiumAccess();
    return _databaseService.getKnowledgeSourcesForProfile(
      profileId,
      knowledgeItemId: knowledgeItemId,
      extractionStatus: extractionStatus,
      limit: limit,
    );
  }

  Future<bool> deleteSource(int sourceId) async {
    _ensurePremiumAccess();
    final rows = await _databaseService.deleteKnowledgeSource(sourceId);
    return rows > 0;
  }

  Future<void> linkSourceToKnowledgeItem({
    required int sourceId,
    required int knowledgeItemId,
  }) async {
    _ensurePremiumAccess();

    final source = await _databaseService.getKnowledgeSourceById(sourceId);
    if (source == null) return;

    await _databaseService.linkKnowledgeItemToSource(
      knowledgeItemId: knowledgeItemId,
      sourceId: sourceId,
    );

    final updated = source.copyWith(
      knowledgeItemId: knowledgeItemId,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _databaseService.updateKnowledgeSource(updated);
  }

  Future<void> unlinkSourceFromKnowledgeItem({
    required int sourceId,
    required int knowledgeItemId,
  }) async {
    _ensurePremiumAccess();

    await _databaseService.unlinkKnowledgeItemFromSource(
      knowledgeItemId: knowledgeItemId,
      sourceId: sourceId,
    );
    final source = await _databaseService.getKnowledgeSourceById(sourceId);
    if (source == null) return;
    if (source.knowledgeItemId == knowledgeItemId) {
      await _databaseService.updateKnowledgeSource(
        source.copyWith(
          clearKnowledgeItemId: true,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<List<KnowledgeSourceChunk>> getRelevantChunksForPrompt({
    required int profileId,
    required String prompt,
    int maxChunks = 6,
  }) async {
    _ensurePremiumAccess();

    final terms = _extractSearchTerms(prompt);
    if (terms.isEmpty) return const [];

    final allChunks =
        await _databaseService.getKnowledgeSourceChunks(profileId: profileId);
    if (allChunks.isEmpty) return const [];

    final scored = <({KnowledgeSourceChunk chunk, int score})>[];
    for (final chunk in allChunks) {
      final lowered = chunk.content.toLowerCase();
      int score = 0;
      for (final term in terms) {
        if (lowered.contains(term)) {
          score += 1;
        }
      }
      if (score > 0) {
        scored.add((chunk: chunk, score: score));
      }
    }

    if (scored.isEmpty) return const [];

    scored.sort((a, b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      return a.chunk.chunkIndex.compareTo(b.chunk.chunkIndex);
    });

    return scored.take(maxChunks).map((entry) => entry.chunk).toList();
  }

  List<KnowledgeSourceChunk> _buildChunks({
    required int sourceId,
    required int profileId,
    required String text,
    required int chunkSize,
    required int chunkOverlap,
  }) {
    final safeChunkSize = chunkSize < 300 ? 300 : chunkSize;
    final safeOverlap = chunkOverlap < 0 ? 0 : chunkOverlap;
    final stride = safeChunkSize - safeOverlap <= 0
        ? safeChunkSize
        : (safeChunkSize - safeOverlap);
    final now = DateTime.now().toIso8601String();

    final chunks = <KnowledgeSourceChunk>[];
    int chunkIndex = 0;
    for (int start = 0; start < text.length; start += stride) {
      final end = (start + safeChunkSize > text.length)
          ? text.length
          : (start + safeChunkSize);
      final value = text.substring(start, end).trim();
      if (value.isEmpty) {
        continue;
      }

      final digest = Object.hashAll([value, chunkIndex]).toString();
      final tokenEstimate = (value.length / 4).ceil();
      chunks.add(
        KnowledgeSourceChunk(
          sourceId: sourceId,
          profileId: profileId,
          chunkIndex: chunkIndex,
          content: value,
          contentHash: digest,
          tokenEstimate: tokenEstimate,
          createdAt: now,
        ),
      );
      chunkIndex += 1;

      if (end >= text.length) {
        break;
      }
    }
    return chunks;
  }

  String _normalizeExtractedText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  Set<String> _extractSearchTerms(String text) {
    final stopwords = <String>{
      'the',
      'and',
      'for',
      'with',
      'that',
      'this',
      'from',
      'have',
      'you',
      'your',
      'are',
      'was',
      'but',
      'can',
      'not',
      'our',
      'about',
      'into',
      'just',
      'want',
      'need',
    };

    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .map((part) => part.trim())
        .where((part) => part.length >= 3 && !stopwords.contains(part))
        .toSet();
  }

  String _computeFileFingerprint(PlatformFile file) {
    return Object.hashAll([
      file.name,
      file.size,
      file.extension ?? '',
      file.path ?? '',
    ]).toString();
  }
}
