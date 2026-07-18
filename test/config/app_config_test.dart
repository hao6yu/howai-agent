import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/config/app_config.dart';

void main() {
  group('AppConfig public backend configuration', () {
    test('is usable without dart-define launch arguments', () {
      final supabaseUri = Uri.parse(AppConfig.supabaseUrl);

      expect(supabaseUri.scheme, 'https');
      expect(supabaseUri.host, endsWith('.supabase.co'));
      expect(AppConfig.supabasePublishableKey, isNotEmpty);
      expect(AppConfig.validatePublicBackendConfig, returnsNormally);
    });

    test('provides complete proxy URLs', () {
      final openAIProxyUri = Uri.parse(AppConfig.openAIProxyBaseUrl);
      final elevenLabsProxyUri = Uri.parse(AppConfig.elevenLabsProxyBaseUrl);

      expect(openAIProxyUri.isAbsolute, isTrue);
      expect(openAIProxyUri.path, '/functions/v1/openai-proxy');
      expect(elevenLabsProxyUri.isAbsolute, isTrue);
      expect(elevenLabsProxyUri.path, '/functions/v1/elevenlabs-proxy');
    });
  });
}
