import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/agent/agent_action_contracts.dart';
import '../models/reminder.dart';

class ReminderServiceException implements Exception {
  const ReminderServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReminderService {
  ReminderService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  String? _capabilityUserId;
  bool _cachedAvailable = false;

  User? get currentUser => _client.auth.currentUser;

  bool get hasSignedInAccount {
    final user = currentUser;
    return user != null && !user.isAnonymous;
  }

  Future<bool> checkAvailability({bool force = false}) async {
    final user = currentUser;
    if (user == null || user.isAnonymous) {
      _capabilityUserId = user?.id;
      _cachedAvailable = false;
      return false;
    }
    if (!force && _capabilityUserId == user.id) return _cachedAvailable;

    try {
      final response = await _client.functions.invoke(
        'reminder-actions',
        body: const {'operation': 'capabilities'},
      ).timeout(const Duration(seconds: 12));
      final data = _map(response.data);
      _capabilityUserId = user.id;
      _cachedAvailable = data['reminders'] == true;
      return _cachedAvailable;
    } catch (_) {
      _capabilityUserId = user.id;
      _cachedAvailable = false;
      return false;
    }
  }

  Future<List<Reminder>> fetchReminders() async {
    final user = _requireSignedInUser();
    try {
      final rows = await _client
          .from('reminders')
          .select()
          .eq('user_id', user.id)
          .order('next_fire_at');
      return rows
          .map((row) => Reminder.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    } catch (error) {
      throw ReminderServiceException(_friendlyError(error));
    }
  }

  Future<List<ActionProposal>> fetchPendingProposals() async {
    final user = _requireSignedInUser();
    try {
      final rows = await _client
          .from('agent_action_runs')
          .select(
            'id,action_type,arguments,human_summary,warnings,origin,proposed_at',
          )
          .eq('user_id', user.id)
          .eq('status', 'proposed')
          .order('proposed_at', ascending: false);
      return rows.map((row) {
        final value = Map<String, dynamic>.from(row);
        return ActionProposal.fromJson({
          'proposal_id': value['id'],
          'action_type': value['action_type'],
          'arguments': value['arguments'],
          'summary': value['human_summary'],
          'warnings': value['warnings'],
          'origin': value['origin'],
          'created_at': value['proposed_at'],
        });
      }).toList(growable: false);
    } catch (error) {
      throw ReminderServiceException(_friendlyError(error));
    }
  }

  Future<ActionProposal> propose({
    required String actionType,
    required Map<String, dynamic> arguments,
    required AgentActionOrigin origin,
    String? conversationId,
    String? idempotencyKey,
    String? replacesProposalId,
  }) async {
    _requireSignedInUser();
    try {
      final response = await _client.functions.invoke(
        'reminder-actions',
        body: {
          'operation': 'propose',
          'action_type': actionType,
          'arguments': arguments,
          'origin': origin.name,
          'conversation_id': conversationId,
          'idempotency_key': idempotencyKey ?? _newIdempotencyKey(actionType),
          'replaces_proposal_id': replacesProposalId,
        },
      ).timeout(const Duration(seconds: 15));
      final data = _map(response.data);
      return ActionProposal.fromJson(_map(data['proposal']));
    } catch (error) {
      if (error is ReminderServiceException) rethrow;
      throw ReminderServiceException(_friendlyError(error));
    }
  }

  Future<ActionProposal> proposeToolCall(
    Map<String, dynamic> toolCall, {
    required AgentActionOrigin origin,
    String? conversationId,
    ActionProposal? replacesProposal,
  }) {
    final actionType = toolCall['name']?.toString();
    if (actionType != 'reminders_create' &&
        actionType != 'reminders_update' &&
        actionType != 'reminders_resume') {
      throw const ReminderServiceException('Unsupported reminder tool call.');
    }
    final supportedActionType = actionType!;
    final arguments = _map(toolCall['arguments']);
    final callId = toolCall['call_id']?.toString().trim();
    return propose(
      actionType: supportedActionType,
      arguments: arguments,
      origin: origin,
      conversationId: conversationId,
      idempotencyKey:
          callId == null || callId.isEmpty ? null : 'openai:$callId',
      replacesProposalId: supportedActionType == 'reminders_create'
          ? replacesProposal?.proposalId
          : null,
    );
  }

  Future<ActionResult?> decide({
    required ActionProposal proposal,
    required AgentActionDecision decision,
    required AgentActionOrigin channel,
  }) async {
    _requireSignedInUser();
    try {
      final functionName = proposal.actionType.startsWith('automations_')
          ? 'automation-actions'
          : 'reminder-actions';
      final response = await _client.functions.invoke(
        functionName,
        body: {
          'operation': 'decide',
          'proposal_id': proposal.proposalId,
          'decision': decision.name,
          'channel': channel.name,
        },
      ).timeout(const Duration(seconds: 15));
      final data = _map(response.data);
      if (decision == AgentActionDecision.rejected) return null;
      return ActionResult.fromJson(_map(data['result']));
    } catch (error) {
      if (error is ReminderServiceException) rethrow;
      throw ReminderServiceException(_friendlyError(error));
    }
  }

  User _requireSignedInUser() {
    final user = currentUser;
    if (user == null || user.isAnonymous) {
      throw const ReminderServiceException(
        'Sign in to create and manage reminders.',
      );
    }
    return user;
  }

  String _newIdempotencyKey(String actionType) {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    return 'app:$actionType:$now';
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map) {
      throw const ReminderServiceException(
          'The reminder service returned invalid data.');
    }
    return Map<String, dynamic>.from(value);
  }

  static String _friendlyError(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        return details['error'] as String;
      }
      return error.reasonPhrase ??
          'The reminder action could not be completed.';
    }
    if (error is ReminderServiceException) return error.message;
    return 'The reminder action could not be completed. Please try again.';
  }
}
