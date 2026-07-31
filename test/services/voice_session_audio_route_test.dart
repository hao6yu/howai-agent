import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/elevenlabs_voice_session_service.dart';
import 'package:haogpt/services/voice_session_service.dart';

void main() {
  VoiceSessionCallbacks callbacks() {
    return VoiceSessionCallbacks(
      onConnected: () {},
      onDisconnected: (_) {},
      onUserSpeechStarted: () {},
      onTranscript: (_) {},
      onSpeakingChanged: (_) {},
      onError: (_) {},
      onToolCall: (_) async {},
    );
  }

  test('voice sessions preserve the existing speaker-on default', () {
    const options = VoiceSessionStartOptions(
      voice: 'marin',
      userId: 'user-1',
      userName: 'Taylor',
      timezone: 'America/Chicago',
      localDateTime: '2026-07-28T12:00:00',
    );

    expect(options.speakerphoneEnabled, isTrue);
  });

  test('backup provider applies speaker and earpiece route changes', () async {
    final routes = <bool>[];
    final service = ElevenLabsVoiceSessionService(
      callbacks: callbacks(),
      audioRouteSetter: (enabled) async => routes.add(enabled),
    );
    addTearDown(service.dispose);

    await service.setSpeakerphoneEnabled(false);
    await service.setSpeakerphoneEnabled(true);

    expect(routes, [false, true]);
  });
}
