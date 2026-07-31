import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef VoiceAudioRouteSetter = Future<void> Function(bool enabled);

/// Owns the native call-audio route used by both voice providers.
///
/// Speaker mode still prefers a connected wired or Bluetooth device. Earpiece
/// mode removes the speaker override and lets the platform select its normal
/// private call route.
abstract final class VoiceAudioRouteService {
  static Future<void> setSpeakerphoneEnabled(bool enabled) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    if (enabled) {
      await Helper.setSpeakerphoneOnButPreferBluetooth();
    } else {
      await Helper.setSpeakerphoneOn(false);
    }

    // WebRTC's iOS voice-processing audio unit provides the acoustic echo
    // cancellation needed when the loudspeaker and microphone are active
    // together. Keep it explicitly out of bypass mode after route changes.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await NativeAudioManagement.setIsVoiceProcessingBypassed(false);
      } catch (error) {
        debugPrint('Could not enforce iOS voice processing: $error');
      }
    }
  }
}
