import 'package:flutter/foundation.dart';

import '../models/knowledge_item.dart';
import 'database_service.dart';
import 'supabase_service.dart';

enum MemoryLearningSource { chat, voice }

class MemoryExtractionResult {
  const MemoryExtractionResult({
    required this.processed,
    this.reason,
    this.activeCount = 0,
    this.suggestedCount = 0,
  });

  final bool processed;
  final String? reason;
  final int activeCount;
  final int suggestedCount;
}

class MemoryPreferences {
  const MemoryPreferences({
    this.personalizationEnabled = true,
    this.learnFromChats = true,
    this.learnFromVoice = true,
  });

  final bool personalizationEnabled;
  final bool learnFromChats;
  final bool learnFromVoice;

  MemoryPreferences copyWith({
    bool? personalizationEnabled,
    bool? learnFromChats,
    bool? learnFromVoice,
  }) {
    return MemoryPreferences(
      personalizationEnabled:
          personalizationEnabled ?? this.personalizationEnabled,
      learnFromChats: learnFromChats ?? this.learnFromChats,
      learnFromVoice: learnFromVoice ?? this.learnFromVoice,
    );
  }
}

class CloudMemorySuggestion {
  const CloudMemorySuggestion({
    required this.id,
    required this.title,
    required this.content,
    required this.memoryType,
    required this.confidence,
    required this.sourceType,
  });

  final String id;
  final String title;
  final String content;
  final MemoryType memoryType;
  final double confidence;
  final String sourceType;
}

/// Bridges the server-owned M5.1 memory store with the existing local
/// Knowledge Hub. Cloud failures never block chat or transcript persistence.
class PersonalMemoryService {
  PersonalMemoryService({
    SupabaseService? supabaseService,
    DatabaseService? databaseService,
  })  : _supabase = supabaseService ?? SupabaseService(),
        _database = databaseService ?? DatabaseService();

  final SupabaseService _supabase;
  final DatabaseService _database;
  final Map<int, DateTime> _lastSyncByProfile = {};
  final Set<int> _migratedLocalProfiles = {};

  bool get hasCloudPersonalization => _supabase.isAuthenticated;

