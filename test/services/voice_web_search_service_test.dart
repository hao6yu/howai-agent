import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/voice_web_search_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('VoiceWebSearchService', () {
    test('uses the authenticated Supabase proxy and requires hosted search',
        () async {
      late http.Request captured;
      final service = VoiceWebSearchService(
        proxyBaseUrl: 'https://example.supabase.co/functions/v1/openai-proxy/',
        supabaseAnonKey: 'public-anon-key',
        accessTokenProvider: () async => 'user-access-token',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'status': 'completed',
              'output': [
                {
                  'type': 'web_search_call',
                  'status': 'completed',
                },
                {
                  'type': 'message',
                  'content': [
                    {
                      'type': 'output_text',
                      'text':
                          'The result is current. [Reuters](https://reuters.com/item)',
                      'annotations': [
                        {
                          'type': 'url_citation',
                          'title': 'Reuters',
                          'url': 'https://reuters.com/item',
                        },
                      ],
                    },
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await service.search(
        query: 'What happened today?',
        timezone: 'America/Chicago',
      );
      final requestBody = jsonDecode(captured.body) as Map<String, dynamic>;

      expect(
        captured.url.toString(),
        'https://example.supabase.co/functions/v1/openai-proxy/v1/responses',
      );
      expect(captured.headers['authorization'], 'Bearer user-access-token');
      expect(captured.headers['apikey'], 'public-anon-key');
      expect(requestBody['tool_choice'], 'required');
      expect(
        (requestBody['tools'] as List).single['type'],
        'web_search',
      );
      expect(
        (requestBody['metadata'] as Map)['howai_web_search'],
        'force',
      );
      expect(result.answer, 'The result is current. Reuters');
      expect(result.sourceNames, ['Reuters']);
    });

    test('rejects a response that did not actually search', () async {
      final service = VoiceWebSearchService(
        proxyBaseUrl: 'https://example.supabase.co/functions/v1/openai-proxy',
        supabaseAnonKey: 'public-anon-key',
        accessTokenProvider: () async => 'user-access-token',
        httpClient: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'status': 'completed',
              'output': [
                {
                  'type': 'message',
                  'content': [
                    {
                      'type': 'output_text',
                      'text': 'An ungrounded answer.',
                    },
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      expect(
        () => service.search(
          query: 'What happened today?',
          timezone: 'UTC',
        ),
        throwsA(
          isA<VoiceWebSearchException>().having(
            (error) => error.message,
            'message',
            contains('not available'),
          ),
        ),
      );
    });

    test('returns a friendly quota failure', () async {
      final service = VoiceWebSearchService(
        proxyBaseUrl: 'https://example.supabase.co/functions/v1/openai-proxy',
        supabaseAnonKey: 'public-anon-key',
        accessTokenProvider: () async => 'user-access-token',
        httpClient: MockClient((_) async => http.Response('{}', 429)),
      );

      expect(
        () => service.search(
          query: 'What happened today?',
          timezone: 'UTC',
        ),
        throwsA(
          isA<VoiceWebSearchException>().having(
            (error) => error.message,
            'message',
            contains('limit'),
          ),
        ),
      );
    });
  });
}
