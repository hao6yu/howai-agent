enum ThinkingLevel {
  auto,
  fast,
  balanced,
  deep;

  String? get reasoningEffort => switch (this) {
        ThinkingLevel.auto => null,
        ThinkingLevel.fast => 'low',
        ThinkingLevel.balanced => 'medium',
        ThinkingLevel.deep => 'high',
      };
}
