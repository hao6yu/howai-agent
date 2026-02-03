import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service to map local INTEGER IDs to Supabase UUIDs
/// Uses SharedPreferences for persistent storage
class IDMappingService {
  static final IDMappingService _instance = IDMappingService._internal();
  factory IDMappingService() => _instance;
  IDMappingService._internal();

  static const String _conversationMappingKey = 'conversation_id_mapping';
  static const String _messageMappingKey = 'message_id_mapping';
  static const String _profileMappingKey = 'profile_id_mapping';
  static const String _personalityMappingKey = 'personality_id_mapping';

  // In-memory cache for faster lookups
  Map<int, String>? _conversationCache;
  Map<int, String>? _messageCache;
  Map<int, String>? _profileCache;
  Map<int, String>? _personalityCache;

  // Reverse mappings (UUID -> local ID)
  Map<String, int>? _reverseConversationCache;
  Map<String, int>? _reverseMessageCache;
  Map<String, int>? _reverseProfileCache;
  Map<String, int>? _reversePersonalityCache;

  /// Initialize and load all mappings into cache
  Future<void> initialize() async {
    await _loadAllMappings();
  }

  Future<void> _loadAllMappings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load conversation mappings
    final convJson = prefs.getString(_conversationMappingKey);
    if (convJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(convJson);
      _conversationCache = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
      _reverseConversationCache = _conversationCache!.map((k, v) => MapEntry(v, k));
    } else {
      _conversationCache = {};
      _reverseConversationCache = {};
    }

    // Load message mappings
    final msgJson = prefs.getString(_messageMappingKey);
    if (msgJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(msgJson);
      _messageCache = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
      _reverseMessageCache = _messageCache!.map((k, v) => MapEntry(v, k));
    } else {
      _messageCache = {};
      _reverseMessageCache = {};
    }

    // Load profile mappings
    final profJson = prefs.getString(_profileMappingKey);
    if (profJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(profJson);
      _profileCache = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
      _reverseProfileCache = _profileCache!.map((k, v) => MapEntry(v, k));
    } else {
      _profileCache = {};
      _reverseProfileCache = {};
    }

    // Load personality mappings
    final persJson = prefs.getString(_personalityMappingKey);
    if (persJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(persJson);
      _personalityCache = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
      _reversePersonalityCache = _personalityCache!.map((k, v) => MapEntry(v, k));
    } else {
      _personalityCache = {};
      _reversePersonalityCache = {};
    }

