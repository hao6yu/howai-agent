import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'voice_session_service.dart';

class RealtimeTurnDetectionConfiguration {
  const RealtimeTurnDetectionConfiguration({
    required this.threshold,
    required this.prefixPaddingMs,
    required this.silenceDurationMs,
  });

  factory RealtimeTurnDetectionConfiguration.fromJson(
    Map<String, dynamic> json,
  ) {
    final threshold = json['threshold'];
    final prefixPaddingMs = json['prefix_padding_ms'];
    final silenceDurationMs = json['silence_duration_ms'];
    if (json['type'] != 'server_vad' ||
        threshold is! num ||
        threshold < 0 ||
        threshold > 1 ||
        prefixPaddingMs is! num ||
        prefixPaddingMs < 0 ||
        prefixPaddingMs > 5000 ||
        silenceDurationMs is! num ||
        silenceDurationMs < 100 ||
        silenceDurationMs > 5000) {
      throw const FormatException('Invalid Realtime turn detection');
    }
    return RealtimeTurnDetectionConfiguration(
      threshold: threshold.toDouble(),
      prefixPaddingMs: prefixPaddingMs.toInt(),
      silenceDurationMs: silenceDurationMs.toInt(),
    );
  }

  final double threshold;
  final int prefixPaddingMs;
  final int silenceDurationMs;

  Map<String, dynamic> toJson() {
    return {
      'type': 'server_vad',
      'threshold': threshold,
      'prefix_padding_ms': prefixPaddingMs,
      'silence_duration_ms': silenceDurationMs,
      'create_response': true,
      'interrupt_response': true,
    };
  }
}

class RealtimeSessionMaterial {
  const RealtimeSessionMaterial({
    required this.sessionId,
    required this.clientSecret,
    required this.clientSecretExpiresAt,
    required this.model,
    required this.voice,
    required this.cohort,
    required this.maxDurationSeconds,
    required this.turnDetection,
  });

  factory RealtimeSessionMaterial.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing $key');
      }
      return value.trim();
    }

    final expiresAt = json['client_secret_expires_at'];
    final maxDuration = json['max_duration_seconds'];
    final rawTurnDetection = json['turn_detection'];
    if (expiresAt is! num || maxDuration is! num || rawTurnDetection is! Map) {
      throw const FormatException('Invalid Realtime session limits');
    }
    final cohort = requiredString('cohort');
    if (cohort != 'anonymous' && cohort != 'free' && cohort != 'paid') {
      throw const FormatException('Invalid Realtime session cohort');
    }
    return RealtimeSessionMaterial(
      sessionId: requiredString('session_id'),
      clientSecret: requiredString('client_secret'),
      clientSecretExpiresAt:
          DateTime.fromMillisecondsSinceEpoch(expiresAt.toInt() * 1000),
      model: requiredString('model'),
      voice: requiredString('voice'),
      cohort: cohort,
      maxDurationSeconds: maxDuration.toInt(),
      turnDetection: RealtimeTurnDetectionConfiguration.fromJson(
        Map<String, dynamic>.from(rawTurnDetection),
      ),
    );
  }

  final String sessionId;
  final String clientSecret;
  final DateTime clientSecretExpiresAt;
  final String model;
  final String voice;
  final String cohort;
  final int maxDurationSeconds;
  final RealtimeTurnDetectionConfiguration turnDetection;

  bool get isPaid => cohort == 'paid';
}

class OpenAIRealtimeVoiceService implements VoiceSessionService {
  OpenAIRealtimeVoiceService({
    required VoiceSessionCallbacks callbacks,
    SupabaseClient? supabaseClient,
    http.Client? httpClient,
  })  : _callbacks = callbacks,
        _supabase = supabaseClient ?? Supabase.instance.client,
        _http = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  static final Uri _callsUri =
      Uri.parse('https://api.openai.com/v1/realtime/calls');
  static const Duration _brokerTimeout = Duration(seconds: 15);
  static const Duration _connectionTimeout = Duration(seconds: 20);
  static const Duration _transientDisconnectGrace = Duration(seconds: 6);

