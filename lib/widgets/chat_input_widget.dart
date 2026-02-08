import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:haogpt/generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/file_service.dart';
import '../services/subscription_service.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode textInputFocusNode;
  final bool isVoiceInputMode;
  final bool isRecording;
  final bool isSending;
  final List<XFile> pendingImages;
  final List<PlatformFile> pendingFiles;
  final bool isPdfWorkflowActive;
  final int pdfCountdown;
  final String recordButtonText;
  final int recordingDuration;
  final bool isShowingCancelHint;
  final bool isCancelingRecording;

  // Callbacks
  final VoidCallback onToggleInputMode;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final Function(Offset) onRecordingMove;
  final Function(int) onRemovePendingImage;
  final Function(int) onRemovePendingFile;
  final VoidCallback onConvertToPdf;
  final VoidCallback onCancelPdfAutoConversion;
  final Function(bool) onShowAttachmentOptions;
  final VoidCallback onShowFileUploadOptions;
  final Function(String, List<XFile>?, List<PlatformFile>?) onSendMessage;
  final Function(String)? onQuickAction;

  // Add callback for location discovery
  final VoidCallback? onLocationDiscovery;

  // Add callback for PPTX generation
  final VoidCallback? onShowPptxDialog;

  // Add callback for image generation
  final VoidCallback? onShowImageGenerationDialog;

  // Add callback for translation
  final VoidCallback? onShowTranslationDialog;

  // Deep research/thinking mode toggle parameters
  final bool forceDeepResearch;
  final Function(bool) onDeepResearchToggle;

  // Showcase keys for feature highlighting
  final GlobalKey? deepResearchKey;
  final GlobalKey? quickActionsKey;

  // Animation controllers
  final AnimationController sendButtonController;
  final AnimationController micAnimationController;
  final AnimationController recordingPulseController;

  const ChatInputWidget({
    super.key,
    required this.textController,
    required this.textInputFocusNode,
    required this.isVoiceInputMode,
    required this.isRecording,
    required this.isSending,
    required this.pendingImages,
    required this.pendingFiles,
    required this.isPdfWorkflowActive,
    required this.pdfCountdown,
    required this.recordButtonText,
    required this.recordingDuration,
    required this.isShowingCancelHint,
    required this.isCancelingRecording,
    required this.onToggleInputMode,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
    required this.onRecordingMove,
    required this.onRemovePendingImage,
    required this.onRemovePendingFile,
    required this.onConvertToPdf,
    required this.onCancelPdfAutoConversion,
    required this.onShowAttachmentOptions,
    required this.onShowFileUploadOptions,
    required this.onSendMessage,
    required this.sendButtonController,
    required this.micAnimationController,
    required this.recordingPulseController,
    this.onQuickAction,
    this.onLocationDiscovery,
    this.onShowPptxDialog,
    this.onShowImageGenerationDialog,
    this.onShowTranslationDialog,
    required this.forceDeepResearch,
    required this.onDeepResearchToggle,
    this.deepResearchKey,
    this.quickActionsKey,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isMenuExpanded = false;

  // Helper method to send message - centralizes send logic
  void _sendMessage() {
    if (widget.textController.text.trim().isEmpty && widget.pendingImages.isEmpty && widget.pendingFiles.isEmpty) {
      return; // Nothing to send
    }

    // print('[ChatInputWidget] Send triggered');
    // print('[ChatInputWidget] - text: "${widget.textController.text}"');
    // print('[ChatInputWidget] - pendingImages: ${widget.pendingImages.length}');
    // print('[ChatInputWidget] - pendingFiles: ${widget.pendingFiles.length}');
    if (widget.pendingFiles.isNotEmpty) {
      for (int i = 0; i < widget.pendingFiles.length; i++) {
        final file = widget.pendingFiles[i];
        // print('[ChatInputWidget] - file[$i]: ${file.name} (${FileService.formatFileSize(file.size)})');
      }
    }

    widget.sendButtonController.forward().then((_) {
      widget.sendButtonController.reverse();
    });
    final imagesToSend = List<XFile>.from(widget.pendingImages);
    final filesToSend = List<PlatformFile>.from(widget.pendingFiles);
    final text = widget.textController.text;
    widget.textController.clear();
    widget.onSendMessage(text, imagesToSend, filesToSend);
  }

  // Helper method to close/hide keyboard
  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final shortestSide = MediaQuery.of(context).size.height < screenWidth ? MediaQuery.of(context).size.height : screenWidth;
    final isTablet = shortestSide >= 600;
    final isPhoneLandscape = !isTablet && isLandscape;

    // Use smaller padding for phone landscape to save space
    final verticalPadding = isPhoneLandscape ? 6.0 : 12.0;
    final horizontalPadding = isPhoneLandscape ? 12.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image attachments area with quick actions
          if (widget.pendingImages.isNotEmpty) ...[
            _buildImageAttachmentsArea(),
            // Quick action buttons for images (only show if not in PDF workflow)
            if (!widget.isPdfWorkflowActive) _buildQuickActionButtons(),
          ],

          // File attachments area
          if (widget.pendingFiles.isNotEmpty) _buildFileAttachmentsArea(),

          // Text input area - Now at the top like ChatGPT
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: widget.isVoiceInputMode ? _buildVoiceInputButton() : _buildTextInputField(),
          ),

          SizedBox(height: isPhoneLandscape ? 4 : 8),

          // Action buttons row - Below text input like ChatGPT
          _buildActionButtonsRow(isPhoneLandscape),
        ],
      ),
    );
  }

  Widget _buildImageAttachmentsArea() {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.pendingImages.length,
            itemBuilder: (context, index) {
              final image = widget.pendingImages[index];
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show image preview - callback to parent
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => widget.onRemovePendingImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Convert to PDF button or countdown (only show when auto-conversion is active or when in PDF workflow)
          if (widget.pdfCountdown > 0 || widget.isPdfWorkflowActive)
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: widget.pdfCountdown > 0 ? widget.onCancelPdfAutoConversion : (widget.pendingImages.isNotEmpty ? widget.onConvertToPdf : null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.pdfCountdown > 0 ? Colors.orange : const Color(0xFF0078D4),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.pdfCountdown > 0) ...[
                          const Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text("Auto PDF in ${widget.pdfCountdown}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ] else ...[
                          const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.convertToPdf, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileAttachmentsArea() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.pendingFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  // File icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0078D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FileService.getFileIcon(file.extension ?? ''),
                      color: const Color(0xFF0078D4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${file.extension?.toUpperCase() ?? 'FILE'} • ${FileService.formatFileSize(file.size)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Remove button
                  GestureDetector(
                    onTap: () => widget.onRemovePendingFile(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVoiceInputButton() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Calculate scaled dimensions - minimum 60, scaled based on font size
        final scaledHeight = math.max(60.0, settings.getScaledFontSize(60));
        final scaledIconSize = settings.getScaledFontSize(20);
        final scaledSpacing = settings.getScaledFontSize(8);
        final scaledPadding = settings.getScaledFontSize(12);
        final scaledBorderRadius = settings.getScaledFontSize(24);

        return GestureDetector(
          onLongPress: widget.onStartRecording,
          onLongPressEnd: (_) {
            if (widget.isCancelingRecording) {
              widget.onCancelRecording();
            } else {
              widget.onStopRecording();
            }
          },
          onLongPressCancel: widget.onStopRecording,
          // Add vertical drag handling for swipe-to-cancel
          onLongPressMoveUpdate: (details) {
            widget.onRecordingMove(details.offsetFromOrigin);
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: scaledHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isRecording ? Colors.red.shade50 : Colors.grey.shade100,
                gradient: widget.isRecording
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.grey.shade100,
                        ],
                      ),
                borderRadius: BorderRadius.circular(scaledBorderRadius),
                border: Border.all(
                  color: widget.isRecording ? Colors.red : const Color(0xFF0078D4).withOpacity(0.3),
                  width: widget.isRecording ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(scaledBorderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Recording pulse animation
                    if (widget.isRecording && !widget.isCancelingRecording)
                      AnimatedBuilder(
                        animation: widget.recordingPulseController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(scaledBorderRadius),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5 * (1 - widget.recordingPulseController.value)),
                                width: 3.0 * (1 - widget.recordingPulseController.value),
                              ),
                            ),
                          );
                        },
                      ),

                    // Cancel indicator
                    if (widget.isShowingCancelHint)
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: scaledSpacing, vertical: settings.getScaledFontSize(2)),
                          decoration: BoxDecoration(
                            color: widget.isCancelingRecording ? Colors.red : Colors.grey.shade700,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(scaledSpacing),
                              bottomRight: Radius.circular(scaledSpacing),
                            ),
                          ),
                          child: Text(
                            widget.isCancelingRecording ? AppLocalizations.of(context)!.releaseToCancel : AppLocalizations.of(context)!.swipeUpToCancel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(10),
                              fontWeight: widget.isCancelingRecording ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),

                    // Button content
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!widget.isRecording)
                                Icon(
                                  Icons.mic_none_rounded,
                                  size: scaledIconSize,
                                  color: const Color(0xFF0078D4),
                                ),
                              if (!widget.isRecording) SizedBox(width: scaledSpacing),
                              Text(
                                widget.isRecording
                                    ? widget.isCancelingRecording
                                        ? AppLocalizations.of(context)!.cancelRecording
                                        : AppLocalizations.of(context)!.listening
                                    : AppLocalizations.of(context)!.holdToTalk,
                                style: TextStyle(
                                  color: widget.isCancelingRecording
                                      ? Colors.red.shade700
                                      : widget.isRecording
                                          ? Colors.red
                                          : const Color(0xFF0078D4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: settings.getScaledFontSize(16),
                                ),
                              ),
                            ],
                          ),
                          if (!widget.isRecording)
                            Text(
                              AppLocalizations.of(context)!.pressAndHoldToSpeak,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(11),
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Recording icon and duration timer
                    if (widget.isRecording && !widget.isCancelingRecording)
                      Positioned(
                        right: scaledPadding,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: scaledSpacing, vertical: settings.getScaledFontSize(2)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(scaledPadding),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: widget.micAnimationController,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.mic,
                                    color: Colors.red.withOpacity(0.7 + 0.3 * widget.micAnimationController.value),
                                    size: settings.getScaledFontSize(16),
                                  );
                                },
                              ),
                              SizedBox(width: settings.getScaledFontSize(4)),
                              Text(
                                _formattedRecordingTime,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: settings.getScaledFontSize(12),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInputField() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Focus(
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
              // Check if shift key is pressed
              final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

              if (!isShiftPressed) {
                // Enter without shift - send message
                _sendMessage();
                return KeyEventResult.handled;
              }
            }
            // Let default handling occur for all other keys
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: widget.textController,
            focusNode: widget.textInputFocusNode,
            minLines: 1,
            maxLines: 5,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(16),
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.chatInputHint,
              hintStyle: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                color: Colors.grey.shade600,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.send,
            onSubmitted: (value) {
              _sendMessage();
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtonsRow(bool isPhoneLandscape) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Check if we're in a narrow layout (keyboard is showing or small screen)
            final isNarrow = constraints.maxWidth < 280;
            final buttonSpacing = settings.getScaledFontSize(isNarrow ? 4.0 : (isPhoneLandscape ? 8 : 12));

            // Adjust button size based on available width and font scale
            final buttonSize = settings.getScaledFontSize(isNarrow ? 32.0 : (isPhoneLandscape ? 32.0 : 40.0));
            final sendButtonSize = settings.getScaledFontSize(isNarrow ? 32.0 : (isPhoneLandscape ? 32.0 : 40.0));
            final sendIconSize = settings.getScaledFontSize(isNarrow ? 14.0 : (isPhoneLandscape ? 16.0 : 20.0));

            return Container(
              height: isNarrow ? 36 : (isPhoneLandscape ? 36 : 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side buttons - Plus button and web search
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Plus button for features menu
                      () {
                        final button = _buildActionButton(
                          icon: _isMenuExpanded ? Icons.close : Icons.add,
                          onTap: () {
                            setState(() {
                              _isMenuExpanded = !_isMenuExpanded;
                            });
                            if (_isMenuExpanded) {
                              _showFeaturesMenu();
                            }
                          },
                          tooltip: _isMenuExpanded ? 'Close menu' : 'More options',
                          isPhoneLandscape: isPhoneLandscape,
                          size: buttonSize,
                        );

                        // Wrap with Showcase if key is provided
                        if (widget.quickActionsKey != null) {
                          return Showcase(
                            key: widget.quickActionsKey!,
                            title: AppLocalizations.of(context)!.featureShowcaseQuickActionsTitle,
                            description: AppLocalizations.of(context)!.featureShowcaseQuickActionsDesc,
                            targetBorderRadius: BorderRadius.circular(8),
                            tooltipBackgroundColor: const Color(0xFFEF4444),
                            textColor: Colors.white,
                            descTextStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                            titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            child: button,
                          );
                        }
                        return button;
                      }(),

                      SizedBox(width: buttonSpacing.toDouble()),

                      // Deep research/thinking mode toggle button (premium feature)
                      Consumer<SubscriptionService>(
                        builder: (context, subscriptionService, child) {
                          final canUseDeepResearch = subscriptionService.isPremium; // Premium only
                          final isEnabled = widget.forceDeepResearch && canUseDeepResearch;

                          final button = _buildDeepResearchButton(
                            isEnabled: isEnabled,
                            canUseDeepResearch: canUseDeepResearch,
                            onTap: () {
                              if (canUseDeepResearch) {
                                widget.onDeepResearchToggle(!widget.forceDeepResearch);
                              } else {
                                _showDeepResearchUpgradeDialog();
                              }
                            },
                            isPhoneLandscape: isPhoneLandscape,
                            size: buttonSize,
                          );

                          // Wrap with Showcase if key is provided
                          if (widget.deepResearchKey != null) {
                            return Showcase(
                              key: widget.deepResearchKey!,
                              title: AppLocalizations.of(context)!.featureShowcaseDeepResearchTitle,
                              description: AppLocalizations.of(context)!.featureShowcaseDeepResearchDesc,
                              targetBorderRadius: BorderRadius.circular(8),
                              tooltipBackgroundColor: const Color(0xFF8E6CFF),
                              textColor: Colors.white,
                              descTextStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              titleTextStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              child: button,
                            );
                          }
                          return button;
                        },
                      ),
                    ],
                  ),

                  // Right side - mic, keyboard close, and send buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Voice/keyboard toggle - moved to far right
                      _buildActionButton(
                        icon: widget.isVoiceInputMode ? Icons.keyboard_alt_outlined : Icons.settings_voice,
                        onTap: widget.onToggleInputMode,
                        tooltip: widget.isVoiceInputMode ? AppLocalizations.of(context)!.switchToKeyboard : AppLocalizations.of(context)!.switchToVoiceInput,
                        isPhoneLandscape: isPhoneLandscape,
                        size: buttonSize,
                      ),

                      // Add spacing only if keyboard close button will be shown
                      if (!widget.isVoiceInputMode && widget.textInputFocusNode.hasFocus) SizedBox(width: buttonSpacing.toDouble()),

                      // Keyboard close button (only when keyboard is focused and in text mode)
                      if (!widget.isVoiceInputMode && widget.textInputFocusNode.hasFocus)
                        Container(
                          width: sendButtonSize,
                          height: sendButtonSize,
                          child: _buildActionButton(
                            icon: Icons.keyboard_hide,
                            onTap: _closeKeyboard,
                            tooltip: 'Hide keyboard',
                            isPhoneLandscape: isPhoneLandscape,
                            size: buttonSize,
                          ),
                        ),

                      // Add spacing only if send button will be shown
                      if (widget.textController.text.trim().isNotEmpty || widget.pendingImages.isNotEmpty || widget.pendingFiles.isNotEmpty) SizedBox(width: buttonSpacing.toDouble()),

                      // Send button (when there's content to send)
                      if (widget.textController.text.trim().isNotEmpty || widget.pendingImages.isNotEmpty || widget.pendingFiles.isNotEmpty)
                        AnimatedBuilder(
                          animation: widget.sendButtonController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (widget.sendButtonController.value * 0.1),
                              child: Container(
                                width: sendButtonSize,
                                height: sendButtonSize,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0078D4),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.send_rounded, size: sendIconSize),
                                  color: Colors.white,
                                  padding: EdgeInsets.zero,
                                  onPressed: _sendMessage,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build action buttons with consistent style
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? iconColor,
    bool isPhoneLandscape = false,
    double? size,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final scaledButtonSize = size ?? settings.getScaledFontSize(isPhoneLandscape ? 32.0 : 40.0);
        final scaledIconSize = settings.getScaledFontSize(isPhoneLandscape ? 18.0 : 22.0);
        final scaledBorderRadius = settings.getScaledFontSize(4);

        return Container(
          width: scaledButtonSize,
          height: scaledButtonSize,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(scaledBorderRadius),
          ),
          child: Tooltip(
            message: tooltip,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(scaledBorderRadius),
                onTap: onTap,
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF0078D4)),
                    size: scaledIconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Format recording time for display
  String get _formattedRecordingTime {
    final minutes = (widget.recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.recordingDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // New method to build quick action buttons for image attachments
  Widget _buildQuickActionButtons() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with subtle styling
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: settings.getScaledFontSize(16),
                      color: const Color(0xFF0078D4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.quickActions,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0078D4),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons in a scrollable row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickActionChip(
                      icon: Icons.translate,
                      label: 'Translate',
                      color: Colors.blue,
                      onTap: () => _handleQuickAction('Please identify and translate any text you can see in this image to English. If the text is already in English, translate it to the most appropriate language based on the context.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.analytics,
                      label: 'Analyze',
                      color: Colors.green,
                      onTap: () => _handleQuickAction('Please provide a detailed analysis of this image, including what you see, the context, any notable features, and your insights about the content.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.description,
                      label: 'Describe',
                      color: Colors.orange,
                      onTap: () => _handleQuickAction('Please describe this image in detail, including the setting, objects, people, colors, composition, and overall atmosphere of the scene.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.text_fields,
                      label: 'Extract Text',
                      color: Colors.purple,
                      onTap: () => _handleQuickAction('Please extract and transcribe all the text you can see in this image, maintaining the original formatting and structure as much as possible.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.help_outline,
                      label: 'Explain',
                      color: Colors.teal,
                      onTap: () => _handleQuickAction('Please explain what\'s happening in this image and provide context, background information, or educational insights about what you see.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.search,
                      label: 'Identify',
                      color: Colors.indigo,
                      onTap: () => _handleQuickAction('Please identify and name all the objects, people, places, or items you can see in this image. Provide specific names and details where possible.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: settings.getScaledFontSize(16),
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(12),
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleQuickAction(String prompt) {
    // Set the text field with the prompt
    widget.textController.text = prompt;

    // If there's a callback, use it; otherwise, send immediately
    if (widget.onQuickAction != null) {
      widget.onQuickAction!(prompt);
    } else {
      // Automatically send the message with the prompt and attached images
      final imagesToSend = List<XFile>.from(widget.pendingImages);
      final filesToSend = List<PlatformFile>.from(widget.pendingFiles);
      widget.onSendMessage(prompt, imagesToSend, filesToSend);
      widget.textController.clear();
    }
  }

  // Show features menu as a bottom sheet with ChatGPT-like styling
  void _showFeaturesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
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
                      SizedBox(height: 12),

                      // Primary attachment options - ChatGPT style
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Consumer<SubscriptionService>(
                                builder: (context, subscriptionService, child) {
                                  final remaining = subscriptionService.remainingImageAnalysis;
                                  final isPremium = subscriptionService.isPremium;
                                  final canUse = isPremium || subscriptionService.canUseImageAnalysis;

                                  return _buildPrimaryAttachmentOption(
                                    icon: Icons.photo_camera,
                                    label: AppLocalizations.of(context)!.quickActionAskFromPhoto,
                                    isPremium: true,
                                    canUse: canUse,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _isMenuExpanded = false;
                                      });
                                      if (canUse) {
                                        widget.onShowAttachmentOptions(false);
                                      } else {
                                        _showUpgradeDialog(context);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildPrimaryAttachmentOption(
                                icon: Icons.folder,
                                label: AppLocalizations.of(context)!.quickActionAskFromFile,
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _isMenuExpanded = false;
                                  });
                                  widget.onShowFileUploadOptions();
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildPrimaryAttachmentOption(
                                icon: Icons.picture_as_pdf,
                                label: AppLocalizations.of(context)!.quickActionScanToPdf,
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _isMenuExpanded = false;
                                  });
                                  widget.onShowAttachmentOptions(true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      // Feature options - Single column ChatGPT style
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Image Generation
                            Consumer<SubscriptionService>(
                              builder: (context, subscriptionService, child) {
                                final remaining = subscriptionService.remainingImageGenerations;
                                final isPremium = subscriptionService.isPremium;
                                final canUse = isPremium || subscriptionService.canUseImageGeneration;

                                return _buildChatGPTStyleOption(
                                  icon: Icons.brush,
                                  title: AppLocalizations.of(context)!.quickActionGenerateImage,
                                  subtitle: null,
                                  isPremium: true,
                                  canUse: canUse,
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isMenuExpanded = false;
                                    });
                                    if (canUse && widget.onShowImageGenerationDialog != null) {
                                      widget.onShowImageGenerationDialog!();
                                    } else if (!canUse) {
                                      _showUpgradeDialog(context);
                                    }
                                  },
                                );
                              },
                            ),

                            // Translation
                            _buildChatGPTStyleOption(
                              icon: Icons.translate,
                              title: AppLocalizations.of(context)!.translate,
                              subtitle: AppLocalizations.of(context)!.quickActionTranslateSubtitle,
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _isMenuExpanded = false;
                                });
                                if (widget.onShowTranslationDialog != null) {
                                  widget.onShowTranslationDialog!();
                                }
                              },
                            ),

                            // Places Explorer
                            Consumer<SubscriptionService>(
                              builder: (context, subscriptionService, child) {
                                final remaining = subscriptionService.remainingPlacesExplorer;
                                final isPremium = subscriptionService.isPremium;
                                final canUse = isPremium || subscriptionService.canUsePlacesExplorer;

                                return _buildChatGPTStyleOption(
                                  icon: Icons.explore,
                                  title: AppLocalizations.of(context)!.quickActionFindPlaces,
                                  subtitle: null,
                                  isPremium: true,
                                  canUse: canUse,
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isMenuExpanded = false;
                                    });
                                    if (canUse && widget.onLocationDiscovery != null) {
                                      widget.onLocationDiscovery!();
                                    } else if (!canUse) {
                                      _showUpgradeDialog(context);
                                    }
                                  },
                                );
                              },
                            ),

                            // Presentation Maker removed - feature deprecated
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Always reset the menu state when sheet is dismissed
      setState(() {
        _isMenuExpanded = false;
      });
    });
  }

  // ChatGPT-style attachment option buttons
  Widget _buildPrimaryAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
    bool isPremium = false,
    bool canUse = true,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isCompactWidth = screenWidth < 390;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canUse ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 60, // Reduced height since we combined title and subtitle
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade800 : Colors.grey.shade700) : (canUse ? Colors.grey.shade50 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade600 : Colors.grey.shade500) : (canUse ? Colors.grey.shade200 : Colors.grey.shade300),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade700 : Colors.grey.shade600) : (canUse ? Colors.white : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: canUse
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          size: 14,
                          color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.white70 : Colors.grey.shade400) : (canUse ? Colors.grey.shade700 : Colors.grey.shade500),
                        ),
                      ),
                      SizedBox(height: 4),
                      // Combined title and subtitle in one line
                      Text(
                        subtitle != null ? '$label - $subtitle' : label,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(isCompactWidth ? 9 : 10),
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.white70 : Colors.grey.shade400) : (canUse ? Colors.grey.shade700 : Colors.grey.shade500),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // PRO badge positioned at top right corner of the card
                  if (isPremium)
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ChatGPT-style feature option (single column, cleaner design)
  Widget _buildChatGPTStyleOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
    bool canUse = true,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canUse ? onTap : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade800 : Colors.grey.shade700) : (canUse ? Colors.white : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade700 : Colors.grey.shade600) : (canUse ? Colors.grey.shade100 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.white70 : Colors.grey.shade400) : (canUse ? Colors.grey.shade700 : Colors.grey.shade500),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.white : Colors.grey.shade400) : (canUse ? Colors.black87 : Colors.grey.shade600),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isPremium) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(12),
                                color: Theme.of(context).brightness == Brightness.dark ? (canUse ? Colors.grey.shade400 : Colors.grey.shade500) : (canUse ? Colors.grey.shade600 : Colors.grey.shade500),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow indicator
                    if (canUse)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isDisabled = false,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                color: isDisabled ? Colors.grey.shade50 : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDisabled ? Colors.grey.shade300 : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isDisabled ? Colors.grey.shade500 : color,
                        ),
                        if (isPremium)
                          Positioned(
                            top: 1,
                            right: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(13),
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey.shade600 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(11),
                      color: isDisabled ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 900 || screenWidth < 400;
            final isVerySmallScreen = screenHeight < 860 && screenWidth < 400;

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 6 : 8, vertical: isVerySmallScreen ? 3 : 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : 12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.upgradeNow,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'This feature is available for premium users. Upgrade now to unlock unlimited access.',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                  height: 1.4,
                ),
              ),
              actions: [
                if (isSmallScreen)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.maybeLater,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: isVerySmallScreen ? 6 : 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.upgradeNow,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, '/subscription');
                          },
                        ),
                      ),
                    ],
                  )
                else ...[
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.maybeLater,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.upgradeNow,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/subscription');
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeepResearchButton({
    required bool isEnabled,
    required bool canUseDeepResearch,
    required VoidCallback onTap,
    required bool isPhoneLandscape,
    required double size,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final scaledButtonSize = size;
        final scaledIconSize = settings.getScaledFontSize(isPhoneLandscape ? 18.0 : 22.0);
        final scaledBorderRadius = settings.getScaledFontSize(4);

        return Container(
          width: scaledButtonSize,
          height: scaledButtonSize,
          decoration: BoxDecoration(
            color: isEnabled
                ? const Color(0xFF0078D4).withOpacity(0.1)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(scaledBorderRadius),
            border: isEnabled ? Border.all(color: const Color(0xFF0078D4), width: 1) : null,
          ),
          child: Tooltip(
            message: canUseDeepResearch ? (isEnabled ? 'Disable deep research mode' : 'Enable deep research mode (gpt-5.2 reasoning)') : 'Deep research (Premium only)',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(scaledBorderRadius),
                onTap: onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.psychology,
                      color: isEnabled
                          ? const Color(0xFF0078D4)
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF0078D4),
                      size: scaledIconSize,
                    ),
                    // Premium indicator for free users
                    if (!canUseDeepResearch)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeepResearchUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.deepResearchUpgradeTitle,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.deepResearchUpgradeDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.maybeLater,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.upgradeNow,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/subscription');
              },
            ),
          ],
        );
      },
    );
  }
}
