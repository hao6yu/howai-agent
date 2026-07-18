import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/vision_frame_encoder.dart';
import 'package:image/image.dart' as img;

void main() {
  group('calculateVisionFrameRotation', () {
    const deviceOrientations = [0, 90, 180, 270];
    const backCameraExpectations = <int, List<int>>{
      0: [0, 270, 180, 90],
      90: [90, 0, 270, 180],
      180: [180, 90, 0, 270],
      270: [270, 180, 90, 0],
    };
    const frontCameraExpectations = <int, List<int>>{
      0: [0, 90, 180, 270],
      90: [90, 180, 270, 0],
      180: [180, 270, 0, 90],
      270: [270, 0, 90, 180],
    };

    test('does not rotate already-oriented iOS frames', () {
      for (final sensorDegrees in backCameraExpectations.keys) {
        for (final deviceDegrees in deviceOrientations) {
          for (final isFrontFacing in [false, true]) {
            expect(
              calculateVisionFrameRotation(
                requiresSoftwareRotation: false,
                sensorOrientationDegrees: sensorDegrees,
                deviceOrientationDegrees: deviceDegrees,
                isFrontFacing: isFrontFacing,
              ),
              0,
              reason: 'iOS frames are already oriented: sensor=$sensorDegrees, '
                  'device=$deviceDegrees, front=$isFrontFacing',
            );
          }
        }
      }
    });

    for (final entry in backCameraExpectations.entries) {
      test(
        'normalizes Android back camera with ${entry.key}° sensor',
        () {
          for (var index = 0; index < deviceOrientations.length; index += 1) {
            expect(
              calculateVisionFrameRotation(
                requiresSoftwareRotation: true,
                sensorOrientationDegrees: entry.key,
                deviceOrientationDegrees: deviceOrientations[index],
                isFrontFacing: false,
              ),
              entry.value[index],
            );
          }
        },
      );
    }

    for (final entry in frontCameraExpectations.entries) {
      test(
        'normalizes Android front camera with ${entry.key}° sensor',
        () {
          for (var index = 0; index < deviceOrientations.length; index += 1) {
            expect(
              calculateVisionFrameRotation(
                requiresSoftwareRotation: true,
                sensorOrientationDegrees: entry.key,
                deviceOrientationDegrees: deviceOrientations[index],
                isFrontFacing: true,
              ),
              entry.value[index],
            );
          }
        },
      );
    }
  });

  test('preserves already-oriented iOS BGRA stream data', () {
    final encoded = encodeVisionStreamFrame({
      'width': 8,
      'height': 4,
      'format': 'bgra8888',
      'rotation': 0,
      'mirror': false,
      'planes': [
        {
          'bytes': _horizontalSplitBgra(width: 8, height: 4),
          'bytesPerRow': 32,
          'bytesPerPixel': 4,
        },
      ],
    });

    final decoded = img.decodeJpg(encoded);
    expect(decoded, isNotNull);
    expect(decoded!.width, 8);
    expect(decoded.height, 4);
    expect(decoded.getPixel(1, 2).r, greaterThan(decoded.getPixel(1, 2).b));
    expect(decoded.getPixel(6, 2).b, greaterThan(decoded.getPixel(6, 2).r));
  });

  test('applies requested Android rotation clockwise before encoding', () {
    final encoded = encodeVisionStreamFrame({
      'width': 8,
      'height': 4,
      'format': 'bgra8888',
      'rotation': 90,
      'mirror': false,
      'planes': [
        {
          'bytes': _horizontalSplitBgra(width: 8, height: 4),
          'bytesPerRow': 32,
          'bytesPerPixel': 4,
        },
      ],
    });

    final decoded = img.decodeJpg(encoded);
    expect(decoded, isNotNull);
    expect(decoded!.width, 4);
    expect(decoded.height, 8);
    expect(decoded.getPixel(2, 1).r, greaterThan(decoded.getPixel(2, 1).b));
    expect(decoded.getPixel(2, 6).b, greaterThan(decoded.getPixel(2, 6).r));
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

Uint8List _horizontalSplitBgra({required int width, required int height}) {
  final bytes = Uint8List(width * height * 4);
  for (var y = 0; y < height; y += 1) {
    for (var x = 0; x < width; x += 1) {
      final offset = (y * width + x) * 4;
      final isRed = x < width ~/ 2;
      bytes[offset] = isRed ? 0 : 255;
      bytes[offset + 1] = 0;
      bytes[offset + 2] = isRed ? 255 : 0;
      bytes[offset + 3] = 255;
    }
  }
  return bytes;
}
