import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _useVoiceResponseKey = 'use_voice_response';
  static const String _selectedVoiceIdKey = 'selected_voice_id';
  static const String _selectedLocaleKey = 'selected_locale';
  static const String _useSpeakerOutputKey = 'use_speaker_output';
  static const String _fontSizeScaleKey = 'font_size_scale';
  static const String _selectedSystemTTSVoiceKey = 'selected_system_tts_voice';
  static const String _ttsPlaybackSpeedKey =
      'tts_playback_speed'; // Legacy key (migration only)
  static const String _systemTtsPlaybackSpeedKey = 'system_tts_playback_speed';
  static const String _elevenLabsPlaybackSpeedKey = 'elevenlabs_playback_speed';
  static const String _premiumTtsEngineKey = 'premium_tts_engine';
  static const String _premiumVoiceDefaultsV2AppliedKey =
      'premium_voice_defaults_v2_applied';
  static const String _themeModeKey = 'theme_mode';
  static const String _useStreamingKey = 'use_streaming';

  bool _useVoiceResponse = false; // Always false - auto-play disabled
  bool _useStreaming =
      true; // Default ON for chat; image requests are routed to non-streaming path
  String _selectedVoiceId = '9BWtsMINqrJLrRacOk9x'; // Default voice (Aria)
  bool _useSpeakerOutput = false;
  double _fontSizeScale = 1.0; // Default font size scale (1.0 = normal)
  double _systemTtsPlaybackSpeed = 0.5; // Free system TTS speed
  double _elevenLabsPlaybackSpeed = 1.0; // Premium ElevenLabs playback speed
  String _premiumTtsEngine = 'elevenlabs'; // 'elevenlabs' | 'system'
  Map<String, String>? _selectedSystemTTSVoice; // Selected system TTS voice
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  String? _selectedLocale; // null = system default
  String? get selectedLocale => _selectedLocale;

  bool get useVoiceResponse => _useVoiceResponse;
  bool get useStreaming => _useStreaming;
  String get selectedVoiceId => _selectedVoiceId;
  bool get useSpeakerOutput => _useSpeakerOutput;
  double get fontSizeScale => _fontSizeScale;
  // Backward-compatible getter
  double get ttsPlaybackSpeed => _systemTtsPlaybackSpeed;
  double get systemTtsPlaybackSpeed => _systemTtsPlaybackSpeed;
  double get elevenLabsPlaybackSpeed => _elevenLabsPlaybackSpeed;
  String get premiumTtsEngine => _premiumTtsEngine;
  bool get premiumUsesSystemTts => _premiumTtsEngine == 'system';
  Map<String, String>? get selectedSystemTTSVoice => _selectedSystemTTSVoice;
  ThemeMode get themeMode => _themeMode;

  // Font size constants (similar to WeChat's scale range)
  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.6;
  static const double defaultFontScale = 1.0;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useVoiceResponse = prefs.getBool(_useVoiceResponseKey) ?? false;
    _useStreaming = prefs.getBool(_useStreamingKey) ?? true;
    _selectedVoiceId =
        prefs.getString(_selectedVoiceIdKey) ?? '9BWtsMINqrJLrRacOk9x';
    _useSpeakerOutput = prefs.getBool(_useSpeakerOutputKey) ?? false;
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? defaultFontScale;
    final legacyTtsSpeed = prefs.getDouble(_ttsPlaybackSpeedKey);
    _systemTtsPlaybackSpeed =
        prefs.getDouble(_systemTtsPlaybackSpeedKey) ?? legacyTtsSpeed ?? 0.5;
    _elevenLabsPlaybackSpeed =
        prefs.getDouble(_elevenLabsPlaybackSpeedKey) ?? 1.0;
    _premiumTtsEngine = prefs.getString(_premiumTtsEngineKey) ?? 'elevenlabs';
    _selectedLocale = prefs.getString(_selectedLocaleKey);

    // Load theme mode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);

    // Load selected system TTS voice
    final voiceName = prefs.getString('${_selectedSystemTTSVoiceKey}_name');
    final voiceLanguage =
        prefs.getString('${_selectedSystemTTSVoiceKey}_language');
    final voiceLocale = prefs.getString('${_selectedSystemTTSVoiceKey}_locale');
    final voiceGender = prefs.getString('${_selectedSystemTTSVoiceKey}_gender');
    final voiceQuality =
        prefs.getString('${_selectedSystemTTSVoiceKey}_quality');
    final voiceIdentifier =
        prefs.getString('${_selectedSystemTTSVoiceKey}_identifier');
    if (voiceName != null && voiceLanguage != null) {
      _selectedSystemTTSVoice = {
        'name': voiceName,
        'language': voiceLanguage,
        if (voiceLocale != null) 'locale': voiceLocale,
        if (voiceGender != null) 'gender': voiceGender,
        if (voiceQuality != null) 'quality': voiceQuality,
        if (voiceIdentifier != null) 'identifier': voiceIdentifier,
      };
    }

    notifyListeners();
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setUseVoiceResponse(bool value) async {
    _useVoiceResponse = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useVoiceResponseKey, value);
    notifyListeners();
  }

  Future<void> setUseStreaming(bool value) async {
    _useStreaming = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useStreamingKey, value);
    notifyListeners();
  }

  Future<void> setSelectedVoiceId(String voiceId) async {
    _selectedVoiceId = voiceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedVoiceIdKey, voiceId);
    notifyListeners();
  }

  Future<void> setSelectedSystemTTSVoice(Map<String, String>? voice) async {
    _selectedSystemTTSVoice = voice;
    final prefs = await SharedPreferences.getInstance();
    if (voice == null) {
      await prefs.remove('${_selectedSystemTTSVoiceKey}_name');
      await prefs.remove('${_selectedSystemTTSVoiceKey}_language');
      await prefs.remove('${_selectedSystemTTSVoiceKey}_locale');
      await prefs.remove('${_selectedSystemTTSVoiceKey}_gender');
      await prefs.remove('${_selectedSystemTTSVoiceKey}_quality');
      await prefs.remove('${_selectedSystemTTSVoiceKey}_identifier');
    } else {
      await prefs.setString(
          '${_selectedSystemTTSVoiceKey}_name', voice['name'] ?? '');
      await prefs.setString(
          '${_selectedSystemTTSVoiceKey}_language', voice['language'] ?? '');
      await prefs.setString(
          '${_selectedSystemTTSVoiceKey}_locale', voice['locale'] ?? '');
      await prefs.setString(
          '${_selectedSystemTTSVoiceKey}_gender', voice['gender'] ?? '');
      await prefs.setString(
          '${_selectedSystemTTSVoiceKey}_quality', voice['quality'] ?? '');
      await prefs.setString('${_selectedSystemTTSVoiceKey}_identifier',
          voice['identifier'] ?? '');
    }
    notifyListeners();
  }

  Future<void> setTtsPlaybackSpeed(double speed) async {
    await setSystemTtsPlaybackSpeed(speed);
  }

  Future<void> setSystemTtsPlaybackSpeed(double speed) async {
    _systemTtsPlaybackSpeed = speed.clamp(0.5, 1.2);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_systemTtsPlaybackSpeedKey, _systemTtsPlaybackSpeed);
    // Keep writing legacy key for backward compatibility with older code paths.
    await prefs.setDouble(_ttsPlaybackSpeedKey, _systemTtsPlaybackSpeed);
    notifyListeners();
  }

  Future<void> setElevenLabsPlaybackSpeed(double speed) async {
    _elevenLabsPlaybackSpeed = speed.clamp(0.8, 1.5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        _elevenLabsPlaybackSpeedKey, _elevenLabsPlaybackSpeed);
    notifyListeners();
  }

  Future<void> setPremiumTtsEngine(String engine) async {
    if (engine != 'system' && engine != 'elevenlabs') return;
    _premiumTtsEngine = engine;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_premiumTtsEngineKey, _premiumTtsEngine);
    notifyListeners();
  }

  Future<void> applyPremiumVoiceDefaultsIfNeeded({
    required bool isPremium,
  }) async {
    if (!isPremium) return;
    final prefs = await SharedPreferences.getInstance();
    final alreadyApplied = prefs.getBool(_premiumVoiceDefaultsV2AppliedKey);
    if (alreadyApplied == true) return;

    _selectedVoiceId = '9BWtsMINqrJLrRacOk9x'; // Aria
    _elevenLabsPlaybackSpeed = 1.0;
    _systemTtsPlaybackSpeed = 0.5;
    _premiumTtsEngine = 'elevenlabs';

    await prefs.setString(_selectedVoiceIdKey, _selectedVoiceId);
    await prefs.setDouble(
        _elevenLabsPlaybackSpeedKey, _elevenLabsPlaybackSpeed);
    await prefs.setDouble(_systemTtsPlaybackSpeedKey, _systemTtsPlaybackSpeed);
    await prefs.setDouble(_ttsPlaybackSpeedKey, _systemTtsPlaybackSpeed);
    await prefs.setString(_premiumTtsEngineKey, _premiumTtsEngine);
    await prefs.setBool(_premiumVoiceDefaultsV2AppliedKey, true);
    notifyListeners();
  }

  Future<void> setUseSpeakerOutput(bool value) async {
    _useSpeakerOutput = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSpeakerOutputKey, value);
    notifyListeners();
  }

  Future<void> setSelectedLocale(String? locale) async {
    _selectedLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_selectedLocaleKey);
      // debugPrint('Removed locale preference (using system default)');
    } else {
      await prefs.setString(_selectedLocaleKey, locale);
      // debugPrint('Saved locale to preferences: $locale');
    }
    notifyListeners();
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale.clamp(minFontScale, maxFontScale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeScaleKey, _fontSizeScale);
    // debugPrint('Saved font size scale: $_fontSizeScale');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
    // debugPrint('Saved theme mode: ${_themeModeToString(mode)}');
    notifyListeners();
  }

  double getScaledFontSize(double baseFontSize) {
    return baseFontSize * _fontSizeScale;
  }

  bool get isDefaultFontSize => _fontSizeScale == defaultFontScale;

  Future<void> resetFontSizeToDefault() async {
    await setFontSizeScale(defaultFontScale);
  }

  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  String get currentThemeModeDisplayName => getThemeModeDisplayName(_themeMode);

  /// Deprecated: settings are local-only and no longer synced via Supabase.
  Future<void> loadSettingsFromSupabase() async {
    return;
  }
}
