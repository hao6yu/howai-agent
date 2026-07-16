import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/agent/agent_action_contracts.dart';

class AutomationServiceException implements Exception {
  const AutomationServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AutomationService {
  AutomationService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  String? _capabilityUserId;
  bool _cachedAvailable = false;

  Future<bool> checkAvailability({bool force = false}) async {
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    if (!force && _capabilityUserId == user.id) return _cachedAvailable;
    try {
      final response = await _client.functions.invoke(
        'automation-actions',
        body: const {'operation': 'capabilities'},
      ).timeout(const Duration(seconds: 12));
      final data = _map(response.data);
      _capabilityUserId = user.id;
      _cachedAvailable = data['automations'] == true;
      return _cachedAvailable;
    } catch (_) {
      _capabilityUserId = user.id;
      _cachedAvailable = false;
      return false;
    }
  }

  Future<ActionProposal> proposeToolCall(
    Map<String, dynamic> toolCall, {
    required AgentActionOrigin origin,
    String? conversationId,
    ActionProposal? replacesProposal,
  }) async {
    _requireSignedInUser();
    final toolName = toolCall['name']?.toString();
    if (toolName != 'automations_create_news_briefing' &&
        toolName != 'automations_create_market_briefing') {
      throw const AutomationServiceException('Unsupported Automation tool.');
    }
    final arguments = _map(toolCall['arguments']);
    arguments['kind'] = toolName == 'automations_create_news_briefing'
        ? 'news_briefing'
        : 'market_briefing';
    final callId = toolCall['call_id']?.toString().trim();
    try {
      final response = await _client.functions.invoke(
        'automation-actions',
        body: {
          'operation': 'propose',
          'action_type': 'automations_create',
          'arguments': arguments,
          'origin': origin.name,
          'conversation_id': conversationId,
          'idempotency_key': callId == null || callId.isEmpty
              ? 'app:automations_create:${DateTime.now().toUtc().microsecondsSinceEpoch}'
              : 'openai:$callId',
          'replaces_proposal_id':
              replacesProposal?.actionType == 'automations_create'
                  ? replacesProposal?.proposalId
                  : null,
        },
      ).timeout(const Duration(seconds: 15));
      return ActionProposal.fromJson(_map(_map(response.data)['proposal']));
    } catch (error) {
      throw AutomationServiceException(_friendlyError(error));
    }
  }

  Future<ActionResult?> decide({
    required ActionProposal proposal,
    required AgentActionDecision decision,
    required AgentActionOrigin channel,
  }) async {
    _requireSignedInUser();
    try {
      final response = await _client.functions.invoke(
        'automation-actions',
        body: {
          'operation': 'decide',
          'proposal_id': proposal.proposalId,
          'decision': decision.name,
          'channel': channel.name,
        },
      ).timeout(const Duration(seconds: 15));
      if (decision == AgentActionDecision.rejected) return null;
      return ActionResult.fromJson(_map(_map(response.data)['result']));
    } catch (error) {
      throw AutomationServiceException(_friendlyError(error));
    }
  }

  void _requireSignedInUser() {
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw const AutomationServiceException(
        'Sign in to create and manage Automations.',
      );
    }
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map) {
      throw const AutomationServiceException(
        'The Automation service returned invalid data.',
      );
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
          'The Automation action could not be completed.';
    }
    if (error is AutomationServiceException) return error.message;
    return 'The Automation action could not be completed. Please try again.';
  }
}
