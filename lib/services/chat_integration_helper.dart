import '../models/chat_message.dart';
import '../services/review_service.dart';

/// Helper class to demonstrate integration of review service with existing chat flow
class ChatIntegrationHelper {
  /// Call this method after each AI response is successfully received
  /// Returns a list of messages that should be added to the chat
  /// - The original AI response (filtered to remove technical content)
  /// - Optionally a review request message (if conditions are met)
  static Future<List<ChatMessage>> processAIResponse({
    required String aiResponseText,
    required bool isUserMessage,
    required String timestamp,
    int? profileId,
    int? conversationId,
    List<String>? imagePaths,
    List<String>? filePaths,
  }) async {
    List<ChatMessage> messagesToAdd = [];

    // Debug: Log received parameters
    // print('[ChatIntegrationHelper] processAIResponse called with:');
    // print('[ChatIntegrationHelper] - filePaths: $filePaths');
    // print('[ChatIntegrationHelper] - imagePaths: $imagePaths');
    // print('[ChatIntegrationHelper] - message length: ${aiResponseText.length}');

    // Filter out technical content that shouldn't be shown to users
    String filteredMessage = _filterTechnicalContent(aiResponseText);

    // Add the main AI response message with filtered content
    final aiMessage = ChatMessage(
      message: filteredMessage,
      isUserMessage: false,
      timestamp: timestamp,
      profileId: profileId,
      conversationId: conversationId,
      imagePaths: imagePaths,
      filePaths: filePaths,
      messageType: MessageType.normal,
    );

    // Debug: Log the created message
    // print('[ChatIntegrationHelper] Created ChatMessage with filePaths: ${aiMessage.filePaths}');
    // print('[ChatIntegrationHelper] Original message length: ${aiResponseText.length}, Filtered length: ${filteredMessage.length}');
    // print('[ChatIntegrationHelper] Original message: "$aiResponseText"');
    // print('[ChatIntegrationHelper] Filtered message: "$filteredMessage"');

    messagesToAdd.add(aiMessage);

    // Increment AI message counter
    await ReviewService.incrementAIMessage();

    // Check if we should show review request
    if (await ReviewService.shouldShowReviewRequest()) {
      // Add the review request message
      final reviewMessage = ChatMessage(
        message: ReviewService.getReviewRequestMessage(),
        isUserMessage: false,
        timestamp: DateTime.now().toIso8601String(),
        profileId: profileId,
        conversationId: conversationId,
        messageType: MessageType.reviewRequest,
      );
      messagesToAdd.add(reviewMessage);

      // Mark that we've requested a review
      await ReviewService.markReviewRequested();
    }

    return messagesToAdd;
  }

  /// Call this when user clicks "Leave Review" button
  /// Returns a thank you message that can be added to the chat
  static ChatMessage createThankYouMessage({
    int? profileId,
    int? conversationId,
  }) {
    return ChatMessage(
      message: ReviewService.getThankYouMessage(),
      isUserMessage: false,
      timestamp: DateTime.now().toIso8601String(),
      profileId: profileId,
      conversationId: conversationId,
      messageType: MessageType.normal,
    );
  }

  /// Helper method to check current review status (for debugging)
  static Future<void> printReviewStatus() async {
    final status = await ReviewService.getStatus();
    // print('Review Status: $status');
  }

  /// Helper method to reset review state (for testing)
  static Future<void> resetForTesting() async {
    await ReviewService.resetReviewState();
  }

