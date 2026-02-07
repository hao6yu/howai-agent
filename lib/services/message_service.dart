import '../models/chat_message.dart';
import '../services/database_service.dart';

class MessageService {
  static const int _pageSize = 50;

  /// Load messages for a specific conversation with pagination
  static Future<MessageLoadResult> loadMessagesForConversation(
    int? conversationId,
    int? profileId,
    DatabaseService databaseService, {
    int limit = 100,
    int offset = 0,
  }) async {
    if (conversationId == null) {
      return MessageLoadResult(
        messages: [],
        loadedCount: 0,
        hasMore: false,
      );
    }

    try {
      // Load all messages for the current profile
      final allMessages = await databaseService.getChatMessages(
        profileId: profileId,
        limit: limit,
        offset: offset,
      );

      // Filter for this conversation
      final conversationMessages =
          allMessages.where((m) => m.conversationId == conversationId).toList();

      // Sort messages by timestamp
      conversationMessages.sort((a, b) {
        final aTime = DateTime.parse(a.timestamp);
        final bTime = DateTime.parse(b.timestamp);
        return aTime.compareTo(bTime);
      });

      return MessageLoadResult(
        messages: conversationMessages,
        loadedCount: conversationMessages.length,
        hasMore: conversationMessages.length == _pageSize,
      );
    } catch (e) {
      // print('Error loading messages for conversation $conversationId: $e');
      return MessageLoadResult(
        messages: [],
        loadedCount: 0,
        hasMore: false,
      );
    }
  }

  /// Load more messages with pagination
  static Future<MessageLoadResult> loadMoreMessages(
    int? profileId,
    DatabaseService databaseService,
    int currentCount,
  ) async {
    try {
      final moreMessages = await databaseService.getChatMessages(
        profileId: profileId,
        limit: _pageSize,
        offset: currentCount,
      );

      return MessageLoadResult(
        messages: moreMessages,
        loadedCount: moreMessages.length,
        hasMore: moreMessages.length == _pageSize,
      );
    } catch (e) {
      // print('Error loading more messages: $e');
      return MessageLoadResult(
        messages: [],
        loadedCount: 0,
        hasMore: false,
      );
    }
  }

