import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for image editing operations like cropping, rotating, and resizing
class ImageEditingService {
  static const int _maxImageSize = 1024; // Max width/height for compressed images
  static const int _jpegQuality = 85; // JPEG compression quality

  /// Crop an image with user-friendly interface
  /// Optimized for avatar/profile pictures
  static Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio? aspectRatio,
    bool isCircular = false,
    String title = 'Crop Image',
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: _jpegQuality,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: const Color(0xFF0078D4),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF0078D4),
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF0078D4),
            cropFrameColor: const Color(0xFF0078D4),
            cropGridColor: Colors.white,
            cropFrameStrokeWidth: 3,
            cropGridStrokeWidth: 1,
            initAspectRatio: isCircular ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
            lockAspectRatio: isCircular, // Lock aspect ratio for circular crops
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: title,
            doneButtonTitle: 'Crop',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockEnabled: isCircular,
            resetAspectRatioEnabled: !isCircular,
            aspectRatioPickerButtonHidden: isCircular,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // print('[ImageEditingService] Error cropping image: $e');
    }
    return null;
  }

  /// Crop image specifically for avatars (circular crop)
  static Future<File?> cropAvatar(File imageFile) async {
    return await cropImage(
      imageFile: imageFile,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square aspect ratio
      isCircular: true,
      title: 'Crop Avatar',
    );
  }

  /// Crop image for general use with free aspect ratio
  static Future<File?> cropGeneral(File imageFile) async {
    return await cropImage(
      imageFile: imageFile,
      title: 'Crop Image',
    );
  }

  /// Quick avatar picker with camera or gallery choice
  static Future<File?> quickAvatarPicker(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Avatar Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Camera option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0078D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF0078D4),
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Use camera to take a new photo',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),

                // Gallery option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0078D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF0078D4),
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Select from your photo library',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),

                const SizedBox(height: 10),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : const Color(0xFF0078D4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (source != null) {
      return await pickAndEditImage(
        context: context,
        source: source,
        isAvatarMode: true,
      );
    }

    return null;
  }

  /// Resize and compress image while maintaining aspect ratio
  static Future<File?> resizeAndCompress({
    required File imageFile,
    int maxWidth = _maxImageSize,
    int maxHeight = _maxImageSize,
    int quality = _jpegQuality,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(dir.path, '${fileName}_compressed.jpg');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      // print('[ImageEditingService] Error compressing image: $e');
    }
    return null;
  }

  /// Show image editing options dialog
  static Future<File?> showImageEditingDialog({
    required BuildContext context,
    required File imageFile,
    bool isAvatarMode = false,
  }) async {
    final result = await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ImageEditingBottomSheet(
        imageFile: imageFile,
        isAvatarMode: isAvatarMode,
      ),
    );
    return result;
  }

  /// Get optimal image from gallery with editing options
  static Future<File?> pickAndEditImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    bool isAvatarMode = false,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      final imageFile = File(pickedFile.path);

      // For avatar mode, directly crop for avatar
      if (isAvatarMode) {
        return await cropAvatar(imageFile);
      }

      // For general mode, show editing options
      final editedFile = await showImageEditingDialog(
        context: context,
        imageFile: imageFile,
        isAvatarMode: isAvatarMode,
      );

      return editedFile ?? imageFile; // Return original if no editing was done
    } catch (e) {
      // print('[ImageEditingService] Error picking and editing image: $e');
      return null;
    }
  }
}

/// Bottom sheet widget for image editing options
class _ImageEditingBottomSheet extends StatelessWidget {
  final File imageFile;
  final bool isAvatarMode;

  const _ImageEditingBottomSheet({
    required this.imageFile,
    required this.isAvatarMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isAvatarMode ? 'Edit Avatar' : 'Edit Image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you\'d like to edit your image',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              _buildEditOption(
                context: context,
                icon: Icons.crop,
                title: isAvatarMode ? 'Crop for Avatar' : 'Crop Image',
                subtitle: isAvatarMode ? 'Square crop for profile picture' : 'Crop to desired size and ratio',
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet first
                  final croppedFile = isAvatarMode ? await ImageEditingService.cropAvatar(imageFile) : await ImageEditingService.cropGeneral(imageFile);
                  if (context.mounted) {
                    Navigator.pop(context, croppedFile);
                  }
                },
              ),

              const SizedBox(height: 12),

              _buildEditOption(
                context: context,
                icon: Icons.compress,
                title: 'Resize & Compress',
                subtitle: 'Optimize file size while keeping quality',
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet first
                  final compressedFile = await ImageEditingService.resizeAndCompress(
                    imageFile: imageFile,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, compressedFile);
                  }
                },
              ),

              const SizedBox(height: 12),

              _buildEditOption(
                context: context,
                icon: Icons.check,
                title: 'Use Original',
                subtitle: 'Keep the image as is',
                onTap: () {
                  Navigator.pop(context, imageFile);
                },
              ),

              const SizedBox(height: 20),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0078D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0078D4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
