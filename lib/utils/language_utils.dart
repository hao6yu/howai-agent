import 'package:flutter/material.dart';
import '../widgets/language_selection_popup.dart';

class LanguageUtils {
  static const Map<String, Map<String, String>> languages = {
    'en': {'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    'zh-cn': {'name': 'Chinese (Simplified)', 'native': '简体中文', 'flag': '🇨🇳'},
    'zh-tw': {'name': 'Chinese (Traditional)', 'native': '繁體中文', 'flag': '🇹🇼'},
    'es': {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    'fr': {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    'de': {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    'it': {'name': 'Italian', 'native': 'Italiano', 'flag': '🇮🇹'},
    'pt': {'name': 'Portuguese', 'native': 'Português', 'flag': '🇧🇷'},
    'pt-pt': {'name': 'Portuguese (Portugal)', 'native': 'Português (Portugal)', 'flag': '🇵🇹'},
    'ru': {'name': 'Russian', 'native': 'Русский', 'flag': '🇷🇺'},
    'ja': {'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
    'ko': {'name': 'Korean', 'native': '한국어', 'flag': '🇰🇷'},
    'ar': {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    'hi': {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    'nl': {'name': 'Dutch', 'native': 'Nederlands', 'flag': '🇳🇱'},
    'sv': {'name': 'Swedish', 'native': 'Svenska', 'flag': '🇸🇪'},
    'da': {'name': 'Danish', 'native': 'Dansk', 'flag': '🇩🇰'},
    'no': {'name': 'Norwegian', 'native': 'Norsk', 'flag': '🇳🇴'},
    'fi': {'name': 'Finnish', 'native': 'Suomi', 'flag': '🇫🇮'},
    'pl': {'name': 'Polish', 'native': 'Polski', 'flag': '🇵🇱'},
    'tr': {'name': 'Turkish', 'native': 'Türkçe', 'flag': '🇹🇷'},
    'th': {'name': 'Thai', 'native': 'ไทย', 'flag': '🇹🇭'},
    'vi': {'name': 'Vietnamese', 'native': 'Tiếng Việt', 'flag': '🇻🇳'},
    'id': {'name': 'Indonesian', 'native': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    'ms': {'name': 'Malay', 'native': 'Bahasa Melayu', 'flag': '🇲🇾'},
    'tl': {'name': 'Filipino', 'native': 'Filipino', 'flag': '🇵🇭'},
    'he': {'name': 'Hebrew', 'native': 'עברית', 'flag': '🇮🇱'},
    'fa': {'name': 'Persian', 'native': 'فارسی', 'flag': '🇮🇷'},
    'ur': {'name': 'Urdu', 'native': 'اردو', 'flag': '🇵🇰'},
    'bn': {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
    'ta': {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    'te': {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
    'mr': {'name': 'Marathi', 'native': 'मराठी', 'flag': '🇮🇳'},
    'gu': {'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳'},
    'kn': {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    'ml': {'name': 'Malayalam', 'native': 'മലയാളം', 'flag': '🇮🇳'},
    'pa': {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    'ne': {'name': 'Nepali', 'native': 'नेपाली', 'flag': '🇳🇵'},
    'si': {'name': 'Sinhala', 'native': 'සිංහල', 'flag': '🇱🇰'},
    'my': {'name': 'Myanmar', 'native': 'မြန်မာ', 'flag': '🇲🇲'},
    'km': {'name': 'Khmer', 'native': 'ខ្មែរ', 'flag': '🇰🇭'},
    'lo': {'name': 'Lao', 'native': 'ລາວ', 'flag': '🇱🇦'},
    'ka': {'name': 'Georgian', 'native': 'ქართული', 'flag': '🇬🇪'},
    'am': {'name': 'Amharic', 'native': 'አማርኛ', 'flag': '🇪🇹'},
    'sw': {'name': 'Swahili', 'native': 'Kiswahili', 'flag': '🇰🇪'},
    'zu': {'name': 'Zulu', 'native': 'isiZulu', 'flag': '🇿🇦'},
    'af': {'name': 'Afrikaans', 'native': 'Afrikaans', 'flag': '🇿🇦'},
    'sq': {'name': 'Albanian', 'native': 'Shqip', 'flag': '🇦🇱'},
    'az': {'name': 'Azerbaijani', 'native': 'Azərbaycan', 'flag': '🇦🇿'},
    'be': {'name': 'Belarusian', 'native': 'Беларуская', 'flag': '🇧🇾'},
    'bg': {'name': 'Bulgarian', 'native': 'Български', 'flag': '🇧🇬'},
    'ca': {'name': 'Catalan', 'native': 'Català', 'flag': '🇪🇸'},
    'hr': {'name': 'Croatian', 'native': 'Hrvatski', 'flag': '🇭🇷'},
    'cs': {'name': 'Czech', 'native': 'Čeština', 'flag': '🇨🇿'},
    'et': {'name': 'Estonian', 'native': 'Eesti', 'flag': '🇪🇪'},
    'gl': {'name': 'Galician', 'native': 'Galego', 'flag': '🇪🇸'},
    'hu': {'name': 'Hungarian', 'native': 'Magyar', 'flag': '🇭🇺'},
    'is': {'name': 'Icelandic', 'native': 'Íslenska', 'flag': '🇮🇸'},
    'ga': {'name': 'Irish', 'native': 'Gaeilge', 'flag': '🇮🇪'},
    'lv': {'name': 'Latvian', 'native': 'Latviešu', 'flag': '🇱🇻'},
    'lt': {'name': 'Lithuanian', 'native': 'Lietuvių', 'flag': '🇱🇹'},
    'mk': {'name': 'Macedonian', 'native': 'Македонски', 'flag': '🇲🇰'},
    'mt': {'name': 'Maltese', 'native': 'Malti', 'flag': '🇲🇹'},
    'ro': {'name': 'Romanian', 'native': 'Română', 'flag': '🇷🇴'},
    'sr': {'name': 'Serbian', 'native': 'Српски', 'flag': '🇷🇸'},
    'sk': {'name': 'Slovak', 'native': 'Slovenčina', 'flag': '🇸🇰'},
    'sl': {'name': 'Slovenian', 'native': 'Slovenščina', 'flag': '🇸🇮'},
    'uk': {'name': 'Ukrainian', 'native': 'Українська', 'flag': '🇺🇦'},
    'cy': {'name': 'Welsh', 'native': 'Cymraeg', 'flag': '🏴󠁧󠁢󠁷󠁬󠁳󠁿'},
  };

  /// Get smart language suggestions based on detected language, device locale, and user preferences
  static List<LanguageOption> getSmartSuggestions({
    required String detectedLanguageCode,
    required String deviceLanguageCode,
    required Locale deviceLocale,
    List<String>? userPreferences,
  }) {
    final suggestions = <LanguageOption>[];
    final addedCodes = <String>{};

    // Helper function to add language if not already added
    void addLanguage(String code) {
      if (!addedCodes.contains(code) && languages.containsKey(code)) {
        final lang = languages[code]!;
        suggestions.add(LanguageOption(
          code: code,
          name: lang['name']!,
          nativeName: lang['native']!,
          flag: lang['flag']!,
        ));
        addedCodes.add(code);
      }
    }

    // 1. PRIORITIZE user's most recent preferences first
    if (userPreferences != null && userPreferences.isNotEmpty) {
      for (String code in userPreferences.take(3)) {
        addLanguage(code);
      }
    }

    // 2. Add smart primary suggestion only if no user preferences
    if (suggestions.isEmpty) {
      String primarySuggestion = _getPrimarySuggestion(
        detectedLanguageCode,
        deviceLanguageCode,
        deviceLocale,
      );
      addLanguage(primarySuggestion);
    }

    // 3. Add device language if not already added
    addLanguage(deviceLanguageCode);

    // 4. Add common fallbacks
    if (detectedLanguageCode != 'en') addLanguage('en');
    if (detectedLanguageCode != 'zh' && detectedLanguageCode != 'zh-cn' && detectedLanguageCode != 'zh-tw') {
      // For Taiwan region, prefer Traditional Chinese
      if (deviceLocale.countryCode?.toLowerCase() == 'tw') {
        addLanguage('zh-tw');
      } else {
        addLanguage('zh-cn');
      }
    }
    if (detectedLanguageCode != 'es') addLanguage('es');

    // 5. Ensure we have at least 4 suggestions
    final commonLanguages = ['fr', 'de', 'ja', 'ko', 'ar', 'hi', 'pt', 'ru', 'it', 'zh-tw', 'zh-cn'];
    for (String code in commonLanguages) {
      if (suggestions.length >= 4) break;
      addLanguage(code);
    }

    return suggestions.take(4).toList();
  }

  static String _getPrimarySuggestion(
    String detectedLanguageCode,
    String deviceLanguageCode,
    Locale deviceLocale,
  ) {
    // Smart translation logic:
    // 1. If detected language is same as device language, translate to English (universal fallback)
    // 2. If detected language is different from device language, translate to device language
    // 3. Special cases for English devices

    if (detectedLanguageCode == deviceLanguageCode) {
      // Same as device language
      if (deviceLanguageCode == 'en') {
        // English device, English text - translate to most common second language based on region
        return _getRegionalSecondLanguage(deviceLocale);
      } else {
        // Non-English device, same language text - translate to English
        return 'en';
      }
    } else {
      // Different from device language
      if (languages.containsKey(deviceLanguageCode)) {
        // Device language is supported
        return deviceLanguageCode;
      } else {
        // Device language not supported, fallback to English
        return 'en';
      }
    }
  }

  static String _getRegionalSecondLanguage(Locale deviceLocale) {
    final country = deviceLocale.countryCode?.toLowerCase();

    switch (country) {
      case 'us':
      case 'ca':
        return 'es'; // Spanish is common in North America
      case 'gb':
      case 'ie':
        return 'fr'; // French is common second language in UK/Ireland
      case 'au':
      case 'nz':
        return 'zh-cn'; // Simplified Chinese is common in Australia/New Zealand
      case 'sg':
      case 'my':
        return 'zh-cn'; // Simplified Chinese is common in Southeast Asia
      case 'tw':
        return 'zh-cn'; // From Traditional Chinese to Simplified Chinese
      case 'cn':
        return 'zh-tw'; // From Simplified Chinese to Traditional Chinese
      case 'hk':
      case 'mo':
        return 'zh-cn'; // From Traditional Chinese to Simplified Chinese
      case 'in':
        return 'hi'; // Hindi for India
      case 'jp':
        return 'en'; // English for Japan
      case 'kr':
        return 'en'; // English for Korea
      default:
        return 'es'; // Spanish as global fallback (most spoken second language)
    }
  }

  /// Get all supported languages as LanguageOption list
  static List<LanguageOption> getAllLanguages() {
    return languages.entries.map((entry) {
      final lang = entry.value;
      return LanguageOption(
        code: entry.key,
        name: lang['name']!,
        nativeName: lang['native']!,
        flag: lang['flag']!,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get language name by code
  static String getLanguageName(String code) {
    return languages[code]?['name'] ?? 'Unknown';
  }

  /// Get language flag by code
  static String getLanguageFlag(String code) {
    return languages[code]?['flag'] ?? '🌐';
  }
}
