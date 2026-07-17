import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/openai_realtime_voice_service.dart';
import 'package:haogpt/services/voice_session_service.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('RealtimeSessionMaterial', () {
    test('parses the short-lived broker response', () {
      final material = RealtimeSessionMaterial.fromJson({
        'session_id': 'session-1',
        'client_secret': 'ek_test',
        'client_secret_expires_at': 1800000000,
        'model': 'gpt-realtime-2.1',
        'voice': 'marin',
        'cohort': 'paid',
        'max_duration_seconds': 240,
        'turn_detection': {
          'type': 'server_vad',
          'threshold': 0.6,
          'prefix_padding_ms': 300,
          'silence_duration_ms': 450,
          'create_response': true,
          'interrupt_response': true,
        },
      });

      expect(material.sessionId, 'session-1');
      expect(material.clientSecret, 'ek_test');
      expect(material.model, 'gpt-realtime-2.1');
      expect(material.voice, 'marin');
      expect(material.cohort, 'paid');
      expect(material.isPaid, isTrue);
      expect(material.maxDurationSeconds, 240);
      expect(material.turnDetection.threshold, 0.6);
      expect(
        material.clientSecretExpiresAt,
        DateTime.fromMillisecondsSinceEpoch(1800000000 * 1000),
      );
    });

    test('rejects incomplete broker responses', () {
      expect(
        () => RealtimeSessionMaterial.fromJson({
          'session_id': 'session-1',
          'client_secret_expires_at': 1800000000,
          'model': 'gpt-realtime-2.1',
          'voice': 'marin',
          'cohort': 'free',
          'max_duration_seconds': 240,
          'turn_detection': {
            'type': 'server_vad',
            'threshold': 0.6,
            'prefix_padding_ms': 300,
            'silence_duration_ms': 450,
          },
        }),
        throwsFormatException,
      );
    });

    test('rejects an unknown broker cohort', () {
      expect(
        () => RealtimeSessionMaterial.fromJson({
          'session_id': 'session-1',
          'client_secret': 'ek_test',
          'client_secret_expires_at': 1800000000,
          'model': 'gpt-realtime-2.1',
          'voice': 'marin',
          'cohort': 'enterprise',
          'max_duration_seconds': 240,
          'turn_detection': {
            'type': 'server_vad',
            'threshold': 0.6,
            'prefix_padding_ms': 300,
            'silence_duration_ms': 450,
          },
        }),
        throwsFormatException,
      );
    });
  });

  group('OpenAIRealtimeVoiceService events', () {
    test('extracts the opaque call id from the WebRTC Location header', () {
      expect(
        OpenAIRealtimeVoiceService.providerCallIdFromLocation(
          'https://api.openai.com/v1/realtime/calls/rtc_test-123',
        ),
        'rtc_test-123',
      );
      expect(
        OpenAIRealtimeVoiceService.providerCallIdFromLocation(null),
        isNull,
      );
    });

    late List<VoiceTranscriptUpdate> transcripts;
    late List<bool> speakingChanges;
    late List<VoiceToolCall> toolCalls;
    late List<String> errors;
    late int userSpeechStarts;
    late OpenAIRealtimeVoiceService service;

    setUp(() {
      transcripts = [];
      speakingChanges = [];
      toolCalls = [];
      errors = [];
      userSpeechStarts = 0;
      service = OpenAIRealtimeVoiceService(
        callbacks: VoiceSessionCallbacks(
          onConnected: () {},
          onDisconnected: (_) {},
          onUserSpeechStarted: () => userSpeechStarts += 1,
          onTranscript: transcripts.add,
          onSpeakingChanged: speakingChanges.add,
          onError: errors.add,
          onToolCall: (call) async => toolCalls.add(call),
        ),
        supabaseClient: SupabaseClient(
          'https://example.supabase.co',
          'public-anon-key',
        ),
        httpClient: MockClient((_) async {
          throw StateError('Network requests are not expected in event tests');
        }),
      );
    });

    tearDown(() => service.dispose());

    test('emits a user-turn boundary when speech starts', () {
      service.handleServerEventForTest({
        'type': 'input_audio_buffer.speech_started',
      });

      expect(userSpeechStarts, 1);
      expect(speakingChanges, [false]);
    });

    test('builds a short audio-only opening greeting', () {
      final event = OpenAIRealtimeVoiceService.initialGreetingEvent();
      final response = event['response'] as Map<String, dynamic>;

      expect(event['type'], 'response.create');
      expect(response['output_modalities'], ['audio']);
      expect(response['tool_choice'], 'none');
      expect(response['max_output_tokens'], 256);
      expect(
        response['instructions'].toString(),
        contains('Hi, I’m HowAI'),
      );
    });

    test('builds a Realtime image input without inventing a response', () {
      final event = OpenAIRealtimeVoiceService.imageInputEvent(
        bytes: Uint8List.fromList([1, 2, 3]),
        message: 'Use this frame with my spoken question.',
      );
      final item = event['item'] as Map<String, dynamic>;
      final content = item['content'] as List<dynamic>;

      expect(event['type'], 'conversation.item.create');
      expect(item['role'], 'user');
      expect(content.first, {
        'type': 'input_text',
        'text': 'Use this frame with my spoken question.',
      });
      expect(content.last, {
        'type': 'input_image',
        'image_url': 'data:image/jpeg;base64,AQID',
      });
    });

    test('suspends VAD only for the opening greeting, then restores it', () {
      final configuration = RealtimeTurnDetectionConfiguration.fromJson({
        'type': 'server_vad',
        'threshold': 0.6,
        'prefix_padding_ms': 300,
        'silence_duration_ms': 450,
      });
      final suspended = OpenAIRealtimeVoiceService.suspendTurnDetectionEvent();
      final restored =
          OpenAIRealtimeVoiceService.restoreTurnDetectionEvent(configuration);

      expect(
        (((suspended['session'] as Map)['audio'] as Map)['input']
            as Map)['turn_detection'],
        isNull,
      );
      expect(
        (((restored['session'] as Map)['audio'] as Map)['input']
            as Map)['turn_detection'],
        {
          'type': 'server_vad',
          'threshold': 0.6,
          'prefix_padding_ms': 300,
          'silence_duration_ms': 450,
          'create_response': true,
          'interrupt_response': true,
        },
      );
    });

    test('emits final user transcripts', () {
      service.handleServerEventForTest({
        'type': 'conversation.item.input_audio_transcription.completed',
        'event_id': 'user-event-1',
        'transcript': 'Hello, ¿cómo estás?',
      });

      expect(transcripts, hasLength(1));
      expect(transcripts.single.text, 'Hello, ¿cómo estás?');
      expect(transcripts.single.isUser, isTrue);
      expect(transcripts.single.isFinal, isTrue);
      expect(transcripts.single.eventId, 'user-event-1');
    });

    test('combines assistant transcript deltas before finalizing', () {
      service.handleServerEventForTest({
        'type': 'response.output_audio_transcript.delta',
        'item_id': 'assistant-1',
        'delta': 'Good ',
      });
      service.handleServerEventForTest({
        'type': 'response.output_audio_transcript.delta',
        'item_id': 'assistant-1',
        'delta': 'morning',
      });
      service.handleServerEventForTest({
        'type': 'response.output_audio_transcript.done',
        'item_id': 'assistant-1',
      });

      expect(transcripts.map((entry) => entry.text), [
        'Good ',
        'Good morning',
        'Good morning',
      ]);
      expect(transcripts.last.isFinal, isTrue);
      expect(speakingChanges, [true, true, false]);
    });

    test('dispatches each function call once', () async {
      final event = {
        'type': 'response.done',
        'response': {
          'output': [
            {
              'type': 'function_call',
              'call_id': 'call-1',
              'name': 'reminders_create',
              'arguments': '{"title":"Call Mom","notes":null,"timezone":"UTC",'
                  '"start_local":"2026-07-18T09:00:00",'
                  '"recurrence":null}',
            },
          ],
        },
      };

      service.handleServerEventForTest(event);
      service.handleServerEventForTest(event);
      await Future<void>.delayed(Duration.zero);

      expect(toolCalls, hasLength(1));
      expect(toolCalls.single.callId, 'call-1');
      expect(toolCalls.single.name, 'reminders_create');
      expect(toolCalls.single.arguments['title'], 'Call Mom');
      expect(errors, isEmpty);
    });
  });
}
