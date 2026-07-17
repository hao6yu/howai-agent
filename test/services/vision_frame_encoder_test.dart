import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/vision_frame_encoder.dart';
import 'package:image/image.dart' as img;

void main() {
  test('encodes iOS BGRA stream data and applies rotation', () {
    final encoded = encodeVisionStreamFrame({
      'width': 2,
      'height': 1,
      'format': 'bgra8888',
      'rotation': 90,
      'mirror': false,
      'planes': [
        {
          // Red, then green, in BGRA byte order.
          'bytes': Uint8List.fromList([
            0,
            0,
            255,
            255,
            0,
            255,
            0,
            255,
          ]),
          'bytesPerRow': 8,
          'bytesPerPixel': 4,
        },
      ],
    });

    final decoded = img.decodeJpg(encoded);
    expect(decoded, isNotNull);
    expect(decoded!.width, 1);
    expect(decoded.height, 2);
  });

  test('encodes a three-plane Android YUV420 stream frame', () {
    final encoded = encodeVisionStreamFrame({
      'width': 2,
      'height': 2,
      'format': 'yuv420',
      'rotation': 0,
      'mirror': false,
      'planes': [
        {
          'bytes': Uint8List.fromList([235, 235, 235, 235]),
          'bytesPerRow': 2,
          'bytesPerPixel': 1,
        },
        {
          'bytes': Uint8List.fromList([128]),
          'bytesPerRow': 1,
          'bytesPerPixel': 1,
        },
        {
          'bytes': Uint8List.fromList([128]),
          'bytesPerRow': 1,
          'bytesPerPixel': 1,
        },
      ],
    });

    final decoded = img.decodeJpg(encoded);
    expect(decoded, isNotNull);
    final pixel = decoded!.getPixel(0, 0);
    expect(pixel.r, greaterThan(220));
    expect(pixel.g, greaterThan(220));
    expect(pixel.b, greaterThan(220));
  });
}
