import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:haogpt/generated/app_localizations.dart';

class AudioService {
  static AudioPlayer? _audioPlayer;
  static StreamSubscription<PlayerState>? _audioStateSubscription;
  static AudioPlayer? _voiceDemoPlayer;
  static StreamSubscription<PlayerState>? _voiceDemoStateSubscription;
  static final ValueNotifier<bool> _isPlayingAudio = ValueNotifier(false);
  static final ValueNotifier<bool> _isVoiceDemoPlaying = ValueNotifier(false);
  static final ValueNotifier<bool> _isVoiceDemoPaused = ValueNotifier(false);

  // Getters for external access
  static ValueNotifier<bool> get isPlayingAudio => _isPlayingAudio;
  static ValueNotifier<bool> get isVoiceDemoPlaying => _isVoiceDemoPlaying;
  static ValueNotifier<bool> get isVoiceDemoPaused => _isVoiceDemoPaused;

  // Get current audio player position
  static Duration? get currentPosition => _audioPlayer?.position;

  // Get position stream for real-time position updates
  static Stream<Duration>? get positionStream => _audioPlayer?.positionStream;

  // Get total duration of current audio
  static Duration? get totalDuration => _audioPlayer?.duration;

  /// Play audio file with proper audio session configuration
  static Future<void> playAudio(
    String audioPath, {
    bool useSpeakerOutput = true,
    double playbackSpeed = 1.0,
  }) async {
    try {
      // print('[Audio Debug] Starting audio playback for: $audioPath');

      // Stop any currently playing audio
      await stopAudio();

      // Create a new audio player
      _audioPlayer = AudioPlayer();

      // Configure audio session
      final session = await AudioSession.instance;

      // print('[Audio Debug] Configuring audio session. Speaker output: $useSpeakerOutput');

      try {
        if (useSpeakerOutput) {
          // Configure for speaker output
          // print('[Audio Debug] 🔊 SPEAKER MODE - Using simple speaker configuration');
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playback,
            avAudioSessionCategoryOptions:
                AVAudioSessionCategoryOptions.defaultToSpeaker,
            avAudioSessionMode: AVAudioSessionMode.defaultMode,
          ));
          // print('[Audio Debug] ✅ Speaker configuration applied');
        } else {
          // Configure for earpiece
          // print('[Audio Debug] 📞 EARPIECE MODE - Using voice call configuration');
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
            avAudioSessionMode: AVAudioSessionMode.voiceChat,
          ));
          // print('[Audio Debug] ✅ Earpiece configuration applied');
        }

        // print('[Audio Debug] 🎵 Audio session configured successfully');
      } catch (e) {
        // print('[Audio Debug] ❌ Error configuring audio session: $e');
        // Fallback configuration
        // print('[Audio Debug] 🔄 Using most basic fallback configuration');
        if (useSpeakerOutput) {
          await session.configure(AudioSessionConfiguration.music());
        } else {
          await session.configure(AudioSessionConfiguration.speech());
        }
      }

      // Set the audio source
      // print('[Audio Debug] Setting audio file path...');
      await _audioPlayer!.setFilePath(audioPath);
      // print('[Audio Debug] Audio file path set successfully');

      // Explicitly set normal speed and volume
      // print('[Audio Debug] Setting playback speed');
      await _audioPlayer!.setSpeed(playbackSpeed.clamp(0.5, 1.5));
      // print('[Audio Debug] Setting volume to 1.0');
      await _audioPlayer!.setVolume(1.0);

      final player = _audioPlayer!;
      await _audioStateSubscription?.cancel();
      _audioStateSubscription = player.playerStateStream.listen(
        (state) {
          if (!identical(_audioPlayer, player)) return;
          if (state.processingState == ProcessingState.completed ||
              state.processingState == ProcessingState.idle) {
            _isPlayingAudio.value = false;
          } else {
            _isPlayingAudio.value = state.playing;
          }
        },
        onError: (_) {
          if (identical(_audioPlayer, player)) {
            _isPlayingAudio.value = false;
          }
        },
      );

      // just_audio's play() future completes when playback finishes. Publish
      // state first and run it without blocking the UI caller.
      _isPlayingAudio.value = true;
      unawaited(
        player.play().catchError((Object error) {
          if (identical(_audioPlayer, player)) {
            _isPlayingAudio.value = false;
          }
        }),
      );
    } catch (e) {
      // print('Error playing audio: $e');
      _isPlayingAudio.value = false;
    }
  }

  /// Stop current audio playback
  static Future<void> stopAudio() async {
    await _audioStateSubscription?.cancel();
    _audioStateSubscription = null;
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        _isPlayingAudio.value = false;
      } catch (e) {
        // print('Error stopping audio: $e');
      }
    }
    _isPlayingAudio.value = false;
  }

  /// Prepare voice demo player
  static Future<void> prepareVoiceDemoPlayer(
      {bool useSpeakerOutput = true}) async {
    try {
      // print('[VoiceDemo] Preparing welcome voice demo player');
      await _voiceDemoStateSubscription?.cancel();
      _voiceDemoStateSubscription = null;
      await _voiceDemoPlayer?.dispose();
      _voiceDemoPlayer = AudioPlayer();

      // Configure audio session
      final session = await AudioSession.instance;

      if (useSpeakerOutput) {
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
        ));
      } else {
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ));
      }

      // Set the audio source
      await _voiceDemoPlayer!.setAsset('assets/audio/hao_voice_demo_fixed.mp3');

      // print('[VoiceDemo] Voice demo player prepared successfully');
    } catch (e) {
      // print('[VoiceDemo] Error preparing voice demo player: $e');
    }
  }

  /// Play voice demo
  static Future<void> playVoiceDemo(BuildContext context,
      {bool useSpeakerOutput = true}) async {
    try {
      // print('[VoiceDemo] Starting welcome voice demo');
      await _voiceDemoStateSubscription?.cancel();
      await _voiceDemoPlayer?.dispose();
      _voiceDemoPlayer = AudioPlayer();

      // Configure audio session
      // print('[VoiceDemo] Configuring audio session...');
      final session = await AudioSession.instance;

      if (useSpeakerOutput) {
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
        ));
      } else {
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ));
      }

      // Set the audio source
      // print('[VoiceDemo] Loading voice demo asset...');
      await _voiceDemoPlayer!.setAsset('assets/audio/hao_voice_demo_fixed.mp3');

      final player = _voiceDemoPlayer!;
      _voiceDemoStateSubscription = player.playerStateStream.listen((state) {
        if (!identical(_voiceDemoPlayer, player)) return;
        if (state.processingState == ProcessingState.completed ||
            state.processingState == ProcessingState.idle) {
          _isVoiceDemoPlaying.value = false;
          _isVoiceDemoPaused.value = false;
        }
      });

      _isVoiceDemoPlaying.value = true;
      _isVoiceDemoPaused.value = false;

      unawaited(
        player.play().catchError((Object error) {
          if (identical(_voiceDemoPlayer, player)) {
            _isVoiceDemoPlaying.value = false;
            _isVoiceDemoPaused.value = false;
          }
        }),
      );
    } catch (e) {
      // print('[VoiceDemo] Error playing demo: $e\n$st');
      _isVoiceDemoPlaying.value = false;
      _isVoiceDemoPaused.value = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotPlayVoiceDemo),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Pause voice demo
  static Future<void> pauseVoiceDemo() async {
    if (_voiceDemoPlayer != null && _isVoiceDemoPlaying.value) {
      await _voiceDemoPlayer!.pause();
      _isVoiceDemoPaused.value = true;
      _isVoiceDemoPlaying.value = false;
    }
  }

  /// Resume voice demo
  static Future<void> resumeVoiceDemo() async {
    if (_voiceDemoPlayer != null && _isVoiceDemoPaused.value) {
      final player = _voiceDemoPlayer!;
      _isVoiceDemoPaused.value = false;
      _isVoiceDemoPlaying.value = true;
      unawaited(
        player.play().catchError((Object error) {
          if (identical(_voiceDemoPlayer, player)) {
            _isVoiceDemoPlaying.value = false;
            _isVoiceDemoPaused.value = false;
          }
        }),
      );
    }
  }

  /// Stop voice demo
  static Future<void> stopVoiceDemo() async {
    await _voiceDemoStateSubscription?.cancel();
    _voiceDemoStateSubscription = null;
    if (_voiceDemoPlayer != null) {
      await _voiceDemoPlayer!.stop();
      _isVoiceDemoPlaying.value = false;
      _isVoiceDemoPaused.value = false;
    }
  }

  /// Dispose all audio players
  static Future<void> dispose() async {
    await stopAudio();
    await stopVoiceDemo();
    await _voiceDemoPlayer?.dispose();
    _isPlayingAudio.dispose();
    _isVoiceDemoPlaying.dispose();
    _isVoiceDemoPaused.dispose();
  }
}
