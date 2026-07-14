import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

enum ElevenLabsVoicePreset {
  male,
  female,
}

/// Service for managing ElevenLabs Conversational AI Agent connections.
///
/// This handles token resolution for the ElevenLabs Agent SDK, supporting
/// both direct API access and optional proxy configurations.
class ElevenLabsAgentService {
  static String _signedUrlEndpoint =
      'https://api.elevenlabs.io/v1/convai/conversation/get-signed-url';

  final String? _apiKey;
  final String? _proxyBaseUrl;
  final String? _supabaseAnonKey;
  final String? _legacyAgentId;
  final String? _maleAgentId;
  final String? _femaleAgentId;

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  ElevenLabsAgentService({
    String? apiKey,
    String? agentId,
    String? maleAgentId,
    String? femaleAgentId,
  })  : _proxyBaseUrl = AppConfig.elevenLabsProxyBaseUrl.trim().isEmpty
            ? null
            : AppConfig.elevenLabsProxyBaseUrl.trim(),
        _supabaseAnonKey = AppConfig.supabaseAnonKey.trim(),
        _apiKey = _firstNonEmpty([
          apiKey,
          AppConfig.elevenLabsApiKey,
          AppConfig.elevenLabsXiApiKey,
        ]),
        _legacyAgentId = _firstNonEmpty([
          agentId,
          AppConfig.elevenLabsAgentId,
          AppConfig.elevenLabsConvaiAgentId,
          AppConfig.elevenLabsConversationalAgentId,
          AppConfig.elevenLabsConversationalAiAgentId,
        ]),
        _maleAgentId = _firstNonEmpty([
          maleAgentId,
          AppConfig.elevenLabsAgentIdMale,
          AppConfig.elevenLabsMaleAgentId,
        ]),
        _femaleAgentId = _firstNonEmpty([
          femaleAgentId,
          AppConfig.elevenLabsAgentIdFemale,
          AppConfig.elevenLabsFemaleAgentId,
        ]) {
    if (_proxyBaseUrl != null) {
      final normalized = _proxyBaseUrl!.replaceFirst(RegExp(r'/+$'), '');
      _signedUrlEndpoint =
          '$normalized/v1/convai/conversation/get-signed-url';
    }
  }

  bool get _hasAnyVoiceSpecificAgent =>
      _maleAgentId != null || _femaleAgentId != null;

  String? _voiceSpecificAgentId(ElevenLabsVoicePreset voice) {
    return switch (voice) {
      ElevenLabsVoicePreset.male => _maleAgentId,
      ElevenLabsVoicePreset.female => _femaleAgentId,
    };
  }

  /// The configured default agent ID (for backwards compatibility).
  ///
  /// For voice-specific selection, use [agentIdForVoice].
  String? get agentId => agentIdForVoice(voice: ElevenLabsVoicePreset.male);

  /// Agent ID resolved for a given voice.
  ///
  /// Resolution order:
  /// 1) voice-specific env var (`_MALE` / `_FEMALE`)
  /// 2) legacy single-agent env var (`ELEVENLABS_AGENT_ID`) only when no
  ///    voice-specific IDs are configured at all.
  String? agentIdForVoice({required ElevenLabsVoicePreset voice}) {
    final specific = _voiceSpecificAgentId(voice);
    if (specific != null) return specific;

    // When one of the new keys is present, require explicit config per voice.
    if (_hasAnyVoiceSpecificAgent) return null;

    return _legacyAgentId;
  }

  /// Whether the chosen voice has a usable agent configuration.
  bool isConfiguredForVoice({required ElevenLabsVoicePreset voice}) =>
      agentIdForVoice(voice: voice) != null;

  /// Whether any voice call agent is configured.
  bool get hasAgentId =>
      isConfiguredForVoice(voice: ElevenLabsVoicePreset.male) ||
      isConfiguredForVoice(voice: ElevenLabsVoicePreset.female);

