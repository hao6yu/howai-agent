import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_gallery_dialog.dart';
import 'supabase_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickImages({bool forPdf = false}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      return images;
    } catch (e) {
      // print('Error picking images: $e');
      return [];
    }
  }

  /// Take a photo with camera
  static Future<XFile?> takePhoto({bool forPdf = false}) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      return photo;
    } catch (e) {
      // print('Error taking photo: $e');
      return null;
    }
  }

  /// Show single image preview in full screen
  static void showSingleImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => ImageGalleryDialog(
        imagePaths: [imageUrl],
        initialIndex: 0,
      ),
    );
  }

  /// Show multiple images preview in gallery
  static void showImageGallery(BuildContext context, List<String> imagePaths, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => ImageGalleryDialog(
        imagePaths: imagePaths,
        initialIndex: initialIndex,
      ),
    );
  }

  /// Show attachment options modal with native iOS styling
  static void showAttachmentOptions(
    BuildContext context, {
    bool forPdf = false,
    required Function(ImageSource) onCameraSelected,
    required Function(ImageSource) onGallerySelected,
    required String attachPhotoText,
    required String cameraText,
    required String galleryText,
    required String cancelText,
  }) {
    // Use native iOS action sheet on iOS, fallback to Material on other platforms
    if (Platform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(
            forPdf ? "Add Images to PDF" : attachPhotoText,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onCameraSelected(ImageSource.camera);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.camera,
                    color: CupertinoColors.systemBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cameraText,
                    style: const TextStyle(
                      fontSize: 20,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onGallerySelected(ImageSource.gallery);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.photo_on_rectangle,
                    color: CupertinoColors.systemBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    galleryText,
                    style: const TextStyle(
                      fontSize: 20,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
        ),
      );
    } else {
      // Fallback to Material Design for Android
      _showMaterialAttachmentOptions(
        context,
        forPdf: forPdf,
        onCameraSelected: onCameraSelected,
        onGallerySelected: onGallerySelected,
        attachPhotoText: attachPhotoText,
        cameraText: cameraText,
        galleryText: galleryText,
        cancelText: cancelText,
      );
    }
  }

  /// Material Design fallback for Android
  static void _showMaterialAttachmentOptions(
    BuildContext context, {
    bool forPdf = false,
    required Function(ImageSource) onCameraSelected,
    required Function(ImageSource) onGallerySelected,
    required String attachPhotoText,
    required String cameraText,
    required String galleryText,
    required String cancelText,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        forPdf ? "Add Images to PDF" : attachPhotoText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      ListTile(
                        leading: const Icon(Icons.camera_alt, color: Colors.blue),
                        title: Text(cameraText),
                        onTap: () {
                          Navigator.pop(context);
                          onCameraSelected(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library, color: Colors.blue),
                        title: Text(galleryText),
                        onTap: () {
                          Navigator.pop(context);
                          onGallerySelected(ImageSource.gallery);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.close, color: Colors.grey),
                        title: Text(cancelText),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Validate if a file exists and is an image
  static bool isValidImagePath(String path) {
    if (path.startsWith('http')) return true;
    return File(path).existsSync();
  }

  /// Filter valid image paths from a list
  static List<String> filterValidImages(List<String> imagePaths) {
    return imagePaths.where((path) => isValidImagePath(path)).toList();
  }

  /// Upload image to Supabase Storage and return public URL
  /// Returns null if upload fails or user is not authenticated
  static Future<String?> uploadImageToSupabase(String localPath) async {
    try {
      final supabase = SupabaseService();
      
      if (!supabase.isAuthenticated) {
        debugPrint('[ImageService] Not authenticated, skipping image upload');
        return null;
      }

      final userId = supabase.currentUser!.id;
      final file = File(localPath);
      
      if (!file.existsSync()) {
        debugPrint('[ImageService] File does not exist: $localPath');
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = localPath.split('.').last;
      final fileName = '$userId/$timestamp.$extension';

      // Upload to Supabase Storage
      final bytes = await file.readAsBytes();
      await supabase.client.storage
          .from('chat-images')
          .uploadBinary(fileName, bytes);

      // Get public URL
      final publicUrl = supabase.client.storage
          .from('chat-images')
          .getPublicUrl(fileName);

      debugPrint('[ImageService] Uploaded image to Supabase: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[ImageService] Error uploading image to Supabase (silent): $e');
      return null; // Silent failure - local path will be used
    }
  }

  /// Upload multiple images to Supabase Storage
  /// Returns list of public URLs (null entries for failed uploads)
  static Future<List<String?>> uploadImagesToSupabase(List<String> localPaths) async {
    final List<String?> urls = [];
    
    for (final path in localPaths) {
      final url = await uploadImageToSupabase(path);
      urls.add(url);
    }
    
    return urls;
  }
}