  final VoiceSessionCallbacks _callbacks;
  final SupabaseClient _supabase;
  final http.Client _http;
  final bool _ownsHttpClient;

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  MediaStreamTrack? _microphoneTrack;
  RealtimeSessionMaterial? _material;
  Completer<void>? _connectedCompleter;
  bool _connected = false;
  bool _closing = false;
  bool _disposed = false;
  bool _disconnectedCallbackSent = false;
  bool _initialGreetingSent = false;
  bool _initialGreetingInProgress = false;
  DateTime? _connectedAt;
  Timer? _disconnectGraceTimer;
  Timer? _initialGreetingRestoreTimer;
  final Set<String> _seenToolCalls = <String>{};
  final Map<String, StringBuffer> _assistantTranscriptBuffers = {};

  @override
  VoiceSessionProvider get provider => VoiceSessionProvider.openAIRealtime;

  @override
  bool get isConnected => _connected;

  @override
  bool get supportsVision => true;

  int get maxDurationSeconds => _material?.maxDurationSeconds ?? 0;
  bool get isPaid => _material?.isPaid ?? false;

  @override
  Future<void> connect(VoiceSessionStartOptions options) async {
    if (_disposed) {
      throw const VoiceSessionException(
        'The voice session has already been closed.',
        code: 'disposed',
      );
    }
    if (_connected || _connectedCompleter != null) return;

    _closing = false;
    _disconnectedCallbackSent = false;
    _initialGreetingSent = false;
    _initialGreetingInProgress = false;
    _initialGreetingRestoreTimer?.cancel();
    _initialGreetingRestoreTimer = null;
    _connectedCompleter = Completer<void>();
    try {
      final material = await _createSession(options);
      if (material.clientSecretExpiresAt.isBefore(DateTime.now())) {
        throw const VoiceSessionException(
          'The temporary voice credential expired before connection.',
          code: 'expired_client_secret',
        );
      }
      _material = material;

      final peer = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
        'iceServers': const <Map<String, dynamic>>[],
      });
      _peerConnection = peer;
      peer.onConnectionState = _handlePeerConnectionState;

      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      _localStream = stream;
      final audioTracks = stream.getAudioTracks();
      if (audioTracks.isEmpty) {
        throw const VoiceSessionException(
          'No microphone audio track was available.',
          code: 'microphone_unavailable',
        );
      }
      _microphoneTrack = audioTracks.first;
      await peer.addTrack(_microphoneTrack!, stream);

      final channel = await peer.createDataChannel(
        'oai-events',
        RTCDataChannelInit()..ordered = true,
      );
      _dataChannel = channel;
      channel.onDataChannelState = _handleDataChannelState;
      channel.onMessage = _handleDataChannelMessage;

      final offer = await peer.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await peer.setLocalDescription(offer);
      final sdp = offer.sdp;
      if (sdp == null || sdp.isEmpty) {
        throw const VoiceSessionException(
          'The device could not create a voice connection.',
          code: 'missing_offer',
        );
      }

