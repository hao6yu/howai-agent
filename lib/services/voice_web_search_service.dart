import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class VoiceWebSearchException implements Exception {
  const VoiceWebSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VoiceWebSearchResult {
  const VoiceWebSearchResult({
    required this.answer,
    required this.sourceNames,
  });

  final String answer;
  final List<String> sourceNames;
}

typedef VoiceSearchAccessTokenProvider = Future<String?> Function();

/// Runs the Realtime voice agent's read-only search function through the
/// authenticated Supabase OpenAI proxy. Provider keys never enter the app.
class VoiceWebSearchService {
  VoiceWebSearchService({
    String? proxyBaseUrl,
    String? supabaseAnonKey,
    SupabaseClient? supabaseClient,
    VoiceSearchAccessTokenProvider? accessTokenProvider,
    http.Client? httpClient,
  })  : _proxyBaseUrl = (proxyBaseUrl ?? AppConfig.openAIProxyBaseUrl).trim(),
        _supabaseAnonKey =
            (supabaseAnonKey ?? AppConfig.supabasePublishableKey).trim(),
        _accessTokenProvider = accessTokenProvider ??
            (() => _currentAccessToken(
                  supabaseClient ?? Supabase.instance.client,
                )),
        _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  static const toolName = 'search_current_information';
  static const Duration _timeout = Duration(seconds: 35);

  final String _proxyBaseUrl;
  final String _supabaseAnonKey;
  final VoiceSearchAccessTokenProvider _accessTokenProvider;
  final http.Client _httpClient;
  final bool _ownsHttpClient;

  Future<VoiceWebSearchResult> search({
    required String query,
    required String timezone,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2 || normalizedQuery.length > 1000) {
      throw const VoiceWebSearchException(
        'Please ask a slightly more specific search question.',
      );
    }
    if (_proxyBaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw const VoiceWebSearchException(
        'Live search is not configured in this app build.',
      );
    }

    final accessToken = await _accessTokenProvider();
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const VoiceWebSearchException(
        'Please sign in again before using live search.',
      );
    }

    final uri = Uri.parse(
      '${_proxyBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/v1/responses',
    );
    final payload = <String, dynamic>{
      'model': AppConfig.openAIChatModel,
      'metadata': {
        'howai_intent': 'primary_chat',
        'howai_response_profile': 'standard',
        'howai_web_search': 'force',
      },
      'instructions':
          'You are the live-search component for a spoken HowAI conversation. '
              'Search the live web and answer the query directly and concisely. '
              'Verify time-sensitive claims against multiple reliable sources '
              'when possible and prefer primary or authoritative sources. If '
              'sources conflict or evidence is incomplete, say so plainly. '
              'Do not include a Sources section, raw URLs, citation markers, '
              'or a markdown table. The user timezone is $timezone.',
      'input': normalizedQuery,
      'max_output_tokens': 600,
      'reasoning': {'effort': 'low'},
      'text': {'verbosity': 'low'},
      'tools': [
        {
          'type': 'web_search',
          'search_context_size': 'low',
        },
      ],
      'tool_choice': 'required',
      'stream': false,
    };

    late http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${accessToken.trim()}',
              'apikey': _supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const VoiceWebSearchException(
        'Live search took too long. Please try again.',
      );
    } catch (_) {
      throw const VoiceWebSearchException(
        'Live search could not connect. Please try again.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const VoiceWebSearchException(
        'Live search needs a fresh sign-in. Please try again after signing in.',
      );
    }
    if (response.statusCode == 429) {
      throw const VoiceWebSearchException(
        'The live-search limit has been reached for now.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const VoiceWebSearchException(
        'Live search is temporarily unavailable.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['output'] is! List) {
      throw const VoiceWebSearchException(
        'Live search returned an invalid response.',
      );
    }

    var completedSearch = false;
    final answer = StringBuffer();
    final sourceNames = <String>{};
    for (final rawItem in decoded['output'] as List) {
      if (rawItem is! Map) continue;
      if (rawItem['type'] == 'web_search_call' &&
          rawItem['status'] == 'completed') {
        completedSearch = true;
      }
      if (rawItem['type'] != 'message' || rawItem['content'] is! List) {
        continue;
      }
      for (final rawContent in rawItem['content'] as List) {
        if (rawContent is! Map || rawContent['type'] != 'output_text') {
          continue;
        }
        final text = rawContent['text'];
        if (text is String && text.trim().isNotEmpty) {
          if (answer.isNotEmpty) answer.write('\n');
          answer.write(text.trim());
        }
        final annotations = rawContent['annotations'];
        if (annotations is List) {
          for (final rawAnnotation in annotations) {
            if (rawAnnotation is! Map ||
                rawAnnotation['type'] != 'url_citation') {
              continue;
            }
            final title = rawAnnotation['title'];
            if (title is String && title.trim().isNotEmpty) {
              sourceNames.add(title.trim());
            }
          }
        }
      }
    }

    if (!completedSearch) {
      throw const VoiceWebSearchException(
        'Live search is not available for this request right now.',
      );
    }
    final spokenAnswer = _sanitizeForSpeech(answer.toString());
    if (spokenAnswer.isEmpty) {
      throw const VoiceWebSearchException(
        'Live search did not return a usable answer.',
      );
    }
    return VoiceWebSearchResult(
      answer: spokenAnswer,
      sourceNames: sourceNames.take(5).toList(growable: false),
    );
  }

  void dispose() {
    if (_ownsHttpClient) _httpClient.close();
  }

  static Future<String?> _currentAccessToken(SupabaseClient client) async {
    var session = client.auth.currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      try {
        final refreshed = await client.auth.refreshSession();
        session = refreshed.session ?? client.auth.currentSession;
      } catch (_) {
        return null;
      }
    }
    return session?.accessToken;
  }

  static String _sanitizeForSpeech(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\(https?://[^)]+\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(RegExp(r'https?://\S+'), '')
        .replaceAll(RegExp(r'【[^】]+】'), '')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
