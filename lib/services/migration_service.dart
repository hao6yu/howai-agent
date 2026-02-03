import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'database_service.dart';
import 'id_mapping_service.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

/// Service to migrate local SQLite data to Supabase
/// Migration is silent and runs in the background
class MigrationService {
  static final MigrationService _instance = MigrationService._internal();
  factory MigrationService() => _instance;
  MigrationService._internal();

  final SupabaseService _supabase = SupabaseService();
  final DatabaseService _database = DatabaseService();
  final IDMappingService _idMapping = IDMappingService();

  bool _isMigrating = false;
  double _migrationProgress = 0.0;
  String _migrationStatus = '';
  int _totalItems = 0;
  int _migratedItems = 0;

  // Getters
  bool get isMigrating => _isMigrating;
  double get migrationProgress => _migrationProgress;
  String get migrationStatus => _migrationStatus;

  /// Start migration process (silent, non-blocking)
  Future<bool> startMigration() async {
    if (!_supabase.isAuthenticated) {
      debugPrint('[MigrationService] Cannot migrate: not authenticated');
      return false;
    }

    if (_isMigrating) {
      debugPrint('[MigrationService] Migration already in progress');
      return false;
    }

    _isMigrating = true;
    _migrationProgress = 0.0;
    _migratedItems = 0;

    try {
      debugPrint('[MigrationService] Starting silent migration in background');

      // Get all conversations
      final conversations = await _database.getAllConversations();
      _totalItems = conversations.length;

      if (_totalItems == 0) {
        debugPrint('[MigrationService] No data to migrate');
        _isMigrating = false;
        return true;
      }

      _migrationStatus = 'Migrating conversations...';
      debugPrint('[MigrationService] Found $_totalItems conversations to migrate');

      // Migrate conversations in batches
      for (int i = 0; i < conversations.length; i++) {
        final convData = conversations[i];
        await _migrateConversation(convData);

        _migratedItems = i + 1;
        _migrationProgress = _migratedItems / _totalItems;

        // Log progress every 10 conversations
        if (_migratedItems % 10 == 0) {
          debugPrint('[MigrationService] Migrated $_migratedItems/$_totalItems conversations');
        }
      }

      _migrationStatus = 'Migration completed';
      _migrationProgress = 1.0;
      debugPrint('[MigrationService] Migration completed successfully');

      _isMigrating = false;
      return true;
    } catch (e) {
      _migrationStatus = 'Migration error (will retry later)';
      debugPrint('[MigrationService] Migration error (silent): $e');
      _isMigrating = false;
      return false;
    }
  }

  /// Migrate a single conversation and its messages
  Future<void> _migrateConversation(Map<String, dynamic> convData) async {
    try {
      final localId = convData['id'] as int;

      // Check if already migrated
      final existingUuid = _idMapping.getConversationUUID(localId);
      if (existingUuid != null) {
        debugPrint('[MigrationService] Conversation $localId already migrated');
        return;
      }

      // Create conversation object
      final conversation = Conversation.fromMap(convData);

      // Upload to Supabase
      final userId = _supabase.currentUser!.id;
      final data = {
        'user_id': userId,
        'title': conversation.title,
        'is_pinned': conversation.isPinned,
        'created_at': conversation.createdAt.toIso8601String(),
        'updated_at': conversation.updatedAt.toIso8601String(),
      };

      final response = await _supabase.client.from('conversations').insert(data).select().single();

      final uuid = response['id'] as String;

      // Store mapping
      await _idMapping.storeConversationMapping(localId, uuid);

      // Migrate messages for this conversation
      await _migrateConversationMessages(localId, uuid);
    } catch (e) {
      debugPrint('[MigrationService] Error migrating conversation (silent): $e');
      // Continue with next conversation
    }
  }

  /// Migrate messages for a conversation
  Future<void> _migrateConversationMessages(int localConversationId, String conversationUuid) async {
    try {
      final messages = await _database.getConversationMessages(localConversationId);

      debugPrint('[MigrationService] Migrating ${messages.length} messages for conversation $localConversationId');

      for (final msgData in messages) {
        final localId = msgData['id'] as int;

        // Check if already migrated
        final existingUuid = _idMapping.getMessageUUID(localId);
        if (existingUuid != null) {
          continue;
        }

        // Create message object
        final message = ChatMessage.fromMap(msgData);

        // Upload to Supabase
        final data = {
          'conversation_id': conversationUuid,
          'content': message.message,
          'is_ai': !message.isUserMessage, // Invert for Supabase
          'created_at': message.timestamp,
        };

        final response = await _supabase.client.from('messages').insert(data).select().single();

        final uuid = response['id'] as String;

        // Store mapping
        await _idMapping.storeMessageMapping(localId, uuid);
      }
    } catch (e) {
      debugPrint('[MigrationService] Error migrating messages (silent): $e');
      // Continue with next conversation
    }
  }

  /// Check if migration is needed
  Future<bool> needsMigration() async {
    if (!_supabase.isAuthenticated) return false;

    try {
      // Check if we have local conversations
      final conversations = await _database.getAllConversations();
      if (conversations.isEmpty) return false;

      // Check if any conversations are not mapped
      for (final conv in conversations) {
        final localId = conv['id'] as int;
        final uuid = _idMapping.getConversationUUID(localId);
        if (uuid == null) {
          return true; // Found unmigrated conversation
        }
      }

      return false; // All conversations migrated
    } catch (e) {
      debugPrint('[MigrationService] Error checking migration status: $e');
      return false;
    }
  }

  /// Get migration statistics
  Map<String, dynamic> getMigrationStats() {
    return {
      'is_migrating': _isMigrating,
      'progress': _migrationProgress,
      'status': _migrationStatus,
      'total_items': _totalItems,
      'migrated_items': _migratedItems,
    };
  }

  /// Reset migration state
  void resetMigration() {
    _isMigrating = false;
    _migrationProgress = 0.0;
    _migrationStatus = '';
    _totalItems = 0;
    _migratedItems = 0;
  }
}