  Future<MemoryPreferences> getPreferences() async {
    if (!_supabase.isAuthenticated) return const MemoryPreferences();
    try {
      final userId = _supabase.currentUser!.id;
      final row = await _supabase.client
          .from('memory_preferences')
          .select('personalization_enabled,learn_from_chats,learn_from_voice')
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) {
        await updatePreferences(const MemoryPreferences());
        return const MemoryPreferences();
      }
      return MemoryPreferences(
        personalizationEnabled: row['personalization_enabled'] != false,
        learnFromChats: row['learn_from_chats'] != false,
        learnFromVoice: row['learn_from_voice'] != false,
      );
    } catch (error) {
      debugPrint('[PersonalMemoryService] Preference load skipped: $error');
      // Do not present personalization as enabled when the privacy preference
      // could not be read.
      return const MemoryPreferences(
        personalizationEnabled: false,
        learnFromChats: false,
        learnFromVoice: false,
      );
    }
  }

  Future<void> updatePreferences(MemoryPreferences preferences) async {
    if (!_supabase.isAuthenticated) return;
    try {
      await _supabase.client.from('memory_preferences').upsert({
        'user_id': _supabase.currentUser!.id,
        'personalization_enabled': preferences.personalizationEnabled,
        'learn_from_chats': preferences.learnFromChats,
        'learn_from_voice': preferences.learnFromVoice,
      }, onConflict: 'user_id');
    } catch (error) {
      debugPrint('[PersonalMemoryService] Preference update skipped: $error');
      rethrow;
    }
  }

  Future<MemoryExtractionResult> learnFromConversation({
    required MemoryLearningSource source,
    required String sourceId,
    required int profileId,
    required List<Map<String, String>> messages,
  }) async {
    if (!_supabase.isAuthenticated) {
      return const MemoryExtractionResult(
        processed: false,
        reason: 'signed_in_account_required',
      );
    }

    try {
      final response = await _supabase.client.functions.invoke(
        'memory-extract',
        body: {
          'source_type': source.name,
          'source_id': sourceId,
          'messages': messages,
        },
      );
      final data = response.data;
      if (data is! Map) {
        return const MemoryExtractionResult(
          processed: false,
          reason: 'invalid_response',
        );
      }
      final result = Map<String, dynamic>.from(data);
      final memories = result['memories'];
      if (memories is List) {
        for (final raw in memories) {
          if (raw is Map && raw['status'] == 'active') {
            await _mirrorCloudMemory(
              profileId,
              Map<String, dynamic>.from(raw),
              source.name,
            );
          }
        }
      }
      return MemoryExtractionResult(
        processed: result['processed'] == true,
        reason: result['reason']?.toString(),
        activeCount: _asInt(result['active_count']),
        suggestedCount: _asInt(result['suggested_count']),
      );
    } catch (error) {
      debugPrint('[PersonalMemoryService] Learning skipped: $error');
      return const MemoryExtractionResult(
        processed: false,
        reason: 'unavailable',
      );
    }
  }

  Future<void> syncActiveMemoriesToLocal(int profileId) async {
    if (!_supabase.isAuthenticated) return;
    await _syncExistingLocalMemoriesToCloud(profileId);
    final lastSync = _lastSyncByProfile[profileId];
    if (lastSync != null &&
        DateTime.now().difference(lastSync) < const Duration(minutes: 1)) {
      return;
    }
    try {
      final rows = await _supabase.client
          .from('user_memories')
          .select(
              'id,title,content,memory_type,tags,status,source_type,created_at,updated_at')
          .inFilter('status', ['active', 'archived'])
          .order('updated_at', ascending: false)
          .limit(100);
      for (final raw in rows) {
        final memory = Map<String, dynamic>.from(raw);
        final status = memory['status']?.toString();
        if (status == 'active') {
          await _mirrorCloudMemory(
            profileId,
            memory,
            memory['source_type']?.toString() ?? 'manual',
          );
        } else if (status == 'archived') {
          final cloudId = memory['id']?.toString();
          if (cloudId == null) continue;
          final local = await _database.getKnowledgeItemByCloudId(cloudId);
          if (local != null && local.isActive) {
            await _database.updateKnowledgeItem(
              local.copyWith(
                isActive: false,
                updatedAt: memory['updated_at']?.toString(),
              ),
            );
          }
        }
      }
      _lastSyncByProfile[profileId] = DateTime.now();
    } catch (error) {
      debugPrint('[PersonalMemoryService] Cloud sync skipped: $error');
    }
  }

  Future<List<CloudMemorySuggestion>> getSuggestedMemories() async {
    if (!_supabase.isAuthenticated) return const [];
    try {
      final rows = await _supabase.client
          .from('user_memories')
          .select(
              'id,title,content,memory_type,confidence,source_type,updated_at')
          .eq('status', 'suggested')
          .order('updated_at', ascending: false)
          .limit(25);
      return rows.map((raw) {
        final memory = Map<String, dynamic>.from(raw);
        final typeName = memory['memory_type']?.toString() ?? 'other';
        return CloudMemorySuggestion(
          id: memory['id'].toString(),
          title: memory['title']?.toString() ?? '',
          content: memory['content']?.toString() ?? '',
          memoryType: MemoryType.values.firstWhere(
            (type) => type.name == typeName,
            orElse: () => MemoryType.other,
          ),
          confidence: (memory['confidence'] as num?)?.toDouble() ?? 0,
          sourceType: memory['source_type']?.toString() ?? 'chat',
        );
      }).where((memory) {
        return memory.id.isNotEmpty &&
            memory.title.trim().isNotEmpty &&
            memory.content.trim().isNotEmpty;
      }).toList(growable: false);
    } catch (error) {
      debugPrint('[PersonalMemoryService] Suggestion load skipped: $error');
      return const [];
    }
  }

  Future<void> reviewSuggestion({
    required CloudMemorySuggestion suggestion,
    required int profileId,
    required bool accept,
  }) async {
    if (!_supabase.isAuthenticated) return;
    final status = accept ? 'active' : 'archived';
    final row = await _supabase.client
        .from('user_memories')
        .update({'status': status})
        .eq('id', suggestion.id)
        .eq('user_id', _supabase.currentUser!.id)
        .select(
            'id,title,content,memory_type,tags,status,source_type,created_at,updated_at')
        .single();
    if (accept) {
      await _mirrorCloudMemory(
        profileId,
        Map<String, dynamic>.from(row),
        suggestion.sourceType,
      );
    }
    _lastSyncByProfile.remove(profileId);
  }

  Future<KnowledgeItem> syncManualMemory(KnowledgeItem item) async {
    if (!_supabase.isAuthenticated) return item;
    try {
      final userId = _supabase.currentUser!.id;
      if (item.cloudId != null) {
        final row = await _supabase.client
            .from('user_memories')
            .update(_cloudPayload(item))
            .eq('id', item.cloudId!)
            .eq('user_id', userId)
            .select('id')
            .single();
        return item.copyWith(cloudId: row['id']?.toString());
      }

      final memoryKey =
          'manual-${DateTime.now().microsecondsSinceEpoch}-${item.profileId}';
      final row = await _supabase.client
          .from('user_memories')
          .insert({
            ..._cloudPayload(item),
            'user_id': userId,
            'memory_key': memoryKey,
            'source_type': 'manual',
            'confidence': 1,
            'is_explicit': true,
            'sensitivity': 'normal',
          })
          .select('id')
          .single();
      return item.copyWith(
        cloudId: row['id']?.toString(),
        sourceType: 'manual',
      );
    } catch (error) {
      debugPrint('[PersonalMemoryService] Manual memory sync skipped: $error');
      return item;
    }
  }

  Future<void> deleteCloudMemory(String? cloudId) async {
    if (cloudId == null || !_supabase.isAuthenticated) return;
    try {
      await _supabase.client
          .from('user_memories')
          .delete()
          .eq('id', cloudId)
          .eq('user_id', _supabase.currentUser!.id);
    } catch (error) {
      debugPrint('[PersonalMemoryService] Cloud delete skipped: $error');
    }
  }

  Future<void> clearCloudMemories() async {
    if (!_supabase.isAuthenticated) return;
    try {
      final userId = _supabase.currentUser!.id;
      await Future.wait([
        _supabase.client.from('user_memories').delete().eq('user_id', userId),
        _supabase.client
            .from('memory_session_summaries')
            .delete()
            .eq('user_id', userId),
      ]);
    } catch (error) {
      debugPrint('[PersonalMemoryService] Cloud clear skipped: $error');
    }
  }

  Future<void> _syncExistingLocalMemoriesToCloud(int profileId) async {
    if (_migratedLocalProfiles.contains(profileId) ||
        !_supabase.isAuthenticated) {
      return;
    }
    try {
      final items = await _database.getKnowledgeItemsForProfile(profileId);
      for (final item in items.where((memory) => memory.cloudId == null)) {
        final synced = await syncManualMemory(item);
        if (synced.cloudId != null && synced.id != null) {
          await _database.updateKnowledgeItem(synced);
        }
      }
      _migratedLocalProfiles.add(profileId);
    } catch (error) {
      debugPrint(
          '[PersonalMemoryService] Existing memory migration skipped: $error');
    }
  }

  Future<void> _mirrorCloudMemory(
    int profileId,
    Map<String, dynamic> memory,
    String sourceType,
  ) async {
    final cloudId = memory['id']?.toString();
    final title = memory['title']?.toString().trim() ?? '';
    final content = memory['content']?.toString().trim() ?? '';
    if (cloudId == null || title.isEmpty || content.isEmpty) return;

    final typeName = memory['memory_type']?.toString() ?? 'other';
    final memoryType = MemoryType.values.firstWhere(
      (type) => type.name == typeName,
      orElse: () => MemoryType.other,
    );
    final tags = memory['tags'] is List
        ? (memory['tags'] as List)
            .map((tag) => tag.toString())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false)
        : const <String>[];
    final now = DateTime.now().toIso8601String();
    final createdAt = memory['created_at']?.toString() ?? now;
    final updatedAt = memory['updated_at']?.toString() ?? now;
    var local = await _database.getKnowledgeItemByCloudId(cloudId);
    if (local == null) {
      final all = await _database.getKnowledgeItemsForProfile(profileId);
      for (final candidate in all) {
        if (candidate.title.trim().toLowerCase() == title.toLowerCase() &&
            candidate.content.trim().toLowerCase() == content.toLowerCase()) {
          local = candidate;
          break;
        }
      }
    }

    if (local == null) {
      await _database.insertKnowledgeItem(
        KnowledgeItem(
          profileId: profileId,
          cloudId: cloudId,
          sourceType: sourceType,
          title: title,
          content: content,
          memoryType: memoryType,
          tags: tags,
          isActive: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
      return;
    }

    await _database.updateKnowledgeItem(
      local.copyWith(
        cloudId: cloudId,
        sourceType: sourceType,
        title: title,
        content: content,
        memoryType: memoryType,
        tags: tags,
        isActive: true,
        updatedAt: updatedAt,
      ),
    );
  }

  Map<String, dynamic> _cloudPayload(KnowledgeItem item) {
    return {
      'title': item.title.trim(),
      'content': item.content.trim(),
      'memory_type': item.memoryType.name,
      'tags': item.tags,
      'status': item.isActive ? 'active' : 'archived',
      'last_observed_at': DateTime.now().toIso8601String(),
    };
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
