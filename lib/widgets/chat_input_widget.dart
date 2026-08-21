import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:haogpt/generated/app_localizations.dart';
import '../models/thinking_level.dart';
import '../providers/settings_provider.dart';
import '../services/file_service.dart';
import '../services/subscription_service.dart';
import '../core/theme/howai_theme.dart';
import '../core/accessibility/motion_preferences.dart';

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

  // Add callback for ElevenLabs voice call
  final VoidCallback? onSpeakCall;

  // Paid GPT-5.6 reasoning control.
  final ThinkingLevel thinkingLevel;
  final ValueChanged<ThinkingLevel> onThinkingLevelChanged;

  // Showcase keys for feature highlighting
  final GlobalKey? quickActionsKey;
  final GlobalKey? speakKey;

  // Animation controllers
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
    required this.micAnimationController,
    required this.recordingPulseController,
    this.onQuickAction,
    this.onLocationDiscovery,
    this.onShowPptxDialog,
    this.onShowImageGenerationDialog,
    this.onShowTranslationDialog,
    this.onSpeakCall,
    required this.thinkingLevel,
    required this.onThinkingLevelChanged,
    this.quickActionsKey,
    this.speakKey,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isMenuExpanded = false;

  // Helper method to send message - centralizes send logic
  void _sendMessage() {
    if (widget.textController.text.trim().isEmpty &&
        widget.pendingImages.isEmpty &&
        widget.pendingFiles.isEmpty) {
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

    final imagesToSend = List<XFile>.from(widget.pendingImages);
    final filesToSend = List<PlatformFile>.from(widget.pendingFiles);
    final text = widget.textController.text;
    widget.textController.clear();
    widget.onSendMessage(text, imagesToSend, filesToSend);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.howaiColors;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final shortestSide = MediaQuery.of(context).size.height < screenWidth
        ? MediaQuery.of(context).size.height
        : screenWidth;
    final isTablet = shortestSide >= 600;
    final isPhoneLandscape = !isTablet && isLandscape;
    // Keep the composer compact; the parent SafeArea already provides the
    // required iPhone home-indicator clearance.
    final verticalPadding = isPhoneLandscape ? 4.0 : 5.0;
    final horizontalPadding = isPhoneLandscape ? 12.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.canvas,
      ),
      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
          horizontalPadding, verticalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            key: const ValueKey<String>('composer_accessories'),
            duration: motionDuration(context, HowAIMotion.standard),
            curve: HowAIMotion.enterCurve,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image attachments area with quick actions
                if (widget.pendingImages.isNotEmpty) ...[
                  _buildImageAttachmentsArea(),
                  if (!widget.isPdfWorkflowActive) _buildQuickActionButtons(),
                ],

                if (widget.pendingFiles.isNotEmpty)
                  _buildFileAttachmentsArea(),

                if (widget.thinkingLevel != ThinkingLevel.auto)
                  _buildThinkingLevelChip(),
              ],
            ),
          ),

          // One adaptive composer surface: tools on the left, text or
          // push-to-talk in the middle, and voice/send on the right.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.textController,
            builder: (context, value, child) =>
                _buildAdaptiveComposer(isPhoneLandscape),
          ),
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
                      key: ValueKey<String>('pending_image_thumbnail_$index'),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: ResizeImage.resizeIfNeeded(
                            256,
                            256,
                            FileImage(File(image.path)),
                          ),
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
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
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
                  onTap: widget.pdfCountdown > 0
                      ? widget.onCancelPdfAutoConversion
                      : (widget.pendingImages.isNotEmpty
                          ? widget.onConvertToPdf
                          : null),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.pdfCountdown > 0
                          ? Colors.orange
                          : const Color(0xFF0078D4),
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
                          const Icon(Icons.timer,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text("Auto PDF in ${widget.pdfCountdown}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ] else ...[
                          const Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.convertToPdf,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
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

  Widget _buildVoiceInputButton({bool compact = false}) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Calculate scaled dimensions - minimum 60, scaled based on font size
        final scaledHeight = compact
            ? math.max(44.0, settings.getScaledFontSize(44))
            : math.max(60.0, settings.getScaledFontSize(60));
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
              decoration: compact
                  ? null
                  : BoxDecoration(
                      color: widget.isRecording
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
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
                        color: widget.isRecording
                            ? Colors.red
                            : const Color(0xFF0078D4).withOpacity(0.3),
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
                              borderRadius:
                                  BorderRadius.circular(scaledBorderRadius),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5 *
                                    (1 -
                                        widget.recordingPulseController.value)),
                                width: 3.0 *
                                    (1 - widget.recordingPulseController.value),
                              ),
                            ),
                          );
                        },
                      ),

                    // Cancel indicator
                    if (widget.isShowingCancelHint && !compact)
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: scaledSpacing,
                              vertical: settings.getScaledFontSize(2)),
                          decoration: BoxDecoration(
                            color: widget.isCancelingRecording
                                ? Colors.red
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(scaledSpacing),
                              bottomRight: Radius.circular(scaledSpacing),
                            ),
                          ),
                          child: Text(
                            widget.isCancelingRecording
                                ? AppLocalizations.of(context)!.releaseToCancel
                                : AppLocalizations.of(context)!.swipeUpToCancel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(10),
                              fontWeight: widget.isCancelingRecording
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                              if (!widget.isRecording)
                                SizedBox(width: scaledSpacing),
                              Text(
                                widget.isRecording
                                    ? widget.isCancelingRecording
                                        ? AppLocalizations.of(context)!
                                            .cancelRecording
                                        : AppLocalizations.of(context)!
                                            .listening
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
                          if (!widget.isRecording && !compact)
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
                          padding: EdgeInsets.symmetric(
                              horizontal: scaledSpacing,
                              vertical: settings.getScaledFontSize(2)),
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
                                    color: Colors.red.withOpacity(0.7 +
                                        0.3 *
                                            widget
                                                .micAnimationController.value),
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
        final colors = context.howaiColors;
        return Focus(
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
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
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.chatInputHint,
              hintStyle: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                color: colors.textTertiary,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.send,
            onTapOutside: (_) => widget.textInputFocusNode.unfocus(),
            onSubmitted: (value) {
              _sendMessage();
            },
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveComposer(bool isPhoneLandscape) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final hasDraft = widget.textController.text.trim().isNotEmpty ||
            widget.pendingImages.isNotEmpty ||
            widget.pendingFiles.isNotEmpty;
        final buttonSize = settings
            .getScaledFontSize(
              isPhoneLandscape ? 38 : 42,
            )
            .clamp(44.0, 52.0)
            .toDouble();
        final canSend = hasDraft && !widget.isSending;

        Widget toolsButton = _buildComposerControl(
          icon: _isMenuExpanded ? Icons.close : Icons.add,
          onTap: () {
            setState(() => _isMenuExpanded = true);
            _showFeaturesMenu();
          },
          tooltip: AppLocalizations.of(context)!.quickActions,
          size: buttonSize,
        );
        if (widget.quickActionsKey != null) {
          toolsButton = Showcase(
            key: widget.quickActionsKey!,
            title:
                AppLocalizations.of(context)!.featureShowcaseQuickActionsTitle,
            description:
                AppLocalizations.of(context)!.featureShowcaseQuickActionsDesc,
            child: toolsButton,
          );
        }

        Widget trailingControl;
        if (widget.isVoiceInputMode) {
          trailingControl = _buildComposerControl(
            icon: Icons.keyboard_alt_outlined,
            onTap: widget.onToggleInputMode,
            tooltip: AppLocalizations.of(context)!.switchToKeyboard,
            size: buttonSize,
          );
        } else if (hasDraft) {
          trailingControl = _buildComposerControl(
            icon: Icons.arrow_upward_rounded,
            onTap: canSend ? _sendMessage : null,
            tooltip: AppLocalizations.of(context)!.send,
            size: buttonSize,
            isPrimary: canSend,
          );
        } else {
          final dictationControl = _buildComposerControl(
            icon: Icons.mic_none_rounded,
            onTap: widget.onToggleInputMode,
            tooltip: AppLocalizations.of(context)!.voiceInput,
            size: buttonSize,
          );
          Widget voiceAgentControl = _buildComposerControl(
            icon: Icons.graphic_eq_rounded,
            onTap: widget.onSpeakCall ?? widget.onToggleInputMode,
            tooltip: AppLocalizations.of(context)!.speakButtonTooltip,
            size: buttonSize,
          );
          if (widget.speakKey != null) {
            voiceAgentControl = Showcase(
              key: widget.speakKey!,
              title: AppLocalizations.of(context)!.speakButtonLabel,
              description: AppLocalizations.of(context)!.voiceCallFeatureDesc,
              child: voiceAgentControl,
            );
          }
          trailingControl = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dictationControl,
              const SizedBox(width: 2),
              voiceAgentControl,
            ],
          );
        }

        final colors = context.howaiColors;
        final composer = Container(
          key: const ValueKey<String>('adaptive_composer'),
          constraints: BoxConstraints(
            minHeight: buttonSize + 8,
          ),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              toolsButton,
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedSwitcher(
                  key: const ValueKey<String>('composer-mode-switcher'),
                  duration: motionDuration(context, HowAIMotion.quick),
                  switchInCurve: HowAIMotion.enterCurve,
                  switchOutCurve: HowAIMotion.exitCurve,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: KeyedSubtree(
                    key: ValueKey<String>(
                      widget.isVoiceInputMode ? 'voice-input' : 'text-input',
                    ),
                    child: widget.isVoiceInputMode
                        ? _buildVoiceInputButton(compact: true)
                        : _buildTextInputField(),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: (buttonSize * 2) + 2,
                height: buttonSize,
                child: AnimatedSwitcher(
                  key: const ValueKey<String>('adaptive-composer-switcher'),
                  duration: motionDuration(context, HowAIMotion.quick),
                  switchInCurve: HowAIMotion.enterCurve,
                  switchOutCurve: HowAIMotion.exitCurve,
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: HowAIMotion.enterCurve,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey<String>(
                      widget.isVoiceInputMode
                          ? 'keyboard'
                          : hasDraft
                              ? 'send'
                              : 'voice-actions',
                    ),
                    child: trailingControl,
                  ),
                ),
              ),
            ],
          ),
        );
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPhoneLandscape ? 0 : 8,
          ),
          child: composer,
        );
      },
    );
  }

  Widget _buildThinkingLevelChip() {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InputChip(
          visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          labelPadding: const EdgeInsets.only(left: 2),
          avatar: Icon(
            Icons.psychology_outlined,
            size: 15,
            color: colorScheme.primary,
          ),
          label: Text(
            _thinkingLevelLabel(widget.thinkingLevel),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onDeleted: () => widget.onThinkingLevelChanged(ThinkingLevel.auto),
          deleteIcon: const Icon(Icons.close, size: 15),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
          backgroundColor:
              colorScheme.secondaryContainer.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  Widget _buildComposerControl({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    required double size,
    bool isPrimary = false,
  }) {
    final colors = context.howaiColors;
    final enabled = onTap != null;

    if (!isPrimary) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(size / 2),
                child: Center(
                  child: Icon(
                    icon,
                    size: size * 0.52,
                    color: enabled ? colors.textPrimary : colors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: onTap,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: colors.textPrimary,
            foregroundColor: colors.canvas,
            disabledBackgroundColor: colors.surfaceStrong,
            disabledForegroundColor: colors.textTertiary,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          icon: Icon(icon, size: size * 0.52),
        ),
      ),
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
                      onTap: () => _handleQuickAction(
                          'Please identify and translate any text you can see in this image to English. If the text is already in English, translate it to the most appropriate language based on the context.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.analytics,
                      label: 'Analyze',
                      color: Colors.green,
                      onTap: () => _handleQuickAction(
                          'Please provide a detailed analysis of this image, including what you see, the context, any notable features, and your insights about the content.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.description,
                      label: 'Describe',
                      color: Colors.orange,
                      onTap: () => _handleQuickAction(
                          'Please describe this image in detail, including the setting, objects, people, colors, composition, and overall atmosphere of the scene.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.text_fields,
                      label: 'Extract Text',
                      color: Colors.purple,
                      onTap: () => _handleQuickAction(
                          'Please extract and transcribe all the text you can see in this image, maintaining the original formatting and structure as much as possible.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.help_outline,
                      label: 'Explain',
                      color: Colors.teal,
                      onTap: () => _handleQuickAction(
                          'Please explain what\'s happening in this image and provide context, background information, or educational insights about what you see.'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.search,
                      label: 'Identify',
                      color: Colors.indigo,
                      onTap: () => _handleQuickAction(
                          'Please identify and name all the objects, people, places, or items you can see in this image. Provide specific names and details where possible.'),
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
    final hostContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.howaiColors.canvas,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final colors = context.howaiColors;
            return Container(
              key: const ValueKey<String>('quick_actions_sheet'),
              decoration: BoxDecoration(
                color: colors.canvas,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.quickActions,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: settings.getScaledFontSize(18),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Primary attachment options - ChatGPT style
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          key: const ValueKey<String>(
                              'attachment_actions_group'),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Consumer<SubscriptionService>(
                                  builder:
                                      (context, subscriptionService, child) {
                                    final isPremium =
                                        subscriptionService.isPremium;
                                    final canUse = isPremium ||
                                        subscriptionService.canUseImageAnalysis;

                                    return _buildPrimaryAttachmentOption(
                                      icon: Icons.photo_camera,
                                      label: AppLocalizations.of(context)!
                                          .quickActionAskFromPhoto,
                                      isPremium: !canUse,
                                      canUse: canUse,
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _isMenuExpanded = false;
                                        });
                                        if (canUse) {
                                          widget.onShowAttachmentOptions(false);
                                        } else {
                                          _showUpgradeDialog(hostContext);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              _buildActionDivider(vertical: true),
                              Expanded(
                                child: _buildPrimaryAttachmentOption(
                                  icon: Icons.folder,
                                  label: AppLocalizations.of(context)!
                                      .quickActionAskFromFile,
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isMenuExpanded = false;
                                    });
                                    widget.onShowFileUploadOptions();
                                  },
                                ),
                              ),
                              _buildActionDivider(vertical: true),
                              Expanded(
                                child: _buildPrimaryAttachmentOption(
                                  icon: Icons.picture_as_pdf,
                                  label: AppLocalizations.of(context)!
                                      .quickActionScanToPdf,
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
                      ),

                      const SizedBox(height: 12),

                      // Feature options - Single column ChatGPT style
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          key: const ValueKey<String>('feature_actions_group'),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Column(
                            children: [
                              // GPT-5.6 thinking level
                              Consumer<SubscriptionService>(
                                builder: (context, subscriptionService, child) {
                                  final canChooseThinking =
                                      subscriptionService.isPremium;

                                  return _buildChatGPTStyleOption(
                                    icon: Icons.psychology,
                                    title: AppLocalizations.of(context)!
                                        .thinkingLevel,
                                    subtitle: _thinkingLevelLabel(
                                        widget.thinkingLevel),
                                    isPremium: !subscriptionService.isPremium,
                                    canUse: canChooseThinking,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _isMenuExpanded = false;
                                      });
                                      if (canChooseThinking) {
                                        _showThinkingLevelMenu();
                                      } else {
                                        _showUpgradeDialog(hostContext);
                                      }
                                    },
                                  );
                                },
                              ),
                              _buildActionDivider(),

                              _buildChatGPTStyleOption(
                                icon: Icons.mic_none_rounded,
                                title: AppLocalizations.of(context)!.voiceInput,
                                subtitle: AppLocalizations.of(context)!
                                    .voiceInputDesc,
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _isMenuExpanded = false);
                                  if (!widget.isVoiceInputMode) {
                                    widget.onToggleInputMode();
                                  }
                                },
                              ),
                              _buildActionDivider(),

                              // Image Generation
                              Consumer<SubscriptionService>(
                                builder: (context, subscriptionService, child) {
                                  final isPremium =
                                      subscriptionService.isPremium;
                                  final canUse = isPremium ||
                                      subscriptionService.canUseImageGeneration;

                                  return _buildChatGPTStyleOption(
                                    icon: Icons.brush,
                                    title: AppLocalizations.of(context)!
                                        .quickActionGenerateImage,
                                    subtitle: null,
                                    isPremium: !canUse,
                                    canUse: canUse,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _isMenuExpanded = false;
                                      });
                                      if (canUse &&
                                          widget.onShowImageGenerationDialog !=
                                              null) {
                                        widget.onShowImageGenerationDialog!();
                                      } else if (!canUse) {
                                        _showUpgradeDialog(hostContext);
                                      }
                                    },
                                  );
                                },
                              ),
                              _buildActionDivider(),

                              // Translation
                              _buildChatGPTStyleOption(
                                icon: Icons.translate,
                                title: AppLocalizations.of(context)!.translate,
                                subtitle: AppLocalizations.of(context)!
                                    .quickActionTranslateSubtitle,
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
                              _buildActionDivider(),

                              // Places Explorer
                              Consumer<SubscriptionService>(
                                builder: (context, subscriptionService, child) {
                                  final isPremium =
                                      subscriptionService.isPremium;
                                  final canUse = isPremium ||
                                      subscriptionService.canUsePlacesExplorer;

                                  return _buildChatGPTStyleOption(
                                    icon: Icons.explore,
                                    title: AppLocalizations.of(context)!
                                        .quickActionFindPlaces,
                                    subtitle: null,
                                    isPremium: !canUse,
                                    canUse: canUse,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _isMenuExpanded = false;
                                      });
                                      if (canUse &&
                                          widget.onLocationDiscovery != null) {
                                        widget.onLocationDiscovery!();
                                      } else if (!canUse) {
                                        _showUpgradeDialog(hostContext);
                                      }
                                    },
                                  );
                                },
                              ),

                              // Presentation Maker removed - feature deprecated
                            ],
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
        final colors = context.howaiColors;
        return Semantics(
          button: true,
          label: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: 82,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: canUse
                                  ? colors.textPrimary
                                  : colors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle != null ? '$label · $subtitle' : label,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(11.5),
                                fontWeight: FontWeight.w500,
                                color: canUse
                                    ? colors.textSecondary
                                    : colors.textTertiary,
                                height: 1.15,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isPremium)
                      PositionedDirectional(
                        top: 7,
                        end: 7,
                        child: _buildPremiumBadge(fontSize: 7.5),
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
        final colors = context.howaiColors;
        return Semantics(
          button: true,
          label: title,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Icon(
                          icon,
                          size: 21,
                          color: canUse
                              ? colors.textSecondary
                              : colors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(15),
                                      fontWeight: FontWeight.w600,
                                      color: canUse
                                          ? colors.textPrimary
                                          : colors.textSecondary,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPremium) ...[
                                  const SizedBox(width: 7),
                                  _buildPremiumBadge(fontSize: 8),
                                ],
                              ],
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(12.5),
                                  color: colors.textSecondary,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionDivider({bool vertical = false}) {
    final colors = context.howaiColors;
    if (vertical) {
      return Container(width: 1, height: 52, color: colors.divider);
    }
    return Container(
      height: 1,
      margin: const EdgeInsetsDirectional.only(start: 54),
      color: colors.divider,
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
                  _buildPremiumBadge(
                    fontSize:
                        settings.getScaledFontSize(isVerySmallScreen ? 10 : 12),
                    compact: false,
                  ),
                  SizedBox(width: isVerySmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.upgradeNow,
                      style: TextStyle(
                        fontSize: settings
                            .getScaledFontSize(isVerySmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                AppLocalizations.of(context)!.premiumFeatureDesc,
                style: TextStyle(
                  fontSize:
                      settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
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
                              fontSize: settings.getScaledFontSize(
                                  isVerySmallScreen ? 14 : 16),
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
                            padding: EdgeInsets.symmetric(
                                vertical: isVerySmallScreen ? 10 : 12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.upgradeNow,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(
                                  isVerySmallScreen ? 14 : 16),
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

  Widget _buildPremiumBadge({
    double fontSize = 8,
    bool compact = true,
  }) {
    final text = AppLocalizations.of(context)!.premiumBadge;
    final colors = context.howaiColors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(compact ? 5 : 7),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: colors.accent,
          letterSpacing: compact ? 0.2 : 0.4,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _thinkingLevelLabel(ThinkingLevel level) {
    final l10n = AppLocalizations.of(context)!;
    return switch (level) {
      ThinkingLevel.auto => l10n.thinkingAuto,
      ThinkingLevel.fast => l10n.thinkingFast,
      ThinkingLevel.balanced => l10n.thinkingBalanced,
      ThinkingLevel.deep => l10n.thinkingDeep,
    };
  }

  void _showThinkingLevelMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.thinkingLevel,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.thinkingLevelNote,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                for (final level in ThinkingLevel.values)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(_thinkingLevelIcon(level)),
                    title: Text(_thinkingLevelLabel(level)),
                    subtitle: level == ThinkingLevel.auto
                        ? Text(l10n.recommended)
                        : null,
                    trailing: widget.thinkingLevel == level
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      widget.onThinkingLevelChanged(level);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _thinkingLevelIcon(ThinkingLevel level) => switch (level) {
        ThinkingLevel.auto => Icons.auto_awesome_outlined,
        ThinkingLevel.fast => Icons.bolt_outlined,
        ThinkingLevel.balanced => Icons.tune_rounded,
        ThinkingLevel.deep => Icons.psychology_outlined,
      };
}
