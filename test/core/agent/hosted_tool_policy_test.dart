import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/agent/hosted_tool_policy.dart';

void main() {
  group('automaticHostedTools', () {
    test('offers enabled tools for model-selected intent', () {
      expect(
        automaticHostedTools(
          allowImageGeneration: true,
          allowWebSearch: true,
        ),
        [
          {'type': 'image_generation'},
          {
            'type': 'web_search',
            'search_context_size': 'low',
          },
        ],
      );
    });

    test('can offer image generation without web search', () {
      expect(
        automaticHostedTools(
          allowImageGeneration: true,
          allowWebSearch: false,
        ),
        [
          {'type': 'image_generation'},
        ],
      );
    });

    test('returns no hosted tools when both capabilities are disabled', () {
      expect(
        automaticHostedTools(
          allowImageGeneration: false,
          allowWebSearch: false,
        ),
        isEmpty,
      );
    });
  });
}
