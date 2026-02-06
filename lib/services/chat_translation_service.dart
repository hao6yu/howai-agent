class ChatTranslationService {
  static String sanitizeForTranslation(String text) {
    var cleaned = text;

    // Convert markdown links to link label only, so local file paths are not translated/displayed.
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (match) => match.group(1) ?? '',
    );

    // Remove any remaining absolute local file paths commonly seen in PDF messages.
    cleaned = cleaned.replaceAll(
      RegExp(r'/Users/[^\s)\]]+'),
      '',
    );

    // Normalize spaces created by removals.
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  static String buildTranslationPrompt({
    required String detectedLanguage,
    required String targetLanguageName,
    required String text,
  }) {
    return 'Translate the following $detectedLanguage message to $targetLanguageName. Only output the translation, no extra explanation or quotes. Message: "$text"';
  }

  static String extractTranslationOrFallback({
    required Map<String, dynamic>? response,
    required String fallback,
  }) {
    if (response == null || response['text'] == null) {
      return fallback;
    }

    final value = response['text'].toString().trim();
    if (value.isEmpty) {
      return fallback;
    }

    return value;
  }
}
