import 'package:image_picker/image_picker.dart';

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
}
