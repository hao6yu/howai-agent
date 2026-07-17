import 'dart:async';
import 'dart:typed_data';

enum VoiceSessionProvider {
  openAIRealtime,
  elevenLabs,
}

class VoiceTranscriptUpdate {
  const VoiceTranscriptUpdate({
    required this.text,
    required this.isUser,
    required this.isFinal,
    this.eventId,
  });

  final String text;
  final bool isUser;
  final bool isFinal;
  final String? eventId;
}

class VoiceToolCall {
  const VoiceToolCall({
    required this.callId,
    required this.name,
    required this.arguments,
  });

  final String callId;
  final String name;
  final Map<String, dynamic> arguments;
}

class VoiceSessionStartOptions {
  const VoiceSessionStartOptions({
    required this.voice,
    required this.userId,
    required this.userName,
    required this.timezone,
    required this.localDateTime,
    this.interestTags,
    this.communicationStyle,
  });

  final String voice;
  final String userId;
  final String userName;
  final String timezone;
  final String localDateTime;
  final String? interestTags;
  final String? communicationStyle;
}

class VoiceSessionCallbacks {
  const VoiceSessionCallbacks({
    required this.onConnected,
    required this.onDisconnected,
    required this.onUserSpeechStarted,
    required this.onTranscript,
    required this.onSpeakingChanged,
    required this.onError,
    required this.onToolCall,
  });

  final void Function() onConnected;
  final void Function(String reason) onDisconnected;
  final void Function() onUserSpeechStarted;
  final void Function(VoiceTranscriptUpdate update) onTranscript;
  final void Function(bool speaking) onSpeakingChanged;
  final void Function(String message) onError;
  final Future<void> Function(VoiceToolCall call) onToolCall;
}

class VoiceSessionException implements Exception {
  const VoiceSessionException(
    this.message, {
    this.code,
    this.fallbackAllowed = false,
  });

  final String message;
  final String? code;
  final bool fallbackAllowed;

  @override
  String toString() => message;
}

abstract class VoiceSessionService {
  VoiceSessionProvider get provider;
  bool get isConnected;
  bool get supportsVision;

  Future<void> connect(VoiceSessionStartOptions options);
  Future<void> setMuted(bool muted);
  Future<void> sendToolResult({
    required String callId,
    required Map<String, dynamic> result,
  });
  Future<void> sendConversationEvent({required String message});
  Future<void> sendImageFrame({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
    String? message,
    bool requestResponse = false,
  });
  Future<void> disconnect({String reason = 'client_ended'});
  Future<void> dispose();
}
