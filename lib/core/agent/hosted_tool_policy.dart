/// Returns the OpenAI-hosted tools available for automatic model selection.
///
/// This policy intentionally does not accept the user's prompt. The model
/// decides whether to call an available tool from the full conversational
/// context instead of the client guessing intent with keyword matching.
List<Map<String, dynamic>> automaticHostedTools({
  required bool allowImageGeneration,
  required bool allowWebSearch,
}) {
  return [
    if (allowImageGeneration) {'type': 'image_generation'},
    if (allowWebSearch)
      {
        'type': 'web_search',
        'search_context_size': 'low',
      },
  ];
}
