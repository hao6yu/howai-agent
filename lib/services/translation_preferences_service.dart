import 'package:shared_preferences/shared_preferences.dart';

class TranslationPreferencesService {
  static const String _translationHistoryKey = 'translation_history';
  static const int _maxHistorySize = 5;

  /// Add a language to user's translation history
  static Future<void> addTranslationChoice(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_translationHistoryKey) ?? [];

    // Remove if already exists to move it to front
    history.removeWhere((code) => code == languageCode);

    // Add to front
    history.insert(0, languageCode);

    // Keep only the most recent choices
    if (history.length > _maxHistorySize) {
      history = history.take(_maxHistorySize).toList();
    }

    await prefs.setStringList(_translationHistoryKey, history);
  }

  /// Get user's translation history (most recent first)
  static Future<List<String>> getTranslationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_translationHistoryKey) ?? [];
  }

  /// Clear translation history
  static Future<void> clearTranslationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_translationHistoryKey);
  }
}
