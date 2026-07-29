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
  static const String _legacyMappingOwnerKey = 'legacy_id_mappings_claimed_by';
  String? _ownerId;

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
  Future<void> initialize(String ownerId) async {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'Must not be empty');
    }
    if (_ownerId == ownerId &&
        _conversationCache != null &&
        _messageCache != null &&
        _profileCache != null &&
        _personalityCache != null) {
      return;
    }
    _ownerId = ownerId;
    await _loadAllMappings();
  }

  String _scopedKey(String baseKey) {
    final ownerId = _ownerId;
    if (ownerId == null) {
      throw StateError('IDMappingService has not been initialized');
    }
    return '${baseKey}_$ownerId';
  }

  Future<String?> _loadScopedJson(
    SharedPreferences preferences,
    String baseKey,
  ) async {
    final scopedKey = _scopedKey(baseKey);
    final scoped = preferences.getString(scopedKey);
    if (scoped != null) return scoped;

    final claimedBy = preferences.getString(_legacyMappingOwnerKey);
    final legacy = preferences.getString(baseKey);
    if (legacy != null && (claimedBy == null || claimedBy == _ownerId)) {
      await preferences.setString(scopedKey, legacy);
      await preferences.setString(_legacyMappingOwnerKey, _ownerId!);
      return legacy;
    }
    return null;
  }

  Map<int, String> _decodeMapping(
    String? encoded,
    String mappingName,
  ) {
    if (encoded == null) return {};
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return {};
      return Map<String, dynamic>.from(decoded).map(
        (key, value) => MapEntry(int.parse(key), value.toString()),
      );
    } catch (error) {
      debugPrint(
        '[IDMappingService] Ignoring malformed $mappingName mapping: $error',
      );
      return {};
    }
  }

  Future<void> _loadAllMappings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load conversation mappings
    final convJson = await _loadScopedJson(prefs, _conversationMappingKey);
    _conversationCache = _decodeMapping(convJson, 'conversation');
    await _replaceMalformedOrEmptyMapping(
      prefs,
      _conversationMappingKey,
      convJson,
      _conversationCache!,
    );
    _reverseConversationCache =
        _conversationCache!.map((key, value) => MapEntry(value, key));

    // Load message mappings
    final msgJson = await _loadScopedJson(prefs, _messageMappingKey);
    _messageCache = _decodeMapping(msgJson, 'message');
    await _replaceMalformedOrEmptyMapping(
      prefs,
      _messageMappingKey,
      msgJson,
      _messageCache!,
    );
    _reverseMessageCache =
        _messageCache!.map((key, value) => MapEntry(value, key));

    // Load profile mappings
    final profJson = await _loadScopedJson(prefs, _profileMappingKey);
    _profileCache = _decodeMapping(profJson, 'profile');
    await _replaceMalformedOrEmptyMapping(
      prefs,
      _profileMappingKey,
      profJson,
      _profileCache!,
    );
    _reverseProfileCache =
        _profileCache!.map((key, value) => MapEntry(value, key));

    // Load personality mappings
    final persJson = await _loadScopedJson(prefs, _personalityMappingKey);
    _personalityCache = _decodeMapping(persJson, 'personality');
    await _replaceMalformedOrEmptyMapping(
      prefs,
      _personalityMappingKey,
      persJson,
      _personalityCache!,
    );
    _reversePersonalityCache =
        _personalityCache!.map((key, value) => MapEntry(value, key));

    debugPrint('[IDMappingService] Loaded mappings: '
        '${_conversationCache!.length} conversations, '
        '${_messageCache!.length} messages, '
        '${_profileCache!.length} profiles, '
        '${_personalityCache!.length} personalities');
  }

  Future<void> _replaceMalformedOrEmptyMapping(
    SharedPreferences preferences,
    String baseKey,
    String? encoded,
    Map<int, String> decoded,
  ) async {
    if (encoded == null || decoded.isNotEmpty) return;
    await preferences.setString(_scopedKey(baseKey), '{}');
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
      debugPrint(
          '[IDMappingService] Removed old mapping: localId=$existingLocalId -> uuid=$uuid');
    }

    _conversationCache![localId] = uuid;
    _reverseConversationCache![uuid] = localId;

    await _saveMapping(
        _scopedKey(_conversationMappingKey), _conversationCache!);
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
      debugPrint(
          '[IDMappingService] Removed old message mapping: localId=$existingLocalId -> uuid=$uuid');
    }

    _messageCache![localId] = uuid;
    _reverseMessageCache![uuid] = localId;

    await _saveMapping(_scopedKey(_messageMappingKey), _messageCache!);
  }

  /// Store a profile ID mapping
  Future<void> storeProfileMapping(int localId, String uuid) async {
    _profileCache ??= {};
    _reverseProfileCache ??= {};

    _profileCache![localId] = uuid;
    _reverseProfileCache![uuid] = localId;

    await _saveMapping(_scopedKey(_profileMappingKey), _profileCache!);
  }

  /// Store a personality ID mapping
  Future<void> storePersonalityMapping(int localId, String uuid) async {
    _personalityCache ??= {};
    _reversePersonalityCache ??= {};

    _personalityCache![localId] = uuid;
    _reversePersonalityCache![uuid] = localId;

    await _saveMapping(_scopedKey(_personalityMappingKey), _personalityCache!);
  }

  /// Get UUID for a local conversation ID
  String? getConversationUUID(int localId) {
    return _conversationCache?[localId];
  }

  Future<void> removeConversationMapping(int localId) async {
    final uuid = _conversationCache?.remove(localId);
    if (uuid != null) {
      _reverseConversationCache?.remove(uuid);
      await _saveMapping(
        _scopedKey(_conversationMappingKey),
        _conversationCache!,
      );
    }
  }

  /// Get UUID for a local message ID
  String? getMessageUUID(int localId) {
    return _messageCache?[localId];
  }

  Future<void> removeMessageMappings(Iterable<int> localIds) async {
    var changed = false;
    for (final localId in localIds) {
      final uuid = _messageCache?.remove(localId);
      if (uuid != null) {
        _reverseMessageCache?.remove(uuid);
        changed = true;
      }
    }
    if (changed) {
      await _saveMapping(
        _scopedKey(_messageMappingKey),
        _messageCache!,
      );
    }
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
      final Map<String, String> stringKeyMap =
          mapping.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(key, jsonEncode(stringKeyMap));
    } catch (e) {
      debugPrint('[IDMappingService] Error saving mapping: $e');
    }
  }

  /// Clear all mappings (useful for testing or logout)
  Future<void> clearAllMappings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scopedKey(_conversationMappingKey));
    await prefs.remove(_scopedKey(_messageMappingKey));
    await prefs.remove(_scopedKey(_profileMappingKey));
    await prefs.remove(_scopedKey(_personalityMappingKey));

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

  /// Clears only process memory when an account signs out. Persisted mappings
  /// remain isolated under that account and are available on the next sign-in.
  void deactivate() {
    _ownerId = null;
    _conversationCache = null;
    _messageCache = null;
    _profileCache = null;
    _personalityCache = null;
    _reverseConversationCache = null;
    _reverseMessageCache = null;
    _reverseProfileCache = null;
    _reversePersonalityCache = null;
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
        debugPrint(
            '[IDMappingService] Found duplicate: UUID ${entry.key} -> localIds ${entry.value}');
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

    debugPrint(
        '[IDMappingService] Cleaning up ${duplicates.length} duplicate conversation mappings');

    for (final entry in duplicates.entries) {
      final localIds = entry.value;

      // Keep the highest local ID (most recent), remove others
      localIds.sort();
      final keepId = localIds.last;

      for (final localId in localIds) {
        if (localId != keepId) {
          _conversationCache!.remove(localId);
          debugPrint(
              '[IDMappingService] Removed duplicate mapping: localId=$localId');
        }
      }
    }

    // Save the cleaned mappings
    await _saveMapping(
      _scopedKey(_conversationMappingKey),
      _conversationCache!,
    );

    // Rebuild reverse cache
    _reverseConversationCache =
        _conversationCache!.map((k, v) => MapEntry(v, k));

    debugPrint('[IDMappingService] Cleanup complete');
  }
}
