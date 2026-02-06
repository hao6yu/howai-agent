import 'package:haogpt/services/elevenlabs_service.dart';

class ChatSpeechService {
  static Future<String?> generateAndPlayAudioForMessage({
    required String message,
    required String voiceId,
    required ElevenLabsService elevenLabsService,
    required Future<void> Function(String audioPath) playAudio,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final messageHash = message.hashCode.abs();
      final audioId = messageHash + timestamp;

      final voiceSettings = {
        'stability': 0.35,
        'similarity_boost': 0.95,
        'style': 0.6,
        'use_speaker_boost': true,
        'speed': 1.0,
      };

      final audioPath = await elevenLabsService.generateAudioWithSettings(
        message,
        audioId,
        voiceId: voiceId,
        voiceSettings: voiceSettings,
      );

      if (audioPath != null) {
        await playAudio(audioPath);
        return audioPath;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> generateSubscriptionAwareAudio({
    required bool isPremium,
    required Future<bool> Function() tryUseElevenLabsTts,
    required bool Function() canUseDeviceTTS,
    required Future<String?> Function() generateElevenLabsAudio,
    required Future<String?> Function() generateDeviceTtsAudio,
  }) async {
    if (isPremium) {
      final canUseElevenLabs = await tryUseElevenLabsTts();
      if (canUseElevenLabs) {
        return generateElevenLabsAudio();
      }
      return generateDeviceTtsAudio();
    }

    if (canUseDeviceTTS()) {
      return generateDeviceTtsAudio();
    }

    return null;
  }
}
