import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/thinking_level.dart';

void main() {
  test('thinking levels map only user-visible paid choices to API effort', () {
    expect(ThinkingLevel.auto.reasoningEffort, isNull);
    expect(ThinkingLevel.fast.reasoningEffort, 'low');
    expect(ThinkingLevel.balanced.reasoningEffort, 'medium');
    expect(ThinkingLevel.deep.reasoningEffort, 'high');
  });
}
