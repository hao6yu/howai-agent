class ConversationGuard {
  static bool shouldHandleConversationChange({
    required bool mounted,
    required bool isSending,
    required bool isCreatingNewConversation,
  }) {
    if (!mounted) {
      return false;
    }

    if (isSending) {
      return false;
    }

    if (isCreatingNewConversation) {
      return false;
    }

    return true;
  }

  static bool shouldReloadConversation({
    required int? selectedConversationId,
    required int? lastLoadedConversationId,
  }) {
    return selectedConversationId != lastLoadedConversationId;
  }
}
