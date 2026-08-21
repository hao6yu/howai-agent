import 'dart:convert';
import '../services/location_service.dart';

enum MessageType { normal, reviewRequest, welcome }

class ChatMessage {
  final int? id;
  final String? clientId;
  final String message;
  final bool isUserMessage;
  final String? audioPath;
  final String timestamp;
  final int? profileId;
  final List<String>? imagePaths; // Local file paths
  final List<String>? imageUrls; // Cloud URLs or private Storage references
  final List<String>? filePaths;
  final bool? isWelcomeMessage;
  final int? conversationId;
  final List<PlaceResult>? locationResults;
  final MessageType messageType;

  bool get hasImages =>
      imagePaths?.any((path) => path.trim().isNotEmpty) == true ||
      imageUrls?.any((url) => url.trim().isNotEmpty) == true;

  int get imageCount {
    final localPaths = imagePaths ?? const <String>[];
    final remoteUrls = imageUrls ?? const <String>[];
    final slots = localPaths.length > remoteUrls.length
        ? localPaths.length
        : remoteUrls.length;
    var count = 0;
    for (var index = 0; index < slots; index++) {
      final hasLocal =
          index < localPaths.length && localPaths[index].trim().isNotEmpty;
      final hasRemote =
          index < remoteUrls.length && remoteUrls[index].trim().isNotEmpty;
      if (hasLocal || hasRemote) count++;
    }
    return count;
  }

  ChatMessage({
    this.id,
    this.clientId,
    required this.message,
    required this.isUserMessage,
    this.audioPath,
    required this.timestamp,
    this.profileId,
    this.imagePaths,
    this.imageUrls,
    this.filePaths,
    this.isWelcomeMessage,
    this.conversationId,
    this.locationResults,
    this.messageType = MessageType.normal,
  });

  Map<String, dynamic> toMap() {
    // Debug: Log filePaths serialization
    // print('[ChatMessage] toMap() called with filePaths: $filePaths');

    final map = {
      'id': id,
      'client_id': clientId,
      'message': message,
      'is_user_message': isUserMessage ? 1 : 0,
      'audio_path': audioPath,
      'timestamp': timestamp,
      'profile_id': profileId,
      'image_paths': imagePaths != null ? jsonEncode(imagePaths) : null,
      'image_urls': imageUrls != null ? jsonEncode(imageUrls) : null,
      'file_paths': filePaths != null ? jsonEncode(filePaths) : null,
      'is_welcome_message': isWelcomeMessage != null && isWelcomeMessage!
          ? 1
          : 0,
      'conversation_id': conversationId,
      'location_results': locationResults != null
          ? jsonEncode(locationResults!.map((r) => r.toJson()).toList())
          : null,
      'message_type': messageType.index,
    };

    // Debug: Log the serialized file_paths field
    // print('[ChatMessage] Serialized file_paths field: ${map['file_paths']}');

    return map;
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final storedMessageType = map['message_type'];
    final messageTypeIndex = storedMessageType is int
        ? storedMessageType
        : null;
    final messageType =
        messageTypeIndex != null &&
            messageTypeIndex >= 0 &&
            messageTypeIndex < MessageType.values.length
        ? MessageType.values[messageTypeIndex]
        : MessageType.normal;
    return ChatMessage(
      id: map['id'],
      clientId: map['client_id'] as String?,
      message: map['message'],
      isUserMessage: map['is_user_message'] == 1,
      audioPath: map['audio_path'],
      timestamp: map['timestamp'],
      profileId: map['profile_id'],
      imagePaths: map['image_paths'] != null
          ? List<String>.from(jsonDecode(map['image_paths']))
          : null,
      imageUrls: map['image_urls'] != null
          ? List<String>.from(jsonDecode(map['image_urls']))
          : null,
      filePaths: map['file_paths'] != null
          ? List<String>.from(jsonDecode(map['file_paths']))
          : null,
      isWelcomeMessage: map['is_welcome_message'] == 1,
      conversationId: map['conversation_id'],
      locationResults: map['location_results'] != null
          ? (jsonDecode(map['location_results']) as List)
                .map((item) => PlaceResult.fromStoredJson(item))
                .toList()
          : null,
      messageType: messageType,
    );
  }

  /// Convert to Supabase format
  Map<String, dynamic> toSupabase(String conversationUuid) {
    return {
      'client_id': clientId,
      'conversation_id': conversationUuid,
      'content': message,
      'is_ai': !isUserMessage, // Invert for Supabase
      'image_urls': imageUrls, // Remote URLs/private Storage references
      'metadata': {
        'is_welcome_message': isWelcomeMessage ?? false,
        'message_type': messageType.name,
        if (locationResults != null)
          'location_results': locationResults!
              .map((result) => result.toJson())
              .toList(),
      },
      'created_at': timestamp,
    };
  }

  /// Create from Supabase data
  factory ChatMessage.fromSupabase(
    Map<String, dynamic> data,
    int localConversationId, {
    required int profileId,
  }) {
    final metadata = data['metadata'] is Map
        ? Map<String, dynamic>.from(data['metadata'] as Map)
        : const <String, dynamic>{};
    final messageTypeName = metadata['message_type'] as String?;
    final messageType = MessageType.values
        .where((value) => value.name == messageTypeName)
        .firstOrNull;
    final storedLocations = metadata['location_results'];

    return ChatMessage(
      clientId: data['client_id'] as String?,
      message: data['content'] as String,
      isUserMessage: !(data['is_ai'] as bool? ?? false), // Invert from Supabase
      timestamp: data['created_at'] as String,
      conversationId: localConversationId,
      imageUrls: data['image_urls'] != null
          ? List<String>.from(data['image_urls'] as List)
          : null,
      profileId: profileId,
      isWelcomeMessage: metadata['is_welcome_message'] as bool? ?? false,
      locationResults: storedLocations is List
          ? storedLocations
                .map((item) => PlaceResult.fromStoredJson(item))
                .toList()
          : null,
      messageType: messageType ?? MessageType.normal,
    );
  }

  /// Copy with method for updating fields
  ChatMessage copyWith({
    int? id,
    String? clientId,
    String? message,
    bool? isUserMessage,
    String? audioPath,
    String? timestamp,
    int? profileId,
    List<String>? imagePaths,
    List<String>? imageUrls,
    List<String>? filePaths,
    bool? isWelcomeMessage,
    int? conversationId,
    List<PlaceResult>? locationResults,
    MessageType? messageType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      message: message ?? this.message,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      audioPath: audioPath ?? this.audioPath,
      timestamp: timestamp ?? this.timestamp,
      profileId: profileId ?? this.profileId,
      imagePaths: imagePaths ?? this.imagePaths,
      imageUrls: imageUrls ?? this.imageUrls,
      filePaths: filePaths ?? this.filePaths,
      isWelcomeMessage: isWelcomeMessage ?? this.isWelcomeMessage,
      conversationId: conversationId ?? this.conversationId,
      locationResults: locationResults ?? this.locationResults,
      messageType: messageType ?? this.messageType,
    );
  }
}
