import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import 'chat_attachment_service.dart';

typedef StorageImageUrlResolver = Future<String> Function(String reference);

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
    final localPaths = message.imagePaths ?? const <String>[];
    final remotePaths = message.imageUrls ?? const <String>[];
    final count = localPaths.length > remotePaths.length
        ? localPaths.length
        : remotePaths.length;
    for (var index = 0; index < count; index++) {
      final localPath = index < localPaths.length
          ? localPaths[index].trim()
          : '';
      final remotePath = index < remotePaths.length
          ? remotePaths[index].trim()
          : '';
      final path = localPath.isNotEmpty ? localPath : remotePath;
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
  const MessageMediaService({StorageImageUrlResolver? storageUrlResolver})
    : _storageUrlResolver = storageUrlResolver;

  final StorageImageUrlResolver? _storageUrlResolver;

  Future<ResolvedMessageMedia> resolve(
    ChatMessage message, {
    ResolvedMessageMedia? initial,
  }) async {
    return resolvePaths(
      imagePaths: message.imagePaths ?? const <String>[],
      imageUrls: message.imageUrls ?? const <String>[],
      filePaths: message.filePaths ?? const <String>[],
      knownDataImageBytes:
          initial?.dataImageBytes ?? const <String, Uint8List>{},
    );
  }

  Future<ResolvedMessageMedia> resolvePaths({
    required List<String> imagePaths,
    List<String> imageUrls = const <String>[],
    List<String> filePaths = const <String>[],
    Map<String, Uint8List> knownDataImageBytes = const <String, Uint8List>{},
  }) async {
    final imageCount = imagePaths.length > imageUrls.length
        ? imagePaths.length
        : imageUrls.length;
    final resolvedImages = await Future.wait([
      for (var index = 0; index < imageCount; index++)
        _resolvePreferredImage(
          index < imagePaths.length ? imagePaths[index] : '',
          index < imageUrls.length ? imageUrls[index] : '',
          knownDataImageBytes,
        ),
    ]);
    final resolvedFiles = await Future.wait(
      filePaths
          .where((path) => path.isNotEmpty)
          .map((path) async => MapEntry(path, await File(path).exists())),
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

  Future<_ResolvedImage> _resolvePreferredImage(
    String localPath,
    String remotePath,
    Map<String, Uint8List> knownDataImageBytes,
  ) async {
    final normalizedLocalPath = localPath.trim();
    if (normalizedLocalPath.isNotEmpty) {
      final local = await _resolveImage(
        normalizedLocalPath,
        knownDataImageBytes[normalizedLocalPath],
      );
      if (local.isVisible) return local;
    }

    final normalizedRemotePath = remotePath.trim();
    if (normalizedRemotePath.isNotEmpty &&
        normalizedRemotePath != normalizedLocalPath) {
      return _resolveImage(
        normalizedRemotePath,
        knownDataImageBytes[normalizedRemotePath],
      );
    }
    return _ResolvedImage(
      path: normalizedLocalPath.isNotEmpty
          ? normalizedLocalPath
          : normalizedRemotePath,
      isVisible: false,
    );
  }

  Future<_ResolvedImage> _resolveImage(
    String path,
    Uint8List? knownDataImageBytes,
  ) async {
    if (path.startsWith('http')) {
      return _ResolvedImage(path: path, isVisible: true);
    }
    if (path.startsWith('${ChatAttachmentService.referenceScheme}://')) {
      try {
        final signedUrl =
            await (_storageUrlResolver ??
                ChatAttachmentService().createSignedImageUrl)(path);
        return _ResolvedImage(path: signedUrl, isVisible: true);
      } catch (_) {
        return _ResolvedImage(path: path, isVisible: false);
      }
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
    return _ResolvedImage(path: path, isVisible: await File(path).exists());
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
