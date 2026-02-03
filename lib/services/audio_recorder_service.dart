import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  static final AudioRecorderService _instance = AudioRecorderService._internal();

  factory AudioRecorderService() => _instance;

  AudioRecorderService._internal();

  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  String? _recordingPath;

  // For real-time streaming
  StreamController<Uint8List>? _audioStreamController;
  bool _isStreamingMode = false;
  List<int> _audioBuffer = [];

  Future<void> initialize() async {
    if (_isRecorderInitialized) return;

    // Disable audio recording on macOS due to plugin compatibility issues
    if (Platform.isMacOS) {
      // debugPrint('Audio recording is disabled on macOS');
      return;
    }

    try {
      // Only create the recorder instance when not on macOS
      _recorder ??= FlutterSoundRecorder();

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }

      // Initialize recorder based on platform
      if (Platform.isIOS) {
        // Try to properly reset the recorder state first
        try {
          await _recorder!.closeRecorder();
        } catch (e) {
          // Ignore errors during closing - might not be open yet
        }
      }

      // Open the recorder with a timeout to prevent hanging
      bool recorderOpened = false;
      try {
        await _recorder!.openRecorder();
        recorderOpened = true;
      } catch (e) {
        if (Platform.isIOS) {
          // On iOS, try once more with a delay
          await Future.delayed(const Duration(milliseconds: 800));
          await _recorder!.openRecorder();
          recorderOpened = true;
        } else {
          rethrow;
        }
      }

      if (!recorderOpened) {
        throw Exception('Failed to open audio recorder');
      }

      _isRecorderInitialized = true;
    } catch (e) {
      // Clean up if initialization failed
      try {
        await _recorder?.closeRecorder();
      } catch (_) {}
      _recorder = null;
      _isRecorderInitialized = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_isRecorderInitialized && _recorder != null) {
      await _recorder!.closeRecorder();
      _isRecorderInitialized = false;
      _recorder = null;
    }
  }

  Future<String?> startRecording() async {
    // Return null immediately on macOS
    if (Platform.isMacOS) {
      // debugPrint('Audio recording not available on macOS');
      return null;
    }

    try {
      if (!_isRecorderInitialized) {
        await initialize();
      }

      if (_recorder == null) return null;

      // Create temp directory for recordings
      final tempDir = await getTemporaryDirectory();
      final recordingsDir = Directory('${tempDir.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Create a unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${recordingsDir.path}/recording_$timestamp.wav';

      // Make sure the recorder is in a good state
      if (Platform.isIOS && _recorder!.isRecording) {
        try {
          await _recorder!.stopRecorder();
        } catch (e) {
          // Continue anyway
        }
      }

      // Start recording to the file
      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );

      return _recordingPath;
    } catch (e) {
      // Try to re-initialize if recording fails
      if (_isRecorderInitialized) {
        try {
          await dispose();
          await Future.delayed(const Duration(milliseconds: 500));
          await initialize();
        } catch (reinitError) {
          // Ignore reinit errors
        }
      }
      return null;
    }
  }

  Future<String?> stopRecording() async {
    // Return null immediately on macOS
    if (Platform.isMacOS) {
      return null;
    }

    if (!_isRecorderInitialized || _recorder == null || !_recorder!.isRecording) {
      return null;
    }

    await _recorder!.stopRecorder();
    return _recordingPath;
  }

  Future<List<int>?> getRecordingBytes() async {
    if (_recordingPath == null) return null;

    final file = File(_recordingPath!);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  bool get isRecording {
    // Always return false on macOS
    if (Platform.isMacOS) {
      return false;
    }
    return _recorder?.isRecording ?? false;
  }

  Future<void> deleteRecording() async {
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _recordingPath = null;
    }
  }

  Future<void> cancelRecording() async {
    // Return early on macOS
    if (Platform.isMacOS) {
      return;
    }

    if (_isRecorderInitialized && _recorder != null && _recorder!.isRecording) {
      await _recorder!.stopRecorder();
    }

    await deleteRecording();
    _recordingPath = null;
  }

  Future<void> cleanupOldRecordings({Duration? olderThan}) async {
    final tempDir = await getTemporaryDirectory();
    final recordingsDir = Directory('${tempDir.path}/recordings');

    if (!await recordingsDir.exists()) {
      return;
    }

    final cutoffTime = DateTime.now().subtract(olderThan ?? const Duration(days: 1));

    try {
      final files = await recordingsDir.list().toList();
      for (final entity in files) {
        if (entity is File && entity.path.contains('recording_')) {
          final fileStat = await entity.stat();
          if (fileStat.modified.isBefore(cutoffTime)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  // Real-time streaming methods
  Future<void> startRealtimeRecording() async {
    // Return early on macOS
    if (Platform.isMacOS) {
      // debugPrint('Real-time recording not available on macOS');
      return;
    }

    try {
      if (!_isRecorderInitialized) {
        await initialize();
      }

      if (_recorder == null) return;

      _isStreamingMode = true;
      _audioStreamController = StreamController<Uint8List>.broadcast();
      _audioBuffer.clear();

      // Listen to the stream and buffer the audio data
      _audioStreamController!.stream.listen((data) {
        _audioBuffer.addAll(data);
      });

      // Start recording to a stream instead of a file
      await _recorder!.startRecorder(
        toStream: _audioStreamController!.sink,
        codec: Codec.pcm16,
        sampleRate: 16000,
        numChannels: 1,
      );
    } catch (e) {
      _isStreamingMode = false;
      _audioStreamController?.close();
      _audioStreamController = null;
      rethrow;
    }
  }

  Future<void> stopRealtimeRecording() async {
    // Return early on macOS
    if (Platform.isMacOS) {
      return;
    }

    if (_isStreamingMode && _recorder != null && _recorder!.isRecording) {
      await _recorder!.stopRecorder();
      _isStreamingMode = false;
      await _audioStreamController?.close();
      _audioStreamController = null;
      _audioBuffer.clear();
    }
  }

  Future<List<int>?> getRealtimeAudioChunk() async {
    // Return null on macOS
    if (Platform.isMacOS) {
      return null;
    }

    if (!_isStreamingMode || _audioBuffer.isEmpty) {
      return null;
    }

    // Return a chunk of audio data (e.g., 1600 bytes for 100ms at 16kHz)
    const chunkSize = 1600;
    if (_audioBuffer.length >= chunkSize) {
      final chunk = _audioBuffer.take(chunkSize).toList();
      _audioBuffer.removeRange(0, chunkSize);
      return chunk;
    }

    return null;
  }
}
