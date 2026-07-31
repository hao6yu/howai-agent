import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/openai_service.dart';

void main() {
  group('OpenAI proxy streaming errors', () {
    test('classifies the anonymous allowance response', () {
      expect(
        classifyOpenAiProxyError(
          429,
          '{"error":"The anonymous daily answer or cost limit has been reached."}',
        ),
        openAiErrorCodeAnonymousLimit,
      );
    });

    test('classifies signed-in usage and generic rate limits separately', () {
      expect(
        classifyOpenAiProxyError(
          429,
          '{"error":"The AI usage limit for the current plan has been reached."}',
        ),
        openAiErrorCodeUsageLimit,
      );
      expect(
        classifyOpenAiProxyError(429, '{"error":"Too many requests"}'),
        openAiErrorCodeRateLimit,
      );
    });

    test('does not classify unrelated HTTP errors as limits', () {
      expect(classifyOpenAiProxyError(503, '{}'), isNull);
      expect(
        safeOpenAiProxyErrorMessage(503),
        'The AI service is temporarily unavailable.',
      );
    });
  });
}
