import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AttachmentSelectionResult {
  final List<XFile> pendingImages;
  final bool isPdfWorkflowActive;
  final bool shouldStartPdfTimer;

  AttachmentSelectionResult({
    required this.pendingImages,
    required this.isPdfWorkflowActive,
    required this.shouldStartPdfTimer,
  });
}

class PendingImageRemovalResult {
  final List<XFile> pendingImages;
  final bool isPdfWorkflowActive;
  final bool shouldCancelPdfTimer;
  final bool shouldRestartPdfTimer;

  PendingImageRemovalResult({
    required this.pendingImages,
    required this.isPdfWorkflowActive,
    required this.shouldCancelPdfTimer,
    required this.shouldRestartPdfTimer,
  });
}

class ChatAttachmentService {
  ChatAttachmentService({SupabaseClient? client})
    : _client = client ?? SupabaseService().client;

  static const bucket = 'chat-attachments';
  static const referenceScheme = 'storage';
  static const maxRemovalBatchSize = 1000;

  final SupabaseClient _client;

  static AttachmentSelectionResult applyImageSelection({
    required List<XFile> currentPendingImages,
    required List<XFile> newImages,
    required bool forPdf,
  }) {
    if (newImages.isEmpty) {
      return AttachmentSelectionResult(
        pendingImages: List<XFile>.from(currentPendingImages),
        isPdfWorkflowActive: forPdf ? true : false,
        shouldStartPdfTimer: false,
      );
    }

    return AttachmentSelectionResult(
      pendingImages: [...currentPendingImages, ...newImages],
      isPdfWorkflowActive: forPdf,
      shouldStartPdfTimer: forPdf,
    );
  }

  static PendingImageRemovalResult removePendingImage({
    required List<XFile> currentPendingImages,
    required int index,
    required bool isPdfWorkflowActive,
  }) {
    final updated = List<XFile>.from(currentPendingImages);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
    }

    final noImagesLeft = updated.isEmpty;
    return PendingImageRemovalResult(
      pendingImages: updated,
      isPdfWorkflowActive: noImagesLeft ? false : isPdfWorkflowActive,
      shouldCancelPdfTimer: noImagesLeft,
      shouldRestartPdfTimer: !noImagesLeft && isPdfWorkflowActive,
    );
  }

  Future<List<String>> ensureImageReferences({
    required String userId,
    required String messageClientId,
    required List<String> localPaths,
    List<String> existingReferences = const <String>[],
  }) async {
    final references = List<String>.generate(
      localPaths.length,
      (index) => index < existingReferences.length
          ? existingReferences[index].trim()
          : '',
    );

    for (var index = 0; index < localPaths.length; index++) {
      if (references[index].isNotEmpty) continue;
      final localPath = localPaths[index].trim();
      if (localPath.isEmpty) continue;
      if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
        references[index] = localPath;
        continue;
      }
      if (localPath.startsWith('data:image')) continue;

      final file = File(localPath);
      if (!await file.exists()) continue;

      final extension = _safeImageExtension(localPath);
      final objectPath = '$userId/$messageClientId/image_$index.$extension';
      await _client.storage
          .from(bucket)
          .uploadBinary(
            objectPath,
            await file.readAsBytes(),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeForExtension(extension),
            ),
          );
      references[index] = storageReference(bucket, objectPath);
    }

    return references;
  }

  Future<String> createSignedImageUrl(String reference) async {
    final parsed = parseStorageReference(reference);
    if (parsed == null || parsed.bucket != bucket) {
      throw FormatException('Invalid chat attachment reference.');
    }
    return _client.storage
        .from(parsed.bucket)
        .createSignedUrl(parsed.objectPath, 60 * 60);
  }

  Future<void> removeImageReferences(Iterable<String> references) async {
    for (final batch in objectPathBatchesForRemoval(references)) {
      await _client.storage.from(bucket).remove(batch);
    }
  }

  static List<List<String>> objectPathBatchesForRemoval(
    Iterable<String> references,
  ) {
    final objectPaths = objectPathsForRemoval(references);
    return [
      for (
        var start = 0;
        start < objectPaths.length;
        start += maxRemovalBatchSize
      )
        objectPaths.sublist(
          start,
          (start + maxRemovalBatchSize).clamp(0, objectPaths.length),
        ),
    ];
  }

  static List<String> objectPathsForRemoval(Iterable<String> references) {
    final paths = <String>{};
    for (final reference in references) {
      final parsed = parseStorageReference(reference);
      if (parsed != null && parsed.bucket == bucket) {
        paths.add(parsed.objectPath);
      }
    }
    return paths.toList(growable: false);
  }

  static String storageReference(String bucket, String objectPath) =>
      '$referenceScheme://$bucket/$objectPath';

  static StoredAttachmentReference? parseStorageReference(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != referenceScheme ||
        uri.host.isEmpty ||
        uri.pathSegments.isEmpty) {
      return null;
    }
    return StoredAttachmentReference(
      bucket: uri.host,
      objectPath: uri.pathSegments.map(Uri.decodeComponent).join('/'),
    );
  }
}

class StoredAttachmentReference {
  const StoredAttachmentReference({
    required this.bucket,
    required this.objectPath,
  });

  final String bucket;
  final String objectPath;
}

String _safeImageExtension(String path) {
  final name = Uri.file(path).pathSegments.last;
  final separator = name.lastIndexOf('.');
  final extension = separator == -1
      ? ''
      : name.substring(separator + 1).toLowerCase().trim();
  switch (extension) {
    case 'jpeg':
    case 'jpg':
      return 'jpg';
    case 'png':
    case 'webp':
    case 'heic':
    case 'heif':
      return extension;
    default:
      return 'jpg';
  }
}

String _contentTypeForExtension(String extension) {
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    default:
      return 'image/jpeg';
  }
}
