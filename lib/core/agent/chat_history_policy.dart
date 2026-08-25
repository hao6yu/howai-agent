import 'dart:convert';

/// Keeps enough recent chat context for continuity without allowing a long
/// conversation to make every request unboundedly expensive.
const int howAiChatHistoryTokenBudget = 16000;

// Aligning retained history to small, fixed blocks keeps the reusable prompt
// prefix stable for several turns after a long conversation crosses the
// budget. A simple sliding window would invalidate the prefix every turn.
const int _cacheStableMessageBlockSize = 8;

/// Returns a defensive, cache-friendly view of prior conversation messages.
///
/// [currentMessage] is removed from the tail when a caller accidentally
/// included it in [history]. The OpenAI request builder appends the current
/// message exactly once after this function returns.
List<Map<String, dynamic>> prepareChatHistory({
  required List<Map<String, dynamic>> history,
  required String currentMessage,
  int tokenBudget = howAiChatHistoryTokenBudget,
}) {
  if (tokenBudget <= 0 || history.isEmpty) return const [];

  final normalized = history
      .where(_isSupportedHistoryMessage)
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList(growable: true);

  while (normalized.isNotEmpty &&
      normalized.last['role'] == 'user' &&
      _plainText(normalized.last['content']) == currentMessage) {
    normalized.removeLast();
  }
  if (normalized.isEmpty) return const [];

  final estimates = normalized.map(estimateChatHistoryTokens).toList();
  final total = estimates.fold<int>(0, (sum, value) => sum + value);
  if (total <= tokenBudget) return normalized;

  final lastBlockStart =
      ((normalized.length - 1) ~/ _cacheStableMessageBlockSize) *
      _cacheStableMessageBlockSize;
  var selectedStart = lastBlockStart;
  var selectedTokens = _sumRange(estimates, lastBlockStart, estimates.length);

  // If the newest partial block alone is unusually large, retain the newest
  // complete messages and shorten only the oldest retained message.
  if (selectedTokens > tokenBudget) {
    return _fitNewestMessages(normalized, estimates, tokenBudget);
  }

  while (selectedStart > 0) {
    final previousStart = selectedStart >= _cacheStableMessageBlockSize
        ? selectedStart - _cacheStableMessageBlockSize
        : 0;
    final previousTokens = _sumRange(estimates, previousStart, selectedStart);
    if (selectedTokens + previousTokens > tokenBudget) break;
    selectedStart = previousStart;
    selectedTokens += previousTokens;
  }

  // Avoid beginning the retained transcript with an orphaned assistant reply.
  while (selectedStart < normalized.length - 1 &&
      normalized[selectedStart]['role'] != 'user') {
    selectedStart++;
  }
  return normalized.sublist(selectedStart);
}

/// Conservative approximation that handles non-Latin text more safely than a
/// simple character-count/4 rule. Exact billing remains server-authoritative.
int estimateChatHistoryTokens(Map<String, dynamic> message) {
  final encodedBytes = utf8.encode(jsonEncode(message)).length;
  return (encodedBytes / 3).ceil() + 8;
}

bool _isSupportedHistoryMessage(Map<String, dynamic> message) {
  final role = message['role'];
  return (role == 'user' || role == 'assistant') && message['content'] != null;
}

String? _plainText(dynamic content) => content is String ? content : null;

int _sumRange(List<int> values, int start, int end) {
  var sum = 0;
  for (var index = start; index < end; index++) {
    sum += values[index];
  }
  return sum;
}

List<Map<String, dynamic>> _fitNewestMessages(
  List<Map<String, dynamic>> messages,
  List<int> estimates,
  int tokenBudget,
) {
  var remaining = tokenBudget;
  var start = messages.length;

  for (var index = messages.length - 1; index >= 0; index--) {
    final estimate = estimates[index];
    if (estimate <= remaining) {
      start = index;
      remaining -= estimate;
      continue;
    }

    if (start == messages.length) {
      if (messages[index]['role'] != 'user') return const [];
      final shortened = _shortenMessage(messages[index], tokenBudget);
      return shortened == null ? const [] : [shortened];
    }
    break;
  }

  while (start < messages.length - 1 && messages[start]['role'] != 'user') {
    start++;
  }
  return messages.sublist(start);
}

Map<String, dynamic>? _shortenMessage(
  Map<String, dynamic> message,
  int tokenBudget,
) {
  final content = message['content'];
  if (content is! String || content.isEmpty) {
    return estimateChatHistoryTokens(message) <= tokenBudget ? message : null;
  }
  if (estimateChatHistoryTokens(message) <= tokenBudget) return message;

  final runes = content.runes.toList(growable: false);
  const marker =
      '\n\n[Earlier content shortened to control conversation cost.]\n\n';
  Map<String, dynamic>? best;
  var low = 0;
  var high = runes.length;

  // Binary-search the largest prefix/suffix pair that remains within the
  // conservative estimate. This keeps the budget true for non-Latin text too.
  while (low <= high) {
    final retainedRunes = (low + high) ~/ 2;
    final prefixLength = retainedRunes ~/ 2;
    final suffixLength = retainedRunes - prefixLength;
    final prefix = String.fromCharCodes(runes.take(prefixLength));
    final suffix = String.fromCharCodes(
      runes.skip(runes.length - suffixLength),
    );
    final candidate = Map<String, dynamic>.from(message)
      ..['content'] = '$prefix$marker$suffix';

    if (estimateChatHistoryTokens(candidate) <= tokenBudget) {
      best = candidate;
      low = retainedRunes + 1;
    } else {
      high = retainedRunes - 1;
    }
  }
  return best;
}
