import 'package:flutter_tts/flutter_tts.dart';

class DeviceTtsService {
  static bool isValidVoiceMap(Map<String, String> voice) {
    return voice.containsKey('name') &&
        voice['name'] != null &&
        voice['name']!.isNotEmpty;
  }

  static Future<FlutterTts?> initialize({
    void Function()? onComplete,
    void Function()? onStart,
    void Function()? onCancel,
    double speechRate = 1.0,
  }) async {
    try {
      final flutterTts = FlutterTts();

      await flutterTts.setLanguage('en-US');
      await flutterTts.setSpeechRate(speechRate.clamp(0.5, 1.2));
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      flutterTts.setCompletionHandler(() {
        if (onComplete != null) {
          onComplete();
        }
      });

      flutterTts.setStartHandler(() {
        if (onStart != null) {
          onStart();
        }
      });

      flutterTts.setCancelHandler(() {
        if (onCancel != null) {
          onCancel();
        }
      });

      return flutterTts;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> generateAndPlay({
    required FlutterTts? flutterTts,
    required String message,
    Map<String, String>? selectedVoice,
    double speechRate = 1.0,
  }) async {
    try {
      if (flutterTts == null) {
        return null;
      }

      await flutterTts.stop();

      if (selectedVoice != null && isValidVoiceMap(selectedVoice)) {
        try {
          await Future.delayed(const Duration(milliseconds: 100));
          await flutterTts.setVoice(selectedVoice);
        } catch (_) {
          // Fallback to default voice if setVoice fails.
        }
      }

      await flutterTts.setSpeechRate(speechRate.clamp(0.5, 1.2));
      await flutterTts.speak(message);
      return 'device_tts';
    } catch (_) {
      return null;
    }
  }

  static Future<void> pause(FlutterTts? flutterTts) async {
    if (flutterTts != null) {
      await flutterTts.pause();
    }
  }

  static Future<void> stop(FlutterTts? flutterTts) async {
    if (flutterTts != null) {
      await flutterTts.stop();
    }
  }
}
