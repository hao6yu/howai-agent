import 'package:flutter/material.dart';

class ChatAudioListenerService {
  static void bindPlaybackListener({
    required ValueNotifier<bool> isPlayingNotifier,
    required bool Function() isMounted,
    required void Function(bool isPlaying) onPlaybackChanged,
  }) {
    isPlayingNotifier.addListener(() {
      if (isMounted()) {
        onPlaybackChanged(isPlayingNotifier.value);
      }
    });
  }
}
