import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Returns the clockwise rotation needed to make a streamed camera frame
/// upright for the current device orientation.
///
/// CameraX delivers Android analysis frames in sensor orientation, so those
/// frames need the sensor/device correction. AVFoundation physically rotates
/// iOS video-data frames before exposing them to Flutter, so applying the same
/// correction there would rotate the image twice.
int calculateVisionFrameRotation({
  required bool requiresSoftwareRotation,
  required int sensorOrientationDegrees,
  required int deviceOrientationDegrees,
  required bool isFrontFacing,
}) {
  if (!requiresSoftwareRotation) {
    return 0;
  }

  final sensorDegrees = sensorOrientationDegrees % 360;
  final deviceDegrees = deviceOrientationDegrees % 360;
  if (isFrontFacing) {
    return (sensorDegrees + deviceDegrees) % 360;
  }
  return (sensorDegrees - deviceDegrees + 360) % 360;
}

/// Converts one sampled camera-stream frame into a bounded JPEG suitable for
/// OpenAI Realtime image input. This runs in a background isolate on devices.
Uint8List encodeVisionStreamFrame(Map<String, dynamic> frame) {
  final width = frame['width'] as int;
  final height = frame['height'] as int;
  final format = frame['format'] as String;
  final planes = (frame['planes'] as List)
      .map((plane) => Map<String, dynamic>.from(plane as Map))
      .toList(growable: false);

  img.Image source;
  if (format == 'bgra8888') {
    final plane = planes.first;
    final bytes = plane['bytes'] as Uint8List;
    source = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      bytesOffset: bytes.offsetInBytes,
      rowStride: plane['bytesPerRow'] as int,
      numChannels: 4,
      order: img.ChannelOrder.bgra,
    );
  } else if (format == 'jpeg') {
    source = img.decodeImage(planes.first['bytes'] as Uint8List) ??
        (throw StateError('The streamed JPEG could not be decoded'));
  } else {
    source = _decodeYuvVisionFrame(
      width: width,
      height: height,
      format: format,
      planes: planes,
    );
  }

  final rotation = frame['rotation'] as int;
  if (rotation != 0) {
    source = img.copyRotate(source, angle: rotation.toDouble());
  }
  if (frame['mirror'] == true) {
    source = img.flipHorizontal(source);
  }

  const maxDimension = 960;
  if (max(source.width, source.height) > maxDimension) {
    source = source.width >= source.height
        ? img.copyResize(source, width: maxDimension)
        : img.copyResize(source, height: maxDimension);
  }
  var encoded = img.encodeJpg(source, quality: 62);
  if (encoded.lengthInBytes > 700 * 1024) {
    source = source.width >= source.height
        ? img.copyResize(source, width: min(720, source.width))
        : img.copyResize(source, height: min(720, source.height));
    encoded = img.encodeJpg(source, quality: 46);
  }
  if (encoded.lengthInBytes > 950 * 1024) {
    throw StateError('Camera frame is too large to share');
  }
  return encoded;
}

img.Image _decodeYuvVisionFrame({
  required int width,
  required int height,
  required String format,
  required List<Map<String, dynamic>> planes,
}) {
  if (planes.isEmpty) {
    throw StateError('The camera stream did not contain image planes');
  }

  final rgba = Uint8List(width * height * 4);
  final yBytes = planes.first['bytes'] as Uint8List;
  final yRowStride = planes.first['bytesPerRow'] as int;

  int yValueAt(int x, int y) => yBytes[y * yRowStride + x];
  int uValueAt(int x, int y) {
    if (planes.length >= 3) {
      final plane = planes[1];
      final pixelStride = plane['bytesPerPixel'] as int;
      return (plane['bytes'] as Uint8List)[
          (y >> 1) * (plane['bytesPerRow'] as int) + (x >> 1) * pixelStride];
    }
    if (planes.length == 2) {
      final plane = planes[1];
      final pixelStride = max(2, plane['bytesPerPixel'] as int);
      return (plane['bytes'] as Uint8List)[
          (y >> 1) * (plane['bytesPerRow'] as int) + (x >> 1) * pixelStride];
    }
    final bytes = planes.first['bytes'] as Uint8List;
    final uvOffset = yRowStride * height + (y >> 1) * yRowStride + (x & ~1);
    return format == 'nv21' ? bytes[uvOffset + 1] : bytes[uvOffset];
  }

  int vValueAt(int x, int y) {
    if (planes.length >= 3) {
      final plane = planes[2];
      final pixelStride = plane['bytesPerPixel'] as int;
      return (plane['bytes'] as Uint8List)[
          (y >> 1) * (plane['bytesPerRow'] as int) + (x >> 1) * pixelStride];
    }
    if (planes.length == 2) {
      final plane = planes[1];
      final pixelStride = max(2, plane['bytesPerPixel'] as int);
      return (plane['bytes'] as Uint8List)[
          (y >> 1) * (plane['bytesPerRow'] as int) +
              (x >> 1) * pixelStride +
              1];
    }
    final bytes = planes.first['bytes'] as Uint8List;
    final uvOffset = yRowStride * height + (y >> 1) * yRowStride + (x & ~1);
    return format == 'nv21' ? bytes[uvOffset] : bytes[uvOffset + 1];
  }

  for (var y = 0; y < height; y += 1) {
    for (var x = 0; x < width; x += 1) {
      final luminance = max(0, yValueAt(x, y) - 16);
      final u = uValueAt(x, y) - 128;
      final v = vValueAt(x, y) - 128;
      final outputIndex = (y * width + x) * 4;
      rgba[outputIndex] =
          ((298 * luminance + 409 * v + 128) >> 8).clamp(0, 255);
      rgba[outputIndex + 1] =
          ((298 * luminance - 100 * u - 208 * v + 128) >> 8).clamp(0, 255);
      rgba[outputIndex + 2] =
          ((298 * luminance + 516 * u + 128) >> 8).clamp(0, 255);
      rgba[outputIndex + 3] = 255;
    }
  }

  return img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
}