  /// Whether an ElevenLabs API key is configured.
  bool get hasApiKey =>
      (_proxyBaseUrl != null && _proxyBaseUrl!.isNotEmpty) ||
      (_apiKey != null && _apiKey!.isNotEmpty);

  /// Whether the service is properly configured for voice calls.
  ///
  /// The SDK call path in this app requires an agent id plus either the
  /// Supabase proxy or a local development API key.
  bool get isConfigured => hasAgentId && hasApiKey;

  /// Human-readable missing configuration summary for debugging.
  String? get configurationIssue {
    if (!hasAgentId) {
      return 'Missing agent id (ELEVENLABS_AGENT_ID or ELEVENLABS_AGENT_ID_MALE/FEMALE)';
    }
    if (!hasApiKey) {
      return 'Missing ElevenLabs proxy URL';
    }
    return null;
  }

  String? configurationIssueForVoice({required ElevenLabsVoicePreset voice}) {
    if (isConfiguredForVoice(voice: voice)) {
      return hasApiKey ? null : 'Missing ElevenLabs proxy URL';
    }

    if (_hasAnyVoiceSpecificAgent) {
      return switch (voice) {
        ElevenLabsVoicePreset.male =>
          'Missing male agent id (ELEVENLABS_AGENT_ID_MALE)',
        ElevenLabsVoicePreset.female =>
          'Missing female agent id (ELEVENLABS_AGENT_ID_FEMALE)',
      };
    }

    return 'Missing agent id (ELEVENLABS_AGENT_ID)';
  }

  /// Resolve a signed URL for connecting to the ElevenLabs agent.
  ///
  /// Returns a signed WebSocket URL that can be used with the SDK,
  /// or null if resolution fails.
  Future<String?> resolveSignedUrl({
    ElevenLabsVoicePreset voice = ElevenLabsVoicePreset.male,
    String? agentId,
  }) async {
    final resolvedAgentId =
        _firstNonEmpty([agentId, agentIdForVoice(voice: voice)]);
    if (resolvedAgentId == null || !hasApiKey) {
      debugPrint(
          'ElevenLabsAgentService: Not configured for signed URL (missing API key or agent ID)');
      return null;
    }

    try {
      final uri = Uri.parse(_signedUrlEndpoint)
          .replace(queryParameters: {'agent_id': resolvedAgentId});

      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
            'ElevenLabsAgentService: Failed to get signed URL - ${response.statusCode}');
        return null;
      }

      return _extractSignedUrl(response.body);
    } catch (e) {
      debugPrint('ElevenLabsAgentService: Error resolving signed URL - $e');
      return null;
    }
  }

  String? _extractSignedUrl(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      // Try various possible field names
      final candidates = [
        decoded['signed_url']?.toString(),
        decoded['websocket_url']?.toString(),
        decoded['url']?.toString(),
      ];

      for (final candidate in candidates) {
        if (candidate != null && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    } catch (e) {
      debugPrint(
          'ElevenLabsAgentService: Error parsing signed URL response - $e');
    }
    return null;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (_proxyBaseUrl != null && _proxyBaseUrl!.isNotEmpty) {
      final accessToken = await _getSupabaseAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      if (_supabaseAnonKey != null && _supabaseAnonKey!.isNotEmpty) {
        headers['apikey'] = _supabaseAnonKey!;
      }
    } else if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['xi-api-key'] = _apiKey!;
    }

    return headers;
  }

  Future<String?> _getSupabaseAccessToken() async {
    final auth = Supabase.instance.client.auth;
    var session = auth.currentSession;
    if (session == null) {
      return null;
    }

    if (session.isExpired) {
      try {
        final refreshed = await auth.refreshSession();
        session = refreshed.session ?? auth.currentSession;
      } catch (_) {
        return session?.accessToken;
      }
    }

    return session?.accessToken;
  }
}
