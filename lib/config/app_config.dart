class AppConfig {
  // Supabase project URLs and publishable keys are public mobile-client
  // configuration. Keep provider credentials and service-role keys server-side.
  //
  // Build-time values still take precedence, but these bundled defaults keep
  // normal Xcode/Android Studio launches from silently creating relative
  // `/auth/v1/...` URLs when no dart-defines were supplied.
  static const _bundledSupabaseUrl = 'https://yjxoreszkpdealtzyvyu.supabase.co';
  static const _bundledSupabasePublishableKey =
      'sb_publishable_NvluG8lAmJXglB0qQRwGRg_bPzYdvDP';

  static const _configuredSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _configuredSupabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _configuredSupabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _isPlaceholder(String value) =>
      value.isEmpty || value.startsWith('your_');

  static String get supabaseUrl {
    final configuredUrl = _configuredSupabaseUrl.trim();
    return _isPlaceholder(configuredUrl) ? _bundledSupabaseUrl : configuredUrl;
  }

  static String get supabasePublishableKey {
    final publishableKey = _configuredSupabasePublishableKey.trim();
    if (!_isPlaceholder(publishableKey)) {
      return publishableKey;
    }

    final legacyAnonKey = _configuredSupabaseAnonKey.trim();
    if (!_isPlaceholder(legacyAnonKey)) {
      return legacyAnonKey;
    }

    return _bundledSupabasePublishableKey;
  }

  static const _configuredOpenAIProxyBaseUrl =
      String.fromEnvironment('OPENAI_PROXY_BASE_URL');

  static String get openAIProxyBaseUrl =>
      _configuredOpenAIProxyBaseUrl.trim().isNotEmpty
          ? _configuredOpenAIProxyBaseUrl.trim()
          : '$supabaseUrl/functions/v1/openai-proxy';

  static const _openAIChatModel = String.fromEnvironment('OPENAI_CHAT_MODEL');
  static const _openAIChatMiniModel =
      String.fromEnvironment('OPENAI_CHAT_MINI_MODEL');

  static String get openAIChatModel =>
      _openAIChatModel.isNotEmpty ? _openAIChatModel : 'howai-chat';
  static String get openAIChatMiniModel => _openAIChatMiniModel.isNotEmpty
      ? _openAIChatMiniModel
      : 'howai-chat-mini';

  static const _configuredElevenLabsProxyBaseUrl =
      String.fromEnvironment('ELEVENLABS_PROXY_BASE_URL');
  static String get elevenLabsProxyBaseUrl =>
      _configuredElevenLabsProxyBaseUrl.trim().isNotEmpty
          ? _configuredElevenLabsProxyBaseUrl.trim()
          : '$supabaseUrl/functions/v1/elevenlabs-proxy';
  static const elevenLabsAgentId =
      String.fromEnvironment('ELEVENLABS_AGENT_ID');
  static const elevenLabsConvaiAgentId =
      String.fromEnvironment('ELEVENLABS_CONVAI_AGENT_ID');
  static const elevenLabsConversationalAgentId =
      String.fromEnvironment('ELEVENLABS_CONVERSATIONAL_AGENT_ID');
  static const elevenLabsConversationalAiAgentId =
      String.fromEnvironment('ELEVENLABS_CONVERSATIONAL_AI_AGENT_ID');
  static const elevenLabsAgentIdMale =
      String.fromEnvironment('ELEVENLABS_AGENT_ID_MALE');
  static const elevenLabsMaleAgentId =
      String.fromEnvironment('ELEVENLABS_MALE_AGENT_ID');
  static const elevenLabsAgentIdFemale =
      String.fromEnvironment('ELEVENLABS_AGENT_ID_FEMALE');
  static const elevenLabsFemaleAgentId =
      String.fromEnvironment('ELEVENLABS_FEMALE_AGENT_ID');

  static const googleApiKey = String.fromEnvironment('GOOGLE_API_KEY');
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static void validatePublicBackendConfig() {
    final uri = Uri.tryParse(supabaseUrl);
    final hasValidUrl = uri != null &&
        uri.scheme == 'https' &&
        uri.hasAuthority &&
        uri.host.isNotEmpty;
    if (!hasValidUrl) {
      throw StateError(
        'Invalid Supabase URL. Set SUPABASE_URL to a complete HTTPS URL.',
      );
    }

    if (supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase publishable key. Set SUPABASE_PUBLISHABLE_KEY.',
      );
    }
  }
}
