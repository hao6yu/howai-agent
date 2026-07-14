class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const openAIApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const openAIProxyBaseUrl =
      String.fromEnvironment('OPENAI_PROXY_BASE_URL');
  static const openAIProxyToken = String.fromEnvironment('OPENAI_PROXY_TOKEN');

  static const _openAIChatModel =
      String.fromEnvironment('OPENAI_CHAT_MODEL');
  static const _openAIChatMiniModel =
      String.fromEnvironment('OPENAI_CHAT_MINI_MODEL');

  static String get openAIChatModel =>
      _openAIChatModel.isNotEmpty ? _openAIChatModel : 'howai-chat';
  static String get openAIChatMiniModel =>
      _openAIChatMiniModel.isNotEmpty
          ? _openAIChatMiniModel
          : 'howai-chat-mini';

  static const elevenLabsApiKey =
      String.fromEnvironment('ELEVENLABS_API_KEY');
  static const elevenLabsProxyBaseUrl =
      String.fromEnvironment('ELEVENLABS_PROXY_BASE_URL');
  static const elevenLabsXiApiKey = String.fromEnvironment('XI_API_KEY');
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
  static const googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');
}