  /// Filters out technical content that shouldn't be shown to users
  static String _filterTechnicalContent(String message) {
    // Remove download links and file paths from the message
    String filtered = message;

    // Check if this looks like a translation response
    // Translation responses are typically short and don't contain technical jargon
    bool looksLikeTranslation = _isLikelyTranslation(message);

    // If it looks like a translation, don't filter it aggressively
    if (looksLikeTranslation) {
      // print('[ChatIntegrationHelper] Detected translation content, skipping aggressive filtering');
      return message.trim();
    }

    // Remove lines that mention file downloads, file paths, or technical functions
    final linesToRemove = [
      RegExp(r'.*You can download.*\.pptx.*', caseSensitive: false),
      RegExp(r'.*The file has been saved.*', caseSensitive: false),
      RegExp(r'.*file path.*', caseSensitive: false),
      RegExp(r'.*generate_pptx.*', caseSensitive: false),
      RegExp(r'.*web_search.*', caseSensitive: false),
      RegExp(r'.*Please use the.*function.*', caseSensitive: false),
      RegExp(r'.*STEP \d+:.*', caseSensitive: false),
      RegExp(r'.*workflow.*', caseSensitive: false),
      RegExp(r'.*ready for download.*', caseSensitive: false),
      RegExp(r'.*make it available for download.*', caseSensitive: false),
    ];

    // Split into lines and filter out unwanted content
    List<String> lines = filtered.split('\n');
    List<String> filteredLines = [];

    for (String line in lines) {
      bool shouldRemove = false;
      for (RegExp pattern in linesToRemove) {
        if (pattern.hasMatch(line)) {
          shouldRemove = true;
          break;
        }
      }

      if (!shouldRemove && line.trim().isNotEmpty) {
        filteredLines.add(line);
      }
    }

    // Rejoin and clean up
    filtered = filteredLines.join('\n').trim();

    // If the message is now empty or too short, provide a default friendly message
    // BUT only if it doesn't look like legitimate content
    if (filtered.isEmpty || (filtered.length < 20 && !_isLikelyValidContent(filtered))) {
      filtered = "I've completed your request successfully!";
    }

    return filtered;
  }

  /// Check if the message looks like a translation
  static bool _isLikelyTranslation(String message) {
    final lowercaseMessage = message.toLowerCase();

    // Check for Chinese characters (common translation target)
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(message)) {
      return true;
    }

    // Check for other common translation indicators
    if (message.length < 200 && // Short message
        !lowercaseMessage.contains('function') &&
        !lowercaseMessage.contains('workflow') &&
        !lowercaseMessage.contains('download') &&
        !lowercaseMessage.contains('file') &&
        !lowercaseMessage.contains('pptx') &&
        !lowercaseMessage.contains('tool')) {
      return true;
    }

    return false;
  }

  /// Check if the content is likely valid even if short
  static bool _isLikelyValidContent(String content) {
    // If it contains non-ASCII characters (like Chinese), it's probably valid
    if (RegExp(r'[^\x00-\x7F]').hasMatch(content)) {
      return true;
    }

    // If it's a complete sentence with punctuation
    if (content.trim().endsWith('.') || content.trim().endsWith('!') || content.trim().endsWith('?')) {
      return true;
    }

    // If it contains multiple words, it's probably valid
    if (content.trim().split(' ').length >= 3) {
      return true;
    }

    return false;
  }
}

/// Example usage in your chat screen or service:
/// 
/// ```dart
/// // After receiving AI response
/// final messages = await ChatIntegrationHelper.processAIResponse(
///   aiResponseText: aiResponse,
///   isUserMessage: false,
///   timestamp: DateTime.now().toIso8601String(),
///   profileId: currentProfileId,
///   conversationId: currentConversationId,
/// );
/// 
/// // Add all messages to your chat
/// setState(() {
///   _messages.addAll(messages);
/// });
/// 
/// // In your ChatMessageWidget:
/// ChatMessageWidget(
///   message: message,
///   // ... other parameters
///   onReviewRequested: () {
///     // Add thank you message when user leaves review
///     final thankYouMessage = ChatIntegrationHelper.createThankYouMessage(
///       profileId: currentProfileId,
///       conversationId: currentConversationId,
///     );
///     setState(() {
///       _messages.add(thankYouMessage);
///     });
///   },
/// );
/// ``` 