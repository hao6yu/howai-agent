const Map<String, String> _languageNames = {
  'ar': 'Arabic',
  'de': 'German',
  'en': 'English',
  'es': 'Spanish',
  'fr': 'French',
  'hi': 'Hindi',
  'id': 'Indonesian',
  'it': 'Italian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'pl': 'Polish',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'tr': 'Turkish',
  'vi': 'Vietnamese',
  'zh': 'Chinese',
};

/// Keeps an isolated typo or foreign word from unexpectedly changing the
/// assistant's language while still allowing genuinely multilingual chats.
String chatResponseLanguageInstructions(String appLocale) {
  final normalized = appLocale.trim().replaceAll('_', '-');
  final languageCode = normalized.split('-').first.toLowerCase();
  final languageName = normalized.toLowerCase() == 'zh-tw'
      ? 'Traditional Chinese'
      : _languageNames[languageCode] ?? 'English';

  return '\n\nRESPONSE LANGUAGE: The app interface language is $languageName. '
      'Reply in $languageName unless the user explicitly requests another '
      'language or their latest message is clearly and predominantly written '
      'in another language. A typo, misspelled first word, proper name, or one '
      'isolated foreign word is not a request to switch languages. When the '
      'message language is ambiguous, use $languageName.';
}

/// Defense in depth for reminder identifiers. The model needs these values for
/// strict tool calls, but they are implementation details and must not be shown
/// in conversational text.
String redactReminderInternals(
  String text,
  List<Map<String, dynamic>> reminders,
) {
  var result = text;
  var removedIdentifier = false;
  for (final reminder in reminders) {
    final id = reminder['reminder_id']?.toString().trim();
    if (id == null || id.isEmpty) continue;
    if (!result.contains(id)) continue;
    removedIdentifier = true;

    final escapedId = RegExp.escape(id);
    result = result.replaceAll(
      RegExp(
        '\\s*\\(\\s*(?:internal\\s+)?(?:reminder\\s+)?id\\s*:\\s*'
        '$escapedId\\s*\\)',
        caseSensitive: false,
      ),
      '',
    );
    result = result.replaceAll(
      RegExp(
        '(?:internal\\s+)?(?:reminder\\s+)?id\\s*:\\s*$escapedId',
        caseSensitive: false,
      ),
      'reminder',
    );
    result = result.replaceAll(id, 'reminder');
  }

  final containedExpectedVersion = RegExp(
    r'expected_version\s*[:=]\s*\d+',
    caseSensitive: false,
  ).hasMatch(result);
  result = result.replaceAll(
    RegExp(r'expected_version\s*[:=]\s*\d+', caseSensitive: false),
    '',
  );
  if (removedIdentifier || containedExpectedVersion) {
    result = result.replaceAll(
      RegExp(r'\s*\(\s*version\s+\d+\s*\)', caseSensitive: false),
      '',
    );
  }

  return result.replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
}