      final answer = await _http
          .post(
            _callsUri,
            headers: {
              'Authorization': 'Bearer ${material.clientSecret}',
              'Content-Type': 'application/sdp',
            },
            body: sdp,
          )
          .timeout(_connectionTimeout);
      if (answer.statusCode < 200 || answer.statusCode >= 300) {
        throw VoiceSessionException(
          'OpenAI Realtime rejected the voice connection.',
          code: 'sdp_${answer.statusCode}',
        );
      }
      final providerCallId = providerCallIdFromLocation(
        answer.headers['location'],
      );
      if (providerCallId == null) {
        throw const VoiceSessionException(
          'OpenAI Realtime did not return a call identifier.',
          code: 'missing_provider_call_id',
        );
      }
      await _registerProviderCall(
        sessionId: material.sessionId,
        providerCallId: providerCallId,
      );
      await peer.setRemoteDescription(
        RTCSessionDescription(answer.body, 'answer'),
      );
      await Helper.setSpeakerphoneOnButPreferBluetooth();
      await _connectedCompleter!.future.timeout(_connectionTimeout);
    } on VoiceSessionException {
      await _cleanup(endReason: 'connection_failed', reportCompletion: true);
      rethrow;
    } on FunctionException catch (error) {
      await _cleanup(endReason: 'broker_failed', reportCompletion: false);
      final details = error.details;
      final code = details is Map ? details['code']?.toString() : null;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : 'Realtime voice is temporarily unavailable.';
      throw VoiceSessionException(
        message,
        code: code,
        fallbackAllowed: code == 'rollout_inactive',
      );
    } on TimeoutException {
      await _cleanup(endReason: 'connection_timeout', reportCompletion: true);
      throw const VoiceSessionException(
        'The Realtime voice connection timed out.',
        code: 'connection_timeout',
      );
    } catch (error) {
      debugPrint('OpenAI Realtime connect failed: $error');
      await _cleanup(endReason: 'connection_failed', reportCompletion: true);
      throw const VoiceSessionException(
        'Could not connect to Realtime voice.',
        code: 'connection_failed',
      );
    } finally {
      if (!_connected) _connectedCompleter = null;
    }
  }

  Future<RealtimeSessionMaterial> _createSession(
    VoiceSessionStartOptions options,
  ) async {
    final response = await _supabase.functions.invoke(
      'realtime-session',
      body: {
        'operation': 'create',
        'voice': options.voice,
        'timezone': options.timezone,
        'local_datetime': options.localDateTime,
      },
    ).timeout(_brokerTimeout);
    if (response.data is! Map) {
      throw const VoiceSessionException(
        'The Realtime session broker returned invalid data.',
        code: 'invalid_broker_response',
      );
    }
    return RealtimeSessionMaterial.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @visibleForTesting
  static String? providerCallIdFromLocation(String? location) {
    if (location == null || location.trim().isEmpty) return null;
    final direct = RegExp(r'rtc_[A-Za-z0-9_-]{1,180}').firstMatch(location);
    return direct?.group(0);
  }

  Future<void> _registerProviderCall({
    required String sessionId,
    required String providerCallId,
  }) async {
    await _supabase.functions.invoke(
      'realtime-session',
      body: {
        'operation': 'register_call',
        'session_id': sessionId,
        'provider_call_id': providerCallId,
      },
    ).timeout(_brokerTimeout);
  }

  void _handleDataChannelState(RTCDataChannelState state) {
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      _disconnectGraceTimer?.cancel();
      _disconnectGraceTimer = null;
      if (!_connected) {
        _connected = true;
        _connectedAt = DateTime.now();
        _connectedCompleter?.complete();
        _callbacks.onConnected();
        unawaited(_sendInitialGreeting());
      }
      return;
    }
    if (state == RTCDataChannelState.RTCDataChannelClosed && !_closing) {
      _notifyDisconnected('data_channel_closed');
    }
  }

  @visibleForTesting
  static Map<String, dynamic> initialGreetingEvent() {
    return {
      'type': 'response.create',
      'response': {
        'instructions':
            'Begin the voice call now. Say exactly: "Hi, I’m HowAI. How can '
                'I help today?" Do not add anything else.',
        'output_modalities': ['audio'],
        'tool_choice': 'none',
        'max_output_tokens': 256,
        'metadata': {
          'response_purpose': 'call_greeting',
        },
      },
    };
  }

  @visibleForTesting
  static Map<String, dynamic> suspendTurnDetectionEvent() {
    return {
      'type': 'session.update',
      'session': {
        'type': 'realtime',
        'audio': {
          'input': {'turn_detection': null},
        },
      },
    };
  }

  @visibleForTesting
  static Map<String, dynamic> restoreTurnDetectionEvent(
    RealtimeTurnDetectionConfiguration configuration,
  ) {
    return {
      'type': 'session.update',
      'session': {
        'type': 'realtime',
        'audio': {
          'input': {'turn_detection': configuration.toJson()},
        },
      },
    };
  }

  Future<void> _sendInitialGreeting() async {
    if (_initialGreetingSent || _closing || _disposed) return;
    final turnDetection = _material?.turnDetection;
    if (turnDetection == null) return;
    _initialGreetingSent = true;
    _initialGreetingInProgress = true;
    try {
      await _sendEvent(suspendTurnDetectionEvent());
      await _sendEvent(initialGreetingEvent());
      _initialGreetingRestoreTimer?.cancel();
      _initialGreetingRestoreTimer = Timer(
        const Duration(seconds: 12),
        () => unawaited(_restoreTurnDetectionAfterGreeting()),
      );
    } catch (error) {
      _initialGreetingSent = false;
      await _restoreTurnDetectionAfterGreeting();
      debugPrint('Could not start the Realtime greeting: $error');
    }
  }

  Future<void> _restoreTurnDetectionAfterGreeting() async {
    if (!_initialGreetingInProgress) return;
    _initialGreetingInProgress = false;
    _initialGreetingRestoreTimer?.cancel();
    _initialGreetingRestoreTimer = null;
    final turnDetection = _material?.turnDetection;
    if (turnDetection == null || _closing || _disposed) return;
    try {
      await _sendEvent({'type': 'input_audio_buffer.clear'});
      await _sendEvent(restoreTurnDetectionEvent(turnDetection));
    } catch (error) {
      debugPrint('Could not restore Realtime turn detection: $error');
    }
  }

  void _handlePeerConnectionState(RTCPeerConnectionState state) {
    if (_closing) return;
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      _disconnectGraceTimer?.cancel();
      _disconnectGraceTimer = null;
      return;
    }
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      _callbacks.onError('The Realtime voice connection failed.');
      _notifyDisconnected('peer_connection_failed');
    } else if (state ==
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      _scheduleTransientDisconnect();
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
      _notifyDisconnected('peer_connection_closed');
    }
  }

  void _scheduleTransientDisconnect() {
    _disconnectGraceTimer?.cancel();
    _disconnectGraceTimer = Timer(_transientDisconnectGrace, () {
      if (_closing || _disposed) return;
      _notifyDisconnected('peer_connection_disconnected');
    });
  }

  void _notifyDisconnected(String reason) {
    _disconnectGraceTimer?.cancel();
    _disconnectGraceTimer = null;
    _connected = false;
    if (_disconnectedCallbackSent) return;
    _disconnectedCallbackSent = true;
    _callbacks.onDisconnected(reason);
    unawaited(
      _cleanup(endReason: reason, reportCompletion: true),
    );
  }

  void _handleDataChannelMessage(RTCDataChannelMessage message) {
    if (message.isBinary) return;
    try {
      final decoded = jsonDecode(message.text);
      if (decoded is! Map) return;
      _handleServerEvent(Map<String, dynamic>.from(decoded));
    } catch (error) {
      debugPrint('Ignored malformed Realtime event: $error');
    }
  }

  @visibleForTesting
  void handleServerEventForTest(Map<String, dynamic> event) {
    _handleServerEvent(event);
  }

  void _handleServerEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    switch (type) {
      case 'input_audio_buffer.speech_started':
        _callbacks.onUserSpeechStarted();
        _callbacks.onSpeakingChanged(false);
      case 'conversation.item.input_audio_transcription.completed':
        final transcript = event['transcript']?.toString().trim() ?? '';
        if (transcript.isNotEmpty) {
          _callbacks.onTranscript(
            VoiceTranscriptUpdate(
              text: transcript,
              isUser: true,
              isFinal: true,
              eventId: event['event_id']?.toString(),
            ),
          );
        }
      case 'response.output_audio_transcript.delta':
        _callbacks.onSpeakingChanged(true);
        final delta = event['delta']?.toString() ?? '';
        if (delta.isEmpty) return;
        final itemId = event['item_id']?.toString() ?? 'assistant';
        final buffer = _assistantTranscriptBuffers.putIfAbsent(
          itemId,
          StringBuffer.new,
        )..write(delta);
        _callbacks.onTranscript(
          VoiceTranscriptUpdate(
            text: buffer.toString(),
            isUser: false,
            isFinal: false,
            eventId: itemId,
          ),
        );
      case 'response.output_audio_transcript.done':
        _callbacks.onSpeakingChanged(false);
        final itemId = event['item_id']?.toString() ?? 'assistant';
        final transcript =
            (event['transcript']?.toString().trim().isNotEmpty == true)
                ? event['transcript'].toString().trim()
                : _assistantTranscriptBuffers[itemId]?.toString().trim() ?? '';
        _assistantTranscriptBuffers.remove(itemId);
        if (transcript.isNotEmpty) {
          _callbacks.onTranscript(
            VoiceTranscriptUpdate(
              text: transcript,
              isUser: false,
              isFinal: true,
              eventId: itemId,
            ),
          );
        }
      case 'output_audio_buffer.started':
        _callbacks.onSpeakingChanged(true);
      case 'output_audio_buffer.stopped':
      case 'output_audio_buffer.cleared':
        _callbacks.onSpeakingChanged(false);
        if (_initialGreetingInProgress) {
          unawaited(_restoreTurnDetectionAfterGreeting());
        }
      case 'response.done':
        _handleCompletedResponse(event);
      case 'error':
        if (_initialGreetingInProgress) {
          unawaited(_restoreTurnDetectionAfterGreeting());
        }
        final error = event['error'];
        final message =
            error is Map ? error['message']?.toString() : error?.toString();
        _callbacks.onError(
          message?.trim().isNotEmpty == true
              ? message!.trim()
              : 'Realtime voice reported an error.',
        );
    }
  }

  void _handleCompletedResponse(Map<String, dynamic> event) {
    final response = event['response'];
    if (response is! Map || response['output'] is! List) return;
    for (final rawItem in response['output'] as List) {
      if (rawItem is! Map || rawItem['type'] != 'function_call') continue;
      final callId = rawItem['call_id']?.toString().trim() ?? '';
      final name = rawItem['name']?.toString().trim() ?? '';
      if (callId.isEmpty || name.isEmpty || !_seenToolCalls.add(callId)) {
        continue;
      }
      try {
        final rawArguments = rawItem['arguments'];
        final decoded =
            rawArguments is String ? jsonDecode(rawArguments) : rawArguments;
        if (decoded is! Map) throw const FormatException('Invalid arguments');
        unawaited(
          _dispatchToolCall(
            VoiceToolCall(
              callId: callId,
              name: name,
              arguments: Map<String, dynamic>.from(decoded),
            ),
          ),
        );
      } catch (_) {
        unawaited(
          _sendFailedToolResult(
            callId: callId,
            message: 'The proposed action was invalid.',
          ),
        );
      }
    }
  }

  Future<void> _dispatchToolCall(VoiceToolCall call) async {
    try {
      await _callbacks.onToolCall(call);
    } catch (error) {
      debugPrint('Realtime tool callback failed: $error');
      await _sendFailedToolResult(
        callId: call.callId,
        message: 'The proposed action could not be prepared.',
      );
    }
  }

  Future<void> _sendFailedToolResult({
    required String callId,
    required String message,
  }) async {
    try {
      await sendToolResult(
        callId: callId,
        result: {
          'status': 'failed',
          'message': message,
        },
      );
    } catch (error) {
      debugPrint('Could not return failed Realtime tool result: $error');
    }
  }

  @override
  Future<void> setMuted(bool muted) async {
    final track = _microphoneTrack;
    if (track == null) return;
    track.enabled = !muted;
    await Helper.setMicrophoneMute(muted, track);
  }

  @override
  Future<void> sendToolResult({
    required String callId,
    required Map<String, dynamic> result,
  }) async {
    await _sendEvent({
      'type': 'conversation.item.create',
      'item': {
        'type': 'function_call_output',
        'call_id': callId,
        'output': jsonEncode(result),
      },
    });
    await _sendEvent({'type': 'response.create'});
  }

  @override
  Future<void> sendConversationEvent({required String message}) async {
    final normalized = message.trim();
    if (normalized.isEmpty) return;
    await _sendEvent({
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': 'user',
        'content': [
          {
            'type': 'input_text',
            'text': '[Trusted app event] $normalized',
          },
        ],
      },
    });
    await _sendEvent({'type': 'response.create'});
  }

  @visibleForTesting
  static Map<String, dynamic> imageInputEvent({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
    String? message,
  }) {
    final normalizedMimeType = switch (mimeType.trim().toLowerCase()) {
      'image/png' => 'image/png',
      'image/webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final normalizedMessage = message?.trim();
    return {
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': 'user',
        'content': [
          if (normalizedMessage?.isNotEmpty == true)
            {
              'type': 'input_text',
              'text': normalizedMessage,
            },
          {
            'type': 'input_image',
            'image_url':
                'data:$normalizedMimeType;base64,${base64Encode(bytes)}',
          },
        ],
      },
    };
  }

  @override
  Future<void> sendImageFrame({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
    String? message,
    bool requestResponse = false,
  }) async {
    if (bytes.isEmpty) {
      throw const VoiceSessionException(
        'The camera frame was empty.',
        code: 'empty_image_frame',
      );
    }
    await _sendEvent(
      imageInputEvent(
        bytes: bytes,
        mimeType: mimeType,
        message: message,
      ),
    );
    if (requestResponse) {
      await _sendEvent({'type': 'response.create'});
    }
  }

  Future<void> _sendEvent(Map<String, dynamic> event) async {
    final channel = _dataChannel;
    if (channel == null ||
        channel.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw const VoiceSessionException(
        'The voice control channel is not connected.',
        code: 'data_channel_unavailable',
      );
    }
    await channel.send(RTCDataChannelMessage(jsonEncode(event)));
  }

  @override
  Future<void> disconnect({String reason = 'client_ended'}) {
    return _cleanup(endReason: reason, reportCompletion: true);
  }

  Future<void> _cleanup({
    required String endReason,
    required bool reportCompletion,
  }) async {
    if (_closing) return;
    _closing = true;
    _connected = false;

    final session = _material;
    final connectedAt = _connectedAt;
    _material = null;
    _connectedAt = null;
    final dataChannel = _dataChannel;
    _dataChannel = null;
    final peer = _peerConnection;
    _peerConnection = null;
    final stream = _localStream;
    _localStream = null;
    _microphoneTrack = null;
    _connectedCompleter = null;
    _disconnectGraceTimer?.cancel();
    _disconnectGraceTimer = null;
    _initialGreetingRestoreTimer?.cancel();
    _initialGreetingRestoreTimer = null;
    _initialGreetingInProgress = false;
    _assistantTranscriptBuffers.clear();

    try {
      await dataChannel?.close();
    } catch (_) {}
    try {
      for (final track in stream?.getTracks() ?? const <MediaStreamTrack>[]) {
        await track.stop();
      }
      await stream?.dispose();
    } catch (_) {}
    try {
      await peer?.close();
      await peer?.dispose();
    } catch (_) {}

    if (reportCompletion && session != null) {
      try {
        await _supabase.functions.invoke(
          'realtime-session',
          body: {
            'operation': 'complete',
            'session_id': session.sessionId,
            'duration_seconds': connectedAt == null
                ? 0
                : DateTime.now().difference(connectedAt).inSeconds,
            'end_reason': endReason,
          },
        ).timeout(const Duration(seconds: 8));
      } catch (error) {
        debugPrint('Could not finalize Realtime voice session: $error');
      }
    }
    _closing = false;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await _cleanup(endReason: 'disposed', reportCompletion: true);
    _disposed = true;
    if (_ownsHttpClient) _http.close();
  }
}
