/// Returns whether this message should be routed directly to the reminder
/// proposal tool. This is deliberately local and deterministic so reminder
/// requests do not pay for a separate classifier call.
bool shouldForceReminderCreateTool({
  required String message,
  required List<Map<String, dynamic>> history,
  bool hasPendingReminderDraft = false,
}) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty || _isReminderCancellation(normalized)) {
    return false;
  }

  if (_isInformationalReminderQuestion(normalized)) {
    return false;
  }

  // A Reminder only delivers its saved title/notes. Scheduled content that
  // must be generated later belongs to the separate Automations contract.
  // Keeping this deterministic prevents a briefing from silently degrading
  // into a static notification when generated Automations are unavailable.
  if (isGeneratedBriefingAutomationRequest(normalized)) {
    return false;
  }

  if (_explicitReminderRequest.hasMatch(normalized)) {
    return true;
  }

  return _isReminderAdjustment(normalized) &&
      (hasPendingReminderDraft || _hasRecentReminderContext(history));
}

/// Returns whether the request is for generated news/market content on a
/// schedule rather than a static reminder to do something.
bool isGeneratedBriefingAutomationRequest(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  final hasSchedule = isHighFrequencyAutomationRequest(normalized) ||
      RegExp(
        r'\b(?:daily|weekly|weekday|weekdays|every\s+(?:day|morning|evening|night|week|weekday|monday|tuesday|wednesday|thursday|friday|saturday|sunday)|each\s+(?:day|morning|evening|week)|at\s+\d{1,2}(?::\d{2})?\s*(?:a\.?m\.?|p\.?m\.?)?)\b',
        caseSensitive: false,
      ).hasMatch(normalized);
  if (!hasSchedule) return false;

  final asksForGeneratedBriefing = RegExp(
    r'\b(?:briefing|brief|digest|recap|summar(?:y|ize|ise)|market\s+update|news\s+update|top\s+\d+\s+(?:[a-z0-9-]+\s+){0,3}(?:news|stories|headlines|stocks)|what\s+happened\s+in\s+(?:the\s+)?(?:stock\s+)?market)\b',
    caseSensitive: false,
  ).hasMatch(normalized);
  if (!asksForGeneratedBriefing) return false;

  return RegExp(
    r'\b(?:news|headline|story|stories|market|stock|stocks|watchlist|briefing|digest)\b',
    caseSensitive: false,
  ).hasMatch(normalized);
}

/// Detects generated-work schedules that are deliberately below HowAI's
/// once-per-day minimum. The server remains authoritative; this local guard is
/// for correct routing and a useful response before any proposal is created.
bool isHighFrequencyAutomationRequest(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return RegExp(
    r'\b(?:hourly|every\s+(?:(?:\d+|one|two|half)\s+)?(?:seconds?|secs?|minutes?|mins?|hours?|hrs?)|each\s+(?:minute|hour))\b',
    caseSensitive: false,
  ).hasMatch(normalized);
}

/// Returns whether this message explicitly asks to modify a saved reminder.
/// The caller can use this before the model request to refresh reminder state.
bool isExistingReminderUpdateRequest(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty ||
      _isReminderCancellation(normalized) ||
      _isInformationalReminderQuestion(normalized)) {
    return false;
  }
  return _reminderUpdateVerb.hasMatch(normalized) &&
      RegExp(r'\bremind(?:er|ing)?\b').hasMatch(normalized);
}

/// Returns whether the user is asking to turn a paused reminder back on.
/// Common natural variants and the frequent shorthand "paused remind" are
/// accepted so this action does not depend on one exact phrase.
bool isExistingReminderResumeRequest(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty || _isInformationalReminderQuestion(normalized)) {
    return false;
  }
  final referencesReminder = RegExp(
    r'\bremind(?:er|ers|ing)?\b',
  ).hasMatch(normalized);
  final referencesPausedState = RegExp(r'\bpaused?\b').hasMatch(normalized);
  return _reminderResumeVerb.hasMatch(normalized) &&
      (referencesReminder || referencesPausedState);
}

