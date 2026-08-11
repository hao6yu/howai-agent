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

/// Image requests use the complete-response path so attachment preprocessing
/// and the active conversation lifecycle remain one atomic request in the UI.
bool shouldUseStreamingChatResponse({
  required bool streamingEnabled,
  required bool hasImageAttachments,
}) {
  return streamingEnabled && !hasImageAttachments;
}

/// Uses the app locale only as a fallback while preserving natural multilingual
/// and code-switched conversations.
String chatResponseLanguageInstructions(String appLocale) {
  final normalized = appLocale.trim().replaceAll('_', '-');
  final languageCode = normalized.split('-').first.toLowerCase();
  final languageName = normalized.toLowerCase() == 'zh-tw'
      ? 'Traditional Chinese'
      : _languageNames[languageCode] ?? 'English';

  return '\n\nRESPONSE LANGUAGE: The app interface language is $languageName, '
      'but it is only a fallback and must not force a single-language reply. '
      'Follow the language or intentional mix of languages the user is using. '
      'When the user code-switches, respond naturally in the same language mix '
      'when that is helpful, and honor any explicit language request. Do not '
      'treat a typo, proper name, or isolated foreign word as a request to '
      'switch the entire reply. If the user\'s intent is genuinely ambiguous, '
      'use $languageName.';
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
