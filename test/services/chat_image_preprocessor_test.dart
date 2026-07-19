import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/chat_image_preprocessor.dart';

void main() {
  test('retries until the image reaches the upload target', () async {
    final sizes = <int>[
      900 * 1024,
      720 * 1024,
      580 * 1024,
    ];
    final attempts = <VisionImageCompressionAttempt>[];

    final dataUrl = await encodeImageForVision(
      '/photo.jpg',
      compressor: (_, attempt) async {
        attempts.add(attempt);
        return Uint8List(sizes[attempts.length - 1]);
      },
    );

    expect(attempts, hasLength(3));
    expect(_decodedLength(dataUrl!), 580 * 1024);
  });

  test('accepts the smallest result only when it is under the hard limit',
      () async {
    final sizes = <int>[
      760 * 1024,
      730 * 1024,
      690 * 1024,
      710 * 1024,
    ];
    var index = 0;

    final dataUrl = await encodeImageForVision(
      '/photo.jpg',
      compressor: (_, __) async => Uint8List(sizes[index++]),
    );

    expect(_decodedLength(dataUrl!), 690 * 1024);
  });

  test('rejects an image that remains over the hard limit', () async {
    final sizes = <int>[
      900 * 1024,
      850 * 1024,
      800 * 1024,
      710 * 1024,
    ];
    var index = 0;

    expect(
      () => encodeImageForVision(
        '/photo.jpg',
        compressor: (_, __) async => Uint8List(sizes[index++]),
      ),
      throwsA(isA<VisionImageTooLargeException>()),
    );
  });

  test('returns null when compression cannot read the image', () async {
    final dataUrl = await encodeImageForVision(
      '/photo.jpg',
      compressor: (_, __) async => null,
    );

    expect(dataUrl, isNull);
  });
}

int _decodedLength(String dataUrl) {
  return base64Decode(dataUrl.split('base64,').last).length;
}
