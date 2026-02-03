import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'database_service.dart';
import 'id_mapping_service.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

/// Service for syncing data between local SQLite and Supabase
/// All sync operations are silent and non-blocking
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseService _supabase = SupabaseService();
  final DatabaseService _database = DatabaseService();
  final IDMappingService _idMapping = IDMappingService();

  Timer? _backgroundSyncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  final List<Map<String, dynamic>> _syncQueue = [];
  RealtimeChannel? _messagesChannel;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  // Sync status
  String _syncStatus = 'idle'; // idle, syncing, error
  String? _lastError;

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncStatus => _syncStatus;
  String? get lastError => _lastError;
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// Initialize sync service
  Future<void> initialize() async {
    await _idMapping.initialize();

    if (_supabase.isAuthenticated) {
      // Clean up any duplicate mappings and conversations from previous sync issues
      await _cleanupDuplicates();

      // Start background sync timer (every 30 seconds)
      _startBackgroundSync();

      // Perform initial sync silently in background
      _performInitialSync();
    }
  }

  /// Clean up duplicate conversations caused by mapping issues (both local and cloud)
  Future<void> _cleanupDuplicates() async {
    try {
      debugPrint('[SyncService] Starting aggressive duplicate cleanup...');

      // STEP 1: Clean up local duplicates
      final allConversations = await _database.getConversations(profileId: 1);

      // Group by title and created_at (within 1 second)
      final groups = <String, List<Map<String, dynamic>>>{};
      for (final conv in allConversations) {
        final title = conv['title'] as String? ?? 'Untitled';
        final createdAt = DateTime.parse(conv['created_at'] as String);
        // Create a key based on title and created_at rounded to nearest second
        final key = '$title-${createdAt.millisecondsSinceEpoch ~/ 1000}';
        groups.putIfAbsent(key, () => []).add(conv);
      }

      // Find and clean up local duplicates
      int deletedCount = 0;
      for (final entry in groups.entries) {
        final conversations = entry.value;
        if (conversations.length > 1) {
          debugPrint('[SyncService] Found ${conversations.length} local duplicates for: ${entry.key}');

          // Sort by ID (keep the highest/most recent)
          conversations.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

          // Delete all but the last one
          for (int i = 0; i < conversations.length - 1; i++) {
            final convId = conversations[i]['id'] as int;
            await _database.deleteConversation(convId);
            deletedCount++;
            debugPrint('[SyncService] Deleted local duplicate conversation: id=$convId');
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint('[SyncService] Deleted $deletedCount local duplicate conversations');
      }

      // STEP 2: Clean up cloud duplicates
      if (_supabase.isAuthenticated) {
        await _cleanupCloudDuplicates();
      }

      // STEP 3: Clear all mappings and let sync rebuild them
      await _idMapping.clearAllMappings();
      debugPrint('[SyncService] Cleared all mappings - will be rebuilt on next sync');
    } catch (e) {
      debugPrint('[SyncService] Error during duplicate cleanup (silent): $e');
      // Don't throw - this is a best-effort cleanup
    }
  }

  /// Clean up duplicate conversations from Supabase
  Future<void> _cleanupCloudDuplicates() async {
    try {
      final userId = _supabase.currentUser!.id;

      // Fetch all conversations from Supabase
      final response = await _supabase.client.from('conversations').select().eq('user_id', userId).order('created_at', ascending: true);

      final conversations = response as List<dynamic>;

      // Group by title and created_at (within 1 second)
      final cloudGroups = <String, List<Map<String, dynamic>>>{};
      for (final conv in conversations) {
        final title = conv['title'] as String? ?? 'Untitled';
        final createdAt = DateTime.parse(conv['created_at'] as String);
        final key = '$title-${createdAt.millisecondsSinceEpoch ~/ 1000}';
        cloudGroups.putIfAbsent(key, () => []).add(conv);
      }

      // Find and delete cloud duplicates
      int cloudDeletedCount = 0;
      for (final entry in cloudGroups.entries) {
        final convs = entry.value;
        if (convs.length > 1) {
          debugPrint('[SyncService] Found ${convs.length} cloud duplicates for: ${entry.key}');

          // Sort by created_at (keep the oldest/first one)
          convs.sort((a, b) {
            final aTime = DateTime.parse(a['created_at'] as String);
            final bTime = DateTime.parse(b['created_at'] as String);
            return aTime.compareTo(bTime);
          });

          // Delete all but the first one
          for (int i = 1; i < convs.length; i++) {
            final uuid = convs[i]['id'] as String;
            await _supabase.client.from('conversations').delete().eq('id', uuid);
            cloudDeletedCount++;
            debugPrint('[SyncService] Deleted cloud duplicate conversation: uuid=$uuid');
          }
        }
      }

      if (cloudDeletedCount > 0) {
        debugPrint('[SyncService] Deleted $cloudDeletedCount cloud duplicate conversations');
      } else {
        debugPrint('[SyncService] No cloud duplicates found');
      }
    } catch (e) {
      debugPrint('[SyncService] Error cleaning cloud duplicates (silent): $e');
    }
  }

  /// Start background sync timer
  void _startBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_supabase.isAuthenticated && !_isSyncing) {
        _syncAll();
      }
    });
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
    _stopRealtimeListener();
  }

  /// Watch a conversation for real-time updates
  Future<void> watchConversation(String conversationUuid) async {
    if (!_supabase.isAuthenticated) return;

    // Stop previous listener if any
    await _stopRealtimeListener();

    try {
      // Subscribe to messages for this conversation
      _messagesChannel = _supabase.client
          .channel('messages:$conversationUuid')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationUuid,
            ),
            callback: (payload) {
              _handleNewMessage(payload.newRecord);
            },
          )
          .subscribe();

      debugPrint('[SyncService] Watching conversation: $conversationUuid');
    } catch (e) {
      debugPrint('[SyncService] Error setting up real-time listener (silent): $e');
    }
  }

  /// Handle new message from real-time subscription
  Future<void> _handleNewMessage(Map<String, dynamic> messageData) async {
    try {
      final uuid = messageData['id'] as String;
      final content = messageData['content'] as String;
      final isAi = messageData['is_ai'] as bool? ?? false;
      final createdAt = messageData['created_at'] as String;
      final conversationUuid = messageData['conversation_id'] as String;

      // Check if we already have this message
      final existingLocalId = _idMapping.getMessageLocalId(uuid);
      if (existingLocalId != null) {
        debugPrint('[SyncService] Message already exists locally: $uuid');
        return;
      }

      // Get local conversation ID
      final localConversationId = _idMapping.getConversationLocalId(conversationUuid);
      if (localConversationId == null) {
        debugPrint('[SyncService] No local conversation found for UUID: $conversationUuid');
        return;
      }

      // Create local message
      final message = ChatMessage(
        message: content,
        isUserMessage: !isAi, // Invert for local storage
        timestamp: createdAt,
        conversationId: localConversationId,
        profileId: 1, // Default profile
      );

      final localId = await _database.insertChatMessage(message);
      await _idMapping.storeMessageMapping(localId, uuid);

      debugPrint('[SyncService] New message synced from real-time: $uuid');
    } catch (e) {
      debugPrint('[SyncService] Error handling real-time message (silent): $e');
    }
  }

  /// Stop real-time listener
  Future<void> _stopRealtimeListener() async {
    if (_messagesChannel != null) {
      await _supabase.client.removeChannel(_messagesChannel!);
      _messagesChannel = null;
      debugPrint('[SyncService] Stopped real-time listener');
    }
  }

  /// Perform initial sync (silent, non-blocking)
  Future<void> _performInitialSync() async {
    try {
      debugPrint('[SyncService] Starting initial sync in background');
      await _syncAll();
    } catch (e) {
      debugPrint('[SyncService] Initial sync error (silent): $e');
      // Don't show error to user - will retry automatically
    }
  }

  /// Sync all data (conversations, messages, etc.) with retry logic
  Future<void> _syncAll() async {
    if (!_supabase.isAuthenticated || _isSyncing) return;

    try {
      _isSyncing = true;
      _syncStatus = 'syncing';

      // Process any queued operations first
      await _processSyncQueue();

      // Sync conversations
      await _syncConversations();

      _lastSyncTime = DateTime.now();
      _syncStatus = 'idle';
      _lastError = null;
      _retryCount = 0; // Reset retry count on success

      debugPrint('[SyncService] Sync completed successfully');
    } catch (e) {
      _syncStatus = 'error';
      _lastError = _getUserFriendlyError(e);
      debugPrint('[SyncService] Sync error (silent): $_lastError');

      // Retry logic with exponential backoff
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final delay = _retryDelay * _retryCount;
        debugPrint('[SyncService] Scheduling retry $_retryCount/$_maxRetries in ${delay.inSeconds}s');

        Future.delayed(delay, () {
          if (_supabase.isAuthenticated && !_isSyncing) {
            _syncAll();
          }
        });
      } else {
        debugPrint('[SyncService] Max retries reached, will try again on next sync cycle');
        _retryCount = 0; // Reset for next cycle
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network connection issue. Will retry automatically.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Will retry automatically.';
    } else if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
      return 'Authentication expired. Please sign in again.';
    } else if (errorStr.contains('forbidden') || errorStr.contains('403')) {
      return 'Access denied. Please check your permissions.';
    } else if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Resource not found. Will retry automatically.';
    } else if (errorStr.contains('server') || errorStr.contains('500')) {
      return 'Server error. Will retry automatically.';
    } else {
      return 'Sync error. Will retry automatically.';
    }
  }

  /// Sync conversations from Supabase to local (with conflict resolution)
  Future<void> _syncConversations() async {
    if (!_supabase.isAuthenticated) return;

    try {
      final userId = _supabase.currentUser!.id;

      // Fetch conversations from Supabase
      final response = await _supabase.client.from('conversations').select().eq('user_id', userId).order('updated_at', ascending: false).limit(50); // Sync most recent 50 conversations

      final conversations = response as List<dynamic>;

      for (final convData in conversations) {
        final uuid = convData['id'] as String;
        final title = convData['title'] as String?;
        final isPinned = convData['is_pinned'] as bool? ?? false;
        final createdAt = DateTime.parse(convData['created_at'] as String);
        final updatedAt = DateTime.parse(convData['updated_at'] as String);

        // Check if we have a local mapping
        int? localId = _idMapping.getConversationLocalId(uuid);

        if (localId == null) {
          // No mapping exists - check if conversation already exists by title/timestamp to prevent duplicates
          final existingConversations = await _database.getConversations(profileId: 1);
          final possibleDuplicate = existingConversations.where((conv) {
            final convCreatedAt = DateTime.parse(conv['created_at'] as String);
            final convTitle = conv['title'] as String?;
            // Match by title and created_at timestamp (within 1 second tolerance)
            return convTitle == title && convCreatedAt.difference(createdAt).abs().inSeconds <= 1;
          }).firstOrNull;

          if (possibleDuplicate != null) {
            // Found existing conversation without mapping - just create the mapping
            localId = possibleDuplicate['id'] as int;
            await _idMapping.storeConversationMapping(localId, uuid);
            debugPrint('[SyncService] Found existing conversation without mapping, created mapping: localId=$localId, uuid=$uuid');

            // Sync messages for this conversation
            await _syncConversationMessages(uuid, localId);
          } else {
            // No duplicate found - create new local conversation
            final conv = Conversation(
              title: title ?? 'Conversation',
              isPinned: isPinned,
              createdAt: createdAt,
              updatedAt: updatedAt,
              profileId: 1, // Default profile
            );

            localId = await _database.insertConversation(conv.toMap());
            await _idMapping.storeConversationMapping(localId, uuid);
            debugPrint('[SyncService] Created new conversation: localId=$localId, uuid=$uuid');

            // Sync messages for this conversation
            await _syncConversationMessages(uuid, localId);
          }
        } else {
          // Mapping exists - verify the conversation still exists locally
          final localConv = await _database.getConversation(localId);

          if (localConv == null) {
            // Mapping exists but conversation was deleted locally
            // Recreate the conversation from cloud
            debugPrint('[SyncService] Conversation mapping exists but local data deleted, recreating from cloud');
            final conv = Conversation(
              title: title ?? 'Conversation',
              isPinned: isPinned,
              createdAt: createdAt,
              updatedAt: updatedAt,
              profileId: 1, // Default profile
            );

            localId = await _database.insertConversation(conv.toMap());
            await _idMapping.storeConversationMapping(localId, uuid);

            // Sync messages for this conversation
            await _syncConversationMessages(uuid, localId);
          } else {
            // Conversation exists - update with last-write-wins strategy
            final localUpdatedAt = DateTime.parse(localConv['updated_at'] as String);

            // Last-write-wins: Compare timestamps
            if (updatedAt.isAfter(localUpdatedAt)) {
              // Remote is newer, update local
              debugPrint('[SyncService] Resolving conflict: Remote wins (remote: $updatedAt, local: $localUpdatedAt)');
              await _database.updateConversation({
                'id': localId,
                'title': title,
                'is_pinned': isPinned ? 1 : 0,
                'updated_at': updatedAt.toIso8601String(),
              });
            } else if (localUpdatedAt.isAfter(updatedAt)) {
              // Local is newer, push to remote
              debugPrint('[SyncService] Resolving conflict: Local wins (local: $localUpdatedAt, remote: $updatedAt)');
              await _pushConversationToRemote(localId, uuid, localConv);
            }
            // If timestamps are equal, no action needed

            // IMPORTANT: Always sync messages for existing conversations
            // This ensures new messages from web are synced to mobile
            await _syncConversationMessages(uuid, localId);
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncService] Error syncing conversations (silent): $e');
      _lastError = e.toString();
    }
  }

  /// Push local conversation changes to remote
  Future<void> _pushConversationToRemote(int localId, String uuid, Map<String, dynamic> localConv) async {
    try {
      await _supabase.client.from('conversations').update({
        'title': localConv['title'],
        'is_pinned': localConv['is_pinned'] == 1,
        'updated_at': localConv['updated_at'],
      }).eq('id', uuid);
    } catch (e) {
      debugPrint('[SyncService] Error pushing conversation to remote (silent): $e');
    }
  }

  /// Sync messages for a specific conversation
  Future<void> _syncConversationMessages(String conversationUuid, int localConversationId) async {
    if (!_supabase.isAuthenticated) return;

    try {
      final response = await _supabase.client.from('messages').select().eq('conversation_id', conversationUuid).order('created_at', ascending: true).limit(100); // Sync last 100 messages

      final messages = response as List<dynamic>;

      for (final msgData in messages) {
        final uuid = msgData['id'] as String;
        final content = msgData['content'] as String;
        final isAi = msgData['is_ai'] as bool? ?? false;
        final createdAt = DateTime.parse(msgData['created_at'] as String);

        // Check if we have a local mapping
        int? localId = _idMapping.getMessageLocalId(uuid);

        if (localId == null) {
          // Create new local message
          final message = ChatMessage(
            message: content,
            isUserMessage: !isAi, // Invert for local storage
            timestamp: createdAt.toIso8601String(),
            conversationId: localConversationId,
            profileId: 1, // Default profile
          );

          localId = await _database.insertChatMessage(message);
          await _idMapping.storeMessageMapping(localId, uuid);
        }
      }
    } catch (e) {
      debugPrint('[SyncService] Error syncing messages (silent): $e');
    }
  }

  /// Upload a conversation to Supabase
  Future<String?> uploadConversation(Conversation conversation) async {
    if (!_supabase.isAuthenticated) {
      // Queue for later sync
      _queueOperation('conversation', 'create', conversation.toMap());
      return null;
    }

    try {
      final userId = _supabase.currentUser!.id;

      // VALIDATION: Check if a conversation with same title and created_at already exists in cloud
      final existingResponse = await _supabase.client.from('conversations').select().eq('user_id', userId).eq('title', conversation.title).limit(10);

      final existing = existingResponse as List<dynamic>;

      // Check if any existing conversation has the same created_at (within 1 second)
      for (final conv in existing) {
        final existingCreatedAt = DateTime.parse(conv['created_at'] as String);
        final diff = existingCreatedAt.difference(conversation.createdAt).abs();

        if (diff.inSeconds <= 1) {
          // Found duplicate - don't upload, just create mapping
          final uuid = conv['id'] as String;
          debugPrint('[SyncService] Prevented duplicate upload - conversation already exists in cloud: uuid=$uuid');

          if (conversation.id != null) {
            await _idMapping.storeConversationMapping(conversation.id!, uuid);
          }

          return uuid;
        }
      }

      // No duplicate found - proceed with upload
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
      if (conversation.id != null) {
        await _idMapping.storeConversationMapping(conversation.id!, uuid);
      }

      debugPrint('[SyncService] Uploaded new conversation to cloud: uuid=$uuid');
      return uuid;
    } catch (e) {
      debugPrint('[SyncService] Error uploading conversation (silent): $e');
      _queueOperation('conversation', 'create', conversation.toMap());
      return null;
    }
  }

  /// Upload a message to Supabase
  Future<String?> uploadMessage(ChatMessage message) async {
    if (!_supabase.isAuthenticated) {
      // Queue for later sync
      _queueOperation('message', 'create', message.toMap());
      return null;
    }

    try {
      // Get conversation UUID
      final conversationUuid = message.conversationId != null ? _idMapping.getConversationUUID(message.conversationId!) : null;

      if (conversationUuid == null) {
        debugPrint('[SyncService] No conversation UUID found for message');
        _queueOperation('message', 'create', message.toMap());
        return null;
      }

      final data = {
        'conversation_id': conversationUuid,
        'content': message.message,
        'is_ai': !message.isUserMessage, // Invert for Supabase
        'created_at': message.timestamp,
      };

      final response = await _supabase.client.from('messages').insert(data).select().single();

      final uuid = response['id'] as String;

      // Store mapping
      if (message.id != null) {
        await _idMapping.storeMessageMapping(message.id!, uuid);
      }

      return uuid;
    } catch (e) {
      debugPrint('[SyncService] Error uploading message (silent): $e');
      _queueOperation('message', 'create', message.toMap());
      return null;
    }
  }

  /// Queue an operation for later sync
  void _queueOperation(String type, String operation, Map<String, dynamic> data) {
    _syncQueue.add({
      'type': type,
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    debugPrint('[SyncService] Queued $operation $type operation (${_syncQueue.length} in queue)');
  }

  /// Process queued sync operations
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || !_supabase.isAuthenticated) return;

    debugPrint('[SyncService] Processing ${_syncQueue.length} queued operations');

    final toProcess = List.from(_syncQueue);
    _syncQueue.clear();

    for (final operation in toProcess) {
      try {
        final type = operation['type'] as String;
        final op = operation['operation'] as String;
        final data = operation['data'] as Map<String, dynamic>;

        if (type == 'conversation' && op == 'create') {
          final conv = Conversation.fromMap(data);
          await uploadConversation(conv);
        } else if (type == 'message' && op == 'create') {
          final msg = ChatMessage.fromMap(data);
          await uploadMessage(msg);
        }
      } catch (e) {
        debugPrint('[SyncService] Error processing queued operation (silent): $e');
        // Re-queue failed operation
        _syncQueue.add(operation);
      }
    }
  }

  /// Manual sync trigger (for user-initiated sync)
  Future<bool> syncNow() async {
    if (!_supabase.isAuthenticated) {
      debugPrint('[SyncService] Cannot sync: not authenticated');
      return false;
    }

    try {
      await _syncAll();
      return true;
    } catch (e) {
      debugPrint('[SyncService] Manual sync error: $e');
      return false;
    }
  }

  /// Clear all sync data (for logout)
  Future<void> clearSyncData() async {
    stopBackgroundSync();
    await _stopRealtimeListener();
    _syncQueue.clear();
    await _idMapping.clearAllMappings();
    _lastSyncTime = null;
    _syncStatus = 'idle';
    _lastError = null;
    debugPrint('[SyncService] Sync data cleared');
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'is_syncing': _isSyncing,
      'last_sync': _lastSyncTime?.toIso8601String(),
      'status': _syncStatus,
      'queued_operations': _syncQueue.length,
      'id_mappings': _idMapping.getStats(),
    };
  }
}
