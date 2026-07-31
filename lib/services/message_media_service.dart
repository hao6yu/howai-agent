import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

@immutable
class ResolvedMessageMedia {
  const ResolvedMessageMedia({
    required this.visibleImagePaths,
    required this.fileAvailability,
    required this.dataImageBytes,
  });

  factory ResolvedMessageMedia.initial(ChatMessage message) {
    final visibleImagePaths = <String>[];
    final dataImageBytes = <String, Uint8List>{};
    for (final path in message.imagePaths ?? const <String>[]) {
      if (path.startsWith('http')) {
        visibleImagePaths.add(path);
      } else if (path.startsWith('data:image')) {
        try {
          dataImageBytes[path] = _decodeDataImage(path);
          visibleImagePaths.add(path);
        } catch (_) {
          // Invalid data images are omitted just like missing local images.
        }
      }
    }
    return ResolvedMessageMedia(
      visibleImagePaths: visibleImagePaths,
      fileAvailability: const <String, bool>{},
      dataImageBytes: dataImageBytes,
    );
  }

  final List<String> visibleImagePaths;
  final Map<String, bool> fileAvailability;
  final Map<String, Uint8List> dataImageBytes;
}

class MessageMediaService {
  const MessageMediaService();

  Future<ResolvedMessageMedia> resolve(
    ChatMessage message, {
    ResolvedMessageMedia? initial,
  }) async {
    return resolvePaths(
      imagePaths: message.imagePaths ?? const <String>[],
      filePaths: message.filePaths ?? const <String>[],
      knownDataImageBytes:
          initial?.dataImageBytes ?? const <String, Uint8List>{},
    );
  }

  Future<ResolvedMessageMedia> resolvePaths({
    required List<String> imagePaths,
    List<String> filePaths = const <String>[],
    Map<String, Uint8List> knownDataImageBytes = const <String, Uint8List>{},
  }) async {
    final resolvedImages = await Future.wait(
      imagePaths.map(
        (path) => _resolveImage(path, knownDataImageBytes[path]),
      ),
    );
    final resolvedFiles = await Future.wait(
      filePaths.where((path) => path.isNotEmpty).map(
            (path) async => MapEntry(path, await File(path).exists()),
          ),
    );

    return ResolvedMessageMedia(
      visibleImagePaths: [
        for (final image in resolvedImages)
          if (image.isVisible) image.path,
      ],
      fileAvailability: Map<String, bool>.fromEntries(resolvedFiles),
      dataImageBytes: {
        for (final image in resolvedImages)
          if (image.bytes != null) image.path: image.bytes!,
      },
    );
  }

  Future<_ResolvedImage> _resolveImage(
    String path,
    Uint8List? knownDataImageBytes,
  ) async {
    if (path.startsWith('http')) {
      return _ResolvedImage(path: path, isVisible: true);
    }
    if (path.startsWith('data:image')) {
      if (knownDataImageBytes != null) {
        return _ResolvedImage(
          path: path,
          isVisible: true,
          bytes: knownDataImageBytes,
        );
      }
      try {
        final bytes = await compute(_decodeDataImage, path);
        return _ResolvedImage(path: path, isVisible: true, bytes: bytes);
      } catch (_) {
        return _ResolvedImage(path: path, isVisible: false);
      }
    }
    return _ResolvedImage(
      path: path,
      isVisible: await File(path).exists(),
    );
  }
}

class _ResolvedImage {
  const _ResolvedImage({
    required this.path,
    required this.isVisible,
    this.bytes,
  });

  final String path;
  final bool isVisible;
  final Uint8List? bytes;
}

Uint8List _decodeDataImage(String dataUri) {
  return base64Decode(dataUri.split(',').last);
}
