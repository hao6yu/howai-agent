import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Helper to download and save image locally with proper error handling
Future<String> downloadAndSaveImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/howai_img_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);

      // Ensure directory exists
      await file.parent.create(recursive: true);

      // Write file with error handling
      await file.writeAsBytes(response.bodyBytes);

      // Verify file was written successfully
      if (await file.exists() && await file.length() > 0) {
        return filePath;
      } else {
        throw Exception('Failed to write image file');
      }
    } else {
      throw Exception('Failed to download image: HTTP ${response.statusCode}');
    }
  } catch (e) {
    // print('Error downloading image from $imageUrl: $e');
    throw Exception('Failed to download image: $e');
  }
}

/// Helper to process markdown and replace image URLs with local file paths
Future<String> replaceImageUrlsWithLocalFiles(String markdown) async {
  final imageRegex = RegExp(r'!\[[^\]]*\]\((https?://[^)]+)\)');
  final matches = imageRegex.allMatches(markdown).toList();
  String processed = markdown;
  for (final match in matches) {
    final url = match.group(1);
    if (url != null) {
      try {
        final localPath = await downloadAndSaveImage(url);
        // Replace only the matched URL, keep the alt text
        processed = processed.replaceFirst(url, localPath);
      } catch (e) {
        // If download fails, keep the original URL
      }
    }
  }
  return processed;
}

/// Generate a short title from the message text
/// This is used as a fallback when OpenAI fails to generate a title
String generateConversationTitle(String message) {
  // Remove common filler words
  final fillerWords = ['a', 'an', 'the', 'this', 'that', 'these', 'those', 'is', 'are', 'was', 'were', 'be', 'been', 'being'];

  // Split into words, remove punctuation, and filter out filler words
  final words = message
      .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
      .split(' ')
      .where((word) => word.isNotEmpty && !fillerWords.contains(word.toLowerCase()))
      .toList();

  // If we have 4 or fewer significant words, use those
  if (words.length <= 4) {
    return words.join(' ');
  }

  // Otherwise take first 3-4 words
  return words.take(4).join(' ');
}

/// Create high-quality WAV file from PCM data
Uint8List createHighQualityWav(Uint8List pcmData) {
  // High-quality WAV header for PCM16, 16kHz, mono
  const sampleRate = 16000;
  const numChannels = 1;
  const bitsPerSample = 16;
  const byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
  const blockAlign = numChannels * bitsPerSample ~/ 8;
  final dataSize = pcmData.length;
  final fileSize = 36 + dataSize;

  final wavHeader = ByteData(44);

  // "RIFF" chunk descriptor
  wavHeader.setUint8(0, 0x52); // R
  wavHeader.setUint8(1, 0x49); // I
  wavHeader.setUint8(2, 0x46); // F
  wavHeader.setUint8(3, 0x46); // F
  wavHeader.setUint32(4, fileSize, Endian.little);
  wavHeader.setUint8(8, 0x57); // W
  wavHeader.setUint8(9, 0x41); // A
  wavHeader.setUint8(10, 0x56); // V
  wavHeader.setUint8(11, 0x45); // E

  // "fmt " sub-chunk
  wavHeader.setUint8(12, 0x66); // f
  wavHeader.setUint8(13, 0x6d); // m
  wavHeader.setUint8(14, 0x74); // t
  wavHeader.setUint8(15, 0x20); // (space)
  wavHeader.setUint32(16, 16, Endian.little); // Sub-chunk size
  wavHeader.setUint16(20, 1, Endian.little); // Audio format (PCM)
  wavHeader.setUint16(22, numChannels, Endian.little);
  wavHeader.setUint32(24, sampleRate, Endian.little);
  wavHeader.setUint32(28, byteRate, Endian.little);
  wavHeader.setUint16(32, blockAlign, Endian.little);
  wavHeader.setUint16(34, bitsPerSample, Endian.little);

  // "data" sub-chunk
  wavHeader.setUint8(36, 0x64); // d
  wavHeader.setUint8(37, 0x61); // a
  wavHeader.setUint8(38, 0x74); // t
  wavHeader.setUint8(39, 0x61); // a
  wavHeader.setUint32(40, dataSize, Endian.little);

  // Combine header and data
  final wavData = Uint8List(44 + dataSize);
  wavData.setRange(0, 44, wavHeader.buffer.asUint8List());
  wavData.setRange(44, 44 + dataSize, pcmData);

  return wavData;
}

/// Helper to safely get localized strings and prevent null check operator errors
String getLocalizedString(dynamic localizations, String Function(dynamic) getter, String fallback) {
  try {
    return localizations != null ? getter(localizations) : fallback;
  } catch (e) {
    // print('Error getting localized string: $e');
    return fallback;
  }
}