  /// Clean up duplicates in messages list using aggressive deduplication
  static List<ChatMessage> cleanupMessagesList(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    // print('[Cleanup] Starting message cleanup. Before: ${messages.length} messages');

    // Create a map to store unique messages
    final Map<String, ChatMessage> uniqueMessages = {};

    // Process messages, prioritizing those with IDs
    for (final msg in messages) {
      String key;

      // Use a multi-tier key strategy for best deduplication
      if (msg.id != null) {
        // Messages with IDs use ID as key
        key = 'id_${msg.id}';
      } else if (msg.conversationId != null) {
        // Messages without ID but with conversationId
        final contentHash = msg.message.hashCode;
        final timestampSec =
            DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/ 1000;
        key =
            'conv_${msg.conversationId}_${contentHash}_${msg.isUserMessage}_${timestampSec}';
      } else {
        // Messages without either ID (temporary messages)
        final contentHash = msg.message.hashCode;
        final timestampSec =
            DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/ 1000;
        key = 'temp_${contentHash}_${msg.isUserMessage}_${timestampSec}';
      }

      if (!uniqueMessages.containsKey(key)) {
        uniqueMessages[key] = msg;
      } else if (msg.id != null && uniqueMessages[key]!.id == null) {
        // Replace non-ID version with ID version
        uniqueMessages[key] = msg;
      }
    }

    // Convert back to list and sort by timestamp
    final cleanedMessages = uniqueMessages.values.toList();
    cleanedMessages.sort((a, b) =>
        DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    // Second-pass semantic dedupe:
    // Collapse near-identical assistant duplicates even if they have different IDs
    // (can happen with local insert + sync callback races).
    final List<ChatMessage> semanticallyDeduped = [];
    for (final msg in cleanedMessages) {
      bool isDuplicate = false;

      if (!msg.isUserMessage && msg.message.trim().isNotEmpty) {
        for (int i = semanticallyDeduped.length - 1; i >= 0; i--) {
          final prev = semanticallyDeduped[i];
          if (prev.isUserMessage) {
            continue;
          }

          // Only compare within the same conversation/profile scope.
          if (prev.conversationId != msg.conversationId ||
              prev.profileId != msg.profileId) {
            continue;
          }

          final sameText = prev.message.trim() == msg.message.trim();
          final sameFiles = _jsonListEquals(prev.filePaths, msg.filePaths);
          final sameImages = _jsonListEquals(prev.imagePaths, msg.imagePaths);
          final closeInTime = (DateTime.parse(msg.timestamp)
                      .difference(DateTime.parse(prev.timestamp))
                      .inSeconds)
                  .abs() <=
              90;

          if (sameText && sameFiles && sameImages && closeInTime) {
            // Keep the message with an ID if possible.
            if (msg.id != null && prev.id == null) {
              semanticallyDeduped[i] = msg;
            }
            isDuplicate = true;
            break;
          }

          // List is time-ordered; stop searching if we're too far back.
          if ((DateTime.parse(msg.timestamp)
                      .difference(DateTime.parse(prev.timestamp))
                      .inMinutes)
                  .abs() >
              5) {
            break;
          }
        }
      }

      if (!isDuplicate) {
        semanticallyDeduped.add(msg);
      }
    }

    // print('[Cleanup] Finished message cleanup. After: ${cleanedMessages.length} messages');
    return semanticallyDeduped;
  }

  static bool _jsonListEquals(List<String>? a, List<String>? b) {
    final aNorm = a ?? const <String>[];
    final bNorm = b ?? const <String>[];
    if (aNorm.length != bNorm.length) return false;
    for (int i = 0; i < aNorm.length; i++) {
      if (aNorm[i] != bNorm[i]) return false;
    }
    return true;
  }

  /// Filter messages by conversation ID
  static List<ChatMessage> filterMessagesByConversation(
    List<ChatMessage> messages,
    int? conversationId, {
    bool includeTemporary = false,
  }) {
    if (conversationId == null && !includeTemporary) {
      return [];
    }

    return messages.where((msg) {
      if (conversationId == null) {
        // Only return temporary messages (no conversation ID)
        return msg.conversationId == null;
      } else {
        // Return messages for this conversation
        // Plus temporary messages if includeTemporary is true
        return msg.conversationId == conversationId ||
            (includeTemporary && msg.conversationId == null);
      }
    }).toList();
  }

  /// Check for duplicate messages in a list
  static bool hasDuplicates(List<ChatMessage> messages) {
    final Set<String> seenKeys = {};

    for (final msg in messages) {
      String key;
      if (msg.id != null) {
        key = 'id_${msg.id}';
      } else {
        final contentHash = msg.message.hashCode;
        final timestampSec =
            DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/ 1000;
        key = 'content_${contentHash}_${msg.isUserMessage}_${timestampSec}';
      }

      if (seenKeys.contains(key)) {
        return true;
      }
      seenKeys.add(key);
    }

    return false;
  }

  /// Merge new messages with existing ones, avoiding duplicates
  static List<ChatMessage> mergeMessages(
    List<ChatMessage> existingMessages,
    List<ChatMessage> newMessages, {
    bool insertAtBeginning = false,
  }) {
    List<ChatMessage> allMessages;

    if (insertAtBeginning) {
      allMessages = [...newMessages, ...existingMessages];
    } else {
      allMessages = [...existingMessages, ...newMessages];
    }

    return cleanupMessagesList(allMessages);
  }

  /// Generate conversation title from message text
  static String generateConversationTitle(String message) {
    // Remove common filler words
    final fillerWords = [
      'a',
      'an',
      'the',
      'this',
      'that',
      'these',
      'those',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being'
    ];

    // Split into words, remove punctuation, and filter out filler words
    final words = message
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(' ')
        .where((word) =>
            word.isNotEmpty && !fillerWords.contains(word.toLowerCase()))
        .toList();

    // If we have 4 or fewer significant words, use those
    if (words.length <= 4) {
      return words.join(' ');
    }

    // Otherwise take first 3-4 words
    return words.take(4).join(' ');
  }

  /// Create a welcome message
  static ChatMessage createWelcomeMessage(String welcomeText, int? profileId) {
    return ChatMessage(
      message: welcomeText,
      isUserMessage: false,
      timestamp: DateTime.now().toIso8601String(),
      profileId: profileId,
      isWelcomeMessage: true,
    );
  }

  /// Check if a message exists in the list
  static bool messageExists(
      List<ChatMessage> messages, ChatMessage targetMessage) {
    return messages.any((existing) =>
        existing.message == targetMessage.message &&
        existing.isUserMessage == targetMessage.isUserMessage &&
        existing.timestamp == targetMessage.timestamp);
  }

  /// Get the latest messages for conversation history
  static List<Map<String, String>> buildConversationHistory(
    List<ChatMessage> messages, {
    int maxMessages = 50,
  }) {
    // Filter and sort messages by conversation
    final sortedMessages = List<ChatMessage>.from(messages);
    sortedMessages.sort((a, b) =>
        DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    // Take the most recent messages
    final recentMessages =
        sortedMessages.reversed.take(maxMessages).toList().reversed;

    return recentMessages
        .map((msg) => {
              'role': msg.isUserMessage ? 'user' : 'assistant',
              'content': msg.message,
            })
        .toList();
  }
}

/// Result class for message loading operations
class MessageLoadResult {
  final List<ChatMessage> messages;
  final int loadedCount;
  final bool hasMore;

  MessageLoadResult({
    required this.messages,
    required this.loadedCount,
    required this.hasMore,
  });
}
