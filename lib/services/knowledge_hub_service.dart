import '../models/knowledge_item.dart';
import 'database_service.dart';
import 'subscription_service.dart';

class PremiumRequiredException implements Exception {
  final String message;
  const PremiumRequiredException(
      [this.message = 'Knowledge Hub is a Premium feature']);

  @override
  String toString() => message;
}

class DuplicateKnowledgeItemException implements Exception {
  final String message;
  const DuplicateKnowledgeItemException(
      [this.message = 'A similar memory already exists']);

  @override
  String toString() => message;
}

class KnowledgeHubService {
  static final KnowledgeHubService _instance = KnowledgeHubService._internal();
  factory KnowledgeHubService() => _instance;
  KnowledgeHubService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  bool get isPremiumAvailable => _subscriptionService.isPremium;

  void _ensurePremiumAccess() {
    if (!_subscriptionService.isPremium) {
      throw const PremiumRequiredException();
    }
  }

  Future<KnowledgeItem> createKnowledgeItem({
    required int profileId,
    int? conversationId,
    int? sourceMessageId,
    required String title,
    required String content,
    required MemoryType memoryType,
    List<String> tags = const [],
    bool isPinned = false,
    bool isActive = true,
  }) async {
    _ensurePremiumAccess();

    final normalizedTitle = title.trim().toLowerCase();
    final normalizedContent = content.trim().toLowerCase();

    final existingItems = await _databaseService.getKnowledgeItemsForProfile(
      profileId,
    );
    final alreadyExists = existingItems.any((item) =>
        item.title.trim().toLowerCase() == normalizedTitle &&
        item.content.trim().toLowerCase() == normalizedContent);
    if (alreadyExists) {
      throw const DuplicateKnowledgeItemException();
    }

    final now = DateTime.now().toIso8601String();
    final item = KnowledgeItem(
      profileId: profileId,
      conversationId: conversationId,
      sourceMessageId: sourceMessageId,
      title: title.trim(),
      content: content.trim(),
      memoryType: memoryType,
      tags: tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList(),
      isPinned: isPinned,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _databaseService.insertKnowledgeItem(item);
    return item.copyWith(id: id);
  }

  Future<List<KnowledgeItem>> getKnowledgeItemsForProfile(
    int profileId, {
    bool activeOnly = false,
    int? limit,
    MemoryType? memoryType,
  }) async {
    _ensurePremiumAccess();

    return _databaseService.getKnowledgeItemsForProfile(
      profileId,
      activeOnly: activeOnly,
      limit: limit,
      memoryType: memoryType?.name,
    );
  }

  Future<KnowledgeItem?> getKnowledgeItemById(int id) async {
    _ensurePremiumAccess();
    return _databaseService.getKnowledgeItemById(id);
  }

  Future<KnowledgeItem?> updateKnowledgeItem(KnowledgeItem item) async {
    _ensurePremiumAccess();

    if (item.id == null) {
      return null;
    }

    final updated = item.copyWith(updatedAt: DateTime.now().toIso8601String());
    final rows = await _databaseService.updateKnowledgeItem(updated);
    if (rows <= 0) {
      return null;
    }

    return _databaseService.getKnowledgeItemById(updated.id!);
  }

  Future<bool> deleteKnowledgeItem(int id) async {
    _ensurePremiumAccess();
    final rows = await _databaseService.deleteKnowledgeItem(id);
    return rows > 0;
  }

  Future<int> clearKnowledgeItemsForProfile(int profileId) async {
    _ensurePremiumAccess();
    return _databaseService.clearKnowledgeItemsForProfile(profileId);
  }

  Future<String> buildKnowledgeContextForPrompt({
    required int profileId,
    required String prompt,
    int maxItems = 5,
  }) async {
    _ensurePremiumAccess();

    final items = await _databaseService.getKnowledgeItemsForProfile(
      profileId,
      activeOnly: true,
    );

    if (items.isEmpty) return '';

    final normalizedPrompt = prompt.toLowerCase();
    final promptTokens = _extractTokens(normalizedPrompt);

    final scored = <({KnowledgeItem item, int score, String updatedAt})>[];
    for (final item in items) {
      final score = _scoreItem(
          item: item,
          normalizedPrompt: normalizedPrompt,
          promptTokens: promptTokens);
      if (score <= 0) continue;
      scored.add((item: item, score: score, updatedAt: item.updatedAt));
    }

    if (scored.isEmpty) return '';

    scored.sort((a, b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final selected = scored.take(maxItems).map((entry) => entry.item).toList();
    final lines = selected.map((item) {
      final type = item.memoryType.name;
      final tags =
          item.tags.isNotEmpty ? ' (tags: ${item.tags.join(', ')})' : '';
      return '- [$type] ${item.title}: ${item.content}$tags';
    }).join('\n');

    return 'User memory context (use only when relevant, do not quote verbatim):\n$lines';
  }

  int _scoreItem({
    required KnowledgeItem item,
    required String normalizedPrompt,
    required Set<String> promptTokens,
  }) {
    int score = 0;

    if (item.isPinned) {
      score += 3;
    }

    if (item.tags.any((tag) => normalizedPrompt.contains(tag.toLowerCase()))) {
      score += 2;
    }

    final itemKeywords = _extractTokens(
        '${item.title.toLowerCase()} ${item.content.toLowerCase()}');
    final hasKeywordMatch = itemKeywords.any(promptTokens.contains);
    if (hasKeywordMatch) {
      score += 2;
    }

    final updatedAt = DateTime.tryParse(item.updatedAt);
    if (updatedAt != null) {
      final isRecent = DateTime.now().difference(updatedAt).inDays <= 14;
      if (isRecent) {
        score += 1;
      }
    }

    return score;
  }

  Set<String> _extractTokens(String text) {
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
        .split(RegExp(r'[^a-z0-9]+'))
        .map((part) => part.trim())
        .where((part) => part.length >= 3 && !stopwords.contains(part))
        .toSet();
  }
}
