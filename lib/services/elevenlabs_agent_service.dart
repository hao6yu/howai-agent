import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for managing ElevenLabs Conversational AI Agent connections.
/// 
/// This handles token resolution for the ElevenLabs Agent SDK, supporting
/// both direct API access and optional proxy configurations.
class ElevenLabsAgentService {
  static const String _directLiveKitTokenEndpoint =
      'https://api.elevenlabs.io/v1/convai/conversation/get-signed-url';

  final String? _apiKey;
  final String? _agentId;

  ElevenLabsAgentService({
    String? apiKey,
    String? agentId,
  })  : _apiKey = (apiKey ?? dotenv.env['ELEVENLABS_API_KEY'])?.trim(),
        _agentId = (agentId ?? dotenv.env['ELEVENLABS_AGENT_ID'])?.trim();

  /// The configured agent ID.
  String? get agentId => _agentId;

  /// Whether an agent ID is configured.
  bool get hasAgentId => _agentId != null && _agentId!.isNotEmpty;

  /// Whether the service is properly configured for use.
  bool get isConfigured => hasAgentId && _apiKey != null && _apiKey!.isNotEmpty;

  /// Resolve a signed URL for connecting to the ElevenLabs agent.
  /// 
  /// Returns a signed WebSocket URL that can be used with the SDK,
  /// or null if resolution fails.
  Future<String?> resolveSignedUrl() async {
    if (!isConfigured) {
      debugPrint('ElevenLabsAgentService: Not configured (missing API key or agent ID)');
      return null;
    }

    try {
      final uri = Uri.parse(_directLiveKitTokenEndpoint)
          .replace(queryParameters: {'agent_id': _agentId});
      
      final response = await http.get(
        uri,
        headers: {
          'xi-api-key': _apiKey!,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('ElevenLabsAgentService: Failed to get signed URL - ${response.statusCode}');
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
      debugPrint('ElevenLabsAgentService: Error parsing signed URL response - $e');
    }
    return null;
  }
}