    debugPrint('[IDMappingService] Loaded mappings: '
        '${_conversationCache!.length} conversations, '
        '${_messageCache!.length} messages, '
        '${_profileCache!.length} profiles, '
        '${_personalityCache!.length} personalities');
  }

  /// Store a conversation ID mapping
  Future<void> storeConversationMapping(int localId, String uuid) async {
    _conversationCache ??= {};
    _reverseConversationCache ??= {};
    
    // Check if this UUID is already mapped to a different local ID
    final existingLocalId = _reverseConversationCache![uuid];
    if (existingLocalId != null && existingLocalId != localId) {
      // Remove the old mapping to prevent duplicates
      _conversationCache!.remove(existingLocalId);
      debugPrint('[IDMappingService] Removed old mapping: localId=$existingLocalId -> uuid=$uuid');
    }
    
    _conversationCache![localId] = uuid;
    _reverseConversationCache![uuid] = localId;
    
    await _saveMapping(_conversationMappingKey, _conversationCache!);
  }

  /// Store a message ID mapping
  Future<void> storeMessageMapping(int localId, String uuid) async {
    _messageCache ??= {};
    _reverseMessageCache ??= {};
    
    // Check if this UUID is already mapped to a different local ID
    final existingLocalId = _reverseMessageCache![uuid];
    if (existingLocalId != null && existingLocalId != localId) {
      // Remove the old mapping to prevent duplicates
      _messageCache!.remove(existingLocalId);
      debugPrint('[IDMappingService] Removed old message mapping: localId=$existingLocalId -> uuid=$uuid');
    }
    
    _messageCache![localId] = uuid;
    _reverseMessageCache![uuid] = localId;
    
    await _saveMapping(_messageMappingKey, _messageCache!);
  }

  /// Store a profile ID mapping
  Future<void> storeProfileMapping(int localId, String uuid) async {
    _profileCache ??= {};
    _reverseProfileCache ??= {};
    
    _profileCache![localId] = uuid;
    _reverseProfileCache![uuid] = localId;
    
    await _saveMapping(_profileMappingKey, _profileCache!);
  }

  /// Store a personality ID mapping
  Future<void> storePersonalityMapping(int localId, String uuid) async {
    _personalityCache ??= {};
    _reversePersonalityCache ??= {};
    
    _personalityCache![localId] = uuid;
    _reversePersonalityCache![uuid] = localId;
    
    await _saveMapping(_personalityMappingKey, _personalityCache!);
  }

  /// Get UUID for a local conversation ID
  String? getConversationUUID(int localId) {
    return _conversationCache?[localId];
  }

  /// Get UUID for a local message ID
  String? getMessageUUID(int localId) {
    return _messageCache?[localId];
  }

  /// Get UUID for a local profile ID
  String? getProfileUUID(int localId) {
    return _profileCache?[localId];
  }

  /// Get UUID for a local personality ID
  String? getPersonalityUUID(int localId) {
    return _personalityCache?[localId];
  }

  /// Get local ID for a conversation UUID
  int? getConversationLocalId(String uuid) {
    return _reverseConversationCache?[uuid];
  }

  /// Get local ID for a message UUID
  int? getMessageLocalId(String uuid) {
    return _reverseMessageCache?[uuid];
  }

  /// Get local ID for a profile UUID
  int? getProfileLocalId(String uuid) {
    return _reverseProfileCache?[uuid];
  }

  /// Get local ID for a personality UUID
  int? getPersonalityLocalId(String uuid) {
    return _reversePersonalityCache?[uuid];
  }

  /// Save mapping to SharedPreferences
  Future<void> _saveMapping(String key, Map<int, String> mapping) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert int keys to strings for JSON
      final Map<String, String> stringKeyMap = mapping.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(key, jsonEncode(stringKeyMap));
    } catch (e) {
      debugPrint('[IDMappingService] Error saving mapping: $e');
    }
  }

  /// Clear all mappings (useful for testing or logout)
  Future<void> clearAllMappings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationMappingKey);
    await prefs.remove(_messageMappingKey);
    await prefs.remove(_profileMappingKey);
    await prefs.remove(_personalityMappingKey);
    
    _conversationCache = {};
    _messageCache = {};
    _profileCache = {};
    _personalityCache = {};
    _reverseConversationCache = {};
    _reverseMessageCache = {};
    _reverseProfileCache = {};
    _reversePersonalityCache = {};
    
    debugPrint('[IDMappingService] All mappings cleared');
  }

  /// Get statistics about stored mappings
  Map<String, int> getStats() {
    return {
      'conversations': _conversationCache?.length ?? 0,
      'messages': _messageCache?.length ?? 0,
      'profiles': _profileCache?.length ?? 0,
      'personalities': _personalityCache?.length ?? 0,
    };
  }

  /// Find and return duplicate conversation mappings (multiple local IDs pointing to same UUID)
  Map<String, List<int>> findDuplicateConversations() {
    final duplicates = <String, List<int>>{};
    
    if (_reverseConversationCache == null) return duplicates;
    
    // Group local IDs by UUID
    final uuidToLocalIds = <String, List<int>>{};
    for (final entry in _conversationCache!.entries) {
      final localId = entry.key;
      final uuid = entry.value;
      uuidToLocalIds.putIfAbsent(uuid, () => []).add(localId);
    }
    
    // Find UUIDs with multiple local IDs
    for (final entry in uuidToLocalIds.entries) {
      if (entry.value.length > 1) {
        duplicates[entry.key] = entry.value;
        debugPrint('[IDMappingService] Found duplicate: UUID ${entry.key} -> localIds ${entry.value}');
      }
    }
    
    return duplicates;
  }

  /// Clean up duplicate mappings by keeping only the most recent one
  Future<void> cleanupDuplicateMappings() async {
    final duplicates = findDuplicateConversations();
    
    if (duplicates.isEmpty) {
      debugPrint('[IDMappingService] No duplicate mappings found');
      return;
    }
    
    debugPrint('[IDMappingService] Cleaning up ${duplicates.length} duplicate conversation mappings');
    
    for (final entry in duplicates.entries) {
      final localIds = entry.value;
      
      // Keep the highest local ID (most recent), remove others
      localIds.sort();
      final keepId = localIds.last;
      
      for (final localId in localIds) {
        if (localId != keepId) {
          _conversationCache!.remove(localId);
          debugPrint('[IDMappingService] Removed duplicate mapping: localId=$localId');
        }
      }
    }
    
    // Save the cleaned mappings
    await _saveMapping(_conversationMappingKey, _conversationCache!);
    
    // Rebuild reverse cache
    _reverseConversationCache = _conversationCache!.map((k, v) => MapEntry(v, k));
    
    debugPrint('[IDMappingService] Cleanup complete');
  }
}


