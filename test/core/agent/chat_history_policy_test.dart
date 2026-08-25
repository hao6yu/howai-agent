import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/chat_history_policy.dart';

void main() {
  test('removes an accidentally duplicated current user message', () {
    final result = prepareChatHistory(
      history: const [
        {'role': 'user', 'content': 'Earlier'},
        {'role': 'assistant', 'content': 'Answer'},
        {'role': 'user', 'content': 'Current'},
      ],
      currentMessage: 'Current',
    );

    expect(result, const [
      {'role': 'user', 'content': 'Earlier'},
      {'role': 'assistant', 'content': 'Answer'},
    ]);
  });

  test('keeps a normal prior transcript unchanged under budget', () {
    final history = List.generate(
      6,
      (index) => {
        'role': index.isEven ? 'user' : 'assistant',
        'content': 'message $index',
      },
    );

    expect(
      prepareChatHistory(history: history, currentMessage: 'new message'),
      history,
    );
  });

  test('bounds long history and starts retained context on a user turn', () {
    final history = List.generate(
      32,
      (index) => {
        'role': index.isEven ? 'user' : 'assistant',
        'content': List.filled(180, 'word').join(' '),
      },
    );

    final result = prepareChatHistory(
      history: history,
      currentMessage: 'new message',
      tokenBudget: 1800,
    );

    expect(result, isNotEmpty);
    expect(result.length, lessThan(history.length));
    expect(result.first['role'], 'user');
    expect(
      result.map(estimateChatHistoryTokens).fold<int>(0, (a, b) => a + b),
      lessThanOrEqualTo(1800),
    );
  });

  test('shortens a single oversized recent message instead of dropping it', () {
    final result = prepareChatHistory(
      history: [
        {'role': 'user', 'content': List.filled(5000, '界').join()},
      ],
      currentMessage: 'different',
      tokenBudget: 300,
    );

    expect(result, hasLength(1));
    expect(result.single['content'], contains('Earlier content shortened'));
    expect(estimateChatHistoryTokens(result.single), lessThanOrEqualTo(300));
  });

  test('does not retain a lone oversized assistant reply', () {
    final result = prepareChatHistory(
      history: [
        {'role': 'assistant', 'content': List.filled(5000, 'word').join(' ')},
      ],
      currentMessage: 'new message',
      tokenBudget: 300,
    );

    expect(result, isEmpty);
  });
}
