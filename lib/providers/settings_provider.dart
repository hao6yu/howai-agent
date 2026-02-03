import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _useVoiceResponseKey = 'use_voice_response';
  static const String _selectedVoiceIdKey = 'selected_voice_id';
  static const String _selectedLocaleKey = 'selected_locale';
  static const String _useSpeakerOutputKey = 'use_speaker_output';
  static const String _fontSizeScaleKey = 'font_size_scale';
  static const String _selectedSystemTTSVoiceKey = 'selected_system_tts_voice';
  static const String _themeModeKey = 'theme_mode';
  static const String _useStreamingKey = 'use_streaming';

  bool _useVoiceResponse = false; // Always false - auto-play disabled
  bool _useStreaming = false; // Disable streaming by default (required for image generation)
  String _selectedVoiceId = '9BWtsMINqrJLrRacOk9x'; // Default voice (Aria)
  bool _useSpeakerOutput = false;
  double _fontSizeScale = 1.0; // Default font size scale (1.0 = normal)
  Map<String, String>? _selectedSystemTTSVoice; // Selected system TTS voice
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  String? _selectedLocale; // null = system default
  String? get selectedLocale => _selectedLocale;

  bool get useVoiceResponse => _useVoiceResponse;
  bool get useStreaming => _useStreaming;
  String get selectedVoiceId => _selectedVoiceId;
  bool get useSpeakerOutput => _useSpeakerOutput;
  double get fontSizeScale => _fontSizeScale;
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
    _useStreaming = prefs.getBool(_useStreamingKey) ?? false;
    _selectedVoiceId = prefs.getString(_selectedVoiceIdKey) ?? '9BWtsMINqrJLrRacOk9x';
    _useSpeakerOutput = prefs.getBool(_useSpeakerOutputKey) ?? false;
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? defaultFontScale;
    _selectedLocale = prefs.getString(_selectedLocaleKey);

    // Load theme mode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);

    // Load selected system TTS voice
    final voiceName = prefs.getString('${_selectedSystemTTSVoiceKey}_name');
    final voiceLanguage = prefs.getString('${_selectedSystemTTSVoiceKey}_language');
    if (voiceName != null && voiceLanguage != null) {
      _selectedSystemTTSVoice = {'name': voiceName, 'language': voiceLanguage};
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
    } else {
      await prefs.setString('${_selectedSystemTTSVoiceKey}_name', voice['name'] ?? '');
      await prefs.setString('${_selectedSystemTTSVoiceKey}_language', voice['language'] ?? '');
    }
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
    
    // Sync to Supabase in background
    _syncSettingsToSupabase();
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale.clamp(minFontScale, maxFontScale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeScaleKey, _fontSizeScale);
    // debugPrint('Saved font size scale: $_fontSizeScale');
    notifyListeners();
    
    // Sync to Supabase in background
    _syncSettingsToSupabase();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
    // debugPrint('Saved theme mode: ${_themeModeToString(mode)}');
    notifyListeners();
    
    // Sync to Supabase in background
    _syncSettingsToSupabase();
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

  /// Sync settings to Supabase (silent background operation)
  void _syncSettingsToSupabase() {
    Future.microtask(() async {
      try {
        final supabase = SupabaseService();
        
        if (!supabase.isAuthenticated) {
          debugPrint('[SettingsProvider] Not authenticated, skipping settings sync');
          return;
        }

        final userId = supabase.currentUser!.id;
        
        final data = {
          'user_id': userId,
          'theme_mode': _themeModeToString(_themeMode),
          'locale': _selectedLocale,
          'font_size_scale': _fontSizeScale,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await supabase.client
            .from('user_settings')
            .upsert(data);
        
        debugPrint('[SettingsProvider] Settings synced to Supabase');
      } catch (e) {
        debugPrint('[SettingsProvider] Error syncing settings (silent): $e');
        // Silent failure - settings still work locally
      }
    });
  }

  /// Load settings from Supabase (for cross-device sync)
  Future<void> loadSettingsFromSupabase() async {
    try {
      final supabase = SupabaseService();
      
      if (!supabase.isAuthenticated) {
        debugPrint('[SettingsProvider] Not authenticated, skipping settings load');
        return;
      }

      final userId = supabase.currentUser!.id;
      
      final response = await supabase.client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        // Update local settings from Supabase
        final themeModeStr = response['theme_mode'] as String?;
        if (themeModeStr != null) {
          _themeMode = _parseThemeMode(themeModeStr);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_themeModeKey, themeModeStr);
        }
        
        final locale = response['locale'] as String?;
        if (locale != null) {
          _selectedLocale = locale;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_selectedLocaleKey, locale);
        }
        
        final fontScale = response['font_size_scale'] as double?;
        if (fontScale != null) {
          _fontSizeScale = fontScale;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble(_fontSizeScaleKey, fontScale);
        }
        
        notifyListeners();
        debugPrint('[SettingsProvider] Loaded settings from Supabase');
      }
    } catch (e) {
      debugPrint('[SettingsProvider] Error loading settings from Supabase (silent): $e');
      // Silent failure - use local settings
    }
  }
}
