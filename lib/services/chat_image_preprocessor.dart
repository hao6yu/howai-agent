import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

const int visionImageTargetBytes = 600 * 1024;
const int visionImageMaximumBytes = 700 * 1024;

class VisionImageCompressionAttempt {
  final int minWidth;
  final int minHeight;
  final int quality;

  const VisionImageCompressionAttempt({
    required this.minWidth,
    required this.minHeight,
    required this.quality,
  });
}

typedef VisionImageCompressor = Future<Uint8List?> Function(
  String path,
  VisionImageCompressionAttempt attempt,
);

class VisionImageTooLargeException implements Exception {
  final int compressedBytes;

  const VisionImageTooLargeException(this.compressedBytes);

  @override
  String toString() =>
      'Image remains too large after compression ($compressedBytes bytes).';
}

const List<VisionImageCompressionAttempt> _compressionAttempts = [
  VisionImageCompressionAttempt(minWidth: 1024, minHeight: 1024, quality: 72),
  VisionImageCompressionAttempt(minWidth: 896, minHeight: 896, quality: 64),
  VisionImageCompressionAttempt(minWidth: 768, minHeight: 768, quality: 56),
  VisionImageCompressionAttempt(minWidth: 640, minHeight: 640, quality: 48),
];

/// Produces a bounded JPEG data URL for an OpenAI vision request.
///
/// The original file is read only by the local compressor and is never
/// inserted into the API payload. The smallest successful result is retained,
/// and results over the hard limit are rejected instead of being uploaded.
Future<String?> encodeImageForVision(
  String path, {
  VisionImageCompressor compressor = _compressImage,
}) async {
  Uint8List? smallest;

  for (final attempt in _compressionAttempts) {
    final candidate = await compressor(path, attempt);
    if (candidate == null || candidate.isEmpty) continue;
    if (smallest == null || candidate.length < smallest.length) {
      smallest = candidate;
    }
    if (candidate.length <= visionImageTargetBytes) {
      return _jpegDataUrl(candidate);
    }
  }

  if (smallest == null) return null;
  if (smallest.length > visionImageMaximumBytes) {
    throw VisionImageTooLargeException(smallest.length);
  }
  return _jpegDataUrl(smallest);
}

Future<Uint8List?> _compressImage(
  String path,
  VisionImageCompressionAttempt attempt,
) {
  return FlutterImageCompress.compressWithFile(
    path,
    minWidth: attempt.minWidth,
    minHeight: attempt.minHeight,
    quality: attempt.quality,
    format: CompressFormat.jpeg,
    keepExif: false,
  );
}

String _jpegDataUrl(Uint8List bytes) {
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}
