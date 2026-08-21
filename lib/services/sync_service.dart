import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/runtime/guarded_tasks.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'chat_attachment_service.dart';
import 'database_service.dart';
import 'id_mapping_service.dart';
import 'message_sync_reconciliation.dart';
import 'supabase_service.dart';
import 'sync_pagination.dart';
import 'sync_reconciliation_policy.dart';

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
  static const int _identityClaimBatchSize = 200;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  final SupabaseService _supabase = SupabaseService();
  final DatabaseService _database = DatabaseService();
  final IDMappingService _idMapping = IDMappingService();
  final ChatAttachmentService _chatAttachments = ChatAttachmentService();

  Timer? _backgroundSyncTimer;
  Timer? _retryTimer;
  RealtimeChannel? _messagesChannel;
  final Map<int, String> _validatedConversationMappings = {};
  int _watchGeneration = 0;
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
    _validatedConversationMappings.clear();
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
    _watchGeneration++;
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
    // A full sync drains the outbox at controlled points. Do not start a
    // second writer while its remote snapshot is being traversed.
    if (_syncTask != null) return;
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
      _validatedConversationMappings.clear();
      final activeOutbox = _outboxTask;
      if (activeOutbox != null) await activeOutbox;
      await _downloadRemoteTombstones();
      if (!_hasActiveUserContext) return;
      await processPendingOperations();
      if (!_hasActiveUserContext) return;
      await _downloadRemoteConversations();
      if (!_hasActiveUserContext) return;
      await _uploadLegacyLocalData();
      if (!_hasActiveUserContext) return;
      await processPendingOperations();
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
      final operations = await _database.getPendingSyncOperations(
        limit: _pageSize,
      );
      if (operations.isEmpty) break;

      for (final operation in operations) {
        if (!_hasActiveUserContext) return;
        final outboxId = operation['id']! as int;
        final localId = operation['local_id']! as int;
        final attempts = operation['attempts']! as int;
        final entityType = operation['entity_type'] as String;
        final operationType = operation['operation'] as String;
        try {
          switch (entityType) {
            case 'conversation':
              if (operationType == 'delete') {
                final data = await _database.getConversationIncludingDeleted(
                  localId,
                );
                if (data == null) {
                  await _database.quarantineSyncOperation(
                    outboxId,
                    reason: 'conversation_missing_for_delete',
                  );
                  continue;
                }
                final conversation = Conversation.fromMap(data);
                if (!conversation.isDeleted) {
                  await _database.quarantineSyncOperation(
                    outboxId,
                    reason: 'delete_operation_without_local_tombstone',
                  );
                  continue;
                }
                await _synchronizeConversationDeletion(conversation);
                if (!_hasActiveUserContext) return;
                await _database.completeSyncOperation(outboxId);
                await _finalizeConversationDeletion(localId);
                continue;
              }
              if (operationType != 'create' && operationType != 'upsert') {
                await _database.quarantineSyncOperation(
                  outboxId,
                  reason: 'unsupported_conversation_operation',
                );
                continue;
              }
              final data = await _database.getConversation(localId);
              if (data == null) {
                final retained = await _database
                    .getConversationIncludingDeleted(localId);
                await _database.quarantineSyncOperation(
                  outboxId,
                  reason: retained == null
                      ? 'conversation_missing_for_upload'
                      : 'conversation_upload_superseded_by_tombstone',
                );
                continue;
              }
              await _uploadConversation(
                Conversation.fromMap(data),
                throwOnFailure: true,
              );
              break;
            case 'message':
              if (operationType != 'create' && operationType != 'upsert') {
                await _database.quarantineSyncOperation(
                  outboxId,
                  reason: 'unsupported_message_operation',
                );
                continue;
              }
              final message = await _database.getChatMessage(localId);
              if (message == null) {
                await _database.quarantineSyncOperation(
                  outboxId,
                  reason: 'message_missing_for_upload',
                );
                continue;
              }
              final conversationId = message.conversationId;
              final parent = conversationId == null
                  ? null
                  : await _database.getConversation(conversationId);
              if (parent == null) {
                await _database.quarantineSyncOperation(
                  outboxId,
                  reason: 'message_parent_missing_or_tombstoned',
                );
                continue;
              }
              await _uploadMessage(message, throwOnFailure: true);
              break;
            default:
              await _database.quarantineSyncOperation(
                outboxId,
                reason: 'unsupported_sync_entity',
              );
              continue;
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
      if (conversation.id == null) continue;
      String? conversationUuid;

      final messages = await _database.getConversationMessages(
        conversation.id!,
      );
      for (final data in messages) {
        if (!_hasActiveUserContext) return;
        final message = ChatMessage.fromMap(data);
        if (message.id == null) continue;
        final mappedUuid = _idMapping.getMessageUUID(message.id!);
        final needsAttachmentBackfill =
            MessageSyncReconciliation.needsAttachmentBackfill(message);
        if (mappedUuid != null && !needsAttachmentBackfill) continue;

        conversationUuid = await _ensureRemoteConversationUuid(conversation);
        if (conversationUuid == null) {
          throw StateError('Conversation could not be synchronized');
        }
        final existingUuid = await _validatedMessageMapping(
          message.id!,
          conversationUuid,
        );
        final prepared = await _prepareMessageAttachments(message);
        if (existingUuid == null) {
          await _uploadMessage(prepared, throwOnFailure: true);
        } else if (!listEquals(message.imageUrls, prepared.imageUrls)) {
          await _updateRemoteMessageImageUrls(
            existingUuid,
            conversationUuid,
            prepared.imageUrls,
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllRows(
    KeysetPageFetcher fetchPage,
  ) {
    return KeysetPagination.collect(fetchPage: fetchPage, pageSize: _pageSize);
  }

  Future<void> _downloadRemoteTombstones() async {
    final userId = _requireActiveUserId();
    final tombstones = await _fetchAllRows((afterId, limit) async {
      final query = _supabase.client
          .from('conversations')
          .select()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null);
      final page = afterId == null ? query : query.gt('id', afterId);
      return List<Map<String, dynamic>>.from(
        await page.order('id', ascending: true).limit(limit),
      );
    });

    for (final remote in tombstones) {
      if (!_hasActiveUserContext) return;
      await _applyRemoteConversationTombstone(remote);
    }
  }

  Future<void> _downloadRemoteConversations() async {
    final userId = _requireActiveUserId();
    final conversations = await _fetchAllRows((afterId, limit) async {
      final query = _supabase.client
          .from('conversations')
          .select()
          .eq('user_id', userId);
      final page = afterId == null ? query : query.gt('id', afterId);
      return List<Map<String, dynamic>>.from(
        await page.order('id', ascending: true).limit(limit),
      );
    });
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
  }

  Future<void> _applyRemoteConversationTombstone(
    Map<String, dynamic> remote,
  ) async {
    final uuid = remote['id']! as String;
    final clientId = remote['client_id'] as String?;
    Map<String, dynamic>? local;
    if (clientId != null && clientId.isNotEmpty) {
      local = await _database.getConversationByClientIdIncludingDeleted(
        clientId,
      );
    }
    final mappedId = _idMapping.getConversationLocalId(uuid);
    local ??= mappedId == null
        ? null
        : await _database.getConversationIncludingDeleted(mappedId);

    if (local == null) {
      if (mappedId != null) {
        await _idMapping.removeConversationMapping(mappedId);
      }
      return;
    }

    final localId = local['id']! as int;
    _validatedConversationMappings.remove(localId);
    final deletedAt = DateTime.parse(remote['deleted_at'] as String);
    await _database.applyRemoteConversationTombstone(
      localId,
      deletedAt: deletedAt,
    );
    await _removeConversationAttachments(localId);
    await _finalizeConversationDeletion(localId);
  }

  Future<int?> _mergeRemoteConversation(
    Map<String, dynamic> remote, {
    Map<String, String>? remoteClientOwners,
  }) async {
    if (ConversationReconciliationPolicy.actionForRemoteRecord(remote) ==
        RemoteConversationAction.purge) {
      await _applyRemoteConversationTombstone(remote);
      return null;
    }

    final uuid = remote['id']! as String;
    final userId = _requireActiveUserId();
    final clientId = remote['client_id'] as String?;
    final profileId = await _database.resolveProfileId(
      clientId: remote['profile_client_id'] as String?,
      name: remote['profile_name'] as String?,
    );

    Map<String, dynamic>? local;
    if (clientId != null && clientId.isNotEmpty) {
      local = await _database.getConversationByClientIdIncludingDeleted(
        clientId,
      );
    }
    final mappedId = _idMapping.getConversationLocalId(uuid);
    local ??= mappedId == null
        ? null
        : await _database.getConversationIncludingDeleted(mappedId);
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

    if (local != null && local['deleted_at'] != null) {
      localId = local['id']! as int;
      await _idMapping.storeConversationMapping(localId, uuid);
      return localId;
    }

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
        await _database.updateConversation({
          'id': localId,
          'client_id': clientId ?? local['client_id'],
          'title': remote['title'] as String? ?? 'Conversation',
          'is_pinned': (remote['is_pinned'] as bool? ?? false) ? 1 : 0,
          'created_at': createdAt.toIso8601String(),
          'updated_at': updatedAt.toIso8601String(),
          'archived_at': archivedAt?.toIso8601String(),
          'profile_id': profileId,
        }, enqueueSync: false);
      } else {
        await _pushConversationToRemote(localId, uuid, local);
      }
    }

    await _idMapping.storeConversationMapping(localId, uuid);
    _validatedConversationMappings[localId] = uuid;
    if (clientId == null) {
      final assignedClientId = await _database.ensureConversationClientId(
        localId,
      );
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
    final messages = await _fetchAllRows((afterId, limit) async {
      final query = _supabase.client
          .from('messages')
          .select()
          .eq('conversation_id', conversationUuid);
      final page = afterId == null ? query : query.gt('id', afterId);
      return List<Map<String, dynamic>>.from(
        await page.order('id', ascending: true).limit(limit),
      );
    });

    final identityClaims = <_LegacyMessageIdentityClaim>[];
    for (final remote in messages) {
      if (!_hasActiveUserContext) return;
      final uuid = remote['id']! as String;
      final clientId = remote['client_id'] as String?;
      ChatMessage? existing;
      if (clientId != null && clientId.isNotEmpty) {
        existing = await _database.getChatMessageByClientId(clientId);
        if (existing?.conversationId != localConversationId) {
          existing = null;
        }
      }
      final mappedId = _idMapping.getMessageLocalId(uuid);
      existing ??= mappedId == null
          ? null
          : await _database.getChatMessage(mappedId);
      final remoteMessage = ChatMessage.fromSupabase(
        remote,
        localConversationId,
        profileId: profileId,
      );
      if (existing != null) {
        final mergedImageUrls = MessageSyncReconciliation.mergedImageUrls(
          local: existing,
          remote: remoteMessage,
        );
        if (!listEquals(existing.imageUrls, mergedImageUrls)) {
          existing = existing.copyWith(imageUrls: mergedImageUrls);
          await _database.updateChatMessage(existing);
        }
        if (clientId != null &&
            clientId.isNotEmpty &&
            existing.clientId != clientId) {
          final adopted = await _database.adoptMessageClientId(
            existing.id!,
            clientId,
          );
          if (!adopted) {
            debugPrint(
              '[SyncService] Preserved conflicting local message identity for $uuid',
            );
          }
        } else if (clientId == null || clientId.isEmpty) {
          final proposedClientId =
              existing.clientId ??
              await _database.ensureMessageClientId(existing.id!);
          identityClaims.add(
            _LegacyMessageIdentityClaim(
              remoteId: uuid,
              localId: existing.id!,
              proposedClientId: proposedClientId,
            ),
          );
        }
        await _idMapping.storeMessageMapping(existing.id!, uuid);
        continue;
      }

      final localId = await _database.insertChatMessage(
        remoteMessage,
        enqueueSync: false,
      );
      await _idMapping.storeMessageMapping(localId, uuid);
      if (clientId == null || clientId.isEmpty) {
        identityClaims.add(
          _LegacyMessageIdentityClaim(
            remoteId: uuid,
            localId: localId,
            proposedClientId: await _database.ensureMessageClientId(localId),
          ),
        );
      }
    }
    await _claimLegacyMessageClientIds(identityClaims);
  }

  Future<void> _claimLegacyMessageClientIds(
    List<_LegacyMessageIdentityClaim> claims,
  ) async {
    for (
      var start = 0;
      start < claims.length;
      start += _identityClaimBatchSize
    ) {
      if (!_hasActiveUserContext) return;
      final end = start + _identityClaimBatchSize < claims.length
          ? start + _identityClaimBatchSize
          : claims.length;
      final batch = claims.sublist(start, end);
      final response = await _supabase.client.rpc(
        'claim_message_client_ids',
        params: {
          'claims': [
            for (final claim in batch)
              {'id': claim.remoteId, 'client_id': claim.proposedClientId},
          ],
        },
      );
      final localClaims = {for (final claim in batch) claim.remoteId: claim};
      for (final value in response as List<dynamic>) {
        if (value is! Map) continue;
        final row = Map<String, dynamic>.from(value);
        final remoteId = row['id'] as String?;
        final canonicalClientId = row['client_id'] as String?;
        if (remoteId == null || canonicalClientId == null) continue;
        final claim = localClaims[remoteId];
        if (claim == null || claim.proposedClientId == canonicalClientId) {
          continue;
        }
        if (_idMapping.getMessageLocalId(remoteId) != claim.localId) continue;
        final adopted = await _database.adoptMessageClientId(
          claim.localId,
          canonicalClientId,
        );
        if (!adopted) {
          debugPrint(
            '[SyncService] Could not adopt canonical message identity for $remoteId',
          );
        }
      }
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
      if (conversation.isDeleted) {
        return _uploadConversationTombstone(conversation);
      }
      final userId = _requireActiveUserId();
      final clientId =
          conversation.clientId ??
          await _database.ensureConversationClientId(conversation.id!);
      final profileId = conversation.profileId;
      final profile = profileId == null
          ? null
          : await _database.getProfile(profileId);
      final profileClientId = profile == null
          ? null
          : await _database.ensureProfileClientId(profileId!);
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

      final targetUuid = await _validatedConversationTarget(
        conversation.id!,
        clientId,
      );
      Map<String, dynamic>? response;
      if (targetUuid != null) {
        response = await _supabase.client
            .from('conversations')
            .update(data)
            .eq('id', targetUuid)
            .eq('user_id', userId)
            .select()
            .maybeSingle();
      }
      response ??= await _supabase.client
          .from('conversations')
          .upsert(data, onConflict: 'user_id,client_id')
          .select()
          .single();

      final uuid = response['id']! as String;
      if (response['deleted_at'] != null) {
        await _applyRemoteConversationTombstone(response);
        return uuid;
      }
      await _idMapping.storeConversationMapping(conversation.id!, uuid);
      _validatedConversationMappings[conversation.id!] = uuid;
      return uuid;
    } catch (error) {
      debugPrint('[SyncService] Conversation upload failed: $error');
      if (throwOnFailure) rethrow;
      return null;
    }
  }

  Future<String?> _ensureRemoteConversationUuid(
    Conversation conversation,
  ) async {
    final localId = conversation.id;
    if (localId == null) return null;
    final cached = _validatedConversationMappings[localId];
    if (cached != null) return cached;
    final clientId =
        conversation.clientId ??
        await _database.ensureConversationClientId(localId);
    final verified = await _validatedConversationTarget(localId, clientId);
    if (verified != null) return verified;
    return _uploadConversation(conversation, throwOnFailure: true);
  }

  Future<String?> _validatedConversationTarget(
    int localId,
    String clientId,
  ) async {
    final cached = _validatedConversationMappings[localId];
    if (cached != null) return cached;

    final userId = _requireActiveUserId();
    final ownerRemoteId = await _findRemoteConversationOwner(userId, clientId);
    final mappedRemoteId = _idMapping.getConversationUUID(localId);
    String? mappedRemoteClientId;
    if (ownerRemoteId == null && mappedRemoteId != null) {
      final mappedRemote = await _supabase.client
          .from('conversations')
          .select('id, client_id')
          .eq('id', mappedRemoteId)
          .eq('user_id', userId)
          .maybeSingle();
      mappedRemoteClientId = mappedRemote?['client_id'] as String?;
    }

    final verified = ConversationReconciliationPolicy.verifiedRemoteId(
      ownerRemoteId: ownerRemoteId,
      mappedRemoteId: mappedRemoteId,
      mappedRemoteClientId: mappedRemoteClientId,
      localClientId: clientId,
    );
    if (verified == null) {
      _validatedConversationMappings.remove(localId);
      if (mappedRemoteId != null) {
        await _idMapping.removeConversationMapping(localId);
      }
      return null;
    }

    await _idMapping.storeConversationMapping(localId, verified);
    _validatedConversationMappings[localId] = verified;
    return verified;
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
    final clientId =
        conversation.clientId ??
        await _database.ensureConversationClientId(localId);
    final response = await _supabase.client
        .from('conversations')
        .update({
          'client_id': clientId,
          'title': conversation.title,
          'is_pinned': conversation.isPinned,
          'archived_at': conversation.archivedAt?.toIso8601String(),
          'updated_at': conversation.updatedAt.toIso8601String(),
        })
        .eq('id', uuid)
        .eq('user_id', userId)
        .select()
        .maybeSingle();
    if (response != null && response['deleted_at'] != null) {
      await _applyRemoteConversationTombstone(response);
    }
  }

  Future<String?> _uploadConversationTombstone(
    Conversation conversation,
  ) async {
    final localId = conversation.id;
    final deletedAt = conversation.deletedAt;
    if (localId == null || deletedAt == null || !_hasActiveUserContext) {
      return null;
    }

    final userId = _requireActiveUserId();
    final clientId =
        conversation.clientId ??
        await _database.ensureConversationClientId(localId);
    final targetUuid = await _validatedConversationTarget(localId, clientId);
    final profileId = conversation.profileId;
    final profile = profileId == null
        ? null
        : await _database.getProfile(profileId);
    final profileClientId = profile == null
        ? null
        : await _database.ensureProfileClientId(profileId!);
    final data = {
      'user_id': userId,
      'client_id': clientId,
      'profile_client_id': profileClientId,
      'profile_name': profile?.name,
      'title': conversation.title,
      'is_pinned': conversation.isPinned,
      'archived_at': conversation.archivedAt?.toIso8601String(),
      'created_at': conversation.createdAt.toIso8601String(),
      'updated_at': deletedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt.toUtc().toIso8601String(),
    };

    Map<String, dynamic>? response;
    if (targetUuid != null) {
      response = await _supabase.client
          .from('conversations')
          .update(data)
          .eq('id', targetUuid)
          .eq('user_id', userId)
          .select()
          .maybeSingle();
    }
    response ??= await _supabase.client
        .from('conversations')
        .upsert(data, onConflict: 'user_id,client_id')
        .select()
        .single();

    if (response['deleted_at'] == null) {
      throw StateError('Server did not acknowledge conversation tombstone');
    }
    final uuid = response['id']! as String;
    await _idMapping.storeConversationMapping(localId, uuid);
    _validatedConversationMappings.remove(localId);
    return uuid;
  }

  Future<void> _synchronizeConversationDeletion(
    Conversation conversation,
  ) async {
    await _uploadConversationTombstone(conversation);
    if (!_hasActiveUserContext) return;
    await _removeConversationAttachments(conversation.id!);
  }

  Future<void> _removeConversationAttachments(int localId) async {
    final messages = await _database.getConversationMessages(localId);
    final references = messages
        .map(ChatMessage.fromMap)
        .expand((message) => message.imageUrls ?? const <String>[]);
    await _chatAttachments.removeImageReferences(references);
  }

  Future<void> _finalizeConversationDeletion(int localId) async {
    final messages = await _database.getConversationMessages(localId);
    await _idMapping.removeMessageMappings(
      messages.map((message) => message['id']).whereType<int>(),
    );
    await _idMapping.removeConversationMapping(localId);
    _validatedConversationMappings.remove(localId);
    await _database.purgeConversation(localId);
  }

  Future<bool> deleteConversation(Conversation conversation) async {
    final localId = conversation.id;
    if (localId == null) return false;
    try {
      return await _database.markConversationDeleted(localId) > 0;
    } catch (error) {
      debugPrint('[SyncService] Conversation tombstone failed: $error');
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
      if (message.conversationId == null) {
        throw StateError('Message has no conversation');
      }
      final conversationData = await _database.getConversation(
        message.conversationId!,
      );
      if (conversationData == null) {
        throw StateError('Message conversation no longer exists');
      }
      final conversationUuid = await _ensureRemoteConversationUuid(
        Conversation.fromMap(conversationData),
      );
      if (conversationUuid == null) {
        throw StateError('Conversation could not be synchronized');
      }

      final existingUuid = await _validatedMessageMapping(
        message.id!,
        conversationUuid,
      );
      if (existingUuid != null) {
        if (MessageSyncReconciliation.needsAttachmentBackfill(message)) {
          final prepared = await _prepareMessageAttachments(message);
          if (!listEquals(message.imageUrls, prepared.imageUrls)) {
            await _updateRemoteMessageImageUrls(
              existingUuid,
              conversationUuid,
              prepared.imageUrls,
            );
          }
        }
        return existingUuid;
      }

      final clientId =
          message.clientId ??
          await _database.ensureMessageClientId(message.id!);
      final persisted = await _prepareMessageAttachments(
        message.copyWith(clientId: clientId),
      );
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

  Future<String?> _validatedMessageMapping(
    int localMessageId,
    String expectedConversationUuid,
  ) async {
    final mappedUuid = _idMapping.getMessageUUID(localMessageId);
    if (mappedUuid == null) return null;

    final remote = await _supabase.client
        .from('messages')
        .select('id, conversation_id')
        .eq('id', mappedUuid)
        .maybeSingle();
    if (remote != null &&
        remote['conversation_id'] == expectedConversationUuid) {
      return mappedUuid;
    }

    await _idMapping.removeMessageMappings([localMessageId]);
    return null;
  }

  Future<void> _updateRemoteMessageImageUrls(
    String messageUuid,
    String conversationUuid,
    List<String>? imageUrls,
  ) async {
    await _supabase.client
        .from('messages')
        .update({'image_urls': imageUrls})
        .eq('id', messageUuid)
        .eq('conversation_id', conversationUuid);
  }

  Future<ChatMessage> _prepareMessageAttachments(ChatMessage message) async {
    final messageId = message.id;
    final localPaths = message.imagePaths ?? const <String>[];
    if (messageId == null || localPaths.isEmpty) return message;

    final clientId =
        message.clientId ?? await _database.ensureMessageClientId(messageId);
    final references = await _chatAttachments.ensureImageReferences(
      userId: _requireActiveUserId(),
      messageClientId: clientId,
      localPaths: localPaths,
      existingReferences: message.imageUrls ?? const <String>[],
    );
    if (!references.any((reference) => reference.isNotEmpty) ||
        listEquals(message.imageUrls, references)) {
      return message.clientId == clientId
          ? message
          : message.copyWith(clientId: clientId);
    }

    final prepared = message.copyWith(
      clientId: clientId,
      imageUrls: references,
    );
    await _database.updateChatMessage(prepared);
    return prepared;
  }

  Future<void> watchConversation(String conversationUuid) async {
    final generation = ++_watchGeneration;
    await _watchConversation(conversationUuid, generation);
  }

  Future<void> _watchConversation(
    String conversationUuid,
    int generation,
  ) async {
    if (!_hasActiveUserContext) return;
    await _stopRealtimeListener();
    if (generation != _watchGeneration || !_hasActiveUserContext) return;

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
            if (generation != _watchGeneration) return;
            _scheduleContainedOperation(
              'Realtime message sync will retry',
              () => _handleNewMessage(payload.newRecord),
            );
          },
        )
        .subscribe();
  }

  Future<String?> watchLocalConversation(int localConversationId) async {
    final generation = ++_watchGeneration;
    if (!_hasActiveUserContext) return null;
    final activeSync = _syncTask;
    if (activeSync != null) await activeSync;
    final activeOutbox = _outboxTask;
    if (activeOutbox != null) await activeOutbox;
    if (generation != _watchGeneration || !_hasActiveUserContext) return null;
    final local = await _database.getConversation(localConversationId);
    if (local == null) return null;
    final conversationUuid = await _ensureRemoteConversationUuid(
      Conversation.fromMap(local),
    );
    if (conversationUuid == null ||
        generation != _watchGeneration ||
        !_hasActiveUserContext) {
      return null;
    }
    await _watchConversation(conversationUuid, generation);
    if (generation != _watchGeneration) return null;
    return conversationUuid;
  }

  Future<void> stopWatchingConversation() async {
    _watchGeneration++;
    await _stopRealtimeListener();
  }

  Future<void> _handleNewMessage(Map<String, dynamic> remote) async {
    if (!_hasActiveUserContext) return;
    final conversationUuid = remote['conversation_id'] as String?;
    if (conversationUuid == null) return;
    var localConversationId = _idMapping.getConversationLocalId(
      conversationUuid,
    );
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
    _validatedConversationMappings.clear();
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
      'quarantined_operations': await _database
          .getQuarantinedSyncOperationCount(),
      'id_mappings': _idMapping.getStats(),
    };
  }
}

class _LegacyMessageIdentityClaim {
  const _LegacyMessageIdentityClaim({
    required this.remoteId,
    required this.localId,
    required this.proposedClientId,
  });

  final String remoteId;
  final int localId;
  final String proposedClientId;
}
