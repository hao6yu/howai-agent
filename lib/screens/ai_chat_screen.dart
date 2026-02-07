import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

// Import the extracted widgets and utilities
import '../widgets/chat_message_widget.dart';
import '../widgets/welcome_screen_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/pptx_generation_dialog.dart';
import '../widgets/translation_dialog.dart';
import '../utils/chat_utils.dart';

// Import the extracted services
import '../services/image_service.dart';
import '../services/audio_service.dart';
import '../services/message_service.dart';
import '../services/pdf_service.dart';
import '../services/chat_speech_service.dart';
import '../services/device_tts_service.dart';
import '../services/chat_attachment_service.dart';
import '../services/pdf_workflow_service.dart';
import '../services/loading_message_service.dart';
import '../services/chat_translation_service.dart';
import '../services/chat_audio_listener_service.dart';
import '../constants/chat_ui_constants.dart';

import '../models/chat_message.dart';
import '../models/knowledge_item.dart';
import '../services/database_service.dart';
import '../services/openai_service.dart';
import '../services/elevenlabs_service.dart';
import '../services/speech_recognition_service.dart';
import '../services/audio_recorder_service.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../widgets/conversation_drawer.dart';
import '../providers/conversation_provider.dart';
import '../providers/ai_personality_provider.dart';
import '../services/subscription_service.dart';
import '../widgets/upgrade_dialog.dart';
import '../widgets/subscription_banner.dart';
import '../services/file_service.dart';
import '../services/location_service.dart';
import '../services/sync_service.dart';
import '../services/id_mapping_service.dart';
import '../widgets/place_result_widget.dart';
import '../services/chat_integration_helper.dart';
import '../services/profile_translation_service.dart';
import '../services/feature_showcase_service.dart';
import '../services/knowledge_hub_service.dart';
import '../utils/language_utils.dart';
import '../utils/location_query_detector.dart';
import '../utils/conversation_guard.dart';
import '../utils/chat_snackbar_service.dart';
import '../widgets/language_selection_popup.dart';
import '../widgets/full_language_selection_dialog.dart';
import '../widgets/location_search_dialog.dart';

class AiChatScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGuide;

  const AiChatScreen({
    super.key,
    this.onNavigateToGuide,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  final OpenAIService _openAIService = OpenAIService();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  final SpeechRecognitionService _speechRecognitionService =
      SpeechRecognitionService();
  final AudioRecorderService _audioRecorderService = AudioRecorderService();

  // Add a FocusNode for the text input
  final FocusNode _textInputFocusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isRecording = false;
  bool _isPlayingAudio = false;
  String _recordButtonText = '';
  int? _currentProfileId;
  String? _currentProfileName;

  // Flag to track if we're in the middle of a database update
  bool _isUpdatingMessages = false;

  // Animation controllers
  late AnimationController _micAnimationController;
  late AnimationController _sendButtonController;

  // Add a flag to control welcome message generation
  bool _skipWelcomeMessage = false;

  // Add new state variable for input mode
  bool _isVoiceInputMode = false;

  // Add input mode animation controller
  late AnimationController _inputModeAnimationController;

  // Add recording animation
  late AnimationController _recordingPulseController;

  // Add variables to track recording time
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  // Add variables for swipe-to-cancel recording
  bool _isShowingCancelHint = false;
  bool _isCancelingRecording = false;

  // Add variable to track if we should show the help tooltip
  bool _showVoiceInputHelp = true;

  // Add this after other state variables
  int _messageCountSinceLastAnalysis = 0;
  static const int _analysisThreshold = 20; // Analyze after every 20 messages

  // Flag to prevent duplicate AI responses during new conversation creation
  bool _isCreatingNewConversation = false;

  // Pagination state
  static const int _pageSize = 50;
  int _loadedCount = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // For multi-image attachment
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pendingImages = [];

  // PDF auto-conversion timer
  Timer? _pdfAutoConversionTimer;
  int _pdfCountdown = 0;
  bool _isSelectingForPdf =
      false; // Flag to track if we're selecting images for PDF
  bool _isPdfWorkflowActive =
      false; // Track if current images are for PDF workflow

  // Add these state variables:
  Duration _aiLoadingTimeout = const Duration(seconds: 300); // 5 minutes
  Duration _aiLoadingLongWait = const Duration(seconds: 180); // 3 minutes
  Timer? _aiLoadingTimer;
  Timer? _aiTimeoutTimer; // Separate timer for timeout handling
  Timer? _loadingMessageRotationTimer; // Timer to rotate loading messages
  String _aiLoadingMessage = '';
  bool _requestCancelled = false; // Flag to track if request was cancelled
  String? _currentRequestId; // Track current request to prevent duplicates
  int _loadingMessageIndex = 0;

  Map<int, String> _translatedMessages = {};
  int _translationPreferenceVersion = 0;

  bool _selectionMode = false;
  Set<int> _selectedMessages = {};

  bool _didInitLocalization = false;

  int? _lastLoadedConversationId;

  // Add TTS instance and state
  FlutterTts? _flutterTts;
  bool _isDeviceTTSPlaying = false;
  int? _currentPlayingMessageId; // Track which specific message is playing

  // Add file upload state
  List<PlatformFile> _pendingFiles = [];

  // Add system instruction for PPTX generation
  String? _pendingSystemInstruction;

  // Add display mode state (Tools mode vs Chat mode)
  bool _isToolsMode = false; // Default to chat mode for new users

  // Deep research/thinking mode toggle state (premium feature)
  bool _forceDeepResearch = false;

  // Showcase GlobalKeys for feature highlighting
  final GlobalKey _deepResearchKey = GlobalKey();
  final GlobalKey _toolsModeKey = GlobalKey();
  final GlobalKey _drawerButtonKey = GlobalKey();
  final GlobalKey _quickActionsKey = GlobalKey();
  bool _showcaseCompleted = false;
  BuildContext? _showcaseContext;

  @override
  void initState() {
    super.initState();

    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize input mode animation controller
    _inputModeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize recording pulse animation
    _recordingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize the speech recognition service
    _speechRecognitionService.initialize();

    // Initialize the audio recorder service
    _audioRecorderService.initialize();

    // Load previous messages, then add welcome message if needed (after first frame)
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessageIfNeeded();
    });

    // Listen for conversation selection changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      conversationProvider.addListener(_onConversationChanged);
    });

    // Listen for auth sync completion to refresh conversations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addListener(_onAuthSyncCompleted);
    });

    _scrollController.addListener(_onScroll);

    // Initialize device TTS
    _initializeDeviceTTS();

    // Load display mode preference
    _loadDisplayModePreference();

    // Initialize feature showcase
    _initializeFeatureShowcase();

    // Setup real-time sync for current conversation
    _setupRealtimeSync();
  }

  // Setup real-time sync for the current conversation
  void _setupRealtimeSync() async {
    try {
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      final currentConv = conversationProvider.selectedConversation;

      if (currentConv?.id != null) {
        final currentConvId = currentConv!.id!;
        // Get the UUID for this conversation
        final idMapping = IDMappingService();
        await idMapping.initialize();
        final conversationUuid = idMapping.getConversationUUID(currentConvId);

        if (conversationUuid != null) {
          // Subscribe to real-time updates for this conversation
          final syncService = SyncService();
          await syncService.watchConversation(conversationUuid);
          debugPrint(
              '[AIChatScreen] Subscribed to real-time updates for conversation: $conversationUuid');
        }
      }
    } catch (e) {
      debugPrint('[AIChatScreen] Error setting up real-time sync (silent): $e');
      // Silent failure - doesn't affect user experience
    }
  }

  // Load display mode preference from storage
  void _loadDisplayModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getBool('display_mode_is_tools') ??
          false; // Default to chat mode for new users
      setState(() {
        _isToolsMode = savedMode;
      });
      //// print('Loaded display mode: ${_isToolsMode ? "Tools" : "Chat"}');
    } catch (e) {
      //// print('Error loading display mode preference: $e');
      // Fallback to default
      setState(() {
        _isToolsMode = false; // Default to chat mode for new users
      });
    }
  }

  // Save display mode preference to storage
  void _saveDisplayModePreference(bool isToolsMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('display_mode_is_tools', isToolsMode);
      //// print('Saved display mode: ${isToolsMode ? "Tools" : "Chat"}');
    } catch (e) {
      //// print('Error saving display mode preference: $e');
    }
  }

  // Initialize feature showcase
  void _initializeFeatureShowcase() async {
    // print('🎯 [ChatScreen] Initializing feature showcase...');

    // Wait for UI to fully load before checking for showcase
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      // print('🎯 [ChatScreen] Widget not mounted, skipping showcase');
      return;
    }

    // print('🎯 [ChatScreen] Checking if should show showcase...');
    final shouldShow = await FeatureShowcaseService.shouldShowShowcase();
    // print('🎯 [ChatScreen] Should show showcase: $shouldShow');

    if (shouldShow) {
      // print('🎯 [ChatScreen] Starting feature showcase...');
      _startFeatureShowcase();
    } else {
      // print('🎯 [ChatScreen] Not showing showcase');

      // Debug: Print showcase status
      final status = await FeatureShowcaseService.getShowcaseStatus();
      // print('🎯 [ChatScreen] Showcase status: $status');
    }
  }

  void _startFeatureShowcase() {
    if (!mounted || _showcaseCompleted || _showcaseContext == null) {
      // print('🎯 [ChatScreen] Cannot start showcase - mounted: $mounted, completed: $_showcaseCompleted, context: ${_showcaseContext != null}');
      return;
    }

    // Get features from service (single source of truth)
    final features =
        FeatureShowcaseService.getFeaturesForCurrentVersion(context);
    final keysToShow = _mapFeaturesToKeys(features);

    if (keysToShow.isEmpty) {
      // print('🎯 [ChatScreen] No features to showcase');
      return;
    }

    // print('🎯 [ChatScreen] Starting showcase with ${keysToShow.length} features');

    // Verify ShowCaseWidget is available
    try {
      final showcaseWidget = ShowCaseWidget.of(_showcaseContext!);
      // print('🎯 [ChatScreen] ShowCaseWidget found: ${showcaseWidget != null}');

      // Start the showcase with features from service
      ShowCaseWidget.of(_showcaseContext!).startShowCase(keysToShow);
      // print('🎯 [ChatScreen] ✅ Showcase started successfully!');
    } catch (e) {
      // print('🎯 [ChatScreen] ❌ Error starting showcase: $e');
    }
  }

  // Map feature IDs to GlobalKeys
  List<GlobalKey> _mapFeaturesToKeys(List<ShowcaseFeature> features) {
    return features
        .map((feature) {
          switch (feature.id) {
            case 'drawer_button':
              return _drawerButtonKey;
            case 'tools_mode':
              return _toolsModeKey;
            case 'quick_actions':
              return _quickActionsKey;
            case 'deep_research':
              return _deepResearchKey;
            default:
              // print('🎯 [ChatScreen] ⚠️ Unknown feature ID: ${feature.id}');
              return null;
          }
        })
        .whereType<GlobalKey>()
        .toList();
  }

  // Get showcase data for a specific feature ID
  ShowcaseFeature? _getShowcaseFeature(String featureId) {
    final features =
        FeatureShowcaseService.getFeaturesForCurrentVersion(context);
    return features.firstWhere((feature) => feature.id == featureId,
        orElse: () => ShowcaseFeature(
              id: featureId,
              title: featureId,
              description: featureId,
            ));
  }

  Future<void> _initializeDeviceTTS() async {
    _flutterTts = await DeviceTtsService.initialize(
      onComplete: () {
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = false;
            _currentPlayingMessageId = null;
          });
        }
      },
      onStart: () {
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = true;
          });
        }
      },
      onCancel: () {
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = false;
            _currentPlayingMessageId = null;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _micAnimationController.dispose();
    _sendButtonController.dispose();
    _inputModeAnimationController.dispose();
    _recordingPulseController.dispose();
    _cancelRecordingTimer();
    _textInputFocusNode.dispose(); // Dispose the focus node

    // Cancel AI loading timers
    _aiLoadingTimer?.cancel();
    _aiTimeoutTimer?.cancel();
    _stopLoadingMessageRotation();

    // Cancel PDF auto-conversion timer
    _pdfAutoConversionTimer?.cancel();

    // Stop any ongoing audio playback using service
    AudioService.stopAudio();

    // Cleanup
    _audioRecorderService.dispose();

    _scrollController.removeListener(_onScroll);

    // Remove conversation listener
    try {
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      conversationProvider.removeListener(_onConversationChanged);
    } catch (e) {}

    // Remove auth listener
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_onAuthSyncCompleted);
    } catch (e) {}

    // Dispose device TTS
    DeviceTtsService.stop(_flutterTts);
    _flutterTts = null;

    super.dispose();
  }

  // PDF Auto-conversion methods
  void _startPdfAutoConversionTimer() {
    _pdfAutoConversionTimer?.cancel();
    if (_pendingImages.isEmpty) return;

    setState(() {
      _pdfCountdown = ChatUiConstants.pdfAutoConvertCountdownSeconds;
    });

    _pdfAutoConversionTimer = PdfWorkflowService.startAutoConversionTimer(
      countdownSeconds: ChatUiConstants.pdfAutoConvertCountdownSeconds,
      onTick: (nextCountdown) {
        if (!mounted) return;
        setState(() {
          _pdfCountdown = nextCountdown;
        });
      },
      onComplete: () {
        _pdfAutoConversionTimer = null;
        if (_pendingImages.isNotEmpty) {
          _onConvertToPdfPressed();
        }
      },
    );
  }

  void _cancelPdfAutoConversion() {
    _pdfAutoConversionTimer?.cancel();
    _pdfAutoConversionTimer = null;
    setState(() {
      _pdfCountdown = 0;
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset <= 100 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages({bool initial = true}) async {
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    final selectedConversation = conversationProvider.selectedConversation;

    // If we have a selected conversation, load messages for that conversation
    if (selectedConversation != null) {
      await _loadMessagesForConversation(selectedConversation.id);
      return;
    }

    // When no conversation is selected, don't load any historical messages
    // Instead, start with an empty state
    setState(() {
      _messages = [];
      _isLoading = false;
    });
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final moreMessages = await _databaseService.getChatMessages(
        profileId: _currentProfileId,
        limit: _pageSize,
        offset: _loadedCount,
      );
      if (moreMessages.isNotEmpty) {
        final prevScrollHeight = _scrollController.position.maxScrollExtent;
        setState(() {
          _messages.insertAll(0, moreMessages);
          _loadedCount += moreMessages.length;
          _hasMore = moreMessages.length == _pageSize;
        });
        // After prepending, maintain scroll position
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newScrollHeight = _scrollController.position.maxScrollExtent;
          final scrollOffset = newScrollHeight - prevScrollHeight;
          _scrollController.jumpTo(_scrollController.offset + scrollOffset);
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      //debug
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    if (animated) {
      // Only animate if requested (e.g., after sending/receiving a new message)
      const threshold = 50.0;
      if ((_scrollController.offset + threshold) < maxScroll) {
        _scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      // Instantly jump to bottom (no animation)
      _scrollController.jumpTo(maxScroll);
    }
  }

  bool _isNearBottom({double threshold = 140}) {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return (position.maxScrollExtent - position.pixels) <= threshold;
  }

  void _addWelcomeMessageIfNeeded() {
    if (_skipWelcomeMessage) {
      // Reset the flag for future app launches
      _skipWelcomeMessage = false;
      return;
    }
    // Extra guard: never add if there are any messages
    if (_messages.isNotEmpty) {
      return;
    }

    // NEW: Don't add welcome message on landing page - only add when user starts a conversation
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    if (conversationProvider.selectedConversation == null) {
      return; // Don't add welcome message on landing page
    }

    // Create the welcome message with simplified content
    _createAndAddWelcomeMessage();
  }

  // Separate method to create welcome message so it can be reused by test button
  void _createAndAddWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      message: AppLocalizations.of(context)!.welcomeMessage,
      isUserMessage: false,
      timestamp: DateTime.now().toIso8601String(),
      profileId: _currentProfileId,
      isWelcomeMessage:
          true, // Add a flag to identify this as the welcome message
    );

    // Save to database
    _databaseService.insertChatMessage(welcomeMessage);

    setState(() {
      _messages.add(welcomeMessage);
    });

    // Initialize voice demo player
    _prepareVoiceDemoPlayer();

    // Explicitly scroll to make the welcome message visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  // Voice demo preparation using service
  Future<void> _prepareVoiceDemoPlayer() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await AudioService.prepareVoiceDemoPlayer(
        useSpeakerOutput: settings.useSpeakerOutput);
  }

  // Start rotating loading messages
  void _startLoadingMessageRotation(String aiName,
      {bool isDeepResearch = false, bool isLongWait = false}) {
    _loadingMessageRotationTimer?.cancel();
    _loadingMessageIndex = 0;

    final shuffled = LoadingMessageService.shuffledMessages(
      isDeepResearch: isDeepResearch,
      isLongWait: isLongWait,
    );

    setState(() {
      _aiLoadingMessage = LoadingMessageService.buildMessage(
        aiName: aiName,
        shuffledMessages: shuffled,
        index: 0,
      );
    });

    _loadingMessageRotationTimer =
        Timer.periodic(ChatUiConstants.loadingRotationInterval, (timer) {
      if (!_isSending || !mounted) {
        timer.cancel();
        return;
      }
      _loadingMessageIndex = (_loadingMessageIndex + 1) % shuffled.length;
      setState(() {
        _aiLoadingMessage = LoadingMessageService.buildMessage(
          aiName: aiName,
          shuffledMessages: shuffled,
          index: _loadingMessageIndex,
        );
      });
    });
  }

  // Stop rotating loading messages
  void _stopLoadingMessageRotation() {
    _loadingMessageRotationTimer?.cancel();
    _loadingMessageRotationTimer = null;
  }

  // Streaming message index tracker for updating the correct message
  int? _streamingMessageIndex;
  bool _streamingMessageAdded = false;
  String? _activeStreamingMessageTimestamp;

  /// Handle streaming response from OpenAI
  /// Returns a Map compatible with the non-streaming response format
  Future<Map<String, dynamic>?> _handleStreamingResponse({
    required String message,
    required List<Map<String, dynamic>> history,
    required String userName,
    required Map<String, dynamic> userCharacteristics,
    List<XFile>? attachments,
    List<PlatformFile>? fileAttachments,
    required bool generateTitle,
    required bool isPremiumUser,
    required bool allowWebSearch,
    required bool allowImageGeneration,
    SubscriptionService? subscriptionService,
    dynamic aiPersonality,
    int? conversationId,
    required String requestId,
    required String aiName,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    // Don't add placeholder yet - just show typing indicator
    // Message will be added when first text arrives
    setState(() {
      _streamingMessageAdded = false;
      _streamingMessageIndex = null;
      _activeStreamingMessageTimestamp = timestamp;
      _isSending = true;
    });
    _startLoadingMessageRotation(aiName);

    String fullText = '';
    String? title;
    List<String>? images;
    List<String>? files;
    String lastRenderedText = '';
    DateTime? lastUiUpdateAt;
    DateTime? lastAutoScrollAt;
    const autoScrollInterval = Duration(milliseconds: 250);
    bool shouldFollowStream = false;

    // Helper to strip title JSON from text
    String _stripTitleJson(String text) {
      // Remove title JSON pattern from anywhere in text (not just beginning)
      final titlePattern = RegExp(r'\s*\{"title"\s*:\s*"[^"]*"\}\s*');
      return text.replaceAll(titlePattern, '').trim();
    }

    // Helper to extract title from text
    String? _extractTitle(String text) {
      final titleMatch =
          RegExp(r'\{"title"\s*:\s*"([^"]+)"\}').firstMatch(text);
      return titleMatch?.group(1);
    }

    try {
      final stream = _openAIService.generateChatResponseStream(
        message: message,
        history: history,
        userName: userName,
        userCharacteristics: userCharacteristics,
        attachments: attachments,
        fileAttachments: fileAttachments,
        generateTitle: generateTitle,
        isPremiumUser: isPremiumUser,
        allowWebSearch: allowWebSearch,
        allowImageGeneration: allowImageGeneration,
        subscriptionService: subscriptionService,
        aiPersonality: aiPersonality,
      );

      await for (final event in stream) {
        // Check if request was cancelled
        if (_requestCancelled || _currentRequestId != requestId) {
          break;
        }

        switch (event.type) {
          case StreamEventType.textDelta:
            // Append delta to full text
            fullText += event.textDelta ?? '';

            // Strip title JSON if present and extract title
            if (title == null && generateTitle) {
              title = _extractTitle(fullText);
            }
            String displayText = _stripTitleJson(fullText);

            // Only show message once we have actual content (not just title JSON)
            if (displayText.trim().isNotEmpty) {
              // Resolve placeholder index by timestamp so list shifts do not
              // cause updates/removals to target the wrong message.
              int placeholderIndex = _messages.lastIndexWhere((m) =>
                  !m.isUserMessage &&
                  m.id == null &&
                  m.timestamp == timestamp &&
                  (m.conversationId == conversationId ||
                      m.conversationId == null));

              if (!_streamingMessageAdded || placeholderIndex == -1) {
                // First real content - add the message to UI
                shouldFollowStream = _isNearBottom();
                setState(() {
                  final newMessage = ChatMessage(
                    message: displayText,
                    isUserMessage: false,
                    timestamp: timestamp,
                    profileId: _currentProfileId,
                    conversationId: conversationId,
                  );
                  _messages.add(newMessage);
                  _streamingMessageIndex = _messages.length - 1;
                  _activeStreamingMessageTimestamp = timestamp;
                  _streamingMessageAdded = true;
                  _isSending =
                      false; // Hide typing indicator, show message instead
                });
                lastRenderedText = displayText;
                lastUiUpdateAt = DateTime.now();
                lastAutoScrollAt = DateTime.now();
                if (shouldFollowStream) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animated: true);
                  });
                }
              } else {
                _streamingMessageIndex = placeholderIndex;
                // Throttle UI updates to avoid excessive full-list rebuilds/flicker.
                final now = DateTime.now();
                final uiUpdateInterval = displayText.length > 8000
                    ? const Duration(milliseconds: 320)
                    : displayText.length > 4000
                        ? const Duration(milliseconds: 220)
                        : const Duration(milliseconds: 80);
                final shouldUpdateUi = lastUiUpdateAt == null ||
                    now.difference(lastUiUpdateAt!) >= uiUpdateInterval;
                final isTextChanged = displayText != lastRenderedText;

                if (shouldUpdateUi && isTextChanged) {
                  setState(() {
                    final updatedMessage = ChatMessage(
                      message: displayText,
                      isUserMessage: false,
                      timestamp: timestamp,
                      profileId: _currentProfileId,
                      conversationId: conversationId,
                    );
                    _messages[placeholderIndex] = updatedMessage;
                  });

                  lastRenderedText = displayText;
                  lastUiUpdateAt = now;

                  final shouldAutoScroll = lastAutoScrollAt == null ||
                      now.difference(lastAutoScrollAt!) >= autoScrollInterval;
                  if (shouldAutoScroll && shouldFollowStream) {
                    lastAutoScrollAt = now;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(animated: false);
                    });
                  }
                }
              }
            }
            break;

          case StreamEventType.textDone:
            fullText = event.fullText ?? fullText;
            break;

          case StreamEventType.done:
            // Final response with all data
            fullText = event.fullText ?? fullText;
            title = event.title ?? title ?? _extractTitle(fullText);
            images = event.images;
            files = event.files;
            break;

          case StreamEventType.error:
            print('[ChatScreen] Streaming error: ${event.error}');
            // Remove any leftover temporary streaming assistant rows.
            setState(() {
              _messages.removeWhere((m) =>
                  !m.isUserMessage &&
                  m.id == null &&
                  (m.timestamp == timestamp ||
                      m.conversationId == conversationId ||
                      m.conversationId == null));
            });
            setState(() {
              _streamingMessageIndex = null;
              _streamingMessageAdded = false;
              _activeStreamingMessageTimestamp = null;
              _isSending = false;
            });
            return null;
        }
      }

      // Clean up the final text
      String cleanedText = _stripTitleJson(fullText);

      // Ensure the latest streamed text is rendered before we remove the temporary message.
      final finalPlaceholderIndex = _messages.lastIndexWhere((m) =>
          !m.isUserMessage &&
          m.id == null &&
          m.timestamp == timestamp &&
          (m.conversationId == conversationId || m.conversationId == null));
      if (finalPlaceholderIndex != -1 &&
          cleanedText.trim().isNotEmpty &&
          cleanedText != lastRenderedText) {
        setState(() {
          final finalUpdatedMessage = ChatMessage(
            message: cleanedText,
            isUserMessage: false,
            timestamp: timestamp,
            profileId: _currentProfileId,
            conversationId: conversationId,
          );
          _messages[finalPlaceholderIndex] = finalUpdatedMessage;
        });
      }

      // Remove the streaming message - it will be re-added by the normal flow with proper DB save
      if (finalPlaceholderIndex != -1) {
        setState(() {
          _messages.removeAt(finalPlaceholderIndex);
        });
      }
      // Fallback cleanup in case index tracking became stale during rebuilds.
      setState(() {
        _messages.removeWhere((m) =>
            !m.isUserMessage &&
            m.id == null &&
            (m.conversationId == conversationId ||
                m.timestamp == timestamp ||
                m.conversationId == null));
        _streamingMessageIndex = null;
        _streamingMessageAdded = false;
        _activeStreamingMessageTimestamp = null;
      });

      // Return response in the same format as non-streaming
      return {
        'text': cleanedText,
        'title': title,
        'images': images,
        'files': files,
        'streamTimestamp': timestamp,
      };
    } catch (e) {
      print('[ChatScreen] Streaming exception: $e');
      // Remove any leftover temporary streaming assistant rows.
      setState(() {
        _messages.removeWhere((m) =>
            !m.isUserMessage &&
            m.id == null &&
            (m.timestamp == timestamp ||
                m.conversationId == conversationId ||
                m.conversationId == null));
      });
      setState(() {
        _streamingMessageIndex = null;
        _streamingMessageAdded = false;
        _activeStreamingMessageTimestamp = null;
        _isSending = false;
      });
      return null;
    }
  }

  // Streaming mode currently skips image generation tools, so detect likely
  // image requests and route those through non-streaming instead.
  bool _looksLikeImageGenerationRequest(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty) return false;

    final imageNouns = RegExp(
      r'\b(image|picture|photo|drawing|art|artwork|illustration|logo|icon|portrait|wallpaper|banner)\b',
    );
    final imageVerbs = RegExp(
      r'\b(generate|create|make|draw|paint|design|illustrate|render)\b',
    );

    if (lower.startsWith('generate an image of') ||
        lower.startsWith('create an image of') ||
        lower.startsWith('draw ') ||
        lower.startsWith('make me an image of')) {
      return true;
    }

    return imageNouns.hasMatch(lower) && imageVerbs.hasMatch(lower);
  }

  Future<void> _sendMessage(String text,
      [List<XFile>? images, List<PlatformFile>? files]) async {
    if (text.trim().isEmpty &&
        (images == null || images.isEmpty) &&
        (files == null || files.isEmpty)) return;

    // Hide keyboard immediately when sending message
    FocusScope.of(context).unfocus();

    //// print('[ChatScreen] _sendMessage called with:');
    //// print('[ChatScreen] - text: "${text.trim()}"');
    //// print('[ChatScreen] - images: ${images?.length ?? 0}');
    //// print('[ChatScreen] - files: ${files?.length ?? 0}');

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        //// print('[ChatScreen] - file[$i]: ${file.name} (${FileService.formatFileSize(file.size)}) extension: ${file.extension}');
      }
    }

    // Check if user is asking for location-based recommendations
    // BUT: Skip location detection if images or files are present (those are analysis requests, not location queries)
    /*if ((images == null || images.isEmpty) && (files == null || files.isEmpty)) {
      final locationQuery = _detectLocationQuery(text);
      if (locationQuery != null) {
        // Get subscription service to check places explorer access
        final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
        if (subscriptionService.canUsePlacesExplorer) {
          // Auto-trigger location search for users with remaining usage
          await _handleLocationQuery(text, locationQuery);
          return; // Don't continue with regular AI response
        } else {
          // Show upgrade dialog when limit is reached
          _showLocationDiscoveryUpgradeDialog();
          return;
        }
      }
    }*/

    // Prevent multiple simultaneous sends
    if (_isSending) {
      return;
    }

    // Get subscription service
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);

    // Check image analysis limits if images are present (but don't consume usage yet)
    if (images != null && images.isNotEmpty) {
      if (!subscriptionService.isPremium) {
        // Check if free user can still use image analysis (without consuming)
        if (!subscriptionService.canUseImageAnalysis) {
          UpgradeDialog.showImageAnalysisLimit(context, () {
            Navigator.pushNamed(context, '/subscription');
          });
          return;
        }
      }
    }

    // File analysis is handled at the UI level - files should only reach here if user has access

    // Generate unique request ID for this send operation
    final requestId =
        'req_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode.abs()}';
    _currentRequestId = requestId;

    // Clear any existing message lists before starting a new conversation
    if (Provider.of<ConversationProvider>(context, listen: false)
            .selectedConversation ==
        null) {
      setState(() {
        _messages = [];
      });
    }

    // Ensure a conversation exists before saving a message
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    bool isNewConversation = conversationProvider.selectedConversation == null;
    final shouldGenerateAiTitle = isNewConversation;
    int? conversationId = isNewConversation
        ? null
        : conversationProvider.selectedConversation!.id;

    // Create/select conversation immediately for first message so sidebar updates
    // right away instead of waiting for the AI response round-trip.
    if (isNewConversation) {
      _isCreatingNewConversation = true;
      final provisionalTitle = MessageService.generateConversationTitle(text);
      await conversationProvider.createConversation(
          provisionalTitle, _currentProfileId);
      conversationId = conversationProvider.selectedConversation?.id;
      if (conversationId == null) {
        setState(() {
          _isCreatingNewConversation = false;
          _isSending = false;
          _currentRequestId = null;
        });
        _showErrorSnackBar('Failed to create conversation.');
        return;
      }
      _lastLoadedConversationId = conversationId;
      isNewConversation = false;
    }

    // Get the current settings and profile from the providers
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    // Get the latest profile name and characteristics
    final currentProfile =
        await _databaseService.getProfile(_currentProfileId!);
    final currentProfileName = currentProfile?.name ?? 'User';
    final userCharacteristics = currentProfile?.characteristics ?? {};

    // Add user message to the chat (with images if any)

    // Debug: print file information
    if (files != null && files.isNotEmpty) {
      //// print('[ChatScreen] Creating user message with ${files.length} files:');
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        //// print('[ChatScreen] - File[$i]: name=${file.name}, path=${file.path}, size=${file.size}');
      }
    }

    final userMessage = ChatMessage(
      message: text,
      isUserMessage: true,
      timestamp: DateTime.now().toIso8601String(),
      profileId: _currentProfileId,
      imagePaths: images != null && images.isNotEmpty
          ? images.map((x) => x.path).toList()
          : null,
      conversationId: conversationId, // May be null for new conversations
      filePaths: files != null && files.isNotEmpty
          ? files.map((f) => f.path ?? f.name).toList()
          : null,
    );

    //// print('[ChatScreen] User message created with filePaths: ${userMessage.filePaths}');

    // Filter messages by conversation ID before building history
    final conversationMessages = conversationId == null
        ? _messages
            .where((msg) => msg.conversationId == null)
            .toList() // For new conversations, only use messages without conversation ID
        : _messages
            .where((msg) => msg.conversationId == conversationId)
            .toList(); // For existing conversations, only use messages from this conversation

    // Add the current user message to the filtered list if not already included
    // This ensures the current message is part of the history even before it's added to _messages
    if (!conversationMessages.any((msg) =>
        msg.isUserMessage &&
        msg.message == userMessage.message &&
        msg.timestamp == userMessage.timestamp)) {
      conversationMessages.add(userMessage);
    }

    // Sort messages by timestamp to ensure proper order
    conversationMessages.sort((a, b) =>
        DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    final history = conversationMessages
        .take(50) // Take last 50 messages for context
        .map((msg) => {
              'role': msg.isUserMessage ? 'user' : 'assistant',
              'content': msg.message,
            })
        .toList();

    // Load AI personality configuration first to get the AI name
    dynamic aiPersonality;
    String aiName = 'HowAI'; // Default fallback matching createDefault()
    if (_currentProfileId != null) {
      final personalityProvider =
          Provider.of<AIPersonalityProvider>(context, listen: false);
      await personalityProvider.loadPersonalityForProfile(_currentProfileId!);
      aiPersonality =
          personalityProvider.getPersonalityForProfile(_currentProfileId!);
      if (aiPersonality != null && aiPersonality.aiName.isNotEmpty) {
        aiName = aiPersonality.aiName;
      }
    }

    // Set loading state first
    final isDeepResearchMode =
        _forceDeepResearch && subscriptionService.isPremium;
    setState(() {
      _isSending = true;
      _textController.clear();
      _messageCountSinceLastAnalysis++;
      _isPdfWorkflowActive =
          false; // Reset PDF workflow flag when sending message
    });
    _startLoadingMessageRotation(aiName, isDeepResearch: isDeepResearchMode);

    // Add message to UI state AFTER building the history, but check for duplicates
    setState(() {
      // Check if this exact message already exists to prevent duplicates
      bool messageExists = _messages.any((existing) =>
          existing.message == userMessage.message &&
          existing.timestamp == userMessage.timestamp &&
          existing.isUserMessage == userMessage.isUserMessage);

      if (!messageExists) {
        _messages.add(userMessage);
      }
    });

    // Force scroll to bottom to show the new message immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: true);
    });

    // Save user message to database and get its ID
    int? userMessageId;
    try {
      userMessageId = await _databaseService.insertChatMessage(userMessage);

      // Update our local message object with the database ID
      if (userMessageId != null) {
        setState(() {
          // Find the message in our state and update it with the ID from DB
          int index = _messages.indexWhere((msg) =>
              msg.isUserMessage &&
              msg.message == text &&
              msg.timestamp == userMessage.timestamp);
          if (index != -1) {
            // Create a new message with the ID
            final updatedMessage = ChatMessage(
              id: userMessageId,
              message: userMessage.message,
              isUserMessage: userMessage.isUserMessage,
              timestamp: userMessage.timestamp,
              profileId: userMessage.profileId,
              imagePaths: userMessage.imagePaths,
              conversationId: userMessage.conversationId,
              filePaths: userMessage.filePaths,
            );
            _messages[index] = updatedMessage;
          }
        });
      }
    } catch (e) {
      //debug
    }

    try {
      // Cancel any existing timers and reset cancellation flag
      _aiLoadingTimer?.cancel();
      _aiTimeoutTimer?.cancel();
      _requestCancelled = false; // Reset cancellation flag for new request

      // Set up progress message timer - switch to long wait messages after a while
      _aiLoadingTimer = Timer(_aiLoadingLongWait, () {
        if (_isSending && mounted) {
          _startLoadingMessageRotation(aiName, isLongWait: true);
        }
      });

      // Set up timeout timer with better handling
      _aiTimeoutTimer = Timer(_aiLoadingTimeout, () {
        if (_isSending && mounted) {
          setState(() {
            _isSending = false;
            _isCreatingNewConversation = false;
            _requestCancelled = true; // Mark request as cancelled
            _currentRequestId = null; // Clear request ID
          });
          _aiLoadingTimer?.cancel();
          if (mounted) {
            _showErrorSnackBar(AppLocalizations.of(context)!.imageTookTooLong);
          }
        }
      });

      // AI personality was already loaded earlier for the loading message

      // Check if we have recent places data that could be relevant for this query
      String? placesContext =
          _getRecentPlacesContext(text, conversationMessages);

      // If user is asking for analysis but no places found, add a specific instruction
      String finalMessage = text;
      if (placesContext != null) {
        finalMessage = '$placesContext\n\nUser question: $text';
      } else {
        // Check if user is asking for place analysis without having place data
        final lowerText = text.toLowerCase();
        final isPlaceAnalysisRequest = (lowerText.contains('suggest') ||
                lowerText.contains('recommend') ||
                lowerText.contains('best') ||
                lowerText.contains('top')) &&
            (lowerText.contains('place') ||
                lowerText.contains('restaurant') ||
                lowerText.contains('location'));

        if (isPlaceAnalysisRequest) {
          finalMessage =
              '$text\n\nIMPORTANT: The user is asking for place recommendations, but I don\'t have any recent place search results in our conversation. I should explain that I need them to search for places first before I can make recommendations, rather than making up place information.';
        }
      }

      finalMessage = await _injectKnowledgeContextIfEligible(
        message: finalMessage,
        userPrompt: text,
        subscriptionService: subscriptionService,
      );

      // Determine if we should use deep research mode
      final isDeepResearchMode =
          _forceDeepResearch && subscriptionService.isPremium;
      if (isDeepResearchMode) {
        // print('[ChatScreen] Deep Research Mode ENABLED - Using reasoning model');
      }

      // Check if streaming is enabled
      // Disable streaming for:
      // 1) deep research mode (reasoning takes too long to stream)
      // 2) image-generation style requests (streaming path skips image tool)
      final isLikelyImageGenerationRequest =
          _looksLikeImageGenerationRequest(finalMessage);
      final useStreaming = settings.useStreaming &&
          !isDeepResearchMode &&
          !isLikelyImageGenerationRequest;
      print(
        '[ChatScreen] Streaming decision => useStreaming=$useStreaming '
        '(settings.useStreaming=${settings.useStreaming}, '
        'isDeepResearchMode=$isDeepResearchMode, '
        'isLikelyImageGenerationRequest=$isLikelyImageGenerationRequest)',
      );

      Map<String, dynamic>? response;

      if (useStreaming) {
        print('[ChatScreen] Using STREAMING response path');
        // STREAMING MODE: Show response as it arrives
        response = await _handleStreamingResponse(
          message: finalMessage,
          history: history,
          userName: currentProfileName,
          userCharacteristics: userCharacteristics,
          attachments: images,
          generateTitle: shouldGenerateAiTitle,
          isPremiumUser: subscriptionService.isPremium,
          allowWebSearch: subscriptionService.canUseWebSearch,
          allowImageGeneration: true,
          subscriptionService: subscriptionService,
          fileAttachments: files,
          aiPersonality: aiPersonality,
          conversationId: conversationId,
          requestId: requestId,
          aiName: aiName,
        );
      } else {
        print('[ChatScreen] Using NON-STREAMING response path');
        // NON-STREAMING MODE: Wait for complete response
        response = await _openAIService.generateChatResponse(
          message: finalMessage,
          history: history,
          userName: currentProfileName,
          userCharacteristics: userCharacteristics,
          attachments: images != null && images.isNotEmpty ? images : null,
          generateTitle: shouldGenerateAiTitle,
          isPremiumUser: subscriptionService.isPremium,
          allowWebSearch: subscriptionService.canUseWebSearch,
          allowImageGeneration: true,
          isDeepResearch: isDeepResearchMode,
          subscriptionService: subscriptionService,
          fileAttachments: files,
          aiPersonality: aiPersonality,
        );
      }

      if (response != null) {
        // Cancel timers immediately when response is received
        _aiLoadingTimer?.cancel();
        _aiTimeoutTimer?.cancel();

        // Check if request was cancelled due to timeout
        if (_requestCancelled) {
          return; // Don't process the response if it was cancelled
        }

        // Check if this response is for the current request
        if (_currentRequestId != requestId) {
          return;
        }

        // NOW consume usage since API call succeeded
        if (!subscriptionService.isPremium) {
          // Consume image analysis if images were present
          if (images != null && images.isNotEmpty) {
            await subscriptionService.tryUseImageAnalysis();
          }

          // Consume document analysis if files were present
          if (files != null && files.isNotEmpty) {
            await subscriptionService.tryUseDocumentAnalysis();
            // Show usage reminder for free users
            final remaining = subscriptionService.remainingDocumentAnalysis;
            final settings =
                Provider.of<SettingsProvider>(context, listen: false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Document analysis used. You have $remaining uses remaining.",
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(14)),
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            });
          }
        }

        String aiText = response['text'] as String? ?? '';
        List<String>? generatedImages = response['images'] as List<String>?;
        List<String>? generatedFiles = response['files'] as List<String>?;
        final String? streamTimestamp = response['streamTimestamp'] as String?;

        // Strip any title JSON that may have leaked into the response text (anywhere in text)
        aiText = aiText
            .replaceAll(RegExp(r'\s*\{"title"\s*:\s*"[^"]*"\}\s*'), '')
            .trim();

        // Debug: Log the received files
        //// print('[ChatScreen] Received response from OpenAI:');
        //// print('[ChatScreen] - aiText length: ${aiText.length}');
        //// print('[ChatScreen] - generatedImages: ${generatedImages?.length ?? 0}');
        //// print('[ChatScreen] - generatedFiles: ${generatedFiles?.length ?? 0}');
        if (generatedFiles != null && generatedFiles.isNotEmpty) {
          for (int i = 0; i < generatedFiles.length; i++) {
            //// print('[ChatScreen] - file[$i]: ${generatedFiles[i]}');
          }
        }

        // If this request started from a new conversation, update the provisional
        // title with AI-generated title when available.
        if (shouldGenerateAiTitle) {
          String? conversationTitle = response['title'] as String?;
          if (conversationTitle != null &&
              conversationTitle.isNotEmpty &&
              conversationId != null) {
            await conversationProvider.updateConversationTitle(
              conversationId: conversationId,
              title: conversationTitle,
              profileId: _currentProfileId,
            );
          }

          // Update _lastLoadedConversationId immediately to prevent reload duplication
          _lastLoadedConversationId = conversationId;

          // CRITICAL: Set a flag to prevent _onConversationChanged from reloading messages
          // This prevents duplicate AI responses when the conversation is created
          _isCreatingNewConversation = true;

          await _ensureUserMessageAssignedToConversation(
            originalUserMessage: userMessage,
            userMessageId: userMessageId,
            conversationId: conversationId!,
          );

          // Defensive: guarantee the just-sent user message is present in the new conversation UI.
          final hasCurrentUserMessage = _messages.any((m) =>
              m.isUserMessage &&
              m.conversationId == conversationId &&
              m.timestamp == userMessage.timestamp &&
              m.message == userMessage.message);
          if (!hasCurrentUserMessage) {
            setState(() {
              _messages.add(ChatMessage(
                id: userMessageId,
                message: userMessage.message,
                isUserMessage: true,
                timestamp: userMessage.timestamp,
                profileId: userMessage.profileId,
                imagePaths: userMessage.imagePaths,
                imageUrls: userMessage.imageUrls,
                filePaths: userMessage.filePaths,
                conversationId: conversationId,
                isWelcomeMessage: userMessage.isWelcomeMessage,
                locationResults: userMessage.locationResults,
                messageType: userMessage.messageType,
              ));
            });
          }
        } else {
          conversationId = conversationProvider.selectedConversation!.id;
        }

        // Post-process: download and replace image URLs with local file paths
        aiText = await replaceImageUrlsWithLocalFiles(aiText);

        // Remove image markdown from AI text since we handle images via imagePaths
        if (generatedImages != null && generatedImages.isNotEmpty) {
          // Remove markdown image syntax to prevent duplicate image display
          aiText = aiText.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '').trim();
        }

        // IMPORTANT: Lock this section to prevent race conditions that might cause duplicates
        await _lockAndUpdateMessages(() async {
          // Get fresh messages to avoid working with stale state
          final currentMessages = await _databaseService.getChatMessages(
            profileId: _currentProfileId,
            limit: 100,
            offset: 0,
          );

          // Filter to only this conversation's messages
          final existingConversationMessages = currentMessages
              .where((m) => m.conversationId == conversationId)
              .toList();

          // Check if this exact AI message already exists in the database
          // IMPORTANT: Also check file paths to avoid treating messages with different files as duplicates
          final serializedGeneratedFiles =
              generatedFiles != null && generatedFiles.isNotEmpty
                  ? jsonEncode(generatedFiles)
                  : null;
          final serializedGeneratedImages =
              generatedImages != null && generatedImages.isNotEmpty
                  ? jsonEncode(generatedImages)
                  : null;
          final aiMessageExists = existingConversationMessages.any((existing) =>
              !existing.isUserMessage && // Only check AI messages
              existing.message == aiText && // Same content
              existing.conversationId == conversationId && // Same conversation
              // Also compare file paths
              (((existing.filePaths == null || existing.filePaths!.isEmpty) &&
                      (generatedFiles == null || generatedFiles.isEmpty)) ||
                  (existing.filePaths != null &&
                      generatedFiles != null &&
                      jsonEncode(existing.filePaths) ==
                          serializedGeneratedFiles)) &&
              // Also compare image paths
              (((existing.imagePaths == null || existing.imagePaths!.isEmpty) &&
                      (generatedImages == null || generatedImages.isEmpty)) ||
                  (existing.imagePaths != null &&
                      generatedImages != null &&
                      jsonEncode(existing.imagePaths) ==
                          serializedGeneratedImages)));

          if (aiMessageExists) {
            //// print('[ChatScreen] Detected duplicate AI message - skipping creation');
            //// print('[ChatScreen] Existing message with same content and files already exists');
            // Just update state from database, but don't add a new message
            setState(() {
              _isSending = false;
              _isCreatingNewConversation = false;
              _currentRequestId = null;
            });

            return; // Exit early without adding a duplicate
          }

          // First create a timestamp to be used for both messages
          final timestamp = DateTime.now().toIso8601String();

          // Debug: Log what we're about to pass to ChatIntegrationHelper
          //// print('[ChatScreen] About to call ChatIntegrationHelper.processAIResponse with:');
          //// print('[ChatScreen] - filePaths: $generatedFiles');

          // Use ChatIntegrationHelper to process AI response and handle review logic
          List<ChatMessage> messagesToAdd;
          try {
            messagesToAdd = await ChatIntegrationHelper.processAIResponse(
              aiResponseText: aiText,
              isUserMessage: false,
              timestamp: timestamp,
              profileId: _currentProfileId,
              conversationId: conversationId,
              imagePaths: generatedImages,
              filePaths: generatedFiles,
            );
            //// print('[ChatScreen] ChatIntegrationHelper.processAIResponse completed successfully');
            //// print('[ChatScreen] - Returned ${messagesToAdd.length} messages');
            for (int i = 0; i < messagesToAdd.length; i++) {
              //// print('[ChatScreen] - message[$i] filePaths: ${messagesToAdd[i].filePaths}');
            }
          } catch (e) {
            //// print('[ChatScreen] ERROR in ChatIntegrationHelper.processAIResponse: $e');
            //// print('[ChatScreen] Stack trace: $stackTrace');
            // Fallback: create message directly
            messagesToAdd = [
              ChatMessage(
                message: aiText,
                isUserMessage: false,
                timestamp: timestamp,
                profileId: _currentProfileId,
                conversationId: conversationId,
                imagePaths: generatedImages,
                filePaths: generatedFiles,
                messageType: MessageType.normal,
              )
            ];
            //// print('[ChatScreen] Created fallback message with filePaths: ${messagesToAdd[0].filePaths}');
          }

          // Save all messages to database and update UI
          final List<ChatMessage> completedMessages = [];
          for (final message in messagesToAdd) {
            // Debug: Log message being saved
            //// print('[ChatScreen] Saving message to database:');
            //// print('[ChatScreen] - message.filePaths: ${message.filePaths}');
            //// print('[ChatScreen] - message.message length: ${message.message.length}');

            // Save to database FIRST to get an ID
            int messageId;
            try {
              messageId = await _databaseService.insertChatMessage(message);
              //// print('[ChatScreen] Successfully saved message to database with ID: $messageId');
            } catch (e) {
              //// print('[ChatScreen] ERROR saving message to database: $e');
              //// print('[ChatScreen] Stack trace: $stackTrace');
              messageId = 0; // Use 0 as fallback ID
            }

            // Create complete message with database ID
            final completeMessage = ChatMessage(
              id: messageId,
              message: message.message,
              isUserMessage: message.isUserMessage,
              timestamp: message.timestamp,
              profileId: message.profileId,
              imagePaths: message.imagePaths,
              conversationId: message.conversationId,
              messageType: message.messageType,
              filePaths: message.filePaths, // Make sure filePaths is included
            );

            // Debug: Log the complete message being added to UI
            //// print('[ChatScreen] Adding complete message to UI:');
            //// print('[ChatScreen] - completeMessage.filePaths: ${completeMessage.filePaths}');
            //// print('[ChatScreen] - completeMessage.id: ${completeMessage.id}');

            completedMessages.add(completeMessage);
          }

          // Only now, update the UI
          setState(() {
            // Deterministically remove temporary assistant rows from in-memory UI.
            // This guarantees the persisted assistant message does not coexist with
            // any stream placeholder residue.
            if (streamTimestamp != null && streamTimestamp.isNotEmpty) {
              _messages.removeWhere((existing) =>
                  !existing.isUserMessage &&
                  existing.id == null &&
                  (existing.conversationId == conversationId ||
                      existing.conversationId == null ||
                      existing.timestamp == streamTimestamp));
            } else {
              // Additional safeguard for non-streaming path.
              _messages.removeWhere((existing) =>
                  !existing.isUserMessage &&
                  existing.id == null &&
                  (existing.conversationId == conversationId ||
                      existing.conversationId == null));
            }

            // Remove matching temporary assistant messages (typically streaming placeholders)
            // so we don't show duplicate AI responses before a full reload.
            for (final persisted in completedMessages) {
              if (persisted.isUserMessage) continue;

              _messages.removeWhere((existing) {
                if (existing.isUserMessage) return false;
                if (existing.id != null) return false; // keep persisted entries
                if (existing.conversationId != persisted.conversationId) {
                  return false;
                }

                final sameText =
                    existing.message.trim() == persisted.message.trim();
                final sameFiles = jsonEncode(existing.filePaths ?? const []) ==
                    jsonEncode(persisted.filePaths ?? const []);
                final sameImages =
                    jsonEncode(existing.imagePaths ?? const []) ==
                        jsonEncode(persisted.imagePaths ?? const []);

                return sameText && sameFiles && sameImages;
              });
            }

            // Debug: Log before adding messages to state
            //// print('[ChatScreen] About to add ${completedMessages.length} messages to _messages state');
            for (int i = 0; i < completedMessages.length; i++) {
              final msg = completedMessages[i];
              //// print('[ChatScreen] - message[$i] filePaths: ${msg.filePaths}');
              //// print('[ChatScreen] - message[$i] id: ${msg.id}');
            }

            // Add all messages to state with their database IDs
            _messages.addAll(completedMessages);
            _pruneStreamingGhostAssistantRows(conversationId: conversationId);

            // Debug: Log _messages state after adding
            //// print('[ChatScreen] _messages state now has ${_messages.length} total messages');
            final lastMessage = _messages.isNotEmpty ? _messages.last : null;
            if (lastMessage != null) {
              //// print('[ChatScreen] Last message filePaths: ${lastMessage.filePaths}');
              //// print('[ChatScreen] Last message isUserMessage: ${lastMessage.isUserMessage}');
            }

            _isSending = false;
            _isCreatingNewConversation = false;
            _currentRequestId = null;
          });
        });

        // Clean up messages to remove any potential duplicates
        _cleanupMessagesList();

        // Scroll to bottom after adding AI message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });

        // Generate and play audio for AI response using subscription-aware logic
        if (settings.useVoiceResponse && aiText.isNotEmpty) {
          // Get the ID of the message we just saved from the database
          // This ensures we modify the right message even if there were race conditions
          final recentMessages = await _databaseService.getChatMessages(
            profileId: _currentProfileId,
            limit: 10,
            offset: 0,
          );

          // Find the most recent AI message with matching content
          final matchingMessage = recentMessages.firstWhere(
            (msg) =>
                !msg.isUserMessage &&
                msg.message == aiText &&
                msg.conversationId == conversationId,
            orElse: () => ChatMessage(
              message: '',
              isUserMessage: false,
              timestamp: DateTime.now().toIso8601String(),
              profileId: _currentProfileId,
            ),
          );

          // Only generate audio if we found the message
          if (matchingMessage.id != null) {
            String? audioPath;

            audioPath = await ChatSpeechService.generateSubscriptionAwareAudio(
              isPremium: subscriptionService.isPremium,
              tryUseElevenLabsTts: () =>
                  subscriptionService.tryUseElevenLabsTTS(),
              canUseDeviceTTS: () => subscriptionService.canUseDeviceTTS(),
              generateElevenLabsAudio: () =>
                  ChatSpeechService.generateAndPlayAudioForMessage(
                message: aiText,
                voiceId: settings.selectedVoiceId,
                elevenLabsService: _elevenLabsService,
                playAudio: _playAudio,
              ),
              generateDeviceTtsAudio: () => _generateAndPlayDeviceTTS(aiText),
            );

            if (audioPath != null) {
              await _persistAudioPathForMessage(
                sourceMessage: matchingMessage,
                audioPath: audioPath,
                clearImagePaths: true,
              );
            }
          } else {}
        }
        // Analyze user characteristics if we've reached the threshold
        if (_messageCountSinceLastAnalysis >= _analysisThreshold &&
            _currentProfileId != null) {
          _analyzeUserCharacteristics(history);
          _messageCountSinceLastAnalysis = 0;
        }
      } else {
        // Cancel timers on null response
        _aiLoadingTimer?.cancel();
        _aiTimeoutTimer?.cancel();

        // Only access context if widget is still mounted
        if (mounted) {
          _showErrorSnackBar(
              AppLocalizations.of(context)!.sorryCouldNotRespond);
          setState(() {
            _isSending = false;
            _isCreatingNewConversation = false;
            _currentRequestId = null;
          });
        }
      }
    } catch (e) {
      // Cancel timers on error
      _aiLoadingTimer?.cancel();
      _aiTimeoutTimer?.cancel();

      // Only access context if widget is still mounted
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.somethingWentWrong);
        setState(() {
          _isSending = false;
          _isCreatingNewConversation = false;
          _currentRequestId = null;
        });
      }
    } finally {
      // Ensure timers are always cleaned up
      _aiLoadingTimer?.cancel();
      _aiTimeoutTimer?.cancel();
    }
  }

  // Detect location query method
  LocationQueryInfo? _detectLocationQuery(String text) {
    return LocationQueryDetector.detect(text);
  }

  // Handle location query method
  Future<void> _handleLocationQuery(
      String originalText, LocationQueryInfo queryInfo) async {
    try {
      //// print('[LocationQuery] Auto-detected location query: ${queryInfo.query} (category: ${queryInfo.category})');

      // Create user message first
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId =
          conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String searchTitle = "Places Explorer: ${queryInfo.query}";

        await conversationProvider.createConversation(
            searchTitle, _currentProfileId);
        messageConversationId = conversationProvider.selectedConversation?.id;

        if (messageConversationId == null) {
          _showErrorSnackBar("Failed to create conversation");
          return;
        }

        _lastLoadedConversationId = messageConversationId;
      }

      // Add user message to chat
      final userMessage = ChatMessage(
        message: originalText,
        isUserMessage: true,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        conversationId: messageConversationId,
      );

      await _databaseService.insertChatMessage(userMessage);

      setState(() {
        _messages.add(userMessage);
      });

      // Show loading indicator
      setState(() {
        _isSending = true;
        _aiLoadingMessage = 'Searching for ${queryInfo.query} near you...';
      });

      // Perform location search
      final LocationService locationService = LocationService();
      final places = await locationService.searchNearbyPlaces(
        query: queryInfo.query,
        type: queryInfo.category,
        openNow: false,
      );

      setState(() {
        _isSending = false;
      });

      if (places.isNotEmpty) {
        // Create AI response message with location results
        final locationResultsMessage = ChatMessage(
          message:
              "🗺️ **Found ${places.length} great ${queryInfo.query} near you!**\n\nTap below to explore these locations with photos, ratings, and directions.",
          isUserMessage: false,
          timestamp: DateTime.now().toIso8601String(),
          profileId: _currentProfileId,
          conversationId: messageConversationId,
          locationResults: places,
        );

        await _databaseService.insertChatMessage(locationResultsMessage);

        setState(() {
          _messages.add(locationResultsMessage);
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });

        // Show success message
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Found ${places.length} ${queryInfo.query} near you!",
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // No results found - create a helpful AI response
        final noResultsMessage = ChatMessage(
          message:
              "🔍 I couldn't find any ${queryInfo.query} in your immediate area. This could be because:\n\n• Your location services might be disabled\n• There might not be any ${queryInfo.query} very close by\n• Try searching for a different type of place\n\nWould you like me to search for something else, or try a broader search?",
          isUserMessage: false,
          timestamp: DateTime.now().toIso8601String(),
          profileId: _currentProfileId,
          conversationId: messageConversationId,
        );

        await _databaseService.insertChatMessage(noResultsMessage);

        setState(() {
          _messages.add(noResultsMessage);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });

      //// print('[LocationQuery] Error handling location query: $e');

      // Create error message
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      final errorMessage = ChatMessage(
        message:
            "❌ Sorry, I had trouble searching for ${queryInfo.query} near you. This might be because:\n\n• Location services are disabled\n• Network connectivity issues\n• The search service is temporarily unavailable\n\nPlease check your location settings and try again, or feel free to ask me something else!",
        isUserMessage: false,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        conversationId: conversationProvider.selectedConversation?.id,
      );

      if (errorMessage.conversationId != null) {
        await _databaseService.insertChatMessage(errorMessage);
        setState(() {
          _messages.add(errorMessage);
        });
      }

      _showErrorSnackBar("Location search failed: $e");
    }
  }

  // 显示位置发现升级对话框
  void _showLocationDiscoveryUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<SettingsProvider, SubscriptionService>(
          builder: (context, settings, subscriptionService, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 700 || screenWidth < 400;

            // Check if user is free tier and has used up their weekly limit
            final isFreeUserWithLimit = !subscriptionService.isPremium;
            final remaining = subscriptionService.remainingPlacesExplorer;

            String dialogTitle = isFreeUserWithLimit && remaining <= 0
                ? 'Places Explorer Limit Reached'
                : 'Smart Location Detection';

            String mainMessage = isFreeUserWithLimit && remaining <= 0
                ? 'You\'ve used all ${subscriptionService.limits.placesExplorerWeekly} weekly place searches. Your limit will reset next week!'
                : 'I detected you\'re looking for local recommendations!';

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF5856D6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF5856D6),
                      size: settings.getScaledFontSize(isSmallScreen ? 18 : 20),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dialogTitle,
                      style: TextStyle(
                        fontSize:
                            settings.getScaledFontSize(isSmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(9),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainMessage,
                      style: TextStyle(
                        fontSize:
                            settings.getScaledFontSize(isSmallScreen ? 14 : 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '✨ Premium benefits:',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    ...[
                      '• Unlimited places exploration',
                      '• Advanced location search',
                      '• Real-time business info',
                      '• Maps integration with directions',
                      '• All premium features unlocked'
                    ].map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings
                                  .getScaledFontSize(isSmallScreen ? 12 : 14),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5856D6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/subscription');
                  },
                  child: Text(
                    'Upgrade Now',
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Update device TTS method
  Future<String?> _generateAndPlayDeviceTTS(String message) async {
    try {
      if (_flutterTts == null) {
        await _initializeDeviceTTS();
      }

      if (_flutterTts == null) {
        return "device_tts";
      }

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final result = await DeviceTtsService.generateAndPlay(
        flutterTts: _flutterTts,
        message: message,
        selectedVoice: settings.selectedSystemTTSVoice,
      );
      return result ?? "device_tts";
    } catch (e) {
      //// print('[DeviceTTS] Error with device TTS: $e');
      return null;
    }
  }

  // Add device TTS control methods
  Future<void> _pauseDeviceTTS() async {
    if (_flutterTts != null) {
      await DeviceTtsService.pause(_flutterTts);
      setState(() {
        _isDeviceTTSPlaying = false;
      });
    }
  }

  Future<void> _stopDeviceTTS() async {
    if (_flutterTts != null) {
      await DeviceTtsService.stop(_flutterTts);
      setState(() {
        _isDeviceTTSPlaying = false;
        _currentPlayingMessageId = null;
      });
    }
  }

  // Audio playback methods replaced with service calls
  Future<void> _playAudio(String audioPath) async {
    // If empty string is passed, stop all audio
    if (audioPath.isEmpty) {
      await _stopAudio();
      await _stopDeviceTTS();
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await AudioService.playAudio(audioPath,
        useSpeakerOutput: settings.useSpeakerOutput);

    ChatAudioListenerService.bindPlaybackListener(
      isPlayingNotifier: AudioService.isPlayingAudio,
      isMounted: () => mounted,
      onPlaybackChanged: (isPlaying) {
        setState(() {
          _isPlayingAudio = isPlaying;
          if (!isPlaying) {
            _currentPlayingMessageId = null;
          }
        });
      },
    );
  }

  Future<void> _stopAudio() async {
    await AudioService.stopAudio();
    setState(() {
      _currentPlayingMessageId = null;
    });
  }

  Future<void> _persistAudioPathForMessage({
    required ChatMessage sourceMessage,
    required String audioPath,
    bool syncInMemory = false,
    bool clearImagePaths = false,
  }) async {
    final updatedMessage = ChatMessage(
      id: sourceMessage.id,
      message: sourceMessage.message,
      isUserMessage: sourceMessage.isUserMessage,
      timestamp: sourceMessage.timestamp,
      profileId: sourceMessage.profileId,
      imagePaths: clearImagePaths ? null : sourceMessage.imagePaths,
      imageUrls: sourceMessage.imageUrls,
      filePaths: sourceMessage.filePaths,
      isWelcomeMessage: sourceMessage.isWelcomeMessage,
      conversationId: sourceMessage.conversationId,
      locationResults: sourceMessage.locationResults,
      messageType: sourceMessage.messageType,
      audioPath: audioPath,
    );

    await _databaseService.updateChatMessage(updatedMessage);

    if (!syncInMemory) {
      return;
    }

    final messageIndex = _messages.indexWhere((m) => m.id == sourceMessage.id);
    if (messageIndex == -1) {
      return;
    }

    setState(() {
      _messages[messageIndex] = updatedMessage;
    });
  }

  Future<void> _ensureUserMessageAssignedToConversation({
    required ChatMessage originalUserMessage,
    required int? userMessageId,
    required int conversationId,
  }) async {
    try {
      int messageIndex = -1;

      if (userMessageId != null) {
        for (int i = 0; i < _messages.length; i++) {
          if (_messages[i].id == userMessageId) {
            messageIndex = i;
            break;
          }
        }
      }

      if (messageIndex == -1) {
        for (int i = _messages.length - 1; i >= 0; i--) {
          final candidate = _messages[i];
          if (candidate.isUserMessage &&
              candidate.timestamp == originalUserMessage.timestamp &&
              candidate.message == originalUserMessage.message) {
            messageIndex = i;
            break;
          }
        }
      }

      final source =
          messageIndex != -1 ? _messages[messageIndex] : originalUserMessage;
      ChatMessage updatedUserMessage = ChatMessage(
        id: source.id ?? userMessageId,
        message: source.message,
        isUserMessage: source.isUserMessage,
        timestamp: source.timestamp,
        profileId: source.profileId,
        imagePaths: source.imagePaths,
        imageUrls: source.imageUrls,
        conversationId: conversationId,
        filePaths: source.filePaths,
        isWelcomeMessage: source.isWelcomeMessage,
        locationResults: source.locationResults,
        messageType: source.messageType,
      );

      if (updatedUserMessage.id != null) {
        await _databaseService.updateChatMessage(updatedUserMessage);
      } else {
        final insertedId =
            await _databaseService.insertChatMessage(updatedUserMessage);
        updatedUserMessage = ChatMessage(
          id: insertedId,
          message: updatedUserMessage.message,
          isUserMessage: updatedUserMessage.isUserMessage,
          timestamp: updatedUserMessage.timestamp,
          profileId: updatedUserMessage.profileId,
          imagePaths: updatedUserMessage.imagePaths,
          imageUrls: updatedUserMessage.imageUrls,
          conversationId: updatedUserMessage.conversationId,
          filePaths: updatedUserMessage.filePaths,
          isWelcomeMessage: updatedUserMessage.isWelcomeMessage,
          locationResults: updatedUserMessage.locationResults,
          messageType: updatedUserMessage.messageType,
        );
      }

      if (messageIndex != -1) {
        setState(() {
          _messages[messageIndex] = updatedUserMessage;
        });
      } else {
        setState(() {
          _messages.add(updatedUserMessage);
        });
      }
    } catch (e) {
      //debug
    }
  }

  // Update the speaking method to handle both ElevenLabs and device TTS
  Future<void> _speakMessage(ChatMessage message) async {
    try {
      // If this specific message is currently playing, stop it
      if (_currentPlayingMessageId == message.id &&
          ((message.audioPath == "device_tts" && _isDeviceTTSPlaying) ||
              (message.audioPath != "device_tts" && _isPlayingAudio))) {
        await _stopAudio();
        await _stopDeviceTTS();
        setState(() {
          _currentPlayingMessageId = null;
        });
        return;
      }

      // Stop any existing audio
      await _stopAudio();
      await _stopDeviceTTS(); // Also stop device TTS

      // Get subscription service
      final subscriptionService =
          Provider.of<SubscriptionService>(context, listen: false);
      // Check if message already has audio (but not device TTS identifier)
      if (message.audioPath != null &&
          message.audioPath != "device_tts" &&
          File(message.audioPath!).existsSync()) {
        // Set this message as the currently playing one and immediately set playing state
        setState(() {
          _currentPlayingMessageId = message.id;
          _isPlayingAudio = true; // Set immediately for ElevenLabs audio
        });
        await _playAudio(message.audioPath!);
        return;
      }

      String? audioPath;

      // Determine what type of audio we'll be using and set the appropriate playing state
      bool willUseDeviceTTS = false;
      if (subscriptionService.isPremium) {
        final canUseElevenLabs =
            await subscriptionService.tryUseElevenLabsTTS();
        willUseDeviceTTS = !canUseElevenLabs;
      } else {
        willUseDeviceTTS = subscriptionService.canUseDeviceTTS();
      }

      // Set this message as the currently playing one and immediately set appropriate playing state
      setState(() {
        _currentPlayingMessageId = message.id;
        if (willUseDeviceTTS) {
          _isDeviceTTSPlaying = true; // Set immediately for device TTS
        } else {
          _isPlayingAudio = true; // Set immediately for ElevenLabs audio
        }
      });

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      audioPath = await ChatSpeechService.generateSubscriptionAwareAudio(
        isPremium: subscriptionService.isPremium,
        tryUseElevenLabsTts: () => subscriptionService.tryUseElevenLabsTTS(),
        canUseDeviceTTS: () => subscriptionService.canUseDeviceTTS(),
        generateElevenLabsAudio: () =>
            ChatSpeechService.generateAndPlayAudioForMessage(
          message: message.message,
          voiceId: settings.selectedVoiceId,
          elevenLabsService: _elevenLabsService,
          playAudio: _playAudio,
        ),
        generateDeviceTtsAudio: () =>
            _generateAndPlayDeviceTTS(message.message),
      );

      if (audioPath != null) {
        await _persistAudioPathForMessage(
          sourceMessage: message,
          audioPath: audioPath,
          syncInMemory: true,
        );
      } else {
        // Audio generation failed, reset playing states
        setState(() {
          _currentPlayingMessageId = null;
          _isDeviceTTSPlaying = false;
          _isPlayingAudio = false;
        });
      }
    } catch (e) {
      //// print('Error in _speakMessage: $e');
      _showErrorSnackBar("Error generating speech");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () async {
        // Mark showcase as completed so it won't show again
        await FeatureShowcaseService.markShowcaseShown();
        _showcaseCompleted = true;
        // print('🎉 Feature showcase completed!');
      },
      onStart: (index, key) {
        // print('🎯 [Showcase] Started step ${(index ?? 0) + 1} with key: $key');
      },
      onComplete: (index, key) {
        // print('🎯 [Showcase] Completed step ${(index ?? 0) + 1} with key: $key');
      },
      enableAutoScroll: true,
      disableBarrierInteraction: false,
      builder: (context) {
        // Store the context that has access to ShowCaseWidget
        _showcaseContext = context;
        return Consumer<ConversationProvider>(
          builder: (context, conversationProvider, child) {
            final selectedConversation =
                conversationProvider.selectedConversation;

            // Filter messages for the selected conversation (important for UI consistency)
            List<ChatMessage> displayMessages = [];
            if (selectedConversation == null) {
              // No conversation selected yet - only show messages being actively sent
              // This avoids showing historical messages without conversation IDs
              if (_isSending) {
                displayMessages = _messages
                    .where((msg) =>
                        msg.conversationId == null &&
                        DateTime.parse(msg.timestamp).isAfter(
                            DateTime.now().subtract(Duration(minutes: 5))))
                    .toList();
              } else {
                // No active sending - don't show any messages
                displayMessages = [];
              }
            } else {
              // For existing conversations, only show messages in this conversation.
              // Temporary null-conversation assistant rows can be stale stream
              // placeholders and should never render here.
              displayMessages = _messages
                  .where((msg) => msg.conversationId == selectedConversation.id)
                  .toList();
            }

            // More aggressive deduplication to prevent duplicate display
            final Map<String, ChatMessage> uniqueMessages = {};
            for (final msg in displayMessages) {
              String key;

              // Use ID if available (most reliable)
              if (msg.id != null) {
                key = 'id_${msg.id}';
              } else {
                // For messages without ID, use multiple criteria
                final contentHash = msg.message.hashCode;
                final timestampHash =
                    DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/
                        1000; // Round to nearest second
                key =
                    'content_${contentHash}_${msg.isUserMessage}_${timestampHash}';
              }

              if (!uniqueMessages.containsKey(key)) {
                uniqueMessages[key] = msg;
              } else {
                // If there's a conflict, prefer the one with an ID
                if (msg.id != null && uniqueMessages[key]!.id == null) {
                  uniqueMessages[key] = msg;
                } else {}
              }
            }
            displayMessages = uniqueMessages.values.toList();

            // Ensure messages are in chronological order
            displayMessages.sort((a, b) {
              final aTime = DateTime.parse(a.timestamp);
              final bTime = DateTime.parse(b.timestamp);
              return aTime.compareTo(bTime);
            });

            return Scaffold(
              drawer: ConversationDrawer(profileId: _currentProfileId),
              appBar: AppBar(
                title: BrandedAppTitle(
                  onTap: () {
                    // Optional: Navigate to subscription screen when tapped
                    Navigator.pushNamed(context, '/subscription');
                  },
                ),
                centerTitle: true,
                leading: Builder(
                  builder: (context) => Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      final drawerButton = IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: settings.getScaledFontSize(24),
                        ),
                        onPressed: () {
                          // Unfocus text field when drawer opens
                          FocusScope.of(context).unfocus();
                          Scaffold.of(context).openDrawer();
                        },
                      );

                      // Wrap with Showcase for feature highlighting
                      final showcaseData = _getShowcaseFeature('drawer_button');
                      return Showcase(
                        key: _drawerButtonKey,
                        title: showcaseData?.title ??
                            '📋 Conversations & Settings',
                        description: showcaseData?.description ??
                            'Tap here to open the side panel where you can view all your conversations, search through them, and access your settings.',
                        targetBorderRadius: BorderRadius.circular(8),
                        tooltipBackgroundColor: const Color(0xFF8B5CF6),
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
                        child: drawerButton,
                      );
                    },
                  ),
                ),
                actions: [
                  // Show mode toggle on welcome page, new conversation when in chat
                  if (selectedConversation == null && displayMessages.isEmpty)
                    // Clean mode toggle - matches drawer button style
                    Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        final button = IconButton(
                          icon: Icon(
                            _isToolsMode
                                ? Icons.grid_view_rounded
                                : Icons.chat_bubble_outline,
                            size: settings.getScaledFontSize(24),
                            color: _isToolsMode
                                ? const Color(0xFF0078D4)
                                : const Color(0xFF0078D4),
                          ),
                          onPressed: () {
                            setState(() {
                              _isToolsMode = !_isToolsMode;
                            });
                            _saveDisplayModePreference(_isToolsMode);
                          },
                          tooltip: _isToolsMode
                              ? 'Switch to Chat Mode'
                              : 'Switch to Tools Mode',
                        );

                        // Wrap with Showcase for feature highlighting
                        final showcaseData = _getShowcaseFeature('tools_mode');
                        return Showcase(
                          key: _toolsModeKey,
                          title: showcaseData?.title ?? '🔧 Tools Mode',
                          description: showcaseData?.description ??
                              'Switch between Chat mode for conversations and Tools mode for quick actions like image generation, PDF creation, and more!',
                          targetBorderRadius: BorderRadius.circular(8),
                          tooltipBackgroundColor: const Color(0xFF10B981),
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
                      },
                    )
                  else
                    // New conversation button when in chat
                    Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        return IconButton(
                          icon: Icon(
                            Icons.post_add,
                            size: settings.getScaledFontSize(24),
                          ),
                          onPressed: () {
                            // Clear current conversation selection and unfocus any text fields
                            FocusScope.of(context).unfocus();
                            final conversationProvider =
                                Provider.of<ConversationProvider>(context,
                                    listen: false);
                            conversationProvider.clearSelection();
                          },
                          tooltip:
                              AppLocalizations.of(context)!.newConversation,
                        );
                      },
                    ),
                ],
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    bottom: true,
                    maintainBottomViewPadding: true,
                    child: Column(
                      children: [
                        // Subscription banner
                        SubscriptionBanner(),

                        // Chat messages list
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF8E6CFF)),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    // When no conversation is selected or displaying messages, show welcome message
                                    selectedConversation == null &&
                                            displayMessages.isEmpty
                                        ? _buildWelcomeScreen()
                                        : displayMessages.isEmpty
                                            ? Center(
                                                child:
                                                    Consumer<SettingsProvider>(
                                                  builder: (context, settings,
                                                      child) {
                                                    return Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .noConversationsYet,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: settings
                                                            .getScaledFontSize(
                                                                16),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : ListView.builder(
                                                controller: _scrollController,
                                                padding: EdgeInsets.fromLTRB(
                                                  16,
                                                  20,
                                                  16,
                                                  _isVoiceInputMode
                                                      ? 100
                                                      : 80, // More padding for voice mode
                                                ),
                                                itemCount:
                                                    displayMessages.length,
                                                reverse:
                                                    false, // Keep chronological order
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(), // Make sure scrolling is always enabled
                                                itemBuilder: (context, index) {
                                                  final message =
                                                      displayMessages[index];
                                                  final messageKey = message
                                                          .id ??
                                                      Object.hash(
                                                        message.timestamp,
                                                        message.isUserMessage,
                                                        message.conversationId,
                                                      );

                                                  final isStreamingRow =
                                                      _streamingMessageAdded &&
                                                          _activeStreamingMessageTimestamp !=
                                                              null &&
                                                          !message
                                                              .isUserMessage &&
                                                          message.id == null &&
                                                          message.timestamp ==
                                                              _activeStreamingMessageTimestamp;

                                                  // Check if this is a places widget message (has locationResults but no message text)
                                                  if (message.locationResults !=
                                                          null &&
                                                      message.locationResults!
                                                          .isNotEmpty &&
                                                      message.message.isEmpty) {
                                                    // Render places widget at full width as a card with consistent styling
                                                    return Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 0),
                                                      child: PlaceResultWidget(
                                                        places: message
                                                            .locationResults!,
                                                        searchQuery:
                                                            _extractSearchQueryFromPreviousMessage(
                                                                index),
                                                      ),
                                                    );
                                                  }

                                                  // Regular message rendering
                                                  return ChatMessageWidget(
                                                    key: ValueKey(
                                                        '${messageKey}'),
                                                    message: message,
                                                    messageKey: messageKey,
                                                    forcePlainText:
                                                        isStreamingRow,
                                                    selectionMode:
                                                        _selectionMode,
                                                    selectedMessages:
                                                        _selectedMessages,
                                                    onToggleSelection:
                                                        (int key) {
                                                      setState(() {
                                                        if (_selectedMessages
                                                            .contains(key)) {
                                                          _selectedMessages
                                                              .remove(key);
                                                        } else {
                                                          _selectedMessages
                                                              .add(key);
                                                        }
                                                      });
                                                    },
                                                    onTranslate:
                                                        (ChatMessage msg) =>
                                                            _translateMessage(
                                                                context,
                                                                msg.message,
                                                                message: msg),
                                                    onQuickTranslate: (ChatMessage
                                                                msg,
                                                            String
                                                                targetLanguageCode,
                                                            String
                                                                targetLanguageName) =>
                                                        _performTranslation(
                                                            context,
                                                            msg.message,
                                                            targetLanguageCode,
                                                            targetLanguageName,
                                                            message: msg),
                                                    onSelectTranslationLanguage:
                                                        (ChatMessage msg) =>
                                                            _showTranslationLanguageSelector(
                                                                context,
                                                                msg.message,
                                                                message: msg),
                                                    translationPreferenceVersion:
                                                        _translationPreferenceVersion,
                                                    onDelete: _deleteMessage,
                                                    onShare: null,
                                                    translatedMessages:
                                                        _translatedMessages,
                                                    isPlayingAudio:
                                                        _currentPlayingMessageId ==
                                                                message.id &&
                                                            (message.audioPath ==
                                                                    "device_tts"
                                                                ? _isDeviceTTSPlaying
                                                                : _isPlayingAudio),
                                                    onPlayAudio: _playAudio,
                                                    onSpeakWithHighlight:
                                                        message.isUserMessage
                                                            ? null
                                                            : _speakMessage,
                                                    onQuickSaveToKnowledgeHub:
                                                        _quickSaveMessageToKnowledgeHub,
                                                    onSaveToKnowledgeHub:
                                                        _saveMessageToKnowledgeHub,
                                                    onReviewRequested:
                                                        () async {
                                                      // Add thank you message when user leaves review
                                                      final thankYouMessage =
                                                          ChatIntegrationHelper
                                                              .createThankYouMessage(
                                                        profileId:
                                                            _currentProfileId,
                                                        conversationId: Provider
                                                                .of<ConversationProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .selectedConversation
                                                            ?.id,
                                                      );

                                                      // Save to database
                                                      final messageId =
                                                          await _databaseService
                                                              .insertChatMessage(
                                                                  thankYouMessage);
                                                      final completeThankYou =
                                                          ChatMessage(
                                                        id: messageId,
                                                        message: thankYouMessage
                                                            .message,
                                                        isUserMessage:
                                                            thankYouMessage
                                                                .isUserMessage,
                                                        timestamp:
                                                            thankYouMessage
                                                                .timestamp,
                                                        profileId:
                                                            thankYouMessage
                                                                .profileId,
                                                        conversationId:
                                                            thankYouMessage
                                                                .conversationId,
                                                        messageType:
                                                            thankYouMessage
                                                                .messageType,
                                                      );

                                                      setState(() {
                                                        _messages.add(
                                                            completeThankYou);
                                                      });

                                                      // Scroll to bottom to show thank you message
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        _scrollToBottom(
                                                            animated: true);
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                    if (_isLoadingMore)
                                      Positioned(
                                        top: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Color(0xFF8E6CFF)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),

                        // Loading indicator for AI typing
                        if (_isSending)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF8E6CFF)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _aiLoadingMessage,
                                      style: TextStyle(
                                        color: Color(0xFF8E6CFF),
                                        fontStyle: FontStyle.italic,
                                        fontSize:
                                            settings.getScaledFontSize(14),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                        // Horizontal action cards removed - features accessible via + button menu

                        // Chat input area (with attachments)
                        ChatInputWidget(
                          textController: _textController,
                          textInputFocusNode: _textInputFocusNode,
                          isVoiceInputMode: _isVoiceInputMode,
                          isRecording: _isRecording,
                          isSending: _isSending,
                          pendingImages: _pendingImages,
                          pendingFiles: _pendingFiles, // Add file attachments
                          isPdfWorkflowActive: _isPdfWorkflowActive,
                          pdfCountdown: _pdfCountdown,
                          recordButtonText: _recordButtonText,
                          recordingDuration: _recordingDuration,
                          isShowingCancelHint: _isShowingCancelHint,
                          isCancelingRecording: _isCancelingRecording,
                          onToggleInputMode: _toggleInputMode,
                          onStartRecording: _startRecording,
                          onStopRecording: _stopRecordingAndProcess,
                          onCancelRecording: _cancelRecording,
                          onRecordingMove: (offset) {
                            // Handle recording move for swipe-to-cancel
                            final verticalDrag = offset.dy;
                            if (_isRecording) {
                              if (verticalDrag < -50 && !_isShowingCancelHint) {
                                setState(() {
                                  _isShowingCancelHint = true;
                                });
                                HapticFeedback.selectionClick();
                              }
                              if (verticalDrag < -100) {
                                setState(() {
                                  _isCancelingRecording = true;
                                });
                              } else {
                                setState(() {
                                  _isCancelingRecording = false;
                                });
                              }
                            }
                          },
                          onRemovePendingImage: _removePendingImage,
                          onRemovePendingFile:
                              _removePendingFile, // Add file removal callback
                          onConvertToPdf: _onConvertToPdfPressed,
                          onCancelPdfAutoConversion: _cancelPdfAutoConversion,
                          onShowAttachmentOptions: (bool forPdf) =>
                              _showAttachmentOptions(forPdf: forPdf),
                          onShowFileUploadOptions:
                              _showFileUploadOptions, // Add file upload callback
                          onLocationDiscovery: () {
                            // Show location discovery dialog with usage limits
                            final subscriptionService =
                                Provider.of<SubscriptionService>(context,
                                    listen: false);
                            if (subscriptionService.isPremium ||
                                subscriptionService.canUsePlacesExplorer) {
                              _showLocationSearch();
                            }
                          },
                          onShowPptxDialog: () {
                            // Show PPTX generation dialog
                            _showPptxGenerationDialog();
                          },
                          onShowImageGenerationDialog: () {
                            // Show AI image generation dialog
                            _showImageGenerationDialog();
                          },
                          onShowTranslationDialog: () {
                            // Show translation dialog
                            _showTranslationDialog();
                          },
                          forceDeepResearch: _forceDeepResearch,
                          onDeepResearchToggle: (enabled) {
                            setState(() {
                              _forceDeepResearch = enabled;
                            });
                          },
                          deepResearchKey: _deepResearchKey,
                          quickActionsKey: _quickActionsKey,
                          onQuickAction: (prompt) {
                            // Handle quick actions by automatically sending with the prompt
                            //// print('[ChatScreen] Quick action triggered with prompt: "$prompt"');
                            _sendButtonController.forward().then((_) {
                              _sendButtonController.reverse();
                            });
                            final imagesToSend =
                                List<XFile>.from(_pendingImages);
                            final filesToSend =
                                List<PlatformFile>.from(_pendingFiles);
                            setState(() {
                              _pendingImages.clear();
                              _pendingFiles.clear();
                            });
                            _sendMessage(prompt, imagesToSend, filesToSend);
                          },
                          onSendMessage: (text, images, files) {
                            // Update to handle files
                            //// print('[ChatScreen] onSendMessage callback called with:');
                            //// print('[ChatScreen] - text: "$text"');
                            //// print('[ChatScreen] - images: ${images?.length ?? 0}');
                            //// print('[ChatScreen] - files: ${files?.length ?? 0}');
                            if (files != null && files.isNotEmpty) {
                              for (int i = 0; i < files.length; i++) {
                                final file = files[i];
                                //// print('[ChatScreen] - file[$i]: ${file.name} (${FileService.formatFileSize(file.size)})');
                              }
                            }

                            _sendButtonController.forward().then((_) {
                              _sendButtonController.reverse();
                            });
                            setState(() {
                              _pendingImages.clear();
                              _pendingFiles.clear(); // Clear pending files
                            });
                            _sendMessage(text, images,
                                files); // Pass files to send message
                          },
                          sendButtonController: _sendButtonController,
                          micAnimationController: _micAnimationController,
                          recordingPulseController: _recordingPulseController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // New: Load messages for a specific conversation
  Future<void> _loadMessagesForConversation(int? conversationId) async {
    // If we're in the middle of sending a message, don't reload messages
    // This prevents the user's message from disappearing during processing
    if (_isSending) {
      return;
    }

    if (conversationId == null) {
      setState(() {
        _messages = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, load all messages for the current profile
      final allMessages = await _databaseService.getChatMessages(
        profileId: _currentProfileId,
        limit:
            100, // Increase limit to make sure we get all messages for this conversation
        offset: 0,
      );

      // Then filter for this conversation
      final conversationMessages =
          allMessages.where((m) => m.conversationId == conversationId).toList();

      // Sort messages by timestamp to ensure proper order
      conversationMessages.sort((a, b) {
        final aTime = DateTime.parse(a.timestamp);
        final bTime = DateTime.parse(b.timestamp);
        return aTime.compareTo(bTime);
      });

      // Preserve any unsent messages, but avoid duplicates
      List<ChatMessage> updatedMessages = List.from(conversationMessages);
      if (_isSending) {
        // If we're sending a message, make sure to keep any messages without conversation ID
        // These are messages that are in the process of being sent
        for (var msg in _messages) {
          // Only preserve messages that don't have an ID (not saved to DB yet)
          // and are not already in the conversation messages
          if (msg.id == null) {
            // Enhanced duplicate check for unsaved messages
            bool alreadyExists = updatedMessages.any((existing) =>
                existing.message == msg.message &&
                existing.isUserMessage == msg.isUserMessage &&
                existing.conversationId == msg.conversationId &&
                // Check if timestamps are within 5 seconds of each other
                (DateTime.parse(existing.timestamp)
                        .difference(DateTime.parse(msg.timestamp))
                        .abs()
                        .inSeconds <
                    5));

            if (!alreadyExists) {
              updatedMessages.add(msg);
            } else {}
          }
        }
      }

      // Final deduplication pass - remove any remaining duplicates based on content and conversation
      final Map<String, ChatMessage> uniqueMessages = {};
      for (final msg in updatedMessages) {
        // Create unique keys based on multiple criteria for more aggressive deduplication

        // First try to use ID (most reliable if available)
        String key;
        if (msg.id != null) {
          key = 'id_${msg.id}';
        } else {
          // For messages without ID, use combination of content hash, user flag, and timestamp
          final contentHash = msg.message.hashCode;
          final timestampHash =
              DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/
                  1000; // Round to nearest second
          key = 'content_${contentHash}_${msg.isUserMessage}_${timestampHash}';
        }

        if (!uniqueMessages.containsKey(key)) {
          uniqueMessages[key] = msg;
        } else {
          // If there's a conflict, keep the one with an ID if possible
          if (msg.id != null && uniqueMessages[key]!.id == null) {
            uniqueMessages[key] = msg;
          }
        }
      }
      updatedMessages = uniqueMessages.values.toList();

      setState(() {
        _messages = updatedMessages;
        _loadedCount = conversationMessages.length;
        _hasMore = conversationMessages.length == _pageSize;
        _isLoading = false;
        _lastLoadedConversationId = conversationId;
      });

      // Run cleanup to ensure no duplicates remain
      _cleanupMessagesList();

      if (_messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: false);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteMessage(ChatMessage message) async {
    setState(() {
      _messages.remove(message);
    });
    if (message.id != null) {
      await _databaseService.deleteChatMessagesBefore(
          DateTime.parse(message.timestamp)
              .add(const Duration(milliseconds: 1)),
          profileId: message.profileId);
      // The above deletes all messages before the given timestamp, but we want to delete just this one.
      // Let's add a dedicated delete method for a single message if needed.
    }
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.messageDeleted,
          style: TextStyle(fontSize: settings.getScaledFontSize(14)),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveMessageToKnowledgeHub(ChatMessage message) async {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);

    if (!subscriptionService.isPremium) {
      _showKnowledgeHubUpgradeDialog();
      return;
    }

    await _showSaveToKnowledgeHubDialog(message);
  }

  Future<void> _quickSaveMessageToKnowledgeHub(ChatMessage message) async {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (!subscriptionService.isPremium) {
      _showKnowledgeHubUpgradeDialog();
      return;
    }

    final content = _buildKnowledgeContent(message.message);
    if (content.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nothing to save from this message.',
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final title = _buildKnowledgeTitle(content);

    try {
      final knowledgeHubService = KnowledgeHubService();
      await knowledgeHubService.createKnowledgeItem(
        profileId: message.profileId ?? _currentProfileId ?? 1,
        conversationId: message.conversationId,
        sourceMessageId: message.id,
        title: title,
        content: content,
        memoryType: MemoryType.fact,
        tags: const [],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved to Knowledge Hub.',
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on PremiumRequiredException {
      if (mounted) {
        _showKnowledgeHubUpgradeDialog();
      }
    } on DuplicateKnowledgeItemException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This memory already exists in your Knowledge Hub.',
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save memory. Please try again.',
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSaveToKnowledgeHubDialog(ChatMessage message) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final titleController = TextEditingController(
      text: _buildKnowledgeTitle(message.message),
    );
    final contentController = TextEditingController(text: message.message);
    final tagsController = TextEditingController();
    MemoryType selectedType = MemoryType.fact;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Save to Knowledge Hub'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Short memory title',
                      ),
                      maxLength: 80,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        hintText: 'What should HowAI remember?',
                      ),
                      maxLines: 4,
                      minLines: 2,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MemoryType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: MemoryType.values
                          .map((type) => DropdownMenuItem<MemoryType>(
                                value: type,
                                child: Text(_memoryTypeLabel(type)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (optional)',
                        hintText: 'comma, separated, tags',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    if (title.isEmpty || content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Title and content are required.',
                            style: TextStyle(
                                fontSize: settings.getScaledFontSize(14)),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final tags = tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList();

                    try {
                      final knowledgeHubService = KnowledgeHubService();
                      await knowledgeHubService.createKnowledgeItem(
                        profileId: message.profileId ?? _currentProfileId ?? 1,
                        conversationId: message.conversationId,
                        sourceMessageId: message.id,
                        title: title,
                        content: content,
                        memoryType: selectedType,
                        tags: tags,
                      );

                      if (mounted) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved to Knowledge Hub.',
                              style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14)),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } on PremiumRequiredException {
                      if (mounted) {
                        Navigator.of(dialogContext).pop();
                        _showKnowledgeHubUpgradeDialog();
                      }
                    } on DuplicateKnowledgeItemException {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'This memory already exists in your Knowledge Hub.',
                              style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14)),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to save memory. Please try again.',
                              style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14)),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _buildKnowledgeTitle(String messageText) {
    final trimmed = messageText.trim().replaceAll('\n', ' ');
    if (trimmed.isEmpty) {
      return 'Saved Memory';
    }
    if (trimmed.length <= 48) {
      return trimmed;
    }
    return '${trimmed.substring(0, 48)}...';
  }

  String _buildKnowledgeContent(String messageText) {
    final compact = messageText.trim();
    if (compact.isEmpty) {
      return '';
    }
    if (compact.length <= 500) {
      return compact;
    }
    return compact.substring(0, 500);
  }

  String _memoryTypeLabel(MemoryType type) {
    switch (type) {
      case MemoryType.preference:
        return 'Preference';
      case MemoryType.fact:
        return 'Fact';
      case MemoryType.goal:
        return 'Goal';
      case MemoryType.constraint:
        return 'Constraint';
      case MemoryType.other:
        return 'Other';
    }
  }

  void _showKnowledgeHubUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpgradeDialog(
        featureName: 'Knowledge Hub',
        limitMessage:
            'Knowledge Hub is a Premium feature. Upgrade to save and reuse personal memories across conversations.',
        premiumBenefits: const [
          'Save personal memory from chat messages',
          'Use saved memory context in AI responses',
          'Manage and organize your knowledge hub',
        ],
        onUpgradePressed: () => Navigator.pushNamed(context, '/subscription'),
      ),
    );
  }

  Future<String> _injectKnowledgeContextIfEligible({
    required String message,
    required String userPrompt,
    required SubscriptionService subscriptionService,
  }) async {
    if (!subscriptionService.isPremium) {
      return message;
    }

    if (_currentProfileId == null) {
      return message;
    }

    try {
      final knowledgeHubService = KnowledgeHubService();
      final knowledgeContext =
          await knowledgeHubService.buildKnowledgeContextForPrompt(
        profileId: _currentProfileId!,
        prompt: userPrompt,
      );

      if (knowledgeContext.isEmpty) {
        return message;
      }

      return '$knowledgeContext\n\nUser request: $message';
    } on PremiumRequiredException {
      return message;
    } catch (_) {
      return message;
    }
  }

  Future<void> _translateMessage(BuildContext context, String text,
      {ChatMessage? message}) async {
    // Show language selection popup instead of directly translating
    await _showTranslationLanguageSelector(context, text, message: message);
  }

  Future<void> _showTranslationLanguageSelector(
      BuildContext context, String text,
      {ChatMessage? message}) async {
    // Get device locale and detected language
    final deviceLocale = Localizations.localeOf(context);
    final deviceLanguage = deviceLocale.languageCode;
    final detectedLanguage = _detectLanguage(text);
    final detectedLanguageCode = _getLanguageCode(detectedLanguage);

    // Get user's translation history for smart suggestions from profile
    final userPreferences =
        ProfileTranslationService.getTranslationHistory(context);

    // For first-time users (no translation history), auto-show full language selector
    if (userPreferences.isEmpty) {
      _showFullLanguageSelector(context, text, detectedLanguage,
          message: message);
      return;
    }

    // Get smart suggestions
    final suggestions = LanguageUtils.getSmartSuggestions(
      detectedLanguageCode: detectedLanguageCode,
      deviceLanguageCode: deviceLanguage,
      deviceLocale: deviceLocale,
      userPreferences: userPreferences,
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return LanguageSelectionPopup(
            sourceText: text,
            detectedLanguage: detectedLanguage,
            suggestedLanguages: suggestions,
            onLanguageSelected: (targetLanguageCode, targetLanguageName) {
              _performTranslation(
                  context, text, targetLanguageCode, targetLanguageName,
                  message: message);
            },
            onMoreLanguages: () {
              _showFullLanguageSelector(context, text, detectedLanguage,
                  message: message);
            },
          );
        },
      );
    }
  }

  Future<void> _showFullLanguageSelector(
      BuildContext context, String text, String detectedLanguage,
      {ChatMessage? message}) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FullLanguageSelectionDialog(
          sourceText: text,
          detectedLanguage: detectedLanguage,
          onLanguageSelected: (targetLanguageCode, targetLanguageName) {
            _performTranslation(
                context, text, targetLanguageCode, targetLanguageName,
                message: message);
          },
        );
      },
    );
  }

  Future<void> _performTranslation(BuildContext context, String text,
      String targetLanguageCode, String targetLanguageName,
      {ChatMessage? message}) async {
    // Save user's choice for future suggestions in their profile
    await ProfileTranslationService.addTranslationChoice(
        context, targetLanguageCode);

    final translationSourceText =
        ChatTranslationService.sanitizeForTranslation(text);
    final detectedLanguage = _detectLanguage(translationSourceText);
    final prompt = ChatTranslationService.buildTranslationPrompt(
      detectedLanguage: detectedLanguage,
      targetLanguageName: targetLanguageName,
      text: translationSourceText,
    );

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translatingTo(targetLanguageName),
          style: TextStyle(fontSize: settings.getScaledFontSize(14)),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final openAIService = _openAIService;
      final response = await openAIService.generateChatResponse(
        message: prompt,
        history: [],
      );
      final translation = ChatTranslationService.extractTranslationOrFallback(
        response: response,
        fallback: AppLocalizations.of(context)!.translationFailed,
      );
      if (message != null) {
        // Safer message key generation to prevent null check issues
        final messageIndex = _messages.indexOf(message);
        final messageKey =
            message.id ?? (messageIndex >= 0 ? messageIndex : message.hashCode);
        setState(() {
          _translatedMessages[messageKey] = translation;
        });
      } else {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              translation,
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Trigger a refresh of the UI to update smart translate buttons with a small delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _translationPreferenceVersion++; // This will force all translate buttons to refresh
          });
        }
      });
    } catch (e) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translationFailed,
            style: TextStyle(fontSize: settings.getScaledFontSize(14)),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Smart translation logic based on device locale and language detection
  Map<String, String> _getSmartTranslationInfo(
      BuildContext context, String text) {
    // Get user's device locale
    final deviceLocale = Localizations.localeOf(context);
    final deviceLanguage = deviceLocale.languageCode;

    // Detect source language using patterns
    String detectedLanguage = _detectLanguage(text);
    String detectedLanguageCode = _getLanguageCode(detectedLanguage);

    // Map language codes to full names for the prompt
    final languageNames = {
      'en': 'English',
      'zh': 'Chinese',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'da': 'Danish',
      'no': 'Norwegian',
      'fi': 'Finnish',
      'pl': 'Polish',
      'tr': 'Turkish',
      'th': 'Thai',
      'vi': 'Vietnamese',
    };

    String targetLanguageCode;
    String sourceLanguageName =
        languageNames[detectedLanguageCode] ?? detectedLanguage;
    String targetLanguageName;

    // Smart translation logic:
    // 1. If detected language is same as device language, translate to English (universal fallback)
    // 2. If detected language is different from device language, translate to device language
    // 3. If device language not supported, fallback to English
    // 4. If detected language is English and device is English, translate to most common second language based on region

    if (detectedLanguageCode == deviceLanguage) {
      // Same as device language
      if (deviceLanguage == 'en') {
        // English device, English text - translate to most common second language based on region
        targetLanguageCode = _getRegionalSecondLanguage(deviceLocale);
      } else {
        // Non-English device, same language text - translate to English
        targetLanguageCode = 'en';
      }
    } else {
      // Different from device language
      if (languageNames.containsKey(deviceLanguage)) {
        // Device language is supported
        targetLanguageCode = deviceLanguage;
      } else {
        // Device language not supported, fallback to English
        targetLanguageCode = 'en';
      }
    }

    targetLanguageName = languageNames[targetLanguageCode] ?? 'English';

    return {
      'source': sourceLanguageName,
      'target': targetLanguageName,
      'targetCode': targetLanguageCode,
    };
  }

  // Detect language using character patterns and common words
  String _detectLanguage(String text) {
    // Chinese (including Traditional and Simplified)
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'Chinese';
    }

    // Japanese (Hiragana, Katakana, Kanji)
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
      return 'Japanese';
    }

    // Korean (Hangul)
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
      return 'Korean';
    }

    // Arabic (including Persian and Urdu)
    if (RegExp(r'[\u0600-\u06ff\u0750-\u077f]').hasMatch(text)) {
      return 'Arabic';
    }

    // Russian (Cyrillic)
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) {
      return 'Russian';
    }

    // Thai
    if (RegExp(r'[\u0e00-\u0e7f]').hasMatch(text)) {
      return 'Thai';
    }

    // Hindi (Devanagari)
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) {
      return 'Hindi';
    }

    // For Latin-based scripts, use common words and patterns
    final lowercaseText = text.toLowerCase();

    // Spanish indicators
    if (_containsSpanishPatterns(lowercaseText)) {
      return 'Spanish';
    }

    // French indicators
    if (_containsFrenchPatterns(lowercaseText)) {
      return 'French';
    }

    // German indicators
    if (_containsGermanPatterns(lowercaseText)) {
      return 'German';
    }

    // Italian indicators
    if (_containsItalianPatterns(lowercaseText)) {
      return 'Italian';
    }

    // Portuguese indicators
    if (_containsPortuguesePatterns(lowercaseText)) {
      return 'Portuguese';
    }

    // Default to English for Latin scripts
    return 'English';
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'Chinese':
        return 'zh';
      case 'Spanish':
        return 'es';
      case 'French':
        return 'fr';
      case 'German':
        return 'de';
      case 'Italian':
        return 'it';
      case 'Portuguese':
        return 'pt';
      case 'Russian':
        return 'ru';
      case 'Japanese':
        return 'ja';
      case 'Korean':
        return 'ko';
      case 'Arabic':
        return 'ar';
      case 'Hindi':
        return 'hi';
      case 'Thai':
        return 'th';
      default:
        return 'en';
    }
  }

  // Get most common second language based on device region
  String _getRegionalSecondLanguage(Locale deviceLocale) {
    final country = deviceLocale.countryCode?.toLowerCase();

    switch (country) {
      case 'us':
      case 'ca':
        return 'es'; // Spanish is common in North America
      case 'gb':
      case 'ie':
        return 'fr'; // French is common second language in UK/Ireland
      case 'au':
      case 'nz':
        return 'zh'; // Chinese is common in Australia/New Zealand
      case 'sg':
      case 'my':
        return 'zh'; // Chinese is common in Southeast Asia
      case 'in':
        return 'hi'; // Hindi for India
      default:
        return 'es'; // Spanish as global fallback (most spoken second language)
    }
  }

  // Language pattern detection helpers
  bool _containsSpanishPatterns(String text) {
    final spanishWords = [
      'el',
      'la',
      'de',
      'que',
      'y',
      'es',
      'en',
      'un',
      'con',
      'no',
      'se',
      'te',
      'lo',
      'le',
      'da',
      'su',
      'por',
      'son',
      'como',
      'para',
      'del',
      'está',
      'una',
      'tiene',
      'más',
      'este',
      'eso',
      'todo',
      'bien',
      'sí',
      'donde',
      'qué',
      'cómo',
      'cuándo',
      'quién'
    ];
    final spanishChars = RegExp(r'[ñáéíóúü]');

    int wordMatches = spanishWords
        .where((word) =>
            text.contains(' $word ') ||
            text.startsWith('$word ') ||
            text.endsWith(' $word'))
        .length;
    bool hasSpanishChars = spanishChars.hasMatch(text);

    return wordMatches >= 2 || hasSpanishChars;
  }

  bool _containsFrenchPatterns(String text) {
    final frenchWords = [
      'le',
      'de',
      'et',
      'à',
      'un',
      'il',
      'être',
      'et',
      'en',
      'avoir',
      'que',
      'pour',
      'dans',
      'ce',
      'son',
      'une',
      'sur',
      'avec',
      'ne',
      'se',
      'pas',
      'tout',
      'plus',
      'par',
      'grand',
      'quand',
      'même',
      'lui',
      'nous',
      'comme',
      'après',
      'votre',
      'très',
      'bien',
      'où',
      'sans',
      'peut'
    ];
    final frenchChars = RegExp(r'[àâäçéèêëïîôùûüÿ]');

    int wordMatches = frenchWords
        .where((word) =>
            text.contains(' $word ') ||
            text.startsWith('$word ') ||
            text.endsWith(' $word'))
        .length;
    bool hasFrenchChars = frenchChars.hasMatch(text);

    return wordMatches >= 2 || hasFrenchChars;
  }

  bool _containsGermanPatterns(String text) {
    final germanWords = [
      'der',
      'die',
      'und',
      'in',
      'den',
      'von',
      'zu',
      'das',
      'mit',
      'sich',
      'des',
      'auf',
      'für',
      'ist',
      'im',
      'dem',
      'nicht',
      'ein',
      'eine',
      'als',
      'auch',
      'es',
      'an',
      'werden',
      'aus',
      'er',
      'hat',
      'dass',
      'sie',
      'nach',
      'wird',
      'bei',
      'einer',
      'um',
      'am',
      'sind',
      'noch',
      'wie',
      'einem',
      'über',
      'einen',
      'so',
      'zum',
      'war',
      'haben',
      'nur',
      'oder',
      'aber',
      'vor',
      'zur',
      'bis',
      'mehr',
      'durch',
      'man',
      'sein',
      'wurde',
      'sei',
      'in'
    ];
    final germanChars = RegExp(r'[äöüß]');

    int wordMatches = germanWords
        .where((word) =>
            text.contains(' $word ') ||
            text.startsWith('$word ') ||
            text.endsWith(' $word'))
        .length;
    bool hasGermanChars = germanChars.hasMatch(text);

    return wordMatches >= 2 || hasGermanChars;
  }

  bool _containsItalianPatterns(String text) {
    final italianWords = [
      'il',
      'di',
      'che',
      'e',
      'la',
      'a',
      'in',
      'un',
      'è',
      'per',
      'una',
      'sono',
      'con',
      'non',
      'le',
      'si',
      'da',
      'al',
      'del',
      'lo',
      'come',
      'ma',
      'se',
      'tutto',
      'nel',
      'ci',
      'anche',
      'questo',
      'quando',
      'molto',
      'bene',
      'senza',
      'può',
      'dove',
      'più',
      'cosa',
      'tempo',
      'tanto',
      'lei',
      'mio'
    ];
    final italianChars = RegExp(r'[àèéìîíòóù]');

    int wordMatches = italianWords
        .where((word) =>
            text.contains(' $word ') ||
            text.startsWith('$word ') ||
            text.endsWith(' $word'))
        .length;
    bool hasItalianChars = italianChars.hasMatch(text);

    return wordMatches >= 2 || hasItalianChars;
  }

  bool _containsPortuguesePatterns(String text) {
    final portugueseWords = [
      'o',
      'de',
      'a',
      'e',
      'do',
      'da',
      'em',
      'um',
      'para',
      'é',
      'com',
      'não',
      'uma',
      'os',
      'no',
      'se',
      'na',
      'por',
      'mais',
      'as',
      'dos',
      'como',
      'mas',
      'foi',
      'ao',
      'ele',
      'das',
      'tem',
      'à',
      'seu',
      'sua',
      'ou',
      'ser',
      'quando',
      'muito',
      'há',
      'nos',
      'já',
      'está',
      'eu',
      'também',
      'só',
      'pelo',
      'pela',
      'até',
      'isso',
      'ela',
      'entre',
      'era',
      'depois',
      'sem',
      'mesmo'
    ];
    final portugueseChars = RegExp(r'[áàâãçéêíóôõú]');

    int wordMatches = portugueseWords
        .where((word) =>
            text.contains(' $word ') ||
            text.startsWith('$word ') ||
            text.endsWith(' $word'))
        .length;
    bool hasPortugueseChars = portugueseChars.hasMatch(text);

    return wordMatches >= 2 || hasPortugueseChars;
  }

  // Update the toggle input mode method
  void _toggleInputMode() {
    setState(() {
      _isVoiceInputMode = !_isVoiceInputMode;

      // If switching to voice mode and help hasn't been shown yet, show it
      if (_isVoiceInputMode && _showVoiceInputHelp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showVoiceInputHelpTooltip();
        });
        _showVoiceInputHelp = false; // Only show once per session
      }
    });

    if (_isVoiceInputMode) {
      _inputModeAnimationController.forward();
    } else {
      _inputModeAnimationController.reverse();
    }

    // Scroll to bottom after toggling to ensure message visibility
    // Use a slightly longer delay to account for the animation
    Future.delayed(const Duration(milliseconds: 150), () {
      _scrollToBottom(animated: true);
    });
  }

  // Build the voice input button with a hint text below it
  Widget _buildVoiceInputButton() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Calculate scaled height - minimum 60, scaled based on font size
        final scaledHeight = math.max(60.0, settings.getScaledFontSize(60));
        final scaledIconSize = settings.getScaledFontSize(20);
        final scaledSpacing = settings.getScaledFontSize(8);
        final scaledPadding = settings.getScaledFontSize(12);
        final scaledBorderRadius = settings.getScaledFontSize(24);

        return GestureDetector(
          onLongPress: _startRecording,
          onLongPressEnd: (_) {
            if (_isCancelingRecording) {
              _cancelRecording();
            } else {
              _stopRecordingAndProcess();
            }
          },
          onLongPressCancel: () {
            if (_isRecording) {
              _stopRecordingAndProcess();
            }
          },
          // Add vertical drag handling for swipe-to-cancel
          onLongPressMoveUpdate: (details) {
            if (_isRecording) {
              final verticalDrag = details.offsetFromOrigin.dy;

              // If user swipes up more than 50 logical pixels, show cancel hint
              if (verticalDrag < -50 && !_isShowingCancelHint) {
                setState(() {
                  _isShowingCancelHint = true;
                });
                // Provide light haptic feedback when cancel hint appears
                HapticFeedback.selectionClick();
              }

              // If user swipes up more than 100 logical pixels, mark as canceling
              if (verticalDrag < -100) {
                setState(() {
                  _isCancelingRecording = true;
                });
              } else {
                setState(() {
                  _isCancelingRecording = false;
                });
              }
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: scaledHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red.shade50 : Colors.grey.shade100,
                gradient: _isRecording
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
                  color: _isRecording
                      ? Colors.red
                      : const Color(0xFF0078D4).withOpacity(0.3),
                  width: _isRecording ? 1.5 : 1,
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
                    if (_isRecording && !_isCancelingRecording)
                      AnimatedBuilder(
                        animation: _recordingPulseController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(scaledBorderRadius),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5 *
                                    (1 - _recordingPulseController.value)),
                                width:
                                    3.0 * (1 - _recordingPulseController.value),
                              ),
                            ),
                          );
                        },
                      ),

                    // Cancel indicator
                    if (_isShowingCancelHint)
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: scaledSpacing,
                              vertical: settings.getScaledFontSize(2)),
                          decoration: BoxDecoration(
                            color: _isCancelingRecording
                                ? Colors.red
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(scaledSpacing),
                              bottomRight: Radius.circular(scaledSpacing),
                            ),
                          ),
                          child: Text(
                            _isCancelingRecording
                                ? AppLocalizations.of(context)!.releaseToCancel
                                : AppLocalizations.of(context)!.swipeUpToCancel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(10),
                              fontWeight: _isCancelingRecording
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
                              if (!_isRecording)
                                Icon(
                                  Icons.mic_none_rounded,
                                  size: scaledIconSize,
                                  color: const Color(0xFF0078D4),
                                ),
                              if (!_isRecording) SizedBox(width: scaledSpacing),
                              Text(
                                _isRecording
                                    ? _isCancelingRecording
                                        ? AppLocalizations.of(context)!
                                            .cancelRecording
                                        : AppLocalizations.of(context)!
                                            .listening
                                    : AppLocalizations.of(context)!.holdToTalk,
                                style: TextStyle(
                                  color: _isCancelingRecording
                                      ? Colors.red.shade700
                                      : _isRecording
                                          ? Colors.red
                                          : const Color(0xFF0078D4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: settings.getScaledFontSize(16),
                                ),
                              ),
                            ],
                          ),
                          if (!_isRecording)
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
                    if (_isRecording && !_isCancelingRecording)
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
                                animation: _micAnimationController,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.mic,
                                    color: Colors.red.withOpacity(0.7 +
                                        0.3 * _micAnimationController.value),
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

  // Update show voice input help tooltip with more details
  void _showVoiceInputHelpTooltip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: Theme.of(context).primaryColor,
                    size: settings.getScaledFontSize(24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.voiceInputTipsTitle,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.touch_app,
                      color: Color(0xFF0078D4),
                      size: settings.getScaledFontSize(20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.voiceInputTipsPressHold,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsPressHoldDesc,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(14)),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: settings.getScaledFontSize(20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSpeakClearly,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!
                          .voiceInputTipsSpeakClearlyDesc,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(14)),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.swipe,
                      color: Colors.orange,
                      size: settings.getScaledFontSize(20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSwipeUp,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSwipeUpDesc,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(14)),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.keyboard,
                      color: Colors.blue,
                      size: settings.getScaledFontSize(20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSwitchInput,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!
                          .voiceInputTipsSwitchInputDesc,
                      style:
                          TextStyle(fontSize: settings.getScaledFontSize(14)),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.voiceInputTipsDontShowAgain,
                    style: TextStyle(fontSize: settings.getScaledFontSize(14)),
                  ),
                  onPressed: () {
                    _showVoiceInputHelp = false;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.voiceInputTipsGotIt,
                    style: TextStyle(fontSize: settings.getScaledFontSize(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add method to cancel recording timer
  void _cancelRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // Format recording time for display
  String get _formattedRecordingTime {
    final minutes = (_recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Add method to cancel recording
  void _cancelRecording() {
    // Give haptic feedback for cancellation
    HapticFeedback.heavyImpact();

    // Stop the animations
    _micAnimationController.stop();
    _micAnimationController.reset();
    _recordingPulseController.stop();
    _recordingPulseController.reset();

    // Cancel recording timer
    _cancelRecordingTimer();

    setState(() {
      _isRecording = false;
      _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
      _recordingDuration = 0;
      _isShowingCancelHint = false;
      _isCancelingRecording = false;
    });

    // Cancel the recording
    _audioRecorderService.cancelRecording();
  }

  Future<void> _analyzeUserCharacteristics(
      List<Map<String, String>> history) async {
    if (_currentProfileId == null) return;

    try {
      final characteristics = await _openAIService.analyzeUserCharacteristics(
        history: history,
        userName: _currentProfileName ?? 'User',
      );

      if (characteristics.isNotEmpty) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.updateProfileCharacteristics(
            _currentProfileId!, characteristics);
      } else {}
    } catch (e) {
      //debug
    }
  }

  // Image picking methods replaced with service calls
  Future<void> _pickImages({bool forPdf = false}) async {
    _isSelectingForPdf = forPdf;
    final List<XFile> images = await ImageService.pickImages(forPdf: forPdf);
    final result = ChatAttachmentService.applyImageSelection(
      currentPendingImages: _pendingImages,
      newImages: images,
      forPdf: _isSelectingForPdf,
    );
    if (images.isNotEmpty) {
      setState(() {
        _pendingImages = result.pendingImages;
        _isPdfWorkflowActive = result.isPdfWorkflowActive;
      });
    }

    if (result.shouldStartPdfTimer) {
      _startPdfAutoConversionTimer();
    }
    _isSelectingForPdf = false;
  }

  Future<void> _takePhoto({bool forPdf = false}) async {
    _isSelectingForPdf = forPdf;
    final XFile? photo = await ImageService.takePhoto(forPdf: forPdf);
    final result = ChatAttachmentService.applyImageSelection(
      currentPendingImages: _pendingImages,
      newImages: photo == null ? [] : [photo],
      forPdf: _isSelectingForPdf,
    );
    if (photo != null) {
      setState(() {
        _pendingImages = result.pendingImages;
        _isPdfWorkflowActive = result.isPdfWorkflowActive;
      });
    }

    if (result.shouldStartPdfTimer) {
      _startPdfAutoConversionTimer();
    }
    _isSelectingForPdf = false;
  }

  // Remove image from pending list
  void _removePendingImage(int index) {
    final result = ChatAttachmentService.removePendingImage(
      currentPendingImages: _pendingImages,
      index: index,
      isPdfWorkflowActive: _isPdfWorkflowActive,
    );

    setState(() {
      _pendingImages = result.pendingImages;
      _isPdfWorkflowActive = result.isPdfWorkflowActive;
    });

    if (result.shouldCancelPdfTimer) {
      _cancelPdfAutoConversion();
    } else if (result.shouldRestartPdfTimer) {
      _startPdfAutoConversionTimer();
    }
  }

  // Remove file from pending list
  void _removePendingFile(int index) {
    setState(() {
      _pendingFiles.removeAt(index);
    });
  }

  // Show file upload options
  void _showFileUploadOptions() {
    //// print('[ChatScreen] _showFileUploadOptions called');
    //// print('[ChatScreen] Context mounted: ${context.mounted}');
    //// print('[ChatScreen] Current pending files count: ${_pendingFiles.length}');

    // Add a small delay to ensure any previous dialogs are closed
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !context.mounted) {
        //// print('[ChatScreen] Context no longer mounted, canceling file upload');
        return;
      }

      try {
        FileService.showFilePickerDialog(
          context,
          onFileSelected: (file) {
            //// print('[ChatScreen] File selected: ${file.name} (${FileService.formatFileSize(file.size)})');
            if (mounted) {
              setState(() {
                _pendingFiles.add(file);
                //// print('[ChatScreen] Added file to pending. Total pending files: ${_pendingFiles.length}');
              });
            }
          },
          title: 'Upload Document',
          subtitle:
              'Select a document file for AI analysis\n(PDF, Word, PowerPoint, Excel, etc.)',
          cancelText: 'Cancel',
        );
      } catch (e) {
        //// print('[ChatScreen] Error showing file picker dialog: $e');
      }
    });
  }

  // Show attachment options using service
  void _showAttachmentOptions({bool forPdf = false}) {
    ImageService.showAttachmentOptions(
      context,
      forPdf: forPdf,
      onCameraSelected: (source) => _takePhoto(forPdf: forPdf),
      onGallerySelected: (source) => _pickImages(forPdf: forPdf),
      attachPhotoText: AppLocalizations.of(context)!.attachPhoto,
      cameraText: AppLocalizations.of(context)!.takePhoto,
      galleryText: AppLocalizations.of(context)!.chooseFromGallery,
      cancelText: AppLocalizations.of(context)!.cancel,
    );
  }

  Future<void> _onConvertToPdfPressed() async {
    if (_pendingImages.isEmpty) return;
    try {
      // Show a loading indicator
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.processing,
            style: TextStyle(fontSize: settings.getScaledFontSize(14)),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final pdfBytes = await PdfService.generatePdfFromImages(_pendingImages);
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/howai_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Verify file was actually written and is accessible
      await Future.delayed(Duration(
          milliseconds: 100)); // Small delay to ensure file system sync
      if (!await file.exists()) {
        throw Exception("PDF file was not created successfully");
      }

      // Double-check file size to ensure it's valid
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception("PDF file is empty");
      }

      //// print('[PDF-CONVERT] PDF file verified: ${fileSize} bytes at ${filePath}');

      setState(() {
        _pendingImages.clear();
        _isPdfWorkflowActive = false; // Reset PDF workflow flag
      });

      // Make sure keyboard is dismissed when conversation changes
      FocusScope.of(context).unfocus();

      // Get the conversation provider
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId =
          conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one for this PDF
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String pdfTitle =
            "PDF Document ${DateTime.now().toString().substring(0, 16)}";

        // Create a new conversation
        await conversationProvider.createConversation(
            pdfTitle, _currentProfileId);

        // Get the new conversation ID
        messageConversationId = conversationProvider.selectedConversation?.id;

        if (messageConversationId == null) {
          // If still null, something went wrong
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.somethingWentWrong,
                style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Make sure we have this conversation ID set in our local state
        _lastLoadedConversationId = messageConversationId;
      }

      // Add AI message with clickable link and the conversation ID
      final aiMessage = ChatMessage(
        message: '📄 Your PDF is ready! [Tap here to open it]($filePath)',
        isUserMessage: false,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        imagePaths: null,
        conversationId: messageConversationId,
      );

      // Save to database
      await _databaseService.insertChatMessage(aiMessage);

      // Only add the message to the UI if we're in the right conversation
      if (conversationProvider.selectedConversation?.id ==
          messageConversationId) {
        setState(() {
          _messages.add(aiMessage);
        });
      }

      // If we created a new conversation, reload messages for that conversation
      if (createdNewConversation) {
        await _loadMessagesForConversation(messageConversationId);
      }

      // Optionally scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pdfCreated,
            style: TextStyle(fontSize: settings.getScaledFontSize(14)),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      final settingsErr = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToCreatePdf(e),
            style: TextStyle(fontSize: settingsErr.getScaledFontSize(14)),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Update the onConversationChanged method
  void _onConversationChanged() {
    if (!ConversationGuard.shouldHandleConversationChange(
      mounted: mounted,
      isSending: _isSending,
      isCreatingNewConversation: _isCreatingNewConversation,
    )) {
      return;
    }

    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    final selectedConversation = conversationProvider.selectedConversation;

    if (ConversationGuard.shouldReloadConversation(
      selectedConversationId: selectedConversation?.id,
      lastLoadedConversationId: _lastLoadedConversationId,
    )) {
      // Clear messages before loading new ones to prevent mixing
      setState(() {
        _messages = [];
      });

      // Always force a reload when the conversation changes
      _lastLoadedConversationId = null;
      _loadMessagesForConversation(selectedConversation?.id);
    }
  }

  // Handle auth sync completion - refresh conversations and profile
  void _onAuthSyncCompleted() {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.syncCompleted) {
      debugPrint(
          '[AIChatScreen] Sync completed, refreshing conversations and profile');

      // Reset the flag so we don't re-trigger
      authProvider.resetSyncCompletedFlag();

      // Force reload conversations from database (which now has synced data)
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      conversationProvider.loadConversations(profileId: _currentProfileId);

      // Reload profile to get updated name/avatar from cloud
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loadProfiles();

      debugPrint('[AIChatScreen] UI refresh triggered after sync');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInitLocalization) {
      _recordButtonText =
          AppLocalizations.of(context)?.holdToTalk ?? 'Hold to Talk';
      _aiLoadingMessage =
          AppLocalizations.of(context)?.processing ?? 'Processing...';
      _didInitLocalization = true;
    }

    // Safety check for AppLocalizations
    if (AppLocalizations.of(context) == null) {
      return;
    }
    // Existing didChangeDependencies logic...
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final currentProfileId = profileProvider.selectedProfileId;
    if (currentProfileId != null) {
      _currentProfileId = currentProfileId;
      _loadProfileDetails(currentProfileId);
    }
    if (Provider.of<ProfileProvider>(context).chatHistoryCleared) {
      setState(() {
        _messages = [];
      });
      Provider.of<ProfileProvider>(context, listen: false)
          .resetChatHistoryClearedFlag();
    }

    // Load conversations for the current profile
    // This is safe because ConversationProvider exists at the app level
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    conversationProvider.ensureConversationsLoaded(context,
        profileId: _currentProfileId);

    // Load messages for the selected conversation
    final selectedConversation = conversationProvider.selectedConversation;
    if (selectedConversation != null &&
        selectedConversation.id != _lastLoadedConversationId) {
      _lastLoadedConversationId = selectedConversation.id;
      _loadMessagesForConversation(selectedConversation.id);
    }
  }

  Future<void> _loadProfileDetails(int profileId) async {
    try {
      final profile = await _databaseService.getProfile(profileId);
      if (profile != null && mounted) {
        setState(() {
          _currentProfileName = profile.name;
        });
      }
    } catch (e) {
      //debug
    }
  }

  void _pruneStreamingGhostAssistantRows({int? conversationId}) {
    final persistedAssistants = _messages
        .where((m) =>
            !m.isUserMessage &&
            m.id != null &&
            (conversationId == null || m.conversationId == conversationId))
        .toList();

    if (persistedAssistants.isEmpty) {
      return;
    }

    _messages.removeWhere((candidate) {
      if (candidate.isUserMessage || candidate.id != null) {
        return false;
      }

      if (conversationId != null &&
          candidate.conversationId != null &&
          candidate.conversationId != conversationId) {
        return false;
      }

      final candidateText = candidate.message.trim();
      if (candidateText.isEmpty) {
        return true;
      }

      final candidateTime = DateTime.tryParse(candidate.timestamp);
      final candidateFiles = jsonEncode(candidate.filePaths ?? const []);
      final candidateImages = jsonEncode(candidate.imagePaths ?? const []);

      for (final saved in persistedAssistants) {
        final savedText = saved.message.trim();
        if (savedText.isEmpty) {
          continue;
        }

        final sameFiles =
            candidateFiles == jsonEncode(saved.filePaths ?? const []);
        final sameImages =
            candidateImages == jsonEncode(saved.imagePaths ?? const []);
        if (!sameFiles || !sameImages) {
          continue;
        }

        final savedTime = DateTime.tryParse(saved.timestamp);
        final closeInTime = candidateTime != null && savedTime != null
            ? candidateTime.difference(savedTime).inSeconds.abs() <= 180
            : true;
        if (!closeInTime) {
          continue;
        }

        if (candidateText == savedText) {
          return true;
        }

        final shorter = candidateText.length <= savedText.length
            ? candidateText
            : savedText;
        final longer =
            candidateText.length > savedText.length ? candidateText : savedText;
        final hasStrongContainment =
            shorter.length >= 120 && longer.contains(shorter);
        if (hasStrongContainment) {
          return true;
        }
      }

      return false;
    });
  }

  // Helper method to clean up duplicates using service
  void _cleanupMessagesList() {
    final selectedConversationId =
        Provider.of<ConversationProvider>(context, listen: false)
            .selectedConversation
            ?.id;
    setState(() {
      _messages = MessageService.cleanupMessagesList(_messages);
      _pruneStreamingGhostAssistantRows(conversationId: selectedConversationId);
    });
  }

  // Helper method to lock database updates to prevent race conditions
  Future<void> _lockAndUpdateMessages(Future<void> Function() action) async {
    // Simple mutex-like mechanism
    if (_isUpdatingMessages) {
      // Wait a bit and try again
      await Future.delayed(Duration(milliseconds: 300));
      return _lockAndUpdateMessages(action);
    }

    try {
      _isUpdatingMessages = true;
      await action();
    } finally {
      _isUpdatingMessages = false;
    }
  }

  Future<void> _startRecording() async {
    try {
      // Save the current position for swipe detection
      _isShowingCancelHint = false;
      _isCancelingRecording = false;

      // Give haptic feedback when recording starts
      HapticFeedback.mediumImpact();

      setState(() {
        _isRecording = true;
        _recordButtonText = AppLocalizations.of(context)!.listening;
        _recordingDuration = 0;
      });

      // Start the mic animation
      _micAnimationController.repeat(reverse: true);

      // Start the recording pulse animation
      _recordingPulseController.repeat();

      // Start recording duration timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });

      // Start recording using the audio recorder service
      await _audioRecorderService.startRecording();
    } catch (e) {
      //debug
      setState(() {
        _isRecording = false;
        _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
      });
      _micAnimationController.stop();
      _recordingPulseController.stop();
      _cancelRecordingTimer();
      _showErrorSnackBar(AppLocalizations.of(context)!.couldNotAccessMic);
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    try {
      // Give haptic feedback when recording stops
      HapticFeedback.lightImpact();

      // Stop the animations
      _micAnimationController.stop();
      _micAnimationController.reset();
      _recordingPulseController.stop();
      _recordingPulseController.reset();

      // Cancel recording timer
      _cancelRecordingTimer();

      setState(() {
        _isRecording = false;
        _recordButtonText = AppLocalizations.of(context)!.processing;
        _recordingDuration = 0;
      });

      // Stop recording
      final recordingPath = await _audioRecorderService.stopRecording();

      if (recordingPath != null) {
        // Get the recording bytes
        final recordingBytes = await _audioRecorderService.getRecordingBytes();

        if (recordingBytes != null) {
          // Transcribe using OpenAI Whisper with smart language detection

          // Determine language hint based on user's locale (optional)
          String? languageHint;
          final locale = Localizations.localeOf(context);

          // Only provide language hint for supported languages, otherwise let Whisper auto-detect
          if (locale.languageCode == 'zh') {
            languageHint = 'zh'; // Chinese
          } else if (locale.languageCode == 'en') {
            languageHint = 'en'; // English
          }
          // For other languages, languageHint remains null and Whisper will auto-detect

          final transcription = await _openAIService
              .transcribeAudio(recordingBytes, language: languageHint);

          if (transcription != null && transcription.isNotEmpty) {
            setState(() {
              _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
            });

            // Send the transcribed text as a message
            await _sendMessage(transcription);
          } else {
            setState(() {
              _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
            });
            _showErrorSnackBar(AppLocalizations.of(context)!.iCouldntHear);
          }
        } else {
          setState(() {
            _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
          });
          _showErrorSnackBar(
              AppLocalizations.of(context)!.errorProcessingAudio);
        }
      } else {
        setState(() {
          _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
        });
        _showErrorSnackBar(AppLocalizations.of(context)!.recordingFailed);
      }

      // Cleanup the recording file
      await _audioRecorderService.deleteRecording();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordButtonText = AppLocalizations.of(context)!.holdToTalk;
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.errorProcessingVoice);
    } finally {}
  }

  void _showErrorSnackBar(String message) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    ChatSnackbarService.show(
      context: context,
      message: message,
      textStyle: TextStyle(fontSize: settings.getScaledFontSize(14)),
      backgroundColor: Colors.red.shade800,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
  }

  // Build responsive welcome screen using the extracted widget
  Widget _buildWelcomeScreen() {
    // In chat mode, show a clean interface without action cards
    if (!_isToolsMode) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clean welcome message for chat mode
                  Text(
                    "What can I help you with?",
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(24),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1C1E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "I'm here to assist with any questions or tasks you have.",
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(16),
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    // In tools mode, show the full grid dashboard
    return WelcomeScreenWidget(
      displayMode: 'grid',
      onFeatureCardTap: _onFeatureCardTap,
      onExampleChipTap: (text) {
        // Use the text as-is to preserve template structure
        _textController.text = text;
        FocusScope.of(context).requestFocus(_textInputFocusNode);
        // Move cursor to end for easy editing
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      },
      onShowImageGenerationDialog: () {
        // Show AI image generation dialog
        _showImageGenerationDialog();
      },
      onShowTranslationDialog: () {
        // Show translation dialog
        _showTranslationDialog();
      },
    );
  }

  // Handle feature card taps
  Future<void> _onFeatureCardTap(String feature) async {
    switch (feature) {
      case 'chat':
        // Focus the text input and provide a helpful prompt
        _textController.text = "Hi! I'd like to have a conversation about ";
        FocusScope.of(context).requestFocus(_textInputFocusNode);
        // Move cursor to end for easy editing
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        break;
      case 'photo':
        // Open camera/gallery picker for photo analysis
        _showAttachmentOptions(forPdf: false);
        break;
      case 'pdf':
        // Open camera/gallery picker specifically for PDF conversion
        _pickImages(forPdf: true);
        break;
      case 'pptx':
        // Show PPTX generation dialog to collect details
        _showPptxGenerationDialog();
        break;
      case 'file':
        // Open file picker for document analysis with usage limits for free users
        final subscriptionService =
            Provider.of<SubscriptionService>(context, listen: false);
        if (subscriptionService.isPremium) {
          _showFileUploadOptions();
        } else {
          // Check if free user can still use document analysis (without consuming)
          if (subscriptionService.canUseDocumentAnalysis) {
            _showFileUploadOptions();
          } else {
            // Show limit reached dialog
            _showDocumentAnalysisLimitDialog();
          }
        }
        break;
      case 'location':
        // Open location discovery feature with usage limits for free users
        final subscriptionService =
            Provider.of<SubscriptionService>(context, listen: false);
        if (subscriptionService.isPremium) {
          _showLocationSearch();
        } else {
          // Check if free user can still use places explorer (without consuming)
          if (subscriptionService.canUsePlacesExplorer) {
            _showLocationSearch();
          } else {
            // Show limit reached dialog
            _showPlacesExplorerLimitDialog();
          }
        }
        break;

      case 'voice':
        // Switch to voice input mode
        if (!_isVoiceInputMode) {
          _toggleInputMode();
        }
        // Show a helpful message
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Voice input activated! Hold the button and speak.",
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF8E44AD),
          ),
        );
        break;
    }
  }

  // Show location search dialog for places explorer
  void _showLocationSearch() {
    showDialog(
      context: context,
      barrierDismissible: true,
      // 确保对话框显示在最前面，特别是警告信息
      barrierColor: Colors.black.withOpacity(0.7),
      useRootNavigator: true,
      builder: (BuildContext context) {
        return LocationSearchDialog(
          onSearchCompleted: (places, query) {
            print(
                '[PlacesExplorer] Search completed: ${places.length} places found for "$query"');
            Navigator.of(context).pop();
            if (places.isNotEmpty) {
              _addLocationResultsToChat(places, query);
            } else {
              print('[PlacesExplorer] No places found - showing message');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'No places found for "$query". Try a different search or location.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        );
      },
    );
  }

  // Share AI message as styled PDF - Available for all users with usage limits for free users
  Future<void> _shareMessage(ChatMessage message) async {
    try {
      // Check PDF generation limits for free users
      final subscriptionService =
          Provider.of<SubscriptionService>(context, listen: false);
      if (!subscriptionService.isPremium) {
        final canUsePdf = await subscriptionService.tryUsePdfGeneration();
        if (!canUsePdf) {
          _showPdfLimitDialog();
          return;
        }
      }

      // Show loading indicator
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Generating styled PDF with formatting...",
            style: TextStyle(fontSize: settings.getScaledFontSize(14)),
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Generate PDF using HTML approach for better Unicode and styling support
      final pdfBytes =
          await PdfService.generateStyledMessagePdf(message.message);

      if (pdfBytes != null) {
        // Save PDF to documents directory
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${dir.path}/howai_message_${timestamp}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        // Verify file was actually written and is accessible
        await Future.delayed(Duration(
            milliseconds: 100)); // Small delay to ensure file system sync
        if (!await file.exists()) {
          throw Exception("PDF file was not created successfully");
        }

        // Double-check file size to ensure it's valid
        final fileSize = await file.length();
        if (fileSize == 0) {
          throw Exception("PDF file is empty");
        }

        //// print('[PDF-SHARE] PDF file verified: ${fileSize} bytes at ${filePath}');

        // Get the conversation provider
        final conversationProvider =
            Provider.of<ConversationProvider>(context, listen: false);
        final messageConversationId =
            conversationProvider.selectedConversation?.id ??
                message.conversationId;

        // Check subscription status for message customization
        final subscriptionService =
            Provider.of<SubscriptionService>(context, listen: false);
        final isPremium = subscriptionService.isPremium;

        // Create different messages for free vs premium users
        String pdfMessage;
        if (isPremium) {
          pdfMessage =
              "📄 **PDF created successfully!**\n\n[Tap here to open and share]($filePath)";
        } else {
          final remaining = subscriptionService.remainingPdfGenerations;
          final limit = subscriptionService.limits.pdfGenerationsWeekly;
          pdfMessage =
              "📄 **PDF created successfully!**\n\n[Tap here to open and share]($filePath)\n\n📊 PDF generations remaining: $remaining/$limit\n✨ Upgrade to Premium for unlimited access";
        }

        // Add AI response message with link to PDF
        final pdfLinkMessage = ChatMessage(
          message: pdfMessage,
          isUserMessage: false,
          timestamp: DateTime.now().toIso8601String(),
          profileId: _currentProfileId,
          conversationId: messageConversationId,
        );

        // Save to database
        await _databaseService.insertChatMessage(pdfLinkMessage);

        // Add to UI if we're in the right conversation
        if (conversationProvider.selectedConversation?.id ==
            messageConversationId) {
          setState(() {
            _messages.add(pdfLinkMessage);
          });
        }

        // Scroll to bottom to show the new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });

        // Share the PDF using native platform share sheet
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(filePath)],
              subject: 'AI Message',
              text: 'Shared from HaoGPT',
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to share PDF: ${e.toString()}",
                style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception("Failed to generate PDF");
      }
    } catch (e) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to generate message PDF: ${e.toString()}",
            style: TextStyle(fontSize: settings.getScaledFontSize(14)),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Show PDF generation limit dialog
  void _showPdfLimitDialog() {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    final remaining = subscriptionService.remainingPdfGenerations;
    final limit = subscriptionService.limits.pdfGenerationsWeekly;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 700;
            final isVerySmallScreen = screenHeight < 860 &&
                screenWidth < 400; // iPhone 16 specifically

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.orange,
                      size: settings
                          .getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'PDF Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'ve used all $limit lifetime PDF generations.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings
                            .getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...[
                      '• Unlimited PDF generation',
                      '• Professional-quality documents',
                      '• No waiting periods',
                      '• All premium features'
                    ].map((feature) => Padding(
                          padding: EdgeInsets.only(
                              bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(
                                  isVerySmallScreen
                                      ? 10
                                      : (isSmallScreen ? 12 : 14)),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                // Responsive button layout
                if (isSmallScreen)
                  // Horizontal layout for small screens
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
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
                  // Vertical layout for larger screens
                  TextButton(
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Upgrade Now',
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

  // Show document analysis limit dialog
  void _showDocumentAnalysisLimitDialog() {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    final remaining = subscriptionService.remainingDocumentAnalysis;
    final limit = subscriptionService.limits.documentAnalysisWeekly;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 700;
            final isVerySmallScreen = screenHeight < 860 &&
                screenWidth < 400; // iPhone 16 specifically

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: Colors.blue,
                      size: settings
                          .getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Document Analysis Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'ve used all $limit lifetime document analyses.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings
                            .getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...[
                      '• Unlimited document analysis',
                      '• Advanced file processing',
                      '• PDF, Word, Excel support',
                      '• All premium features'
                    ].map((feature) => Padding(
                          padding: EdgeInsets.only(
                              bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(
                                  isVerySmallScreen
                                      ? 10
                                      : (isSmallScreen ? 12 : 14)),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                // Responsive button layout
                if (isSmallScreen)
                  // Horizontal layout for small screens
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
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
                  // Vertical layout for larger screens
                  TextButton(
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Upgrade Now',
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

  // Show places explorer limit dialog
  void _showPlacesExplorerLimitDialog() {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    final remaining = subscriptionService.remainingPlacesExplorer;
    final limit = subscriptionService.limits.placesExplorerWeekly;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 700;
            final isVerySmallScreen = screenHeight < 860 &&
                screenWidth < 400; // iPhone 16 specifically

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF5856D6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF5856D6),
                      size: settings
                          .getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Places Explorer Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'ve used all $limit lifetime place searches.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(
                            isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings
                            .getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...[
                      '• Unlimited places exploration',
                      '• Advanced location search',
                      '• Real-time business info',
                      '• All premium features'
                    ].map((feature) => Padding(
                          padding: EdgeInsets.only(
                              bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(
                                  isVerySmallScreen
                                      ? 10
                                      : (isSmallScreen ? 12 : 14)),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                // Responsive button layout
                if (isSmallScreen)
                  // Horizontal layout for small screens
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
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
                  // Vertical layout for larger screens
                  TextButton(
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Upgrade Now',
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

  // Show PPTX generation dialog to collect user details
  void _showPptxGenerationDialog() {
    // Check subscription status first
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    // For PPTX: Premium users have unlimited access, free users get 3 uses based on document analysis remaining
    if (!subscriptionService.isPremium &&
        subscriptionService.remainingDocumentAnalysis <= 0) {
      _showPptxUpgradeDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return PptxGenerationDialog(
              onPptxRequest: (details) {
                // Close dialog and process immediately - no delay needed since we fixed the double-close issue
                Navigator.of(context).pop();
                if (mounted) {
                  _processPptxGeneration(details);
                }
              },
            );
          },
        );
      },
    );
  }

  // Show translation dialog to collect text and target language
  void _showTranslationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return TranslationDialog(
              onTranslate: (translationPrompt, {List<XFile>? images}) {
                _processTranslation(translationPrompt, images: images);
              },
            );
          },
        );
      },
    );
  }

  // Process translation request (unified for both text and images)
  Future<void> _processTranslation(String translationPrompt,
      {List<XFile>? images}) async {
    // Send the translation prompt as a regular chat message
    // If images are provided, send them along with the text
    if (images != null && images.isNotEmpty) {
      _sendMessage(translationPrompt, images);
    } else {
      _sendMessage(translationPrompt);
    }
  }

  // Process PPTX generation request
  Future<void> _processPptxGeneration(Map<String, String> details) async {
    // Determine if the topic requires current information
    final topic = details['topic'] ?? '';
    final keyPoints = details['keyPoints'] ?? '';
    final combinedText = '$topic $keyPoints'.toLowerCase();

    // Check for keywords that indicate need for current information
    final needsCurrentInfo = combinedText.contains('latest') ||
        combinedText.contains('current') ||
        combinedText.contains('recent') ||
        combinedText.contains('today') ||
        combinedText.contains('this week') ||
        combinedText.contains('last week') ||
        combinedText.contains('market') ||
        combinedText.contains('trends') ||
        combinedText.contains('news') ||
        combinedText.contains('analysis') ||
        combinedText.contains('research');

    // Create a user-friendly prompt that doesn't expose backend technical details
    final userFriendlyMessage = needsCurrentInfo
        ? """Create a PowerPoint presentation about ${details['topic']}. Please include the latest information and current trends.

**Presentation Details:**
- **Topic:** ${details['topic'] ?? 'Not specified'}
- **Number of Slides:** ${details['slides'] ?? '1-3'} slides
- **Key Points to Cover:** ${details['keyPoints'] ?? 'Standard coverage'}

Please create a comprehensive presentation with current information and make it available for download."""
        : """Create a PowerPoint presentation about ${details['topic']}.

**Presentation Details:**
- **Topic:** ${details['topic'] ?? 'Not specified'}
- **Number of Slides:** ${details['slides'] ?? '1-3'} slides
- **Key Points to Cover:** ${details['keyPoints'] ?? 'Standard coverage'}

Please create a comprehensive presentation with appropriate slide content, titles, and structure.""";

    // Create the system instruction for the AI (hidden from user)
    final systemInstruction = needsCurrentInfo
        ? """User wants a PPTX presentation that requires current information. Follow this workflow:
1. FIRST: Use web_search to gather latest information about: ${details['topic']}
2. IMMEDIATELY after: Use generate_pptx function to create the actual PPTX file
CRITICAL: You MUST complete BOTH steps. Do not stop after searching."""
        : """User wants a PPTX presentation. Use generate_pptx function to create the presentation file directly.""";

    // Store the system instruction for the AI service to use internally
    _pendingSystemInstruction = systemInstruction;
    final prompt = userFriendlyMessage;

    // Send the prompt as a regular chat message - check if widget is still mounted
    if (mounted) {
      _sendMessage(prompt);
    }
  }

  // Show PPTX upgrade dialog for non-premium users
  void _showPptxUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF9500).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.slideshow,
                        size: settings.getScaledFontSize(48),
                        color: Color(0xFFFF9500),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Presentation Maker - Premium Feature',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create professional PowerPoint presentations with AI assistance. This feature is available for Premium subscribers only.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '✨ Premium Benefits:',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: 8),
                          ...[
                            '• Create professional PPTX presentations',
                            '• Unlimited presentation generation',
                            '• Custom themes and layouts',
                            '• All premium AI features unlocked'
                          ].map(
                            (benefit) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                benefit,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(13),
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF9500),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/subscription');
                            },
                            child: Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _extractSearchQueryFromPreviousMessage(int currentIndex) {
    // Look for the user message before this places widget message
    for (int i = currentIndex - 1; i >= 0; i--) {
      final message = _messages[i];
      if (message.isUserMessage &&
          message.message.toLowerCase().contains('find')) {
        // Extract search query from messages like "Find restaurants near me"
        final words = message.message.split(' ');
        final findIndex =
            words.indexWhere((word) => word.toLowerCase() == 'find');
        if (findIndex >= 0 && findIndex < words.length - 1) {
          return words
              .sublist(findIndex + 1)
              .join(' ')
              .replaceAll(' near me', '');
        }
      }
    }
    return 'places'; // fallback
  }

  // Extract recent places context for AI follow-up questions
  String? _getRecentPlacesContext(
      String userMessage, List<ChatMessage> history) {
    // Skip if this looks like a new search command rather than a question about existing results
    final lowerMessage = userMessage.toLowerCase();

    // Check for analysis/recommendation keywords that should NOT be treated as new searches
    final isAnalysisRequest = lowerMessage.contains('suggest') ||
        lowerMessage.contains('recommend') ||
        lowerMessage.contains('best') ||
        lowerMessage.contains('top ') ||
        lowerMessage.contains('which') ||
        lowerMessage.contains('explain why') ||
        lowerMessage.contains('analyze') ||
        lowerMessage.contains('compare') ||
        lowerMessage.contains('choose') ||
        lowerMessage.contains('pick');

    // Only skip if it's clearly a NEW search command AND not an analysis request
    final isNewSearchCommand = !isAnalysisRequest &&
        (lowerMessage.startsWith('find ') ||
            lowerMessage.startsWith('search ') ||
            lowerMessage.startsWith('show me ') ||
            (lowerMessage.contains('near me') &&
                !lowerMessage.contains('suggest')) ||
            lowerMessage.contains('search for'));

    if (isNewSearchCommand) return null;

    // Look for recent messages with location results (within last 8 messages)
    for (int i = history.length - 1; i >= 0 && i >= history.length - 8; i--) {
      final message = history[i];
      if (message.locationResults != null &&
          message.locationResults!.isNotEmpty) {
        // Found recent places data, format it for AI context
        final places = message.locationResults!;
        final placesInfo = StringBuffer();
        placesInfo.writeln('Here are the places I recently found for you:');

        for (int j = 0; j < places.length && j < 20; j++) {
          final place = places[j];
          placesInfo.writeln('${j + 1}. ${place.name}');
          placesInfo.writeln(
              '   - Rating: ${place.rating}/5 (${place.userRatingsTotal} reviews)');
          placesInfo.writeln('   - Type: ${place.types.join(', ')}');
          placesInfo.writeln('   - Price: ${place.priceLevel}');
          placesInfo.writeln('   - Distance: ${place.getDistanceText(
            locale: Localizations.localeOf(context).toString(),
            countryCode: Localizations.localeOf(context).countryCode,
          )}');
          if (place.aiSummary?.isNotEmpty == true) {
            placesInfo.writeln('   - Description: ${place.aiSummary}');
          }
          placesInfo.writeln('');
        }

        placesInfo.writeln(
            'Please answer the user\'s question about these places based on their ratings, reviews, type, and other information provided. If they ask for recommendations, suggestions, or want you to pick the best options, analyze the data above and provide specific recommendations with detailed explanations of why you chose those particular places (consider factors like rating, number of reviews, price level, distance, and type).\n\nIMPORTANT: Only discuss the places listed above. Do NOT make up or fabricate information about places not in this list. If you cannot find relevant places in the provided data, clearly state that you need more information or suggest the user perform a new search.');
        return placesInfo.toString();
      }
    }

    return null;
  }

  // Add location search results to chat as a special message
  // Generate smart, contextual message for places results
  String _generateSmartPlacesMessage(List<PlaceResult> places, String query) {
    if (places.isEmpty) {
      return "I couldn't find any places matching \"$query\" in your area. Try a different search term or check your location settings.";
    }

    // Analyze the types of places to generate a smart response
    final placeTypes = <String>{};
    for (final place in places) {
      placeTypes.addAll(place.types);
    }

    // Generate context-aware message based on place types
    String placeCategory = 'places';
    String searchContext = query.toLowerCase();

    if (placeTypes.any(
        (type) => ['restaurant', 'food', 'meal_takeaway'].contains(type))) {
      if (searchContext.contains('chinese')) {
        placeCategory = 'Chinese restaurants';
      } else if (searchContext.contains('pizza')) {
        placeCategory = 'pizza places';
      } else if (searchContext.contains('sushi')) {
        placeCategory = 'sushi restaurants';
      } else if (searchContext.contains('mexican')) {
        placeCategory = 'Mexican restaurants';
      } else if (searchContext.contains('thai')) {
        placeCategory = 'Thai restaurants';
      } else if (searchContext.contains('italian')) {
        placeCategory = 'Italian restaurants';
      } else if (searchContext.contains('indian')) {
        placeCategory = 'Indian restaurants';
      } else if (searchContext.contains('burger')) {
        placeCategory = 'burger joints';
      } else if (searchContext.contains('seafood')) {
        placeCategory = 'seafood restaurants';
      } else {
        placeCategory = 'restaurants';
      }
    } else if (placeTypes.contains('cafe')) {
      placeCategory = 'coffee shops';
    } else if (placeTypes.any((type) => ['bakery', 'dessert'].contains(type))) {
      placeCategory = 'bakeries and dessert places';
    } else if (placeTypes.contains('parking')) {
      placeCategory = 'parking spots';
    } else if (placeTypes
        .any((type) => ['hospital', 'pharmacy', 'doctor'].contains(type))) {
      if (placeTypes.contains('pharmacy')) {
        placeCategory = 'pharmacies';
      } else {
        placeCategory = 'healthcare facilities';
      }
    } else if (placeTypes.contains('gas_station')) {
      placeCategory = 'gas stations';
    } else if (placeTypes.contains('atm')) {
      placeCategory = 'ATMs';
    } else if (placeTypes.contains('bank')) {
      placeCategory = 'banks';
    } else if (placeTypes
        .any((type) => ['shopping_mall', 'store'].contains(type))) {
      placeCategory = 'shopping locations';
    } else if (placeTypes.contains('lodging')) {
      placeCategory = 'hotels';
    } else if (placeTypes.contains('tourist_attraction')) {
      placeCategory = 'attractions';
    } else if (placeTypes.contains('gym')) {
      placeCategory = 'fitness centers';
    } else if (placeTypes.contains('beauty_salon')) {
      placeCategory = 'beauty salons';
    } else if (placeTypes.contains('laundry')) {
      placeCategory = 'laundromats';
    } else if (placeTypes.contains('night_club')) {
      placeCategory = 'bars and nightlife';
    } else if (placeTypes.contains('park')) {
      placeCategory = 'parks';
    } else if (placeTypes.contains('subway_station')) {
      placeCategory = 'transit stations';
    }

    // Special handling for restroom searches
    if (searchContext.contains('restroom') ||
        searchContext.contains('bathroom') ||
        searchContext.contains('toilet')) {
      return "I found ${places.length} places with public restrooms nearby. These locations typically have facilities available:";
    }

    // Check if it's a location-specific search
    bool hasLocationContext = query.toLowerCase().contains(' in ') ||
        query.toLowerCase().contains(' at ') ||
        RegExp(r'\b\d{5}\b').hasMatch(query); // zip code

    if (hasLocationContext) {
      return "I found ${places.length} $placeCategory in your specified area:";
    } else {
      return "I found ${places.length} $placeCategory near you:";
    }
  }

  Future<void> _addLocationResultsToChat(
      List<PlaceResult> places, String query) async {
    try {
      // Consume places explorer usage for free users
      final subscriptionService =
          Provider.of<SubscriptionService>(context, listen: false);
      if (!subscriptionService.isPremium) {
        await subscriptionService.tryUsePlacesExplorer();
        // Show usage reminder for free users
        final remaining = subscriptionService.remainingPlacesExplorer;
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Places explorer used. You have $remaining uses remaining.",
                style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
            ),
          );
        });
      }

      // Get the conversation provider
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId =
          conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one for this search
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String searchTitle = "Places Explorer: $query";

        // Create a new conversation
        await conversationProvider.createConversation(
            searchTitle, _currentProfileId);

        // Get the new conversation ID
        messageConversationId = conversationProvider.selectedConversation?.id;

        if (messageConversationId == null) {
          _showErrorSnackBar("Failed to create conversation");
          return;
        }

        // Make sure we have this conversation ID set in our local state
        _lastLoadedConversationId = messageConversationId;
      }

      // Create user message for the search
      final userMessage = ChatMessage(
        message: "Find $query near me",
        isUserMessage: true,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        conversationId: messageConversationId,
      );

      // Save user message to database
      await _databaseService.insertChatMessage(userMessage);

      // Create AI response with a smart dynamic message
      final aiResponseMessage = ChatMessage(
        message: _generateSmartPlacesMessage(places, query),
        isUserMessage: false,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        conversationId: messageConversationId,
      );

      // Create separate places widget message (no text, just the places data)
      final locationResultsMessage = ChatMessage(
        message: "", // Empty message since this is just for the places widget
        isUserMessage: false,
        timestamp: DateTime.now().toIso8601String(),
        profileId: _currentProfileId,
        conversationId: messageConversationId,
        locationResults: places,
      );

      // Save both AI messages to database
      await _databaseService.insertChatMessage(aiResponseMessage);
      await _databaseService.insertChatMessage(locationResultsMessage);

      // If we created a new conversation, reload messages for that conversation
      if (createdNewConversation) {
        await _loadMessagesForConversation(messageConversationId);
      } else {
        // Just add messages to current conversation
        setState(() {
          _messages.add(userMessage);
          _messages.add(aiResponseMessage);
          _messages.add(locationResultsMessage);
        });
      }

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });
    } catch (e) {
      //// print('[LocationSearch] Error adding results to chat: $e');
      _showErrorSnackBar("Failed to save location results");
    }
  }

  // Show AI Image generation dialog to guide user with prompting
  void _showImageGenerationDialog() {
    // Check subscription status first
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    if (!subscriptionService.canUseImageGeneration) {
      _showImageGenerationUpgradeDialog();
      return;
    }

    TextEditingController promptController = TextEditingController();

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Stack(
                children: [
                  // Positioned dialog very close to top
                  Positioned(
                    top: 120, // Very close to top
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.75,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Compact header with icon and title in same row
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Column(
                                  children: [
                                    // Icon and title in same row
                                    Row(
                                      children: [
                                        // Smaller header icon
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? Colors.teal.withOpacity(0.2)
                                                : Colors.teal.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Icon(
                                            Icons.brush,
                                            size:
                                                settings.getScaledFontSize(24),
                                            color: Colors.teal,
                                          ),
                                        ),
                                        SizedBox(width: 12),

                                        // Title and description
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'AI Image Generation',
                                                style: TextStyle(
                                                  fontSize: settings
                                                      .getScaledFontSize(16),
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Color(0xFF1C1C1E),
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Describe what you want to create',
                                                style: TextStyle(
                                                  fontSize: settings
                                                      .getScaledFontSize(11),
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Scrollable content area
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      // Compact input field
                                      TextField(
                                        controller: promptController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .futuristicCityExample,
                                          hintStyle: TextStyle(
                                            fontSize:
                                                settings.getScaledFontSize(11),
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade500,
                                          ),
                                          filled: true,
                                          fillColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey.shade800
                                                  : Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.teal, width: 2),
                                          ),
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        style: TextStyle(
                                          fontSize:
                                              settings.getScaledFontSize(13),
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      // Compact tips
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.blue.shade900
                                                  .withOpacity(0.3)
                                              : Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '💡 Tips:',
                                              style: TextStyle(
                                                fontSize: settings
                                                    .getScaledFontSize(13),
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.blue.shade300
                                                    : Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '• Style: realistic, cartoon, digital art\n• Lighting & mood details\n• Colors & composition',
                                              style: TextStyle(
                                                fontSize: settings
                                                    .getScaledFontSize(13),
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.blue.shade200
                                                    : Colors.blue.shade600,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8), // Space for scroll
                                    ],
                                  ),
                                ),
                              ),

                              // Compact bottom buttons
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize:
                                                settings.getScaledFontSize(13),
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                        ),
                                        onPressed: () {
                                          final prompt =
                                              promptController.text.trim();
                                          if (prompt.isNotEmpty) {
                                            FocusScope.of(context).unfocus();
                                            Navigator.of(context).pop();
                                            _processImageGeneration(prompt);
                                          }
                                        },
                                        child: Text(
                                          'Generate',
                                          style: TextStyle(
                                            fontSize:
                                                settings.getScaledFontSize(13),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  // Process AI image generation request
  Future<void> _processImageGeneration(String prompt) async {
    // Construct a detailed prompt for image generation
    final fullPrompt = "Generate an image of $prompt";

    // Send the prompt as a regular chat message
    _sendMessage(fullPrompt);
  }

  // Show upgrade dialog for non-premium users
  void _showImageGenerationUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.brush,
                        size: settings.getScaledFontSize(48),
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'AI Image Generation - Premium Feature',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create stunning artwork and images from your imagination. This feature is available for Premium subscribers.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/subscription');
                            },
                            child: Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
