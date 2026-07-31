import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/runtime/guarded_tasks.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'database_service.dart';
import 'id_mapping_service.dart';
import 'supabase_service.dart';

/// Synchronizes the active account's SQLite file with Supabase.
///
/// Local writes are committed with a durable SQLite outbox. Stable client IDs
/// make retries idempotent; no title/timestamp heuristics or destructive
/// duplicate cleanup are used.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const int _pageSize = 200;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  final SupabaseService _supabase = SupabaseService();
  final DatabaseService _database = DatabaseService();
  final IDMappingService _idMapping = IDMappingService();

  Timer? _backgroundSyncTimer;
  Timer? _retryTimer;
  RealtimeChannel? _messagesChannel;
  Future<void>? _syncTask;
  Future<void>? _outboxTask;
  String? _activeAccountId;
  bool _isSyncing = false;
  int _retryCount = 0;
  DateTime? _lastSyncTime;
  String _syncStatus = 'idle';
  String? _lastError;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncStatus => _syncStatus;
  String? get lastError => _lastError;
  bool get isAuthenticated => _supabase.isAuthenticated;

  Future<void> initialize() async {
    final user = _supabase.currentUser;
    if (user == null || user.isAnonymous) {
      stopBackgroundSync();
      _idMapping.deactivate();
      return;
    }

    await _database.activateAccount(user.id);
    await _idMapping.initialize(user.id);
    _activeAccountId = user.id;
    _startBackgroundSync();
    _scheduleBackgroundSync('Initial');
  }

  void _startBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_supabase.isAuthenticated && !_isSyncing) {
        _scheduleBackgroundSync('Periodic');
      }
    });
  }

  void stopBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _scheduleContainedOperation(
      'Realtime listener cleanup failed',
      _stopRealtimeListener,
    );
  }

  void _scheduleBackgroundSync(String source) {
    _scheduleContainedOperation('$source sync will retry', _syncAll);
  }

  void _scheduleContainedOperation(
    String failureMessage,
    Future<void> Function() operation,
  ) {
    unawaited(
      runContainedTask(
        operation,
        onError: (error, _) {
          debugPrint('[SyncService] $failureMessage: $error');
        },
      ),
    );
  }

  void schedulePendingOperations() {
    _scheduleContainedOperation(
      'Outbox processing will retry',
      processPendingOperations,
    );
  }

  Future<void> _syncAll() {
    final activeTask = _syncTask;
    if (activeTask != null) return activeTask;
    if (!_hasActiveUserContext) return Future<void>.value();

    late final Future<void> task;
    task = _runSyncAll().whenComplete(() {
      if (identical(_syncTask, task)) {
        _syncTask = null;
      }
    });
    _syncTask = task;
    return task;
  }

  Future<void> _runSyncAll() async {
    _isSyncing = true;
    _syncStatus = 'syncing';
    try {
      await processPendingOperations();
      if (!_hasActiveUserContext) return;
      await _downloadRemoteConversations();
      if (!_hasActiveUserContext) return;
      await _uploadLegacyLocalData();
      if (!_hasActiveUserContext) return;
      _lastSyncTime = DateTime.now();
      _syncStatus = 'idle';
      _lastError = null;
      _retryCount = 0;
    } catch (error) {
      _syncStatus = 'error';
      _lastError = _getUserFriendlyError(error);
      _scheduleRetry();
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      _retryCount = 0;
      return;
    }
    _retryCount++;
    final delay = _retryDelay * _retryCount;
    final accountId = _activeAccountId;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (accountId != null &&
          accountId == _activeAccountId &&
          _hasActiveUserContext) {
        _scheduleBackgroundSync('Retry');
      }
    });
  }

  bool get _hasActiveUserContext {
    final user = _supabase.currentUser;
    final accountId = _activeAccountId;
    return accountId != null &&
        user != null &&
        !user.isAnonymous &&
        user.id == accountId &&
        _database.activeAccountId == accountId;
  }

  String _requireActiveUserId() {
    if (!_hasActiveUserContext) {
      throw StateError('Sync account changed');
    }
    return _activeAccountId!;
  }

  String _getUserFriendlyError(Object error) {
    final value = error.toString().toLowerCase();
    if (value.contains('timeout')) {
      return 'Request timed out. Will retry automatically.';
    }
    if (value.contains('network') || value.contains('connection')) {
      return 'Network connection issue. Will retry automatically.';
    }
    if (value.contains('401') || value.contains('unauthorized')) {
      return 'Authentication expired. Please sign in again.';
    }
    return 'Sync error. Will retry automatically.';
  }

  /// Drains durable operations. A failed row stays on disk with backoff.
  Future<void> processPendingOperations() {
    final activeTask = _outboxTask;
    if (activeTask != null) return activeTask;
    if (!_hasActiveUserContext) return Future<void>.value();

    late final Future<void> task;
    task = _runPendingOperations().whenComplete(() {
      if (identical(_outboxTask, task)) {
        _outboxTask = null;
      }
    });
    _outboxTask = task;
    return task;
  }

  Future<void> _runPendingOperations() async {
    while (_hasActiveUserContext) {
      final operations =
          await _database.getPendingSyncOperations(limit: _pageSize);
      if (operations.isEmpty) break;

      for (final operation in operations) {
        if (!_hasActiveUserContext) return;
        final outboxId = operation['id']! as int;
        final localId = operation['local_id']! as int;
        final attempts = operation['attempts']! as int;
        try {
          switch (operation['entity_type']) {
            case 'conversation':
              final data = await _database.getConversation(localId);
              if (data != null) {
                await _uploadConversation(
                  Conversation.fromMap(data),
                  throwOnFailure: true,
                );
              }
              break;
            case 'message':
              final message = await _database.getChatMessage(localId);
              if (message != null) {
                await _uploadMessage(message, throwOnFailure: true);
              }
              break;
            default:
              break;
          }
          if (!_hasActiveUserContext) return;
          await _database.completeSyncOperation(outboxId);
        } catch (error) {
          if (!_hasActiveUserContext) return;
          await _database.failSyncOperation(
            outboxId,
            attempts: attempts,
            error: error,
          );
        }
      }

      if (operations.length < _pageSize) break;
    }
  }

  Future<void> _uploadLegacyLocalData() async {
    _requireActiveUserId();
    final conversations = await _database.getAllConversations();
    for (final data in conversations) {
      if (!_hasActiveUserContext) return;
      final conversation = Conversation.fromMap(data);
      final conversationUuid = conversation.id == null
          ? null
          : _idMapping.getConversationUUID(conversation.id!) ??
              await _uploadConversation(
                conversation,
                throwOnFailure: true,
              );
      if (conversationUuid == null || conversation.id == null) continue;

      final messages =
          await _database.getConversationMessages(conversation.id!);
      for (final data in messages) {
        if (!_hasActiveUserContext) return;
        final message = ChatMessage.fromMap(data);
        if (message.id != null &&
            _idMapping.getMessageUUID(message.id!) == null) {
          await _uploadMessage(message, throwOnFailure: true);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllRows(
    Future<List<Map<String, dynamic>>> Function(int from, int to) fetchPage,
  ) async {
    final rows = <Map<String, dynamic>>[];
    var offset = 0;
    while (true) {
      final page = await fetchPage(offset, offset + _pageSize - 1);
      rows.addAll(page);
      if (page.length < _pageSize) break;
      offset += _pageSize;
    }
    return rows;
  }

  Future<void> _downloadRemoteConversations() async {
    final userId = _requireActiveUserId();
    final conversations = await _fetchAllRows(
      (from, to) async => List<Map<String, dynamic>>.from(
        await _supabase.client
            .from('conversations')
            .select()
            .eq('user_id', userId)
            .order('updated_at', ascending: false)
            .order('id', ascending: true)
            .range(from, to),
      ),
    );
    final remoteClientOwners = <String, String>{
      for (final row in conversations)
        if (row['client_id'] case final String clientId
            when clientId.isNotEmpty)
          clientId: row['id']! as String,
    };

    for (final remote in conversations) {
      if (!_hasActiveUserContext) return;
      await _mergeRemoteConversation(
        remote,
        remoteClientOwners: remoteClientOwners,
      );
    }

    if (!_hasActiveUserContext) return;
    await _removeConversationsDeletedRemotely(
      conversations.map((row) => row['id']! as String).toSet(),
    );
  }

  Future<void> _removeConversationsDeletedRemotely(
    Set<String> remoteConversationIds,
  ) async {
    final localConversations = await _database.getAllConversations();
    for (final local in localConversations) {
      if (!_hasActiveUserContext) return;
      final localId = local['id']! as int;
      final remoteId = _idMapping.getConversationUUID(localId);
      // No mapping means this is a local/offline conversation that still
      // needs to upload. Only reconcile rows known to have existed remotely.
      if (remoteId == null || remoteConversationIds.contains(remoteId)) {
        continue;
      }

      final messages = await _database.getConversationMessages(localId);
      await _database.deleteConversation(localId);
      await _idMapping.removeConversationMapping(localId);
      await _idMapping.removeMessageMappings(
        messages.map((message) => message['id']).whereType<int>(),
      );
    }
  }

  Future<int> _mergeRemoteConversation(
    Map<String, dynamic> remote, {
    Map<String, String>? remoteClientOwners,
  }) async {
    final uuid = remote['id']! as String;
    final userId = _requireActiveUserId();
    final clientId = remote['client_id'] as String?;
    final profileId = await _database.resolveProfileId(
      clientId: remote['profile_client_id'] as String?,
      name: remote['profile_name'] as String?,
    );

    Map<String, dynamic>? local;
    if (clientId != null && clientId.isNotEmpty) {
      local = await _database.getConversationByClientId(clientId);
    }
    final mappedId = _idMapping.getConversationLocalId(uuid);
    local ??=
        mappedId == null ? null : await _database.getConversation(mappedId);
    if (clientId == null && local != null) {
      final localId = local['id']! as int;
      final localClientId = local['client_id'] as String?;
      if (localClientId != null && localClientId.isNotEmpty) {
        final ownerUuid = remoteClientOwners == null
            ? await _findRemoteConversationOwner(userId, localClientId)
            : remoteClientOwners[localClientId];
        if (ownerUuid != null && ownerUuid != uuid) {
          // A legacy reverse mapping can point at a local conversation whose
          // stable client ID already belongs to another cloud row. Preserve
          // both rows: reserve this local row for its canonical owner and let
          // the legacy row receive a fresh local identity below.
          await _idMapping.storeConversationMapping(localId, ownerUuid);
          local = null;
        }
      }
    }

    final createdAt = DateTime.parse(remote['created_at'] as String);
    final updatedAt = DateTime.parse(remote['updated_at'] as String);
    final archivedAt = remote['archived_at'] == null
        ? null
        : DateTime.parse(remote['archived_at'] as String);
    late int localId;

    if (local == null) {
      localId = await _database.insertConversation(
        Conversation(
          clientId: clientId,
          title: remote['title'] as String? ?? 'Conversation',
          isPinned: remote['is_pinned'] as bool? ?? false,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          profileId: profileId,
        ).toMap(),
        enqueueSync: false,
      );
    } else {
      localId = local['id']! as int;
      final localUpdatedAt = DateTime.parse(local['updated_at'] as String);
      if (!localUpdatedAt.isAfter(updatedAt)) {
        await _database.updateConversation(
          {
            'id': localId,
            'client_id': clientId ?? local['client_id'],
            'title': remote['title'] as String? ?? 'Conversation',
            'is_pinned': (remote['is_pinned'] as bool? ?? false) ? 1 : 0,
            'created_at': createdAt.toIso8601String(),
            'updated_at': updatedAt.toIso8601String(),
            'archived_at': archivedAt?.toIso8601String(),
            'profile_id': profileId,
          },
          enqueueSync: false,
        );
      } else {
        await _pushConversationToRemote(localId, uuid, local);
      }
    }

    await _idMapping.storeConversationMapping(localId, uuid);
    if (clientId == null) {
      final assignedClientId =
          await _database.ensureConversationClientId(localId);
      await _supabase.client
          .from('conversations')
          .update({'client_id': assignedClientId})
          .eq('id', uuid)
          .eq('user_id', userId);
    }
    await _downloadConversationMessages(uuid, localId, profileId);
    return localId;
  }

  Future<void> _downloadConversationMessages(
    String conversationUuid,
    int localConversationId,
    int profileId,
  ) async {
    final messages = await _fetchAllRows(
      (from, to) async => List<Map<String, dynamic>>.from(
        await _supabase.client
            .from('messages')
            .select()
            .eq('conversation_id', conversationUuid)
            .order('created_at', ascending: true)
            .order('id', ascending: true)
            .range(from, to),
      ),
    );

    for (final remote in messages) {
      if (!_hasActiveUserContext) return;
      final uuid = remote['id']! as String;
      final clientId = remote['client_id'] as String?;
      ChatMessage? existing;
      if (clientId != null && clientId.isNotEmpty) {
        existing = await _database.getChatMessageByClientId(clientId);
      }
      final mappedId = _idMapping.getMessageLocalId(uuid);
      existing ??=
          mappedId == null ? null : await _database.getChatMessage(mappedId);
      if (existing != null) {
        await _idMapping.storeMessageMapping(existing.id!, uuid);
        continue;
      }

      final message = ChatMessage.fromSupabase(
        remote,
        localConversationId,
        profileId: profileId,
      );
      final localId = await _database.insertChatMessage(
        message,
        enqueueSync: false,
      );
      await _idMapping.storeMessageMapping(localId, uuid);
    }
  }

  Future<int?> syncConversationByUuid(String conversationUuid) async {
    if (!_supabase.isAuthenticated || conversationUuid.trim().isEmpty) {
      return null;
    }
    try {
      final response = await _supabase.client
          .from('conversations')
          .select()
          .eq('id', conversationUuid)
          .eq('user_id', _requireActiveUserId())
          .maybeSingle();
      if (response == null) return null;
      return _mergeRemoteConversation(response);
    } catch (error) {
      debugPrint('[SyncService] Conversation pull failed: $error');
      return null;
    }
  }

  Future<String?> uploadConversation(Conversation conversation) {
    return _uploadConversation(conversation);
  }

  Future<String?> _uploadConversation(
    Conversation conversation, {
    bool throwOnFailure = false,
  }) async {
    if (conversation.id == null || !_hasActiveUserContext) return null;
    try {
      final userId = _requireActiveUserId();
      final clientId = conversation.clientId ??
          await _database.ensureConversationClientId(conversation.id!);
      final profileId =
          conversation.profileId ?? (await _database.getProfiles()).first.id!;
      final profile = await _database.getProfile(profileId);
      final profileClientId = await _database.ensureProfileClientId(profileId);
      final data = {
        'user_id': userId,
        'client_id': clientId,
        'profile_client_id': profileClientId,
        'profile_name': profile?.name,
        'title': conversation.title,
        'is_pinned': conversation.isPinned,
        'archived_at': conversation.archivedAt?.toIso8601String(),
        'created_at': conversation.createdAt.toIso8601String(),
        'updated_at': conversation.updatedAt.toIso8601String(),
      };

      final mappedUuid = _idMapping.getConversationUUID(conversation.id!);
      late Map<String, dynamic> response;
      if (mappedUuid != null) {
        final ownerUuid = await _findRemoteConversationOwner(userId, clientId);
        final targetUuid = ownerUuid ?? mappedUuid;
        if (targetUuid != mappedUuid) {
          await _idMapping.storeConversationMapping(
            conversation.id!,
            targetUuid,
          );
        }
        response = await _supabase.client
            .from('conversations')
            .update(data)
            .eq('id', targetUuid)
            .eq('user_id', userId)
            .select()
            .single();
      } else {
        response = await _supabase.client
            .from('conversations')
            .upsert(data, onConflict: 'user_id,client_id')
            .select()
            .single();
      }

      final uuid = response['id']! as String;
      await _idMapping.storeConversationMapping(conversation.id!, uuid);
      return uuid;
    } catch (error) {
      debugPrint('[SyncService] Conversation upload failed: $error');
      if (throwOnFailure) rethrow;
      return null;
    }
  }

  Future<String?> _findRemoteConversationOwner(
    String userId,
    String clientId,
  ) async {
    final response = await _supabase.client
        .from('conversations')
        .select('id')
        .eq('user_id', userId)
        .eq('client_id', clientId)
        .maybeSingle();
    return response?['id'] as String?;
  }

  Future<void> updateConversation(Conversation conversation) async {
    await _uploadConversation(conversation);
  }

  Future<void> _pushConversationToRemote(
    int localId,
    String uuid,
    Map<String, dynamic> local,
  ) async {
    final conversation = Conversation.fromMap(local);
    final userId = _requireActiveUserId();
    final clientId = conversation.clientId ??
        await _database.ensureConversationClientId(localId);
    await _supabase.client
        .from('conversations')
        .update({
          'client_id': clientId,
          'title': conversation.title,
          'is_pinned': conversation.isPinned,
          'archived_at': conversation.archivedAt?.toIso8601String(),
          'updated_at': conversation.updatedAt.toIso8601String(),
        })
        .eq('id', uuid)
        .eq('user_id', userId);
  }

  Future<bool> deleteConversation(Conversation conversation) async {
    if (conversation.id == null || !_hasActiveUserContext) return true;
    final uuid = _idMapping.getConversationUUID(conversation.id!);
    if (uuid == null) return true;

    try {
      final messages =
          await _database.getConversationMessages(conversation.id!);
      await _supabase.client
          .from('conversations')
          .delete()
          .eq('id', uuid)
          .eq('user_id', _requireActiveUserId());
      await _idMapping.removeConversationMapping(conversation.id!);
      await _idMapping.removeMessageMappings(
        messages.map((message) => message['id']).whereType<int>(),
      );
      return true;
    } catch (error) {
      debugPrint('[SyncService] Conversation delete failed: $error');
      return false;
    }
  }

  Future<String?> uploadMessage(ChatMessage message) {
    return _uploadMessage(message);
  }

  Future<String?> _uploadMessage(
    ChatMessage message, {
    bool throwOnFailure = false,
  }) async {
    if (message.id == null || !_hasActiveUserContext) return null;
    try {
      final existingUuid = _idMapping.getMessageUUID(message.id!);
      if (existingUuid != null) return existingUuid;

      if (message.conversationId == null) {
        throw StateError('Message has no conversation');
      }
      var conversationUuid =
          _idMapping.getConversationUUID(message.conversationId!);
      if (conversationUuid == null) {
        final conversationData =
            await _database.getConversation(message.conversationId!);
        if (conversationData == null) {
          throw StateError('Message conversation no longer exists');
        }
        conversationUuid = await _uploadConversation(
          Conversation.fromMap(conversationData),
          throwOnFailure: true,
        );
      }
      if (conversationUuid == null) {
        throw StateError('Conversation could not be synchronized');
      }

      final clientId = message.clientId ??
          await _database.ensureMessageClientId(message.id!);
      final persisted = message.copyWith(clientId: clientId);
      final data = persisted.toSupabase(conversationUuid);
      final response = await _supabase.client
          .from('messages')
          .upsert(data, onConflict: 'conversation_id,client_id')
          .select()
          .single();
      final uuid = response['id']! as String;
      await _idMapping.storeMessageMapping(message.id!, uuid);
      return uuid;
    } catch (error) {
      debugPrint('[SyncService] Message upload failed: $error');
      if (throwOnFailure) rethrow;
      return null;
    }
  }

  Future<void> watchConversation(String conversationUuid) async {
    if (!_hasActiveUserContext) return;
    await _stopRealtimeListener();

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
            _scheduleContainedOperation(
              'Realtime message sync will retry',
              () => _handleNewMessage(payload.newRecord),
            );
          },
        )
        .subscribe();
  }

  Future<void> _handleNewMessage(Map<String, dynamic> remote) async {
    if (!_hasActiveUserContext) return;
    final conversationUuid = remote['conversation_id'] as String?;
    if (conversationUuid == null) return;
    var localConversationId =
        _idMapping.getConversationLocalId(conversationUuid);
    localConversationId ??= await syncConversationByUuid(conversationUuid);
    if (localConversationId == null) return;

    final conversation = await _database.getConversation(localConversationId);
    if (conversation == null) return;
    await _downloadConversationMessages(
      conversationUuid,
      localConversationId,
      conversation['profile_id'] as int,
    );
  }

  Future<void> _stopRealtimeListener() async {
    final channel = _messagesChannel;
    _messagesChannel = null;
    if (channel != null) {
      await _supabase.client.removeChannel(channel);
    }
  }

  Future<bool> syncNow() async {
    if (!_hasActiveUserContext) return false;
    try {
      await _syncAll();
      return _syncStatus == 'idle';
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSyncData() async {
    _activeAccountId = null;
    stopBackgroundSync();
    await _stopRealtimeListener();
    final activeTasks = <Future<void>>[
      if (_syncTask != null) _syncTask!,
      if (_outboxTask != null) _outboxTask!,
    ];
    if (activeTasks.isNotEmpty) {
      await Future.wait(
        activeTasks.map((task) => task.catchError((Object _) {})),
      );
    }
    _idMapping.deactivate();
    _retryCount = 0;
    _lastSyncTime = null;
    _syncStatus = 'idle';
    _lastError = null;
  }

  Future<Map<String, dynamic>> getSyncStats() async {
    return {
      'is_syncing': _isSyncing,
      'last_sync': _lastSyncTime?.toIso8601String(),
      'status': _syncStatus,
      'queued_operations': await _database.getPendingSyncOperationCount(),
      'id_mappings': _idMapping.getStats(),
    };
  }
}