/// Routes a resume request only when a paused, user-owned reminder is
/// available. This prevents the model from inventing an identifier or version.
bool shouldForceReminderResumeTool({
  required String message,
  required bool hasPausedReminders,
  bool hasPendingReminderDraft = false,
}) {
  return hasPausedReminders &&
      !hasPendingReminderDraft &&
      isExistingReminderResumeRequest(message);
}

/// Returns whether a saved reminder update should be routed directly to the
/// update tool. Existing reminder data must be available so the model cannot
/// invent a reminder identifier or version.
bool shouldForceReminderUpdateTool({
  required String message,
  required List<Map<String, dynamic>> history,
  required bool hasExistingReminders,
  bool hasPendingReminderDraft = false,
}) {
  if (!hasExistingReminders || hasPendingReminderDraft) return false;
  if (isExistingReminderUpdateRequest(message)) return true;

  final normalized = message.trim().toLowerCase();
  return _isReminderAdjustment(normalized) &&
      _hasRecentReminderContext(history);
}

final RegExp _explicitReminderRequest = RegExp(
  r"(?:^|\b)(?:(?:please\s+)?(?:(?:can|could|would)\s+you\s+)?)?"
  r"(?:remind\s+me\s+(?:to|at|on|in|every|about)\b|"
  r"(?:set|create|add|schedule)\s+(?:me\s+)?(?:a\s+)?reminder\b|"
  r"reminder\s+(?:for|at|on|in|every)\b)",
  caseSensitive: false,
);

final RegExp _reminderUpdateVerb = RegExp(
  r'\b(?:update|edit|adjust|change|move|reschedule)\b',
  caseSensitive: false,
);

final RegExp _reminderResumeVerb = RegExp(
  r'\b(?:resume|unpause|reactivate|re[-\s]?enable)\b|'
  r'\bturn\s+(?:it|that(?:\s+reminder)?|the\s+reminder)\s+back\s+on\b',
  caseSensitive: false,
);

bool _isReminderCancellation(String message) {
  return RegExp(
    r"\b(?:do\s+not|don't|dont|stop|cancel|delete|remove)\s+"
    r"(?:my\s+|the\s+|a\s+)?remind(?:er|ing)?\b",
    caseSensitive: false,
  ).hasMatch(message);
}

bool _isInformationalReminderQuestion(String message) {
  if (!message.contains('remind')) return false;
  return RegExp(r'^(?:how|what|why|where|when)\b').hasMatch(message) ||
      RegExp(r'\bhow\s+to\s+(?:set|create|add|schedule)\b').hasMatch(message);
}

bool _isReminderAdjustment(String message) {
  return RegExp(
    r"^(?:actually[, ]+)?(?:(?:can|could|would)\s+you\s+)?(?:please\s+)?(?:"
    r"for\s+(?:the\s+)?next\s+\d+\s+(?:day|week|month|year)s?|"
    r"until\s+.+|"
    r"(?:make|change|move|reschedule)\s+(?:it|that|the\s+(?:time|date|schedule))\s+.+|"
    r"(?:what|how)\s+about\s+.+|"
    r"(?:start|starting|end|ending)\s+.+|"
    r"(?:at|on|every)\s+.+\s+instead|"
    r"(?:daily|weekly|monthly)(?:\s+.+)?"
    r")[?.!]*$",
    caseSensitive: false,
  ).hasMatch(message);
}

bool _hasRecentReminderContext(List<Map<String, dynamic>> history) {
  final recent = history.reversed.take(8);
  for (final entry in recent) {
    final content = entry['content'];
    final text = content is String
        ? content
        : content is List
            ? content
                .whereType<Map>()
                .map((block) => block['text']?.toString() ?? '')
                .join(' ')
            : '';
    if (RegExp(r'\bremind(?:er|ing)?\b', caseSensitive: false).hasMatch(text)) {
      return true;
    }
  }
  return false;
}
