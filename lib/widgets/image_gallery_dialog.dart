import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:haogpt/generated/app_localizations.dart';

class ImageGalleryDialog extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageGalleryDialog({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<ImageGalleryDialog>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _saveSuccessController;
  late Animation<double> _saveSuccessAnimation;
  bool _showSaveSuccess = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize save success animation
    _saveSuccessController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _saveSuccessAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _saveSuccessController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _saveSuccessController.dispose();
    super.dispose();
  }

  void _showSaveSuccessIndicator() {
    setState(() {
      _showSaveSuccess = true;
    });

    _saveSuccessController.forward().then((_) {
      // Auto hide after animation completes
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _saveSuccessController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showSaveSuccess = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PhotoViewGallery.builder(
              itemCount: widget.imagePaths.length,
              pageController: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              builder: (context, index) {
                final path = widget.imagePaths[index];

                // Safe image provider creation with file existence check
                ImageProvider<Object> imageProvider;
                if (path.startsWith('http')) {
                  imageProvider = NetworkImage(path);
                } else if (path.startsWith('data:image')) {
                  // Handle base64 data URLs
                  try {
                    final base64Data = path.split(',').last;
                    final bytes = base64Decode(base64Data);
                    imageProvider = MemoryImage(Uint8List.fromList(bytes));
                  } catch (e) {
                    // Return a placeholder for failed base64 decode
                    return PhotoViewGalleryPageOptions.customChild(
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey.shade400,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to decode image',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  }
                } else {
                  final file = File(path);
                  if (file.existsSync()) {
                    imageProvider = FileImage(file);
                  } else {
                    // Return a placeholder provider for missing files
                    return PhotoViewGalleryPageOptions.customChild(
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Image no longer available',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  }
                }

                return PhotoViewGalleryPageOptions(
                  imageProvider: imageProvider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  errorBuilder: (context, error, stackTrace) {
                    // print('Error loading image in gallery: $error');
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

            if (widget.imagePaths.length > 1)
              Positioned(
                bottom: 32,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            // Show download/save button for both local and remote images on all platforms
            if (widget.imagePaths[_currentIndex].startsWith('http') ||
                widget.imagePaths[_currentIndex].startsWith('data:image') ||
                File(widget.imagePaths[_currentIndex]).existsSync())
              Positioned(
                top: 48,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.save_alt_rounded,
                        color: Colors.white, size: 28),
                    tooltip: AppLocalizations.of(context)!.saveToPhotos,
                    onPressed: () async {
                      final path = widget.imagePaths[_currentIndex];
                      try {
                        Uint8List? imageBytes;
                        if (path.startsWith('http')) {
                          final response = await http.get(Uri.parse(path));
                          if (response.statusCode == 200) {
                            imageBytes = Uint8List.fromList(response.bodyBytes);
                          }
                        } else if (path.startsWith('data:image')) {
                          // Handle base64 data URLs
                          final base64Data = path.split(',').last;
                          imageBytes =
                              Uint8List.fromList(base64Decode(base64Data));
                        } else if (File(path).existsSync()) {
                          imageBytes = await File(path).readAsBytes();
                        }

                        if (imageBytes != null) {
                          try {
                            // Check if we have permission first (for Android)
                            bool hasAccess = await Gal.hasAccess();
                            if (!hasAccess) {
                              hasAccess = await Gal.requestAccess();
                            }

                            if (hasAccess) {
                              await Gal.putImageBytes(imageBytes);
                              if (mounted) {
                                // Show animated success indicator
                                _showSaveSuccessIndicator();

                                // Also show snackbar for confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(AppLocalizations.of(context)!
                                              .imageSaved),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2)),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .failedToSaveImage),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // print('Error saving image: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .failedToSaveImage),
                                    duration: Duration(seconds: 2)),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .failedToDownloadImage),
                                  duration: Duration(seconds: 2)),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .somethingWentWrong),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),

            // Success indicator overlay
            if (_showSaveSuccess)
              AnimatedBuilder(
                animation: _saveSuccessAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.3 * _saveSuccessAnimation.value),
                      child: Center(
                        child: Transform.scale(
                          scale: _saveSuccessAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Saved!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
