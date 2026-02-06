import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_message.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/ai_personality_provider.dart';
import '../services/file_service.dart';
import '../services/review_service.dart';
import 'image_gallery_dialog.dart';
import 'content_report_dialog.dart';
import '../services/content_report_service.dart';
// place_result_widget is now handled separately in chat screen
import 'package:haogpt/generated/app_localizations.dart';
import '../services/profile_translation_service.dart';
import '../utils/language_utils.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final int messageKey;
  final bool selectionMode;
  final Set<int> selectedMessages;
  final Function(int) onToggleSelection;
  final Function(ChatMessage) onTranslate;
  final Function(
          ChatMessage, String targetLanguageCode, String targetLanguageName)?
      onQuickTranslate;
  final Function(ChatMessage)? onSelectTranslationLanguage;
  final int translationPreferenceVersion;
  final Function(ChatMessage) onDelete;
  final Function(ChatMessage)? onShare;
  final Map<int, String> translatedMessages;
  final bool isPlayingAudio;
  final Function(String) onPlayAudio;
  final Function(ChatMessage)? onSpeakWithHighlight;
  final Function()? onReviewRequested;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.messageKey,
    required this.selectionMode,
    required this.selectedMessages,
    required this.onToggleSelection,
    required this.onTranslate,
    this.onQuickTranslate,
    this.onSelectTranslationLanguage,
    required this.translationPreferenceVersion,
    required this.onDelete,
    required this.translatedMessages,
    required this.isPlayingAudio,
    required this.onPlayAudio,
    this.onSpeakWithHighlight,
    this.onShare,
    this.onReviewRequested,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  Offset? _lastTapPosition;
  String? _selectedText;

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.isUserMessage;
    final isSelected = widget.selectedMessages.contains(widget.messageKey);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          isUserMessage
              ? 16.0
              : 0.0, // No left padding for AI messages, normal padding for user messages
          8.0, // Top padding
          isUserMessage
              ? 0.0
              : 16.0, // No right padding for user messages, normal padding for AI messages
          8.0 // Bottom padding
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Message content row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection checkbox (if in selection mode)
              if (widget.selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: GestureDetector(
                    onTap: () => widget.onToggleSelection(widget.messageKey),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E3A5F)
                                  : const Color(0xFF0078D4))
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isSelected
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFF0078D4))
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade700
                                : Colors.white),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                ),

              // Message content
              Expanded(
                child: isUserMessage ? _buildUserMessage() : _buildAIMessage(),
              ),
            ],
          ),

          // Action buttons for AI messages (copy and translate only)
          if (!isUserMessage) _buildAIMessageActions(),
        ],
      ),
    );
  }

  Widget _buildUserMessage() {
    return GestureDetector(
      onLongPressStart: (details) {
        _lastTapPosition = details.globalPosition;
      },
      onLongPress: () {
        if (widget.selectionMode) {
          widget.onToggleSelection(widget.messageKey);
        } else {
          if (_lastTapPosition != null) {
            _showMessageActions(context, widget.message);
          }
        }
      },
      onTap: () {
        if (widget.selectionMode) {
          widget.onToggleSelection(widget.messageKey);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: _buildMessageContent(true),
          ),
          const SizedBox(width: 8),
          _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAIMessage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getMessageReportStatus(),
      builder: (context, snapshot) {
        final reportData =
            snapshot.data ?? {'isReported': false, 'shouldHide': false};
        final isReported = reportData['isReported'] as bool;
        final shouldHide = reportData['shouldHide'] as bool;

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Stack(
                children: [
                  // Message content with conditional border
                  Container(
                    decoration: BoxDecoration(
                      // Add subtle background if reported
                      color:
                          isReported ? Colors.orange.withOpacity(0.05) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: isReported
                          ? Border.all(
                              color: Colors.orange.withOpacity(0.3), width: 1)
                          : null,
                    ),
                    child: shouldHide
                        ? _buildHiddenContentWarning()
                        : _buildMessageContent(false),
                  ),

                  // Reported indicator badge
                  if (isReported)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.flag,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageContent(bool isUserMessage) {
    final settings = Provider.of<SettingsProvider>(context);
    final isWelcomeMessage = widget.message.isWelcomeMessage ?? false;
    final hasLocationResults = !isUserMessage &&
        widget.message.locationResults != null &&
        widget.message.locationResults!.isNotEmpty;

    // Reduce AI message width to prevent overlap, keep user messages same
    final maxWidth = isUserMessage
        ? MediaQuery.of(context).size.width *
            0.60 // User messages reduced from 0.7 to 0.65
        : MediaQuery.of(context).size.width *
            0.72; // AI messages increased from 0.65 to 0.72

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: isUserMessage
                      ? 0
                      : 0, // Removed padding, changed from 6 to 0
                  right: isUserMessage
                      ? 0
                      : 0, // Removed padding, changed from 6 to 0
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 12, // Increased for speech bubble
                  vertical: 8, // Increased for speech bubble
                ),
                decoration: isUserMessage
                    ? BoxDecoration(
                        // User messages: subtle gray bubble (ChatGPT style)
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          width: 0.5,
                        ),
                      )
                    : null, // AI messages: no background, clean look
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.imagePaths != null &&
                        widget.message.imagePaths!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.message.imagePaths!
                              .where((path) =>
                                  path.startsWith('http') ||
                                  path.startsWith('data:image') ||
                                  File(path).existsSync())
                              .map((path) => GestureDetector(
                                    onTap: () {
                                      final imagePaths = widget
                                          .message.imagePaths!
                                          .where((p) =>
                                              p.startsWith('http') ||
                                              p.startsWith('data:image') ||
                                              File(p).existsSync())
                                          .toList();
                                      final initialIndex =
                                          imagePaths.indexOf(path);
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black,
                                        builder: (_) => ImageGalleryDialog(
                                          imagePaths: imagePaths,
                                          initialIndex: initialIndex,
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: path.startsWith('http')
                                          ? Image.network(
                                              path,
                                              width: 96,
                                              height: 96,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 96,
                                                  height: 96,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey.shade400,
                                                    size: 32,
                                                  ),
                                                );
                                              },
                                            )
                                          : path.startsWith('data:image')
                                              ? Image.memory(
                                                  base64Decode(
                                                      path.split(',').last),
                                                  width: 96,
                                                  height: 96,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 96,
                                                      height: 96,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        color: Colors
                                                            .grey.shade400,
                                                        size: 32,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : _buildSafeLocalImage(
                                                  path, 96, 96),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),

                    // File attachments display
                    if (widget.message.filePaths != null &&
                        widget.message.filePaths!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.message.filePaths!
                              .where((path) => path.isNotEmpty)
                              .map((path) {
                            // Check file existence
                            final fileExists = File(path).existsSync();

                            return GestureDetector(
                              onTap: () => _openFile(path),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Simple file icon
                                    Icon(
                                      _getFileIcon(path),
                                      color: const Color(0xFF0078D4),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),

                                    // File name and type
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getFileName(path),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (!fileExists) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'File not accessible',
                                              style: TextStyle(
                                                color: Colors.orange.shade600,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // File type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF0078D4)
                                                .withOpacity(0.3)
                                            : const Color(0xFF0078D4)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getFileExtension(path).toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.blue.shade300
                                              : const Color(0xFF0078D4),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    if (widget.message.message.isNotEmpty)
                      isUserMessage
                          ? Text(
                              widget.message.message,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: settings.getScaledFontSize(14),
                              ),
                            )
                          : SelectionArea(
                              onSelectionChanged:
                                  (SelectedContent? selectedContent) {
                                setState(() {
                                  _selectedText = selectedContent?.plainText;
                                });
                              },
                              contextMenuBuilder:
                                  (context, selectableRegionState) {
                                // Get the default button items (Copy, Select All, etc.)
                                final List<ContextMenuButtonItem> buttonItems =
                                    selectableRegionState
                                        .contextMenuButtonItems;

                                // Add native iOS/Android actions if there's selected text
                                if (_selectedText != null &&
                                    _selectedText!.isNotEmpty) {
                                  // Share button (native)
                                  buttonItems.add(ContextMenuButtonItem(
                                    onPressed: () async {
                                      ContextMenuController.removeAny();

                                      // Get the position for iOS share sheet
                                      final RenderBox? renderBox = context
                                          .findRenderObject() as RenderBox?;
                                      final Rect sharePositionOrigin =
                                          renderBox != null
                                              ? Rect.fromPoints(
                                                  renderBox.localToGlobal(
                                                      Offset.zero),
                                                  renderBox.localToGlobal(
                                                      renderBox.size
                                                          .bottomRight(
                                                              Offset.zero)),
                                                )
                                              : const Rect.fromLTWH(0, 0, 1, 1);

                                      await SharePlus.instance.share(
                                        ShareParams(
                                          text: _selectedText!,
                                          sharePositionOrigin:
                                              sharePositionOrigin,
                                        ),
                                      );
                                    },
                                    type: ContextMenuButtonType.share,
                                  ));

                                  // Look Up button (opens Wikipedia/dictionary)
                                  buttonItems.add(ContextMenuButtonItem(
                                    onPressed: () async {
                                      ContextMenuController.removeAny();

                                      if (_selectedText != null &&
                                          _selectedText!.isNotEmpty) {
                                        // Open Wikipedia for Look Up (similar to native iOS behavior)
                                        final wikiUrl = Uri.parse(
                                            'https://en.m.wikipedia.org/wiki/Special:Search?search=${Uri.encodeComponent(_selectedText!)}');
                                        await launchUrl(wikiUrl,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    type: ContextMenuButtonType.lookUp,
                                  ));

                                  // Search Web button (opens web search)
                                  buttonItems.add(ContextMenuButtonItem(
                                    onPressed: () async {
                                      ContextMenuController.removeAny();

                                      if (_selectedText != null &&
                                          _selectedText!.isNotEmpty) {
                                        final searchUrl = Uri.parse(
                                            'https://www.google.com/search?q=${Uri.encodeComponent(_selectedText!)}');
                                        await launchUrl(searchUrl,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    type: ContextMenuButtonType.searchWeb,
                                  ));
                                }

                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  anchors:
                                      selectableRegionState.contextMenuAnchors,
                                  buttonItems: buttonItems,
                                );
                              },
                              child: MarkdownBody(
                                data: widget.message.message,
                                imageBuilder: (uri, title, alt) {
                                  // Custom image builder that handles missing local files safely and makes images clickable
                                  if (uri.scheme.isEmpty ||
                                      uri.scheme == 'file') {
                                    // Local file path
                                    final path = uri.scheme.isEmpty
                                        ? uri.toString()
                                        : uri.path;
                                    final file = File(path);

                                    // If file doesn't exist, return empty container (skip the image)
                                    if (!file.existsSync()) {
                                      return SizedBox
                                          .shrink(); // Invisible widget that takes no space
                                    }

                                    // File exists, show it safely with click handler
                                    return GestureDetector(
                                      onTap: () {
                                        // Show image in gallery dialog for saving
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black,
                                          builder: (_) => ImageGalleryDialog(
                                            imagePaths: [path],
                                            initialIndex: 0,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Stack(
                                            children: [
                                              Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  // If there's an error loading the file, also skip it
                                                  return SizedBox.shrink();
                                                },
                                              ),
                                              // Hover effect for clickable indication
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.zoom_in,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Network image - also make it clickable
                                    final imageUrl = uri.toString();
                                    return GestureDetector(
                                      onTap: () {
                                        // Show network image in gallery dialog for saving
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black,
                                          builder: (_) => ImageGalleryDialog(
                                            imagePaths: [imageUrl],
                                            initialIndex: 0,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Stack(
                                            children: [
                                              Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    height: 200,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  // For network images that fail to load, also skip them
                                                  return SizedBox.shrink();
                                                },
                                              ),
                                              // Hover effect for clickable indication
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.zoom_in,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: settings.getScaledFontSize(14),
                                    height: 1.4,
                                  ),
                                  a: TextStyle(
                                    color: Color(0xFF0078D4),
                                    decoration: TextDecoration.underline,
                                    fontSize: settings.getScaledFontSize(14),
                                  ),
                                  em: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: settings.getScaledFontSize(14),
                                  ),
                                  h1: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: settings.getScaledFontSize(18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h2: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: settings.getScaledFontSize(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h3: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: settings.getScaledFontSize(15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  code: TextStyle(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade100,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontFamily: 'monospace',
                                    fontSize: settings.getScaledFontSize(12),
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  blockquote: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: settings.getScaledFontSize(14),
                                  ),
                                  listBullet: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: settings.getScaledFontSize(14),
                                  ),
                                ),
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    if (href.endsWith('.pdf') &&
                                        File(href).existsSync()) {
                                      await OpenFile.open(href);
                                    } else {
                                      final isImage = href.endsWith('.png') ||
                                          href.endsWith('.jpg') ||
                                          href.endsWith('.jpeg') ||
                                          href.endsWith('.gif') ||
                                          href.contains('oaidalleapiprodscus');
                                      if (isImage) {
                                        _showSingleImagePreview(context, href);
                                      } else {
                                        final uri = Uri.tryParse(href);
                                        if (uri != null &&
                                            await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      }
                                    }
                                  }
                                },
                              ),
                            ),

                    // Location results are now handled separately in the chat screen
                    // No longer embedded in message bubbles
                  ],
                ),
              ),
            ],
          ),
          if (widget.translatedMessages.containsKey(widget.messageKey) &&
              widget.translatedMessages[widget.messageKey] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 8.0, right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.amber.shade900.withOpacity(0.3)
                      : Colors.yellow[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.amber.shade600
                        : (Colors.yellow[700] ?? Colors.orange),
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.translatedMessages[widget.messageKey] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: settings.getScaledFontSize(15),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.translatedMessages.remove(widget.messageKey);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0, top: 2.0),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIMessageActions() {
    // For review request messages, show special review buttons
    if (widget.message.messageType == MessageType.reviewRequest) {
      return _buildReviewRequestButtons();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Copy
          _buildActionButton(
            icon: Icons.copy,
            tooltip: "Copy",
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.message.message));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Copied to clipboard"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // 2. Speak
          if (widget.onSpeakWithHighlight != null) ...[
            SizedBox(width: 4),
            _buildActionButton(
              icon: widget.isPlayingAudio
                  ? (widget.message.audioPath == "device_tts"
                      ? Icons.stop_circle
                      : Icons.pause_circle_outline)
                  : Icons.play_circle_outline,
              tooltip: widget.isPlayingAudio
                  ? (widget.message.audioPath == "device_tts"
                      ? "Stop audio"
                      : "Pause audio")
                  : "Play audio",
              onTap: () {
                if (widget.isPlayingAudio) {
                  if (widget.message.audioPath == "device_tts") {
                    widget.onSpeakWithHighlight!(widget.message);
                  } else {
                    widget.onPlayAudio('');
                  }
                } else {
                  widget.onSpeakWithHighlight!(widget.message);
                }
              },
            ),
          ],

          // 3. Report
          SizedBox(width: 4),
          _buildReportButton(),

          // 4. More (translate actions only)
          SizedBox(width: 4),
          _buildTranslateMoreButton(),
        ],
      ),
    );
  }

  Widget _buildReviewRequestButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await ReviewService.openAppStoreReview();
              if (widget.onReviewRequested != null) {
                widget.onReviewRequested!();
              }
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Leave Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              // User declined - nothing special happens, just continue
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Maybe Later',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateMoreButton() {
    return _buildActionButton(
      icon: Icons.more_horiz,
      tooltip: "More",
      onTap: _showTranslateActionsSheet,
    );
  }

  void _showTranslateActionsSheet() {
    final options = _getSmartTranslationOptions();
    final primaryOption = options.first;
    final targetLanguage = primaryOption['targetLanguage'] ?? 'English';
    final targetLanguageCode = primaryOption['targetLanguageCode'] ?? 'en';
    final targetLanguageFlag = primaryOption['targetLanguageFlag'] ?? '🌐';
    final recentOptions = options.skip(1).take(2).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1D1D1F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                ListTile(
                  leading: Text(
                    targetLanguageFlag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text('Translate to $targetLanguage'),
                  subtitle: const Text('Quick translate'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (widget.onQuickTranslate != null) {
                      widget.onQuickTranslate!(
                          widget.message, targetLanguageCode, targetLanguage);
                    } else {
                      widget.onTranslate(widget.message);
                    }
                  },
                ),
                if (recentOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent targets',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ...recentOptions.map((option) {
                  final recentLanguage =
                      option['targetLanguage'] ?? option['targetLanguageCode']!;
                  final recentCode = option['targetLanguageCode'] ?? 'en';
                  final recentFlag = option['targetLanguageFlag'] ?? '🌐';
                  return ListTile(
                    leading: Text(
                      recentFlag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text('Translate to $recentLanguage'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (widget.onQuickTranslate != null) {
                        widget.onQuickTranslate!(
                            widget.message, recentCode, recentLanguage);
                      } else {
                        widget.onTranslate(widget.message);
                      }
                    },
                  );
                }),
                Divider(
                  height: 8,
                  thickness: 0.6,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Choose language'),
                  subtitle: const Text('Translate to another language'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (widget.onSelectTranslationLanguage != null) {
                      widget.onSelectTranslationLanguage!(widget.message);
                    } else {
                      widget.onTranslate(widget.message);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getSmartTranslationOptions() {
    try {
      // Get device locale and detected language
      final deviceLocale = Localizations.localeOf(context);
      final deviceLanguage = deviceLocale.languageCode;

      // Simple language detection (you can make this more sophisticated)
      String detectedLanguageCode = 'en';
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(widget.message.message)) {
        detectedLanguageCode = 'zh';
      } else if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]')
          .hasMatch(widget.message.message)) {
        detectedLanguageCode = 'ja';
      } else if (RegExp(r'[\uac00-\ud7af]').hasMatch(widget.message.message)) {
        detectedLanguageCode = 'ko';
      }

      // Get user's translation history for smart suggestions from profile
      final userPreferences =
          ProfileTranslationService.getTranslationHistory(context);

      // Get smart suggestions
      final suggestions = LanguageUtils.getSmartSuggestions(
        detectedLanguageCode: detectedLanguageCode,
        deviceLanguageCode: deviceLanguage,
        deviceLocale: deviceLocale,
        userPreferences: userPreferences,
      );

      if (suggestions.isNotEmpty) {
        return suggestions
            .map((choice) => {
                  'targetLanguage': choice.name,
                  'targetLanguageCode': choice.code,
                  'targetLanguageFlag': choice.flag,
                })
            .toList();
      }

      return [
        {
          'targetLanguage': 'English',
          'targetLanguageCode': 'en',
          'targetLanguageFlag': '🇺🇸',
        }
      ];
    } catch (e) {
      return [
        {
          'targetLanguage': 'English',
          'targetLanguageCode': 'en',
          'targetLanguageFlag': '🇺🇸',
        }
      ];
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.14),
            highlightColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: settings.getScaledFontSize(16),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportButton() {
    return FutureBuilder<bool>(
      future: _isMessageReported(),
      builder: (context, snapshot) {
        final isReported = snapshot.data ?? false;

        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.14),
                highlightColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                onTap: isReported
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        _showReportDialog();
                      }, // Disable if already reported
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isReported ? Icons.flag : Icons.flag_outlined,
                    size: settings.getScaledFontSize(16),
                    color: isReported
                        ? Colors.orange[700]
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _isMessageReported() async {
    try {
      final messageId = widget.message.id;
      if (messageId == null) return false;

      final contentReportService = ContentReportService();
      return await contentReportService.isMessageReported(messageId);
    } catch (e) {
      // print('❌ Error checking if message is reported: $e');
      return false;
    }
  }

  void _showSingleImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => ImageGalleryDialog(
        imagePaths: [imageUrl],
        initialIndex: 0,
      ),
    );
  }

  void _showMessageActions(BuildContext context, ChatMessage message) async {
    if (_lastTapPosition == null) return;
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final double panelWidth = 320;
    final double panelHeight = 80;
    final double left = (_lastTapPosition!.dx - panelWidth / 2)
        .clamp(12.0, overlay.size.width - panelWidth - 12.0);
    final double top = (_lastTapPosition!.dy - panelHeight - 12)
        .clamp(24.0, overlay.size.height - panelHeight - 24.0);
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
                width: overlay.size.width,
                height: overlay.size.height,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.copy,
                        label: AppLocalizations.of(context)!.copy,
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: message.message));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text(AppLocalizations.of(context)!.copied),
                                duration: Duration(seconds: 2)),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        label: AppLocalizations.of(context)!.delete,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onDelete(message);
                        },
                      ),
                      _ActionButton(
                        icon: Icons.translate,
                        label: AppLocalizations.of(context)!.translate,
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onTranslate(message);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getFileIcon(String path) {
    return FileService.getFileIconFromPath(path);
  }

  String _getFileName(String path) {
    return FileService.getFileName(path);
  }

  String _getFileExtension(String path) {
    return FileService.getFileExtension(path);
  }

  Future<void> _openFile(String path) async {
    try {
      // print('[ChatMessageWidget] Attempting to open file: $path');

      // Check if file exists first
      final file = File(path);
      if (!file.existsSync()) {
        // print('[ChatMessageWidget] File does not exist: $path');

        // Show a helpful error message to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'File not found. The file may have been moved or deleted.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Get file size for logging
      final fileSize = await file.length();
      // print('[ChatMessageWidget] Opening file: ${file.path} (${fileSize} bytes)');

      final result = await OpenFile.open(path);
      // print('[ChatMessageWidget] OpenFile result: ${result.type} - ${result.message}');

      // Handle specific result types
      switch (result.type) {
        case ResultType.done:
          // print('[ChatMessageWidget] File opened successfully');
          break;
        case ResultType.noAppToOpen:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'No app available to open this file type. Please install an appropriate app.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          break;
        case ResultType.fileNotFound:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'File not found. The file may have been moved or deleted.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          break;
        case ResultType.permissionDenied:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Permission denied. Unable to access the file.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          break;
        case ResultType.error:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error opening file: ${result.message}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          break;
      }
    } catch (e) {
      // print('[ChatMessageWidget] Exception opening file: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open file. Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildSafeLocalImage(String path, double width, double height) {
    final file = File(path);

    // Check if file exists before trying to load it
    if (!file.existsSync()) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: width * 0.3,
            ),
            SizedBox(height: 4),
            Text(
              'Image not found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Image.file(
      file,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // print('Error loading local image: $error');
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.grey.shade400,
                size: width * 0.3,
              ),
              SizedBox(height: 4),
              Text(
                'Failed to load',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Removed _extractSearchQueryFromMessage - now handled in chat screen

  // Avatar building methods
  Widget _buildUserAvatar() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final selectedProfile = profileProvider.profiles
                .where(
                  (p) => p.id == profileProvider.selectedProfileId,
                )
                .isNotEmpty
            ? profileProvider.profiles
                .firstWhere((p) => p.id == profileProvider.selectedProfileId)
            : null;

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(
              top: 2), // Added top margin for text alignment
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF1E3A5F).withOpacity(
                          0.8), // More visible dark blue for dark mode
                      const Color(0xFF2C5282).withOpacity(
                          0.6), // More visible dark blue for dark mode
                    ]
                  : [
                      const Color(0xFF0078D4)
                          .withOpacity(0.1), // Original for light mode
                      const Color(0xFF0078D4)
                          .withOpacity(0.05), // Original for light mode
                    ],
            ),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C5282)
                      .withOpacity(0.8) // More visible border for dark mode
                  : const Color(0xFF0078D4)
                      .withOpacity(0.2), // Original for light mode
              width: 1,
            ),
          ),
          child: selectedProfile?.avatarPath != null
              ? FutureBuilder<String?>(
                  future: _resolveUserAvatarPath(selectedProfile!.avatarPath),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        radius: 16,
                        backgroundImage: FileImage(File(snapshot.data!)),
                      );
                    }
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          Colors.transparent, // Transparent like in settings
                      child: Text(
                        selectedProfile?.name.isNotEmpty == true
                            ? selectedProfile!.name
                                .substring(0, 1)
                                .toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600, // w600 like in settings
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // White text for dark mode
                              : const Color(
                                  0xFF0078D4), // Blue text for light mode
                        ),
                      ),
                    );
                  },
                )
              : CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      Colors.transparent, // Transparent like in settings
                  child: Text(
                    selectedProfile?.name.isNotEmpty == true
                        ? selectedProfile!.name.substring(0, 1).toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600, // w600 like in settings
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // White text for dark mode
                          : const Color(0xFF0078D4), // Blue text for light mode
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAIAvatar() {
    return Consumer2<ProfileProvider, AIPersonalityProvider>(
      builder: (context, profileProvider, aiPersonalityProvider, child) {
        final currentProfileId = profileProvider.selectedProfileId;
        final aiPersonality = currentProfileId != null
            ? aiPersonalityProvider.getPersonalityForProfile(currentProfileId)
            : null;

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(
              top: 2), // Added top margin for text alignment
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0078D4)
                    .withOpacity(0.1), // Restored blue gradient
                const Color(0xFF0078D4)
                    .withOpacity(0.05), // Restored blue gradient
              ],
            ),
            border: Border.all(
              color: const Color(0xFF0078D4)
                  .withOpacity(0.2), // Restored blue border
              width: 1,
            ),
          ),
          child: aiPersonality?.avatarPath != null
              ? FutureBuilder<String?>(
                  future: _resolveAIAvatarPath(aiPersonality!.avatarPath),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        radius: 16,
                        backgroundImage: FileImage(File(snapshot.data!)),
                      );
                    }
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/icon/hao_avatar.png'),
                    );
                  },
                )
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/icon/hao_avatar.png'),
                ),
        );
      },
    );
  }

  Future<String?> _resolveUserAvatarPath(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    // If it's already an absolute path and exists, use it
    if (avatarPath.startsWith('/') && File(avatarPath).existsSync()) {
      return avatarPath;
    }

    // If it's a relative path, resolve it relative to app documents directory
    if (avatarPath.startsWith('profiles/')) {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$avatarPath';
      if (File(fullPath).existsSync()) {
        return fullPath;
      }
    }

    return null;
  }

  Future<String?> _resolveAIAvatarPath(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    // If it's already an absolute path and exists, use it
    if (avatarPath.startsWith('/') && File(avatarPath).existsSync()) {
      return avatarPath;
    }

    // If it's a relative path, resolve it relative to app documents directory
    if (avatarPath.startsWith('ai_avatars/')) {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$avatarPath';
      if (File(fullPath).existsSync()) {
        return fullPath;
      }
    }

    return null;
  }

  /// Show the content report dialog for AI messages
  void _showReportDialog() {
    // Only allow reporting of AI messages with valid IDs
    if (widget.message.isUserMessage || widget.message.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This message cannot be reported.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ContentReportDialog(
        message: widget.message,
        onReportSubmitted: () {
          // Refresh the widget to show updated report status
          if (mounted) {
            setState(() {
              // This will trigger a rebuild to show reported indicators
            });
          }
        },
      ),
    );
  }

  /// Get report status for this message
  Future<Map<String, dynamic>> _getMessageReportStatus() async {
    if (widget.message.id == null || widget.message.isUserMessage) {
      return {'isReported': false, 'shouldHide': false};
    }

    try {
      final reportService = ContentReportService();
      final isReported =
          await reportService.isMessageReported(widget.message.id!);

      // Check if message has images (AI-generated images should be hidden when reported)
      final hasImages = widget.message.imagePaths?.isNotEmpty == true;
      final shouldHide = await reportService.shouldHideMessage(
        widget.message.id!,
        hasImages: hasImages,
      );

      return {
        'isReported': isReported,
        'shouldHide': shouldHide,
      };
    } catch (e) {
      // print('❌ Error getting message report status: $e');
      return {'isReported': false, 'shouldHide': false};
    }
  }

  /// Build hidden content warning for reported messages
  Widget _buildHiddenContentWarning() {
    final hasImages = widget.message.imagePaths?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasImages ? Icons.image_not_supported : Icons.visibility_off,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasImages
                      ? 'Image content hidden due to report'
                      : 'Content hidden due to report',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasImages
                ? 'This message contained AI-generated images that were reported as inappropriate.'
                : 'This message has been flagged as inappropriate content.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          // Only show "View original" for text messages, not for image messages
          if (!hasImages) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Show a dialog with the original content
                _showHiddenContentDialog();
              },
              icon: Icon(Icons.visibility, size: 16),
              label: Text('View original'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange[700],
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show dialog with hidden content (for user review)
  void _showHiddenContentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool showImages = false;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Flagged Content'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This content was flagged as inappropriate. View at your own discretion.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show the original message content
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text content
                        if (widget.message.message.isNotEmpty)
                          Text(widget.message.message),

                        // Images handling
                        if (widget.message.imagePaths?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          if (!showImages) ...[
                            // Warning box with show images button
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning,
                                          color: Colors.red[600], size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Contains ${widget.message.imagePaths!.length} flagged image(s)',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          showImages = true;
                                        });
                                      },
                                      icon: Icon(Icons.visibility, size: 16),
                                      label: Text('Show Images'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red[700],
                                        backgroundColor: Colors.red[100],
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Show actual images
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.message.imagePaths!
                                  .where((path) =>
                                      path.startsWith('http') ||
                                      File(path).existsSync())
                                  .map((path) => GestureDetector(
                                        onTap: () {
                                          final imagePaths = widget
                                              .message.imagePaths!
                                              .where((p) =>
                                                  p.startsWith('http') ||
                                                  File(p).existsSync())
                                              .toList();
                                          final initialIndex =
                                              imagePaths.indexOf(path);
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black,
                                            builder: (_) => ImageGalleryDialog(
                                              imagePaths: imagePaths,
                                              initialIndex: initialIndex,
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: path.startsWith('http')
                                              ? Image.network(
                                                  path,
                                                  width: 96,
                                                  height: 96,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 96,
                                                      height: 96,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        color: Colors
                                                            .grey.shade400,
                                                        size: 32,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : _buildSafeLocalImage(
                                                  path, 96, 96),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  showImages = false;
                                });
                              },
                              icon: Icon(Icons.visibility_off, size: 16),
                              label: Text('Hide Images'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF0078D4),
                  size: settings.getScaledFontSize(26),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87),
                    fontSize: settings.getScaledFontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
