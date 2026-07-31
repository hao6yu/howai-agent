import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/foundation.dart';

import 'elevenlabs_agent_service.dart';
import 'voice_audio_route_service.dart';
import 'voice_session_service.dart';

class ElevenLabsVoiceSessionService implements VoiceSessionService {
  ElevenLabsVoiceSessionService({
    required VoiceSessionCallbacks callbacks,
    ElevenLabsAgentService? agentService,
    VoiceAudioRouteSetter? audioRouteSetter,
  })  : _callbacks = callbacks,
        _agentService = agentService ?? ElevenLabsAgentService(),
        _audioRouteSetter =
            audioRouteSetter ?? VoiceAudioRouteService.setSpeakerphoneEnabled;

  final VoiceSessionCallbacks _callbacks;
  final ElevenLabsAgentService _agentService;
  final VoiceAudioRouteSetter _audioRouteSetter;
  ConversationClient? _client;
  bool _connected = false;
  bool _closing = false;
  bool _userTurnInProgress = false;

  @override
  VoiceSessionProvider get provider => VoiceSessionProvider.elevenLabs;

  @override
  bool get isConnected => _connected;

  @override
  bool get supportsVision => false;

  @override
  Future<void> connect(VoiceSessionStartOptions options) async {
    final preset = options.voice == 'marin'
        ? ElevenLabsVoicePreset.female
        : ElevenLabsVoicePreset.male;
    final agentId = _agentService.agentIdForVoice(voice: preset);
    if (agentId == null) {
      throw const VoiceSessionException(
        'The backup voice service is not configured.',
        code: 'legacy_not_configured',
      );
    }

    _closing = false;
    _userTurnInProgress = false;
    _client = ConversationClient(
      callbacks: ConversationCallbacks(
        onConnect: ({required String conversationId}) {
          _connected = true;
          _callbacks.onConnected();
        },
        onDisconnect: (details) {
          final wasConnected = _connected;
          _connected = false;
          if (wasConnected && !_closing) {
            _callbacks.onDisconnected('provider_disconnected');
          }
        },
        onStatusChange: ({required ConversationStatus status}) {
          if (status == ConversationStatus.disconnected ||
              status == ConversationStatus.disconnecting) {
            _connected = false;
          }
        },
        onModeChange: ({required ConversationMode mode}) {
          if (mode == ConversationMode.speaking) {
            _userTurnInProgress = false;
          }
          _callbacks.onSpeakingChanged(mode == ConversationMode.speaking);
        },
        onInterruption: (_) {
          _notifyUserSpeechStarted();
          _callbacks.onSpeakingChanged(false);
        },
        onMessage: ({required String message, required Role source}) {
          if (message.trim().isEmpty) return;
          _callbacks.onTranscript(
            VoiceTranscriptUpdate(
              text: message,
              isUser: source == Role.user,
              isFinal: true,
            ),
          );
        },
        onUserTranscript: ({
          required String transcript,
          required int eventId,
        }) {
          if (transcript.trim().isEmpty) return;
          _notifyUserSpeechStarted();
          _callbacks.onTranscript(
            VoiceTranscriptUpdate(
              text: transcript,
              isUser: true,
              isFinal: true,
              eventId: eventId.toString(),
            ),
          );
        },
        onTentativeUserTranscript: ({
          required String transcript,
          required int eventId,
        }) {
          if (transcript.trim().isEmpty) return;
          _notifyUserSpeechStarted();
          _callbacks.onTranscript(
            VoiceTranscriptUpdate(
              text: transcript,
              isUser: true,
              isFinal: false,
              eventId: eventId.toString(),
            ),
          );
        },
        onError: (message, [context]) {
          _callbacks.onError(message);
        },
        onEndCallRequested: () {
          _callbacks.onDisconnected('agent_end_call_requested');
        },
      ),
    );

    final variables = <String, dynamic>{'user_name': options.userName};
    if (options.interestTags?.isNotEmpty == true) {
      variables['interest_tags'] = options.interestTags;
    }
    if (options.communicationStyle?.isNotEmpty == true) {
      variables['communication_style'] = options.communicationStyle;
    }
    try {
      await _client!.startSession(
        agentId: agentId,
        userId: options.userId,
        dynamicVariables: variables,
      );
      try {
        await setSpeakerphoneEnabled(options.speakerphoneEnabled);
      } catch (error) {
        debugPrint('Could not apply the initial backup audio route: $error');
      }
    } catch (error) {
      await dispose();
      throw VoiceSessionException(
        'Could not connect to the backup voice service.',
        code: 'legacy_connection_failed',
      );
    }
  }

  @override
  Future<void> setMuted(bool muted) async {
    await _client?.setMicMuted(muted);
  }

  void _notifyUserSpeechStarted() {
    if (_userTurnInProgress) return;
    _userTurnInProgress = true;
    _callbacks.onUserSpeechStarted();
  }

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    // LiveKit already captures voice with AEC/noise suppression/AGC. Tearing
    // down its microphone track for a route change can lose real speech and
    // force the echo canceller to retrain.
    await _audioRouteSetter(enabled);
  }

  @override
  Future<void> sendToolResult({
    required String callId,
    required Map<String, dynamic> result,
  }) async {
    throw const VoiceSessionException(
      'Tools are not available on the backup voice service.',
      code: 'legacy_tools_unavailable',
    );
  }

  @override
  Future<void> sendConversationEvent({required String message}) async {
    // The backup provider does not expose client-authored conversation items.
  }

  @override
  Future<void> sendImageFrame({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
    String? message,
    bool requestResponse = false,
  }) async {
    throw const VoiceSessionException(
      'Vision is available with HowAI Realtime voice.',
      code: 'legacy_vision_unavailable',
    );
  }

  @override
  Future<void> disconnect({String reason = 'client_ended'}) async {
    _closing = true;
    _connected = false;
    await _client?.endSession();
    _userTurnInProgress = false;
    _closing = false;
  }

  @override
  Future<void> dispose() async {
    _closing = true;
    _connected = false;
    _client?.dispose();
    _client = null;
    _userTurnInProgress = false;
  }
}
