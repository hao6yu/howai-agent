import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
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

import '../models/chat_message.dart';
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
import '../utils/language_utils.dart';
import '../widgets/language_selection_popup.dart';
import '../widgets/full_language_selection_dialog.dart';

// Add LocationQueryInfo class definition
class LocationQueryInfo {
  final String category;
  final String query;
  final String originalText;

  LocationQueryInfo({
    required this.category,
    required this.query,
    required this.originalText,
  });
}

class AiChatScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGuide;

  const AiChatScreen({
    super.key,
    this.onNavigateToGuide,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  final OpenAIService _openAIService = OpenAIService();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();
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
  bool _isSelectingForPdf = false; // Flag to track if we're selecting images for PDF
  bool _isPdfWorkflowActive = false; // Track if current images are for PDF workflow

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
  
  // Dynamic loading messages like Claude Code
  static const List<String> _thinkingMessages = [
    'is thinking...',
    'is pondering...',
    'is analyzing...',
    'is considering...',
    'is processing...',
    'is working on it...',
    'is figuring it out...',
    'is contemplating...',
    'is reasoning...',
    'is crafting a response...',
  ];
  
  static const List<String> _deepThinkingMessages = [
    'is deep reasoning...',
    'is thinking deeply...',
    'is analyzing in depth...',
    'is doing heavy lifting...',
    'is crunching the data...',
    'is exploring possibilities...',
    'is diving deep...',
    'is connecting the dots...',
    'is synthesizing insights...',
    'is reasoning step by step...',
  ];
  
  static const List<String> _longWaitMessages = [
    'is still working...',
    'is almost there...',
    'just a bit longer...',
    'working hard on this...',
    'taking extra care...',
    'putting finishing touches...',
    'wrapping things up...',
    'hang tight...',
  ];

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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
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
          debugPrint('[AIChatScreen] Subscribed to real-time updates for conversation: $conversationUuid');
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
      final savedMode = prefs.getBool('display_mode_is_tools') ?? false; // Default to chat mode for new users
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
    final features = FeatureShowcaseService.getFeaturesForCurrentVersion(context);
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
    final features = FeatureShowcaseService.getFeaturesForCurrentVersion(context);
    return features.firstWhere((feature) => feature.id == featureId,
        orElse: () => ShowcaseFeature(
              id: featureId,
              title: featureId,
              description: featureId,
            ));
  }

  // Helper method to validate voice map
  bool _isValidVoiceMap(Map<String, String> voice) {
    return voice.containsKey('name') && voice['name'] != null && voice['name']!.isNotEmpty;
  }

  Future<void> _initializeDeviceTTS() async {
    try {
      _flutterTts = FlutterTts();

      // Set basic TTS properties first
      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setSpeechRate(0.5); // Optimized for clarity
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      // DO NOT set custom voice during initialization to avoid crashes
      // Voice will be set later when actually speaking if needed

      // Set completion handler
      _flutterTts!.setCompletionHandler(() {
        //// print('[DeviceTTS] TTS playback completed');
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = false;
            _currentPlayingMessageId = null;
          });
        }
      });

      // Set start handler
      _flutterTts!.setStartHandler(() {
        //// print('[DeviceTTS] TTS playback started');
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = true;
          });
        }
      });

      // Set cancel handler
      _flutterTts!.setCancelHandler(() {
        //// print('[DeviceTTS] TTS playback cancelled');
        if (mounted) {
          setState(() {
            _isDeviceTTSPlaying = false;
            _currentPlayingMessageId = null;
          });
        }
      });

      //// print('[DeviceTTS] Device TTS initialized successfully');
    } catch (e) {
      //// print('[DeviceTTS] Error initializing device TTS: $e');
    }
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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      conversationProvider.removeListener(_onConversationChanged);
    } catch (e) {}
    
    // Remove auth listener
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_onAuthSyncCompleted);
    } catch (e) {}

    // Dispose device TTS
    _flutterTts?.stop();
    _flutterTts = null;

    super.dispose();
  }

  // PDF Auto-conversion methods
  void _startPdfAutoConversionTimer() {
    // Cancel any existing timer
    _pdfAutoConversionTimer?.cancel();

    if (_pendingImages.isEmpty) return;

    // Start countdown from 3 seconds
    setState(() {
      _pdfCountdown = 3;
    });

    _pdfAutoConversionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _pdfCountdown--;
      });

      if (_pdfCountdown <= 0) {
        timer.cancel();
        _pdfAutoConversionTimer = null;

        // Auto-convert to PDF
        if (_pendingImages.isNotEmpty) {
          _onConvertToPdfPressed();
        }
      }
    });
  }

  void _cancelPdfAutoConversion() {
    _pdfAutoConversionTimer?.cancel();
    _pdfAutoConversionTimer = null;
    setState(() {
      _pdfCountdown = 0;
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.offset <= 100 && !_isLoadingMore && _hasMore && !_isLoading) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages({bool initial = true}) async {
    final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
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
    final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
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
      isWelcomeMessage: true, // Add a flag to identify this as the welcome message
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
    await AudioService.prepareVoiceDemoPlayer(useSpeakerOutput: settings.useSpeakerOutput);
  }

  // Start rotating loading messages
  void _startLoadingMessageRotation(String aiName, {bool isDeepResearch = false, bool isLongWait = false}) {
    _loadingMessageRotationTimer?.cancel();
    _loadingMessageIndex = 0;
    
    // Set initial message
    final messages = isLongWait 
        ? _longWaitMessages 
        : (isDeepResearch ? _deepThinkingMessages : _thinkingMessages);
    
    // Shuffle for variety (use a copy to not modify original)
    final shuffled = List<String>.from(messages)..shuffle();
    
    setState(() {
      _aiLoadingMessage = '$aiName ${shuffled[0]}';
    });
    
    // Rotate every 2-3 seconds
    _loadingMessageRotationTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!_isSending || !mounted) {
        timer.cancel();
        return;
      }
      _loadingMessageIndex = (_loadingMessageIndex + 1) % shuffled.length;
      setState(() {
        _aiLoadingMessage = '$aiName ${shuffled[_loadingMessageIndex]}';
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
      _isSending = true;
    });
    _startLoadingMessageRotation(aiName);

    String fullText = '';
    String? title;
    List<String>? images;
    List<String>? files;

    // Helper to strip title JSON from text
    String _stripTitleJson(String text) {
      // Remove title JSON pattern from anywhere in text (not just beginning)
      final titlePattern = RegExp(r'\s*\{"title"\s*:\s*"[^"]*"\}\s*');
      return text.replaceAll(titlePattern, '').trim();
    }

    // Helper to extract title from text
    String? _extractTitle(String text) {
      final titleMatch = RegExp(r'\{"title"\s*:\s*"([^"]+)"\}').firstMatch(text);
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
              if (!_streamingMessageAdded) {
                // First real content - add the message to UI
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
                  _streamingMessageAdded = true;
                  _isSending = false; // Hide typing indicator, show message instead
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(animated: true);
                });
              } else if (_streamingMessageIndex != null && _streamingMessageIndex! < _messages.length) {
                // Update existing message
                setState(() {
                  final updatedMessage = ChatMessage(
                    message: displayText,
                    isUserMessage: false,
                    timestamp: timestamp,
                    profileId: _currentProfileId,
                    conversationId: conversationId,
                  );
                  _messages[_streamingMessageIndex!] = updatedMessage;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(animated: false);
                });
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
            // Remove message on error if it was added
            if (_streamingMessageAdded && _streamingMessageIndex != null && _streamingMessageIndex! < _messages.length) {
              setState(() {
                _messages.removeAt(_streamingMessageIndex!);
              });
            }
            setState(() {
              _streamingMessageIndex = null;
              _streamingMessageAdded = false;
              _isSending = false;
            });
            return null;
        }
      }

      // Clean up the final text
      String cleanedText = _stripTitleJson(fullText);

      // Remove the streaming message - it will be re-added by the normal flow with proper DB save
      if (_streamingMessageAdded && _streamingMessageIndex != null && _streamingMessageIndex! < _messages.length) {
        setState(() {
          _messages.removeAt(_streamingMessageIndex!);
        });
      }
      setState(() {
        _streamingMessageIndex = null;
        _streamingMessageAdded = false;
      });

      // Return response in the same format as non-streaming
      return {
        'text': cleanedText,
        'title': title,
        'images': images,
        'files': files,
      };

    } catch (e) {
      print('[ChatScreen] Streaming exception: $e');
      // Remove message on exception if it was added
      if (_streamingMessageAdded && _streamingMessageIndex != null && _streamingMessageIndex! < _messages.length) {
        setState(() {
          _messages.removeAt(_streamingMessageIndex!);
        });
      }
      setState(() {
        _streamingMessageIndex = null;
        _streamingMessageAdded = false;
        _isSending = false;
      });
      return null;
    }
  }

  Future<void> _sendMessage(String text, [List<XFile>? images, List<PlatformFile>? files]) async {
    if (text.trim().isEmpty && (images == null || images.isEmpty) && (files == null || files.isEmpty)) return;

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
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);

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
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode.abs()}';
    _currentRequestId = requestId;

    // Clear any existing message lists before starting a new conversation
    if (Provider.of<ConversationProvider>(context, listen: false).selectedConversation == null) {
      setState(() {
        _messages = [];
      });
    }

    // Ensure a conversation exists before saving a message
    final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
    bool isNewConversation = conversationProvider.selectedConversation == null;
    int? conversationId = isNewConversation ? null : conversationProvider.selectedConversation!.id;

    // Get the current settings and profile from the providers
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Get the latest profile name and characteristics
    final currentProfile = await _databaseService.getProfile(_currentProfileId!);
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
      imagePaths: images != null && images.isNotEmpty ? images.map((x) => x.path).toList() : null,
      conversationId: conversationId, // May be null for new conversations
      filePaths: files != null && files.isNotEmpty ? files.map((f) => f.path ?? f.name).toList() : null,
    );

    //// print('[ChatScreen] User message created with filePaths: ${userMessage.filePaths}');

    // Filter messages by conversation ID before building history
    final conversationMessages = conversationId == null
        ? _messages.where((msg) => msg.conversationId == null).toList() // For new conversations, only use messages without conversation ID
        : _messages.where((msg) => msg.conversationId == conversationId).toList(); // For existing conversations, only use messages from this conversation

    // Add the current user message to the filtered list if not already included
    // This ensures the current message is part of the history even before it's added to _messages
    if (!conversationMessages.any((msg) => msg.isUserMessage && msg.message == userMessage.message && msg.timestamp == userMessage.timestamp)) {
      conversationMessages.add(userMessage);
    }

    // Sort messages by timestamp to ensure proper order
    conversationMessages.sort((a, b) => DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

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
      final personalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
      await personalityProvider.loadPersonalityForProfile(_currentProfileId!);
      aiPersonality = personalityProvider.getPersonalityForProfile(_currentProfileId!);
      if (aiPersonality != null && aiPersonality.aiName.isNotEmpty) {
        aiName = aiPersonality.aiName;
      }
    }

    // Set loading state first
    final isDeepResearchMode = _forceDeepResearch && subscriptionService.isPremium;
    setState(() {
      _isSending = true;
      _textController.clear();
      _messageCountSinceLastAnalysis++;
      _isPdfWorkflowActive = false; // Reset PDF workflow flag when sending message
    });
    _startLoadingMessageRotation(aiName, isDeepResearch: isDeepResearchMode);

    // Add message to UI state AFTER building the history, but check for duplicates
    setState(() {
      // Check if this exact message already exists to prevent duplicates
      bool messageExists = _messages.any((existing) => existing.message == userMessage.message && existing.timestamp == userMessage.timestamp && existing.isUserMessage == userMessage.isUserMessage);

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
          int index = _messages.indexWhere((msg) => msg.isUserMessage && msg.message == text && msg.timestamp == userMessage.timestamp);
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
      String? placesContext = _getRecentPlacesContext(text, conversationMessages);

      // If user is asking for analysis but no places found, add a specific instruction
      String finalMessage = text;
      if (placesContext != null) {
        finalMessage = '$placesContext\n\nUser question: $text';
      } else {
        // Check if user is asking for place analysis without having place data
        final lowerText = text.toLowerCase();
        final isPlaceAnalysisRequest = (lowerText.contains('suggest') || lowerText.contains('recommend') || lowerText.contains('best') || lowerText.contains('top')) && (lowerText.contains('place') || lowerText.contains('restaurant') || lowerText.contains('location'));

        if (isPlaceAnalysisRequest) {
          finalMessage =
              '$text\n\nIMPORTANT: The user is asking for place recommendations, but I don\'t have any recent place search results in our conversation. I should explain that I need them to search for places first before I can make recommendations, rather than making up place information.';
        }
      }

      // Determine if we should use deep research mode
      final isDeepResearchMode = _forceDeepResearch && subscriptionService.isPremium;
      if (isDeepResearchMode) {
        // print('[ChatScreen] Deep Research Mode ENABLED - Using reasoning model');
      }

      // Check if streaming is enabled
      // Disable streaming for deep research mode (reasoning takes too long to stream)
      final useStreaming = settings.useStreaming && !isDeepResearchMode;

      Map<String, dynamic>? response;

      if (useStreaming) {
        // STREAMING MODE: Show response as it arrives
        response = await _handleStreamingResponse(
          message: finalMessage,
          history: history,
          userName: currentProfileName,
          userCharacteristics: userCharacteristics,
          attachments: images,
          generateTitle: isNewConversation,
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
        // NON-STREAMING MODE: Wait for complete response
        response = await _openAIService.generateChatResponse(
          message: finalMessage,
          history: history,
          userName: currentProfileName,
          userCharacteristics: userCharacteristics,
          attachments: images != null && images.isNotEmpty ? images : null,
          generateTitle: isNewConversation,
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
            final settings = Provider.of<SettingsProvider>(context, listen: false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Document analysis used. You have $remaining uses remaining.",
                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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
        
        // Strip any title JSON that may have leaked into the response text (anywhere in text)
        aiText = aiText.replaceAll(RegExp(r'\s*\{"title"\s*:\s*"[^"]*"\}\s*'), '').trim();

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

        // If this is a new conversation, create it with the AI-generated title
        if (isNewConversation) {
          String? conversationTitle = response['title'] as String?;
          if (conversationTitle != null && conversationTitle.isNotEmpty) {
            await conversationProvider.createConversation(conversationTitle, _currentProfileId);
          } else {
            // Fallback to local title generation if AI didn't provide one
            String generatedTitle = MessageService.generateConversationTitle(text);
            await conversationProvider.createConversation(generatedTitle, _currentProfileId);
          }

          // Now we have a conversation ID
          conversationId = conversationProvider.selectedConversation!.id;

          // Update _lastLoadedConversationId immediately to prevent reload duplication
          _lastLoadedConversationId = conversationId;

          // CRITICAL: Set a flag to prevent _onConversationChanged from reloading messages
          // This prevents duplicate AI responses when the conversation is created
          _isCreatingNewConversation = true;

          // Update all messages in our state and database with this conversation ID
          if (userMessageId != null) {
            try {
              // Find our message in the state
              int messageIndex = -1;
              for (int i = 0; i < _messages.length; i++) {
                if (_messages[i].id == userMessageId) {
                  messageIndex = i;
                  break;
                }
              }

              if (messageIndex != -1) {
                // Create a new message with the updated conversation ID
                final updatedUserMessage = ChatMessage(
                  id: userMessageId,
                  message: _messages[messageIndex].message,
                  isUserMessage: _messages[messageIndex].isUserMessage,
                  timestamp: _messages[messageIndex].timestamp,
                  profileId: _messages[messageIndex].profileId,
                  imagePaths: _messages[messageIndex].imagePaths,
                  conversationId: conversationId,
                  filePaths: _messages[messageIndex].filePaths,
                );

                // Update in the database
                await _databaseService.updateChatMessage(updatedUserMessage);

                // Update in state
                setState(() {
                  _messages[messageIndex] = updatedUserMessage;
                });
              } else {}
            } catch (e) {
              //debug
            }
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
          final existingConversationMessages = currentMessages.where((m) => m.conversationId == conversationId).toList();

          // Check if this exact AI message already exists in the database
          // IMPORTANT: Also check file paths to avoid treating messages with different files as duplicates
          final serializedGeneratedFiles = generatedFiles != null && generatedFiles.isNotEmpty ? jsonEncode(generatedFiles) : null;
          final serializedGeneratedImages = generatedImages != null && generatedImages.isNotEmpty ? jsonEncode(generatedImages) : null;
          final aiMessageExists = existingConversationMessages.any((existing) =>
              !existing.isUserMessage && // Only check AI messages
                  existing.message == aiText && // Same content
                  existing.conversationId == conversationId && // Same conversation
                  // Also compare file paths
                  (((existing.filePaths == null || existing.filePaths!.isEmpty) && (generatedFiles == null || generatedFiles.isEmpty)) ||
                   (existing.filePaths != null && generatedFiles != null && jsonEncode(existing.filePaths) == serializedGeneratedFiles)) &&
                  // Also compare image paths
                  (((existing.imagePaths == null || existing.imagePaths!.isEmpty) && (generatedImages == null || generatedImages.isEmpty)) ||
                   (existing.imagePaths != null && generatedImages != null && jsonEncode(existing.imagePaths) == serializedGeneratedImages)));

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
            // Debug: Log before adding messages to state
            //// print('[ChatScreen] About to add ${completedMessages.length} messages to _messages state');
            for (int i = 0; i < completedMessages.length; i++) {
              final msg = completedMessages[i];
              //// print('[ChatScreen] - message[$i] filePaths: ${msg.filePaths}');
              //// print('[ChatScreen] - message[$i] id: ${msg.id}');
            }

            // Add all messages to state with their database IDs
            _messages.addAll(completedMessages);

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
            (msg) => !msg.isUserMessage && msg.message == aiText && msg.conversationId == conversationId,
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

            // Use subscription-aware audio generation
            if (subscriptionService.isPremium) {
              // Check if premium user can use ElevenLabs
              final canUseElevenLabs = await subscriptionService.tryUseElevenLabsTTS();
              if (canUseElevenLabs) {
                // Premium users get ElevenLabs TTS
                audioPath = await _generateAndPlayAudioForMessage(aiText, settings.selectedVoiceId);
              } else {
                // Fallback to device TTS even for premium if ElevenLabs fails
                audioPath = await _generateAndPlayDeviceTTS(aiText);
              }
            } else {
              // Free users get device TTS
              if (subscriptionService.canUseDeviceTTS()) {
                audioPath = await _generateAndPlayDeviceTTS(aiText);
              }
            }

            if (audioPath != null) {
              final updatedAiMessage = ChatMessage(
                id: matchingMessage.id,
                message: matchingMessage.message,
                isUserMessage: false,
                timestamp: matchingMessage.timestamp,
                profileId: _currentProfileId,
                imagePaths: null,
                conversationId: conversationId,
                audioPath: audioPath,
              );
              await _databaseService.updateChatMessage(updatedAiMessage);
            }
          } else {}
        }
        // Analyze user characteristics if we've reached the threshold
        if (_messageCountSinceLastAnalysis >= _analysisThreshold && _currentProfileId != null) {
          _analyzeUserCharacteristics(history);
          _messageCountSinceLastAnalysis = 0;
        }
      } else {
        // Cancel timers on null response
        _aiLoadingTimer?.cancel();
        _aiTimeoutTimer?.cancel();

        // Only access context if widget is still mounted
        if (mounted) {
          _showErrorSnackBar(AppLocalizations.of(context)!.sorryCouldNotRespond);
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
    final lowerText = text.toLowerCase();

    // Skip location detection if this is clearly an analysis request about existing results
    final isAnalysisRequest = lowerText.contains('suggest') && (lowerText.contains('from the list') || lowerText.contains('top ') || lowerText.contains('best')) ||
        lowerText.contains('recommend') && (lowerText.contains('from the list') || lowerText.contains('top ') || lowerText.contains('best')) ||
        lowerText.contains('explain why') ||
        lowerText.contains('analyze') ||
        lowerText.contains('compare') ||
        lowerText.contains('choose') ||
        lowerText.contains('pick');

    if (isAnalysisRequest) {
      // print('[DEBUG] Skipping location detection - this is an analysis request: $text');
      return null;
    }

    // Food-related query patterns
    final foodPatterns = [
      // Chinese patterns
      RegExp(r'附近.*?(餐厅|饭店|美食|吃饭|吃的|火锅|烧烤|日料|韩料|川菜|粤菜|湘菜|东北菜)', caseSensitive: false),
      RegExp(r'(哪里|哪儿).*?(好吃|美食|餐厅|饭店)', caseSensitive: false),
      RegExp(r'推荐.*?(餐厅|美食|吃饭|饭店)', caseSensitive: false),

      // English patterns
      RegExp(r'(restaurants?|food|eating|dining).*?(near|nearby|around|close)', caseSensitive: false),
      RegExp(r'(near|nearby|around|close).*?(restaurants?|food|eating|dining)', caseSensitive: false),
      RegExp(r'(recommend|suggest|find).*?(restaurants?|food|places to eat)', caseSensitive: false),
      RegExp(r'(where.*?(eat|dine|food)|best.*?(restaurants?|food))', caseSensitive: false),
      RegExp(r'(good|best).*(pizza|burger|sushi|chinese|italian|mexican|thai|indian)', caseSensitive: false),
      // Location-based patterns with "in"
      RegExp(r'(restaurants?|food|places|dining).*?(in|at)\s+\w+', caseSensitive: false), // "restaurants in area"
      RegExp(r'(any|find|looking for).*(restaurants?|food|places to eat)', caseSensitive: false), // "any restaurants"
      RegExp(r'(pizza|burger|sushi|chinese|italian|mexican|thai|indian|coffee).*?(in|at)\s+\w+', caseSensitive: false), // "pizza in 77479"
    ];

    // Bar/nightlife related queries
    final barPatterns = [
      // Chinese
      RegExp(r'附近.*?(酒吧|夜店|清吧|夜生活|喝酒)', caseSensitive: false),
      RegExp(r'(哪里|哪儿).*?(喝酒|酒吧)', caseSensitive: false),

      // English
      RegExp(r'(bars?|nightlife|drinking|cocktails?).*?(near|nearby|around)', caseSensitive: false),
      RegExp(r'(near|nearby|around).*?(bars?|nightlife|drinking)', caseSensitive: false),
      RegExp(r'(find|recommend).*(bars?|nightlife|drinks)', caseSensitive: false),
    ];

    // Coffee shop related
    final cafePatterns = [
      RegExp(r'(coffee|cafe|咖啡).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(coffee|cafe|咖啡)', caseSensitive: false),
      RegExp(r'(coffee|cafe|咖啡).*?(in|at)\s+\w+', caseSensitive: false),
      RegExp(r'(any|find|looking for).*?(coffee|cafe)', caseSensitive: false),
    ];

    // Shopping related
    final shoppingPatterns = [
      RegExp(r'(shopping|mall|store|商场|购物).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(shopping|mall|store|商场|购物)', caseSensitive: false),
    ];

    // Dessert/ice cream related
    final dessertPatterns = [
      RegExp(r'(ice cream|gelato|dessert|sweet|bakery|cake|donut|甜品|冰淇淋|蛋糕|面包房).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(ice cream|gelato|dessert|sweet|bakery|cake|donut|甜品|冰淇淋|蛋糕)', caseSensitive: false),
      RegExp(r'(find|looking for|any).*?(ice cream|gelato|dessert|sweet|bakery)', caseSensitive: false),
    ];

    // Parking related
    final parkingPatterns = [
      RegExp(r'(parking|garage|park.*car|停车|停车场).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(parking|garage|停车)', caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(parking|garage|place to park)', caseSensitive: false),
    ];

    // Restroom related
    final restroomPatterns = [
      RegExp(r'(restroom|bathroom|toilet|washroom|wc|洗手间|厕所|卫生间).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(restroom|bathroom|toilet|washroom|洗手间|厕所)', caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(restroom|bathroom|toilet|washroom)', caseSensitive: false),
    ];

    // Beauty/Spa related
    final beautyPatterns = [
      RegExp(r'(beauty|salon|spa|nail|hair|massage|美容|美发|按摩|指甲).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(beauty|salon|spa|nail|hair|massage|美容|美发)', caseSensitive: false),
      RegExp(r'(find|looking for).*?(beauty|salon|spa|nail salon|hair salon)', caseSensitive: false),
    ];

    // Pharmacy related
    final pharmacyPatterns = [
      RegExp(r'(pharmacy|drugstore|medicine|药店|药房|医药).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(pharmacy|drugstore|medicine|药店|药房)', caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(pharmacy|drugstore|medicine)', caseSensitive: false),
    ];

    // ATM related
    final atmPatterns = [
      RegExp(r'(atm|cash|withdraw|money|取款机|提款机|现金).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(atm|cash|withdraw|取款机)', caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(atm|cash machine|money)', caseSensitive: false),
    ];

    // Laundry related
    final laundryPatterns = [
      RegExp(r'(laundry|laundromat|dry.*clean|洗衣|干洗).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(laundry|laundromat|dry.*clean|洗衣)', caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(laundry|laundromat|dry cleaning)', caseSensitive: false),
    ];

    // Attractions related
    final attractionPatterns = [
      RegExp(r'(attractions?|tourist|sightseeing|景点|旅游|游玩).*?(near|nearby|around|附近)', caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(attractions?|tourist|sightseeing|景点|旅游)', caseSensitive: false),
    ];

    // General location query patterns with zip codes, area codes etc
    final generalLocationPatterns = [
      RegExp(r'(any|find|looking for|show me|list).*?(shops?|stores?|places?).*?(in|at)\s+\d{5}', caseSensitive: false), // "any shops in 77479"
      RegExp(r'(any|find|looking for|show me|list).*?(in|at)\s+\w+\s+(area|city|town|neighborhood)', caseSensitive: false), // "any coffee in area"
      RegExp(r'\b\d{5}\b.*?(area|region|zip|code)', caseSensitive: false), // "77479 area"
    ];

    // Check various patterns and return corresponding query info
    for (final pattern in foodPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'restaurant',
          query: _extractFoodQuery(text),
          originalText: text,
        );
      }
    }

    for (final pattern in barPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'night_club',
          query: _extractBarQuery(text),
          originalText: text,
        );
      }
    }

    for (final pattern in cafePatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'cafe',
          query: 'coffee shops',
          originalText: text,
        );
      }
    }

    for (final pattern in shoppingPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'shopping_mall',
          query: 'shopping',
          originalText: text,
        );
      }
    }

    for (final pattern in attractionPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'tourist_attraction',
          query: 'attractions',
          originalText: text,
        );
      }
    }

    // Check dessert/ice cream patterns
    for (final pattern in dessertPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'convenience_store',
          query: 'ice cream desserts',
          originalText: text,
        );
      }
    }

    // Check parking patterns
    for (final pattern in parkingPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'parking',
          query: 'parking garage',
          originalText: text,
        );
      }
    }

    // Check restroom patterns
    for (final pattern in restroomPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'restroom',
          query: 'public restroom',
          originalText: text,
        );
      }
    }

    // Check beauty/spa patterns
    for (final pattern in beautyPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'beauty_salon',
          query: 'beauty spa salon',
          originalText: text,
        );
      }
    }

    // Check pharmacy patterns
    for (final pattern in pharmacyPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'pharmacy',
          query: 'pharmacy drugstore',
          originalText: text,
        );
      }
    }

    // Check ATM patterns
    for (final pattern in atmPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'atm',
          query: 'atm cash machine',
          originalText: text,
        );
      }
    }

    // Check laundry patterns
    for (final pattern in laundryPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'laundry',
          query: 'laundromat dry cleaning',
          originalText: text,
        );
      }
    }

    // Check general location query patterns
    for (final pattern in generalLocationPatterns) {
      if (pattern.hasMatch(lowerText)) {
        // Infer category based on message content
        String category = 'restaurant'; // default
        String query = text;

        if (lowerText.contains('coffee') || lowerText.contains('cafe')) {
          category = 'cafe';
          query = 'coffee shops';
        } else if (lowerText.contains('shop') || lowerText.contains('store')) {
          category = 'shopping_mall';
          query = 'shops';
        } else if (lowerText.contains('restaurant') || lowerText.contains('food')) {
          category = 'restaurant';
          query = 'restaurants';
        } else if (lowerText.contains('bar') || lowerText.contains('drink')) {
          category = 'night_club';
          query = 'bars';
        } else if (lowerText.contains('ice cream') || lowerText.contains('dessert')) {
          category = 'convenience_store';
          query = 'ice cream desserts';
        } else if (lowerText.contains('parking') || lowerText.contains('garage')) {
          category = 'parking';
          query = 'parking garage';
        } else if (lowerText.contains('restroom') || lowerText.contains('bathroom')) {
          category = 'restroom';
          query = 'public restroom';
        }

        return LocationQueryInfo(
          category: category,
          query: query,
          originalText: text,
        );
      }
    }

    return null; // No location query detected
  }

  String _extractFoodQuery(String text) {
    final lowerText = text.toLowerCase();

    // Try to extract specific food types
    final foodKeywords = {
      'pizza': 'pizza places',
      'burger': 'burger joints',
      'sushi': 'sushi restaurants',
      'chinese': 'chinese restaurants',
      'italian': 'italian restaurants',
      'mexican': 'mexican restaurants',
      'thai': 'thai restaurants',
      'indian': 'indian restaurants',
      'korean': 'korean restaurants',
      'japanese': 'japanese restaurants',
      'vietnamese': 'vietnamese restaurants',
      'seafood': 'seafood restaurants',
      'steakhouse': 'steakhouses',
      'bbq': 'bbq restaurants',
      'breakfast': 'breakfast places',
      'lunch': 'lunch spots',
      'dinner': 'dinner restaurants',

      // Chinese food types
      '火锅': 'hot pot restaurants',
      '烧烤': 'bbq restaurants',
      '日料': 'japanese restaurants',
      '韩料': 'korean restaurants',
      '川菜': 'sichuan restaurants',
      '粤菜': 'cantonese restaurants',
      '湘菜': 'hunan restaurants',
      '东北菜': 'northeastern chinese restaurants',
    };

    for (final keyword in foodKeywords.keys) {
      if (lowerText.contains(keyword)) {
        return foodKeywords[keyword]!;
      }
    }

    return 'restaurants'; // default return
  }

  String _extractBarQuery(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('cocktail')) return 'cocktail bars';
    if (lowerText.contains('wine')) return 'wine bars';
    if (lowerText.contains('beer')) return 'beer bars';
    if (lowerText.contains('rooftop')) return 'rooftop bars';
    if (lowerText.contains('sports')) return 'sports bars';

    return 'bars'; // default return
  }

  // Handle location query method
  Future<void> _handleLocationQuery(String originalText, LocationQueryInfo queryInfo) async {
    try {
      //// print('[LocationQuery] Auto-detected location query: ${queryInfo.query} (category: ${queryInfo.category})');

      // Create user message first
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId = conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String searchTitle = "Places Explorer: ${queryInfo.query}";

        await conversationProvider.createConversation(searchTitle, _currentProfileId);
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
          message: "🗺️ **Found ${places.length} great ${queryInfo.query} near you!**\n\nTap below to explore these locations with photos, ratings, and directions.",
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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
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

            String dialogTitle = isFreeUserWithLimit && remaining <= 0 ? 'Places Explorer Limit Reached' : 'Smart Location Detection';

            String mainMessage = isFreeUserWithLimit && remaining <= 0 ? 'You\'ve used all ${subscriptionService.limits.placesExplorerWeekly} weekly place searches. Your limit will reset next week!' : 'I detected you\'re looking for local recommendations!';

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
                        fontSize: settings.getScaledFontSize(isSmallScreen ? 16 : 18),
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
                        fontSize: settings.getScaledFontSize(isSmallScreen ? 14 : 16),
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
                    ...['• Unlimited places exploration', '• Advanced location search', '• Real-time business info', '• Maps integration with directions', '• All premium features unlocked'].map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isSmallScreen ? 12 : 14),
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

      if (_flutterTts != null) {
        // Stop any ongoing TTS
        await _flutterTts!.stop();

        // Try to set the selected voice, but don't fail if it doesn't work
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final selectedVoice = settings.selectedSystemTTSVoice;
        if (selectedVoice != null && _isValidVoiceMap(selectedVoice)) {
          try {
            // Add a small delay to ensure TTS is ready
            await Future.delayed(Duration(milliseconds: 100));
            await _flutterTts!.setVoice(selectedVoice);
            //// print('[DeviceTTS] Successfully set voice: ${selectedVoice['name']}');
          } catch (e) {
            //// print('[DeviceTTS] Failed to set voice, using default: $e');
            // Continue with default voice instead of failing
          }
        }

        //// print('[DeviceTTS] Playing device TTS for message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

        // Speak the message using device TTS
        final result = await _flutterTts!.speak(message);

        if (result == 1) {
          //// print('[DeviceTTS] Device TTS started successfully');
        } else {
          //// print('[DeviceTTS] Failed to start device TTS');
        }
      }

      return "device_tts"; // Return a special identifier for device TTS
    } catch (e) {
      //// print('[DeviceTTS] Error with device TTS: $e');
      return null;
    }
  }

  // Add device TTS control methods
  Future<void> _pauseDeviceTTS() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
      setState(() {
        _isDeviceTTSPlaying = false;
      });
    }
  }

  Future<void> _stopDeviceTTS() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      setState(() {
        _isDeviceTTSPlaying = false;
        _currentPlayingMessageId = null;
      });
    }
  }

  Future<String?> _generateAndPlayAudioForMessage(String message, String voiceId) async {
    try {
      // Create a unique identifier for this message
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final messageHash = message.hashCode.abs();
      final audioId = messageHash + timestamp;

      // Create voice settings with faster speed (1.0)
      final voiceSettings = {
        'stability': 0.35,
        'similarity_boost': 0.95,
        'style': 0.6,
        'use_speaker_boost': true,
        'speed': 1.0, // Set faster speech speed
      };

      final audioPath = await _elevenLabsService.generateAudioWithSettings(message, audioId, voiceId: voiceId, voiceSettings: voiceSettings);

      if (audioPath != null) {
        _playAudio(audioPath);
        return audioPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {}
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
    await AudioService.playAudio(audioPath, useSpeakerOutput: settings.useSpeakerOutput);

    // Listen to state changes
    AudioService.isPlayingAudio.addListener(() {
      if (mounted) {
        setState(() {
          _isPlayingAudio = AudioService.isPlayingAudio.value;
          // Clear current playing message when audio stops
          if (!_isPlayingAudio) {
            _currentPlayingMessageId = null;
          }
        });
      }
    });
  }

  Future<void> _stopAudio() async {
    await AudioService.stopAudio();
    setState(() {
      _currentPlayingMessageId = null;
    });
  }

  // Update the speaking method to handle both ElevenLabs and device TTS
  Future<void> _speakMessage(ChatMessage message) async {
    try {
      // If this specific message is currently playing, stop it
      if (_currentPlayingMessageId == message.id && ((message.audioPath == "device_tts" && _isDeviceTTSPlaying) || (message.audioPath != "device_tts" && _isPlayingAudio))) {
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
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      // Check if message already has audio (but not device TTS identifier)
      if (message.audioPath != null && message.audioPath != "device_tts" && File(message.audioPath!).existsSync()) {
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
        final canUseElevenLabs = await subscriptionService.tryUseElevenLabsTTS();
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

      // Use subscription-aware audio generation
      if (subscriptionService.isPremium) {
        // Check if premium user can use ElevenLabs
        final canUseElevenLabs = await subscriptionService.tryUseElevenLabsTTS();
        if (canUseElevenLabs) {
          // Premium users get ElevenLabs TTS
          final settings = Provider.of<SettingsProvider>(context, listen: false);
          audioPath = await _generateAndPlayAudioForMessage(message.message, settings.selectedVoiceId);
        } else {
          // Fallback to device TTS even for premium if ElevenLabs fails
          audioPath = await _generateAndPlayDeviceTTS(message.message);
        }
      } else {
        // Free users get device TTS
        if (subscriptionService.canUseDeviceTTS()) {
          audioPath = await _generateAndPlayDeviceTTS(message.message);
        }
      }

      if (audioPath != null) {
        // Update message with audio path
        final updatedMessage = ChatMessage(
          id: message.id,
          message: message.message,
          isUserMessage: message.isUserMessage,
          timestamp: message.timestamp,
          profileId: message.profileId,
          conversationId: message.conversationId,
          audioPath: audioPath,
        );
        await _databaseService.updateChatMessage(updatedMessage);

        // Update local state
        final messageIndex = _messages.indexWhere((m) => m.id == message.id);
        if (messageIndex != -1) {
          setState(() {
            _messages[messageIndex] = updatedMessage;
          });
        }
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
            final selectedConversation = conversationProvider.selectedConversation;

            // Filter messages for the selected conversation (important for UI consistency)
            List<ChatMessage> displayMessages = [];
            if (selectedConversation == null) {
              // No conversation selected yet - only show messages being actively sent
              // This avoids showing historical messages without conversation IDs
              if (_isSending) {
                displayMessages = _messages.where((msg) => msg.conversationId == null && DateTime.parse(msg.timestamp).isAfter(DateTime.now().subtract(Duration(minutes: 5)))).toList();
              } else {
                // No active sending - don't show any messages
                displayMessages = [];
              }
            } else {
              // For existing conversations, show all messages in this conversation
              // Plus any pending messages that don't have a conversation ID yet (if sending)
              displayMessages = _messages
                  .where((msg) =>
                      // Messages that belong to this conversation
                      msg.conversationId == selectedConversation.id ||
                      // OR messages without a conversation ID if we're in the process of sending
                      (msg.conversationId == null && _isSending))
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
                final timestampHash = DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/ 1000; // Round to nearest second
                key = 'content_${contentHash}_${msg.isUserMessage}_${timestampHash}';
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
                        title: showcaseData?.title ?? '📋 Conversations & Settings',
                        description: showcaseData?.description ?? 'Tap here to open the side panel where you can view all your conversations, search through them, and access your settings.',
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
                            _isToolsMode ? Icons.grid_view_rounded : Icons.chat_bubble_outline,
                            size: settings.getScaledFontSize(24),
                            color: _isToolsMode ? const Color(0xFF0078D4) : const Color(0xFF0078D4),
                          ),
                          onPressed: () {
                            setState(() {
                              _isToolsMode = !_isToolsMode;
                            });
                            _saveDisplayModePreference(_isToolsMode);
                          },
                          tooltip: _isToolsMode ? 'Switch to Chat Mode' : 'Switch to Tools Mode',
                        );

                        // Wrap with Showcase for feature highlighting
                        final showcaseData = _getShowcaseFeature('tools_mode');
                        return Showcase(
                          key: _toolsModeKey,
                          title: showcaseData?.title ?? '🔧 Tools Mode',
                          description: showcaseData?.description ?? 'Switch between Chat mode for conversations and Tools mode for quick actions like image generation, PDF creation, and more!',
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
                            final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
                            conversationProvider.clearSelection();
                          },
                          tooltip: AppLocalizations.of(context)!.newConversation,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E6CFF)),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    // When no conversation is selected or displaying messages, show welcome message
                                    selectedConversation == null && displayMessages.isEmpty
                                        ? _buildWelcomeScreen()
                                        : displayMessages.isEmpty
                                            ? Center(
                                                child: Consumer<SettingsProvider>(
                                                  builder: (context, settings, child) {
                                                    return Text(
                                                      AppLocalizations.of(context)!.noConversationsYet,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: settings.getScaledFontSize(16),
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
                                                  _isVoiceInputMode ? 100 : 80, // More padding for voice mode
                                                ),
                                                itemCount: displayMessages.length,
                                                reverse: false, // Keep chronological order
                                                physics: const AlwaysScrollableScrollPhysics(), // Make sure scrolling is always enabled
                                                itemBuilder: (context, index) {
                                                  final message = displayMessages[index];
                                                  // Safer message key generation to avoid null check issues
                                                  final messageIndex = _messages.indexOf(message);
                                                  final messageKey = message.id ?? (messageIndex >= 0 ? messageIndex : message.hashCode);

                                                  // Check if this is a places widget message (has locationResults but no message text)
                                                  if (message.locationResults != null && message.locationResults!.isNotEmpty && message.message.isEmpty) {
                                                    // Render places widget at full width as a card with consistent styling
                                                    return Container(
                                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                      child: PlaceResultWidget(
                                                        places: message.locationResults!,
                                                        searchQuery: _extractSearchQueryFromPreviousMessage(index),
                                                      ),
                                                    );
                                                  }

                                                  // Regular message rendering
                                                  return ChatMessageWidget(
                                                    key: ValueKey('${messageKey}'),
                                                    message: message,
                                                    messageKey: messageKey,
                                                    selectionMode: _selectionMode,
                                                    selectedMessages: _selectedMessages,
                                                    onToggleSelection: (int key) {
                                                      setState(() {
                                                        if (_selectedMessages.contains(key)) {
                                                          _selectedMessages.remove(key);
                                                        } else {
                                                          _selectedMessages.add(key);
                                                        }
                                                      });
                                                    },
                                                    onTranslate: (ChatMessage msg) => _translateMessage(context, msg.message, message: msg),
                                                    onQuickTranslate: (ChatMessage msg, String targetLanguageCode, String targetLanguageName) => _performTranslation(context, msg.message, targetLanguageCode, targetLanguageName, message: msg),
                                                    onSelectTranslationLanguage: (ChatMessage msg) => _showTranslationLanguageSelector(context, msg.message, message: msg),
                                                    translationPreferenceVersion: _translationPreferenceVersion,
                                                    onDelete: _deleteMessage,
                                                    onShare: message.isUserMessage ? null : _shareMessage,
                                                    translatedMessages: _translatedMessages,
                                                    isPlayingAudio: _currentPlayingMessageId == message.id && (message.audioPath == "device_tts" ? _isDeviceTTSPlaying : _isPlayingAudio),
                                                    onPlayAudio: _playAudio,
                                                    onSpeakWithHighlight: message.isUserMessage ? null : _speakMessage,
                                                    onReviewRequested: () async {
                                                      // Add thank you message when user leaves review
                                                      final thankYouMessage = ChatIntegrationHelper.createThankYouMessage(
                                                        profileId: _currentProfileId,
                                                        conversationId: Provider.of<ConversationProvider>(context, listen: false).selectedConversation?.id,
                                                      );

                                                      // Save to database
                                                      final messageId = await _databaseService.insertChatMessage(thankYouMessage);
                                                      final completeThankYou = ChatMessage(
                                                        id: messageId,
                                                        message: thankYouMessage.message,
                                                        isUserMessage: thankYouMessage.isUserMessage,
                                                        timestamp: thankYouMessage.timestamp,
                                                        profileId: thankYouMessage.profileId,
                                                        conversationId: thankYouMessage.conversationId,
                                                        messageType: thankYouMessage.messageType,
                                                      );

                                                      setState(() {
                                                        _messages.add(completeThankYou);
                                                      });

                                                      // Scroll to bottom to show thank you message
                                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        _scrollToBottom(animated: true);
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
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E6CFF)),
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E6CFF)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _aiLoadingMessage,
                                      style: TextStyle(
                                        color: Color(0xFF8E6CFF),
                                        fontStyle: FontStyle.italic,
                                        fontSize: settings.getScaledFontSize(14),
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
                          onRemovePendingFile: _removePendingFile, // Add file removal callback
                          onConvertToPdf: _onConvertToPdfPressed,
                          onCancelPdfAutoConversion: _cancelPdfAutoConversion,
                          onShowAttachmentOptions: (bool forPdf) => _showAttachmentOptions(forPdf: forPdf),
                          onShowFileUploadOptions: _showFileUploadOptions, // Add file upload callback
                          onLocationDiscovery: () {
                            // Show location discovery dialog with usage limits
                            final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
                            if (subscriptionService.isPremium || subscriptionService.canUsePlacesExplorer) {
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
                            final imagesToSend = List<XFile>.from(_pendingImages);
                            final filesToSend = List<PlatformFile>.from(_pendingFiles);
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
                            _sendMessage(text, images, files); // Pass files to send message
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
        limit: 100, // Increase limit to make sure we get all messages for this conversation
        offset: 0,
      );

      // Then filter for this conversation
      final conversationMessages = allMessages.where((m) => m.conversationId == conversationId).toList();

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
                (DateTime.parse(existing.timestamp).difference(DateTime.parse(msg.timestamp)).abs().inSeconds < 5));

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
          final timestampHash = DateTime.parse(msg.timestamp).millisecondsSinceEpoch ~/ 1000; // Round to nearest second
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
      await _databaseService.deleteChatMessagesBefore(DateTime.parse(message.timestamp).add(const Duration(milliseconds: 1)), profileId: message.profileId);
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

  Future<void> _translateMessage(BuildContext context, String text, {ChatMessage? message}) async {
    // Show language selection popup instead of directly translating
    await _showTranslationLanguageSelector(context, text, message: message);
  }

  Future<void> _showTranslationLanguageSelector(BuildContext context, String text, {ChatMessage? message}) async {
    // Get device locale and detected language
    final deviceLocale = Localizations.localeOf(context);
    final deviceLanguage = deviceLocale.languageCode;
    final detectedLanguage = _detectLanguage(text);
    final detectedLanguageCode = _getLanguageCode(detectedLanguage);

    // Get user's translation history for smart suggestions from profile
    final userPreferences = ProfileTranslationService.getTranslationHistory(context);

    // For first-time users (no translation history), auto-show full language selector
    if (userPreferences.isEmpty) {
      _showFullLanguageSelector(context, text, detectedLanguage, message: message);
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
              _performTranslation(context, text, targetLanguageCode, targetLanguageName, message: message);
            },
            onMoreLanguages: () {
              _showFullLanguageSelector(context, text, detectedLanguage, message: message);
            },
          );
        },
      );
    }
  }

  Future<void> _showFullLanguageSelector(BuildContext context, String text, String detectedLanguage, {ChatMessage? message}) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FullLanguageSelectionDialog(
          sourceText: text,
          detectedLanguage: detectedLanguage,
          onLanguageSelected: (targetLanguageCode, targetLanguageName) {
            _performTranslation(context, text, targetLanguageCode, targetLanguageName, message: message);
          },
        );
      },
    );
  }

  Future<void> _performTranslation(BuildContext context, String text, String targetLanguageCode, String targetLanguageName, {ChatMessage? message}) async {
    // Save user's choice for future suggestions in their profile
    await ProfileTranslationService.addTranslationChoice(context, targetLanguageCode);

    final detectedLanguage = _detectLanguage(text);
    final prompt = 'Translate the following ${detectedLanguage} message to ${targetLanguageName}. Only output the translation, no extra explanation or quotes. Message: "$text"';

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
      final translation = response != null && response['text'] != null && response['text'].toString().trim().isNotEmpty ? response['text'].toString().trim() : AppLocalizations.of(context)!.translationFailed;
      if (message != null) {
        // Safer message key generation to prevent null check issues
        final messageIndex = _messages.indexOf(message);
        final messageKey = message.id ?? (messageIndex >= 0 ? messageIndex : message.hashCode);
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
  Map<String, String> _getSmartTranslationInfo(BuildContext context, String text) {
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
    String sourceLanguageName = languageNames[detectedLanguageCode] ?? detectedLanguage;
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
    final spanishWords = ['el', 'la', 'de', 'que', 'y', 'es', 'en', 'un', 'con', 'no', 'se', 'te', 'lo', 'le', 'da', 'su', 'por', 'son', 'como', 'para', 'del', 'está', 'una', 'tiene', 'más', 'este', 'eso', 'todo', 'bien', 'sí', 'donde', 'qué', 'cómo', 'cuándo', 'quién'];
    final spanishChars = RegExp(r'[ñáéíóúü]');

    int wordMatches = spanishWords.where((word) => text.contains(' $word ') || text.startsWith('$word ') || text.endsWith(' $word')).length;
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

    int wordMatches = frenchWords.where((word) => text.contains(' $word ') || text.startsWith('$word ') || text.endsWith(' $word')).length;
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

    int wordMatches = germanWords.where((word) => text.contains(' $word ') || text.startsWith('$word ') || text.endsWith(' $word')).length;
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

    int wordMatches = italianWords.where((word) => text.contains(' $word ') || text.startsWith('$word ') || text.endsWith(' $word')).length;
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

    int wordMatches = portugueseWords.where((word) => text.contains(' $word ') || text.startsWith('$word ') || text.endsWith(' $word')).length;
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
                  color: _isRecording ? Colors.red : const Color(0xFF0078D4).withOpacity(0.3),
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
                              borderRadius: BorderRadius.circular(scaledBorderRadius),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5 * (1 - _recordingPulseController.value)),
                                width: 3.0 * (1 - _recordingPulseController.value),
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
                          padding: EdgeInsets.symmetric(horizontal: scaledSpacing, vertical: settings.getScaledFontSize(2)),
                          decoration: BoxDecoration(
                            color: _isCancelingRecording ? Colors.red : Colors.grey.shade700,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(scaledSpacing),
                              bottomRight: Radius.circular(scaledSpacing),
                            ),
                          ),
                          child: Text(
                            _isCancelingRecording ? AppLocalizations.of(context)!.releaseToCancel : AppLocalizations.of(context)!.swipeUpToCancel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(10),
                              fontWeight: _isCancelingRecording ? FontWeight.bold : FontWeight.normal,
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
                                        ? AppLocalizations.of(context)!.cancelRecording
                                        : AppLocalizations.of(context)!.listening
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
                          padding: EdgeInsets.symmetric(horizontal: scaledSpacing, vertical: settings.getScaledFontSize(2)),
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
                                    color: Colors.red.withOpacity(0.7 + 0.3 * _micAnimationController.value),
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
                      style: TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsPressHoldDesc,
                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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
                      style: TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSpeakClearlyDesc,
                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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
                      style: TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSwipeUpDesc,
                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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
                      style: TextStyle(fontSize: settings.getScaledFontSize(16)),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.voiceInputTipsSwitchInputDesc,
                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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

  Future<void> _analyzeUserCharacteristics(List<Map<String, String>> history) async {
    if (_currentProfileId == null) return;

    try {
      final characteristics = await _openAIService.analyzeUserCharacteristics(
        history: history,
        userName: _currentProfileName ?? 'User',
      );

      if (characteristics.isNotEmpty) {
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.updateProfileCharacteristics(_currentProfileId!, characteristics);
      } else {}
    } catch (e) {
      //debug
    }
  }

  // Image picking methods replaced with service calls
  Future<void> _pickImages({bool forPdf = false}) async {
    _isSelectingForPdf = forPdf;
    final List<XFile> images = await ImageService.pickImages(forPdf: forPdf);
    if (images.isNotEmpty) {
      setState(() {
        _pendingImages.addAll(images);
        if (_isSelectingForPdf) {
          _isPdfWorkflowActive = true;
        }
      });

      if (_isSelectingForPdf) {
        _startPdfAutoConversionTimer();
      }
    }
    _isSelectingForPdf = false;
  }

  Future<void> _takePhoto({bool forPdf = false}) async {
    _isSelectingForPdf = forPdf;
    final XFile? photo = await ImageService.takePhoto(forPdf: forPdf);
    if (photo != null) {
      setState(() {
        _pendingImages.add(photo);
        if (_isSelectingForPdf) {
          _isPdfWorkflowActive = true;
        }
      });

      if (_isSelectingForPdf) {
        _startPdfAutoConversionTimer();
      }
    }
    _isSelectingForPdf = false;
  }

  // Remove image from pending list
  void _removePendingImage(int index) {
    setState(() {
      _pendingImages.removeAt(index);
    });

    // Cancel auto-conversion if no images left, or restart timer
    if (_pendingImages.isEmpty) {
      _cancelPdfAutoConversion();
      _isPdfWorkflowActive = false; // Reset PDF workflow flag
    } else {
      // Restart timer for remaining images only if in PDF workflow
      if (_isPdfWorkflowActive) {
        _startPdfAutoConversionTimer();
      }
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
          subtitle: 'Select a document file for AI analysis\n(PDF, Word, PowerPoint, Excel, etc.)',
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

      final pdf = pw.Document();
      for (final xfile in _pendingImages) {
        final imageBytes = await File(xfile.path).readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }
      final pdfBytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/howai_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Verify file was actually written and is accessible
      await Future.delayed(Duration(milliseconds: 100)); // Small delay to ensure file system sync
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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId = conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one for this PDF
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String pdfTitle = "PDF Document ${DateTime.now().toString().substring(0, 16)}";

        // Create a new conversation
        await conversationProvider.createConversation(pdfTitle, _currentProfileId);

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
      if (conversationProvider.selectedConversation?.id == messageConversationId) {
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
    if (!mounted) {
      return;
    }

    // Don't reload messages if we're currently sending a message
    // This prevents duplication when a new conversation is created during _sendMessage
    if (_isSending) {
      return;
    }

    // Don't reload messages if we're in the process of creating a new conversation
    // This prevents duplicate AI responses from appearing
    if (_isCreatingNewConversation) {
      return;
    }

    final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
    final selectedConversation = conversationProvider.selectedConversation;

    if (selectedConversation?.id != _lastLoadedConversationId) {
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
      debugPrint('[AIChatScreen] Sync completed, refreshing conversations and profile');
      
      // Reset the flag so we don't re-trigger
      authProvider.resetSyncCompletedFlag();
      
      // Force reload conversations from database (which now has synced data)
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      conversationProvider.loadConversations(profileId: _currentProfileId);
      
      // Reload profile to get updated name/avatar from cloud
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loadProfiles();
      
      debugPrint('[AIChatScreen] UI refresh triggered after sync');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInitLocalization) {
      _recordButtonText = AppLocalizations.of(context)?.holdToTalk ?? 'Hold to Talk';
      _aiLoadingMessage = AppLocalizations.of(context)?.processing ?? 'Processing...';
      _didInitLocalization = true;
    }

    // Safety check for AppLocalizations
    if (AppLocalizations.of(context) == null) {
      return;
    }
    // Existing didChangeDependencies logic...
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final currentProfileId = profileProvider.selectedProfileId;
    if (currentProfileId != null) {
      _currentProfileId = currentProfileId;
      _loadProfileDetails(currentProfileId);
    }
    if (Provider.of<ProfileProvider>(context).chatHistoryCleared) {
      setState(() {
        _messages = [];
      });
      Provider.of<ProfileProvider>(context, listen: false).resetChatHistoryClearedFlag();
    }

    // Load conversations for the current profile
    // This is safe because ConversationProvider exists at the app level
    final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
    conversationProvider.ensureConversationsLoaded(context, profileId: _currentProfileId);

    // Load messages for the selected conversation
    final selectedConversation = conversationProvider.selectedConversation;
    if (selectedConversation != null && selectedConversation.id != _lastLoadedConversationId) {
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

  // Helper method to clean up duplicates using service
  void _cleanupMessagesList() {
    setState(() {
      _messages = MessageService.cleanupMessagesList(_messages);
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

          final transcription = await _openAIService.transcribeAudio(recordingBytes, language: languageHint);

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
          _showErrorSnackBar(AppLocalizations.of(context)!.errorProcessingAudio);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: settings.getScaledFontSize(14)),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
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
        final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
        final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
            print('[PlacesExplorer] Search completed: ${places.length} places found for "$query"');
            Navigator.of(context).pop();
            if (places.isNotEmpty) {
              _addLocationResultsToChat(places, query);
            } else {
              print('[PlacesExplorer] No places found - showing message');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No places found for "$query". Try a different search or location.'),
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
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
      final pdfBytes = await _generateHtmlToPdf(message);

      if (pdfBytes != null) {
        // Save PDF to documents directory
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${dir.path}/howai_message_${timestamp}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        // Verify file was actually written and is accessible
        await Future.delayed(Duration(milliseconds: 100)); // Small delay to ensure file system sync
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
        final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
        final messageConversationId = conversationProvider.selectedConversation?.id ?? message.conversationId;

        // Check subscription status for message customization
        final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
        final isPremium = subscriptionService.isPremium;

        // Create different messages for free vs premium users
        String pdfMessage;
        if (isPremium) {
          pdfMessage = "📄 **PDF created successfully!**\n\n[Tap here to open and share]($filePath)";
        } else {
          final remaining = subscriptionService.remainingPdfGenerations;
          final limit = subscriptionService.limits.pdfGenerationsWeekly;
          pdfMessage = "📄 **PDF created successfully!**\n\n[Tap here to open and share]($filePath)\n\n📊 PDF generations remaining: $remaining/$limit\n✨ Upgrade to Premium for unlimited access";
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
        if (conversationProvider.selectedConversation?.id == messageConversationId) {
          setState(() {
            _messages.add(pdfLinkMessage);
          });
        }

        // Scroll to bottom to show the new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: true);
        });

        // Auto-open the PDF for immediate sharing
        try {
          await OpenFile.open(filePath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "PDF opened! Use your device's share button to send it.",
                style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "PDF created! Tap the link in the message to open it.",
                style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              ),
              backgroundColor: Colors.green,
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

  // Generate PDF using simple, robust text cleaning approach - Premium quality for all users
  Future<List<int>?> _generateHtmlToPdf(ChatMessage message) async {
    try {
      //// print('[PDF-SIMPLE] Starting premium-quality PDF generation...');

      // Get current profile for personalization
      final currentProfile = await _databaseService.getProfile(_currentProfileId!);
      final profileName = currentProfile?.name ?? 'User';

      // Minimal cleaning approach - preserve quotes at all costs
      String cleanText = message.message;

      // Only do the most basic cleaning - remove markdown images and fix obvious issues
      cleanText = cleanText.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), ''); // Remove markdown images
      cleanText = cleanText.replaceAll(''', "'"); // Smart single quote left
      cleanText = cleanText.replaceAll(''', "'"); // Smart single quote right
      cleanText = cleanText.replaceAll('"', '"'); // Smart double quote left
      cleanText = cleanText.replaceAll('"', '"'); // Smart double quote right
      cleanText = cleanText.replaceAll('—', '-'); // Em dash
      cleanText = cleanText.replaceAll('–', '-'); // En dash

      //// print('[PDF-SIMPLE] Minimally cleaned text: ${cleanText.length} characters');
      //// print('[PDF-SIMPLE] Sample: ${cleanText.substring(0, cleanText.length > 100 ? 100 : cleanText.length)}');

      // Try to load Unicode-supporting font
      pw.Font? unicodeFont;
      try {
        final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        unicodeFont = pw.Font.ttf(fontData);
        //// print('[PDF-SIMPLE] Successfully loaded NotoSans font for Unicode support');
      } catch (e) {
        //// print('[PDF-SIMPLE] Could not load NotoSans font, will use more aggressive text cleaning: $e');
        unicodeFont = null;
      }

      // If no Unicode font available, do more aggressive cleaning
      if (unicodeFont == null) {
        // More comprehensive Unicode character replacement
        cleanText = cleanText.replaceAll('•', '- '); // Bullet point
        cleanText = cleanText.replaceAll('…', '...'); // Ellipsis
        cleanText = cleanText.replaceAll('°', ' degrees'); // Degree symbol
        cleanText = cleanText.replaceAll('©', '(c)'); // Copyright
        cleanText = cleanText.replaceAll('®', '(R)'); // Registered
        cleanText = cleanText.replaceAll('™', '(TM)'); // Trademark

        // Remove any remaining non-ASCII characters that might cause issues
        cleanText = cleanText.replaceAllMapped(RegExp(r'[^\x00-\x7F]'), (match) {
          final char = match.group(0)!;
          final codeUnit = char.codeUnitAt(0);
          //// print('[PDF-SIMPLE] Removing problematic character: $char (U+${codeUnit.toRadixString(16).toUpperCase().padLeft(4, '0')})');
          return ' '; // Replace with space
        });

        //// print('[PDF-SIMPLE] Applied ASCII-only cleaning due to font limitations');
      }

      // Generate multi-page PDF that can handle long content
      final pdf = pw.Document();

      // Split text into manageable chunks for better formatting
      final lines = cleanText.split('\n');
      final List<pw.Widget> contentWidgets = [];

      // Process lines and create widgets
      for (String line in lines) {
        line = line.trim();

        if (line.isEmpty) {
          contentWidgets.add(pw.SizedBox(height: 8));
          continue;
        }

        // Check if line is a header (all caps, short, or ends with colon)
        bool isHeader = line.length < 50 && (line.toUpperCase() == line || line.endsWith(':') || line.startsWith('---'));

        if (isHeader) {
          contentWidgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
            child: pw.Text(
              line.replaceAll('---', '').trim(),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                font: unicodeFont,
              ),
            ),
          ));
        } else if (line.startsWith('• ') || line.startsWith('- ')) {
          // Bullet point
          contentWidgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(left: 16, bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 16,
                  child: pw.Text('•', style: pw.TextStyle(fontSize: 12, font: unicodeFont)),
                ),
                pw.Expanded(
                  child: pw.Text(
                    line.substring(2).trim(),
                    style: pw.TextStyle(fontSize: 12, height: 1.4, font: unicodeFont),
                  ),
                ),
              ],
            ),
          ));
        } else {
          // Regular text paragraph
          contentWidgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              line,
              style: pw.TextStyle(fontSize: 12, height: 1.4, font: unicodeFont),
            ),
          ));
        }
      }

      // Always use premium layout (clean content without headers/footers)
      final List<pw.Widget> buildContent = [];
      // Add top padding since there's no header
      buildContent.add(pw.SizedBox(height: 30));
      buildContent.addAll(contentWidgets);

      // Add pages with clean premium layout
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30), // Premium margins
          // No headers or footers for clean look
          build: (pw.Context context) => buildContent,
        ),
      );

      final pdfBytes = await pdf.save();
      //// print('[PDF-SIMPLE] Successfully generated premium-quality PDF with ${pdfBytes.length} bytes');
      return pdfBytes;
    } catch (e) {
      //// print('[PDF-SIMPLE] Error generating simple PDF: $e');
      return null;
    }
  }

  // Convert markdown to HTML with proper styling
  String _convertMarkdownToHtml(String markdown) {
    String html = markdown;

    // Convert headers
    html = html.replaceAllMapped(RegExp(r'^### (.+)$', multiLine: true), (match) => '<h3>${match.group(1)}</h3>');
    html = html.replaceAllMapped(RegExp(r'^## (.+)$', multiLine: true), (match) => '<h2>${match.group(1)}</h2>');
    html = html.replaceAllMapped(RegExp(r'^# (.+)$', multiLine: true), (match) => '<h1>${match.group(1)}</h1>');

    // Convert bold and italic
    html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (match) => '<strong>${match.group(1)}</strong>');
    html = html.replaceAllMapped(RegExp(r'\*(.+?)\*'), (match) => '<em>${match.group(1)}</em>');

    // Convert bullet points
    html = html.replaceAllMapped(RegExp(r'^- (.+)$', multiLine: true), (match) => '<li>${match.group(1)}</li>');

    // Wrap consecutive list items in <ul> tags
    html = html.replaceAllMapped(RegExp(r'(<li>.*?</li>(?:\s*<li>.*?</li>)*)', dotAll: true), (match) => '<ul>${match.group(1)}</ul>');

    // Convert line breaks
    html = html.replaceAll('\n\n', '</p><p>');
    html = html.replaceAll('\n', '<br>');

    // Wrap in paragraphs
    html = '<p>$html</p>';

    return html;
  }

  // Helper method to detect header lines based on content patterns
  bool _isHeaderLine(String line) {
    // Common header patterns in travel itineraries and content
    final headerPatterns = [
      RegExp(r'^### ', caseSensitive: false), // Markdown headers
      RegExp(r'^Day \d+:', caseSensitive: false),
      RegExp(r'^Morning:?$', caseSensitive: false),
      RegExp(r'^Afternoon:?$', caseSensitive: false),
      RegExp(r'^Evening:?$', caseSensitive: false),
      RegExp(r'^Option [A-Z]:', caseSensitive: false),
      RegExp(r'^Tips?:?$', caseSensitive: false),
      RegExp(r'^Important:?$', caseSensitive: false),
      RegExp(r'^Note:?$', caseSensitive: false),
      RegExp(r'^Summary:?$', caseSensitive: false),
      RegExp(r'.+ - .+'), // Pattern like "Day 1: Tokyo - Modern & Traditional Blend"
    ];

    return headerPatterns.any((pattern) => pattern.hasMatch(line));
  }

  // Helper method to detect bullet points
  bool _isBulletPoint(String line) {
    return line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ') || RegExp(r'^\w+:').hasMatch(line); // Pattern like "Tsukiji Outer Market:" or "Hamarikyu Gardens:"
  }

  // Helper method to clean bullet text
  String _cleanBulletText(String line) {
    // Remove bullet markers
    if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ')) {
      return line.substring(2).trim();
    }
    return line.trim();
  }

  // Show PDF generation limit dialog
  void _showPdfLimitDialog() {
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
            final isVerySmallScreen = screenHeight < 860 && screenWidth < 400; // iPhone 16 specifically

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
                      size: settings.getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'PDF Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
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
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...['• Unlimited PDF generation', '• Professional-quality documents', '• No waiting periods', '• All premium features'].map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
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
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
            final isVerySmallScreen = screenHeight < 860 && screenWidth < 400; // iPhone 16 specifically

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
                      size: settings.getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Document Analysis Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
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
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...['• Unlimited document analysis', '• Advanced file processing', '• PDF, Word, Excel support', '• All premium features'].map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
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
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
            final isVerySmallScreen = screenHeight < 860 && screenWidth < 400; // iPhone 16 specifically

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
                      size: settings.getScaledFontSize(isVerySmallScreen ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Places Explorer Limit Reached',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18)),
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
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 12),
                    Text(
                      '✨ Upgrade to Premium for:',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    ...['• Unlimited places exploration', '• Advanced location search', '• Real-time business info', '• All premium features'].map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: isVerySmallScreen ? 2 : 4),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
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
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    // For PPTX: Premium users have unlimited access, free users get 3 uses based on document analysis remaining
    if (!subscriptionService.isPremium && subscriptionService.remainingDocumentAnalysis <= 0) {
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
  Future<void> _processTranslation(String translationPrompt, {List<XFile>? images}) async {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          ...['• Create professional PPTX presentations', '• Unlimited presentation generation', '• Custom themes and layouts', '• All premium AI features unlocked'].map(
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
      if (message.isUserMessage && message.message.toLowerCase().contains('find')) {
        // Extract search query from messages like "Find restaurants near me"
        final words = message.message.split(' ');
        final findIndex = words.indexWhere((word) => word.toLowerCase() == 'find');
        if (findIndex >= 0 && findIndex < words.length - 1) {
          return words.sublist(findIndex + 1).join(' ').replaceAll(' near me', '');
        }
      }
    }
    return 'places'; // fallback
  }

  // Extract recent places context for AI follow-up questions
  String? _getRecentPlacesContext(String userMessage, List<ChatMessage> history) {
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
    final isNewSearchCommand = !isAnalysisRequest && (lowerMessage.startsWith('find ') || lowerMessage.startsWith('search ') || lowerMessage.startsWith('show me ') || (lowerMessage.contains('near me') && !lowerMessage.contains('suggest')) || lowerMessage.contains('search for'));

    if (isNewSearchCommand) return null;

    // Look for recent messages with location results (within last 8 messages)
    for (int i = history.length - 1; i >= 0 && i >= history.length - 8; i--) {
      final message = history[i];
      if (message.locationResults != null && message.locationResults!.isNotEmpty) {
        // Found recent places data, format it for AI context
        final places = message.locationResults!;
        final placesInfo = StringBuffer();
        placesInfo.writeln('Here are the places I recently found for you:');

        for (int j = 0; j < places.length && j < 20; j++) {
          final place = places[j];
          placesInfo.writeln('${j + 1}. ${place.name}');
          placesInfo.writeln('   - Rating: ${place.rating}/5 (${place.userRatingsTotal} reviews)');
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

    if (placeTypes.any((type) => ['restaurant', 'food', 'meal_takeaway'].contains(type))) {
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
    } else if (placeTypes.any((type) => ['hospital', 'pharmacy', 'doctor'].contains(type))) {
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
    } else if (placeTypes.any((type) => ['shopping_mall', 'store'].contains(type))) {
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
    if (searchContext.contains('restroom') || searchContext.contains('bathroom') || searchContext.contains('toilet')) {
      return "I found ${places.length} places with public restrooms nearby. These locations typically have facilities available:";
    }

    // Check if it's a location-specific search
    bool hasLocationContext = query.toLowerCase().contains(' in ') || query.toLowerCase().contains(' at ') || RegExp(r'\b\d{5}\b').hasMatch(query); // zip code

    if (hasLocationContext) {
      return "I found ${places.length} $placeCategory in your specified area:";
    } else {
      return "I found ${places.length} $placeCategory near you:";
    }
  }

  Future<void> _addLocationResultsToChat(List<PlaceResult> places, String query) async {
    try {
      // Consume places explorer usage for free users
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      int? messageConversationId = conversationProvider.selectedConversation?.id;
      bool createdNewConversation = false;

      // If no conversation exists, create one for this search
      if (messageConversationId == null) {
        createdNewConversation = true;
        final String searchTitle = "Places Explorer: $query";

        // Create a new conversation
        await conversationProvider.createConversation(searchTitle, _currentProfileId);

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
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
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
                            maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.withOpacity(0.2) : Colors.teal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Icon(
                                            Icons.brush,
                                            size: settings.getScaledFontSize(24),
                                            color: Colors.teal,
                                          ),
                                        ),
                                        SizedBox(width: 12),

                                        // Title and description
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'AI Image Generation',
                                                style: TextStyle(
                                                  fontSize: settings.getScaledFontSize(16),
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1C1C1E),
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Describe what you want to create',
                                                style: TextStyle(
                                                  fontSize: settings.getScaledFontSize(11),
                                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                                          hintText: AppLocalizations.of(context)!.futuristicCityExample,
                                          hintStyle: TextStyle(
                                            fontSize: settings.getScaledFontSize(11),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade500,
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.teal, width: 2),
                                          ),
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        style: TextStyle(
                                          fontSize: settings.getScaledFontSize(13),
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      // Compact tips
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '💡 Tips:',
                                              style: TextStyle(
                                                fontSize: settings.getScaledFontSize(13),
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '• Style: realistic, cartoon, digital art\n• Lighting & mood details\n• Colors & composition',
                                              style: TextStyle(
                                                fontSize: settings.getScaledFontSize(13),
                                                color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
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
                                            fontSize: settings.getScaledFontSize(13),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        onPressed: () {
                                          final prompt = promptController.text.trim();
                                          if (prompt.isNotEmpty) {
                                            FocusScope.of(context).unfocus();
                                            Navigator.of(context).pop();
                                            _processImageGeneration(prompt);
                                          }
                                        },
                                        child: Text(
                                          'Generate',
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(13),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

// Location Search Dialog
class LocationSearchDialog extends StatefulWidget {
  final Function(List<PlaceResult>, String) onSearchCompleted;

  const LocationSearchDialog({
    super.key,
    required this.onSearchCompleted,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();
  bool _isSearching = false;
  bool _isGettingLocation = false;
  String? _locationError;
  String _selectedCategory = 'restaurant';
  bool _openNow = false; // Track "open now" filter
  bool _useCurrentLocation = true; // Toggle for location type
  String? _lastCustomLocation; // Remember last custom location
  String? _validationError; // Show validation errors prominently

  final Map<String, String> _categories = {
    'restaurant': 'Restaurants',
    'cafe': 'Coffee Shops',
    'bakery': 'Sweet Food & Bakery',
    'convenience_store': 'Ice Cream & Desserts',
    'lodging': 'Hotels',
    'tourist_attraction': 'Attractions',
    'shopping_mall': 'Shopping',
    'gas_station': 'Gas Stations',
    'parking': 'Parking Garage',
    'hospital': 'Healthcare',
    'pharmacy': 'Pharmacy',
    'bank': 'Banks',
    'atm': 'ATM',
    'gym': 'Fitness',
    'beauty_salon': 'Beauty & Spa',
    'laundry': 'Laundromat',
    'car_wash': 'Car Wash',
    'night_club': 'Nightlife',
    'park': 'Parks',
    'subway_station': 'Public Transit',
    'restroom': 'Public Restroom',
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // Add listener to update button text when search field changes
    _searchController.addListener(() {
      setState(() {
        // Rebuild to update button text
      });
    });

    // Add listener for location controller
    _locationController.addListener(() {
      setState(() {
        // Rebuild to update UI state
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    // Only request location permission if using current location
    if (!_useCurrentLocation) return;

    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      bool hasPermission = await _locationService.checkLocationPermission();
      if (hasPermission) {
        await _locationService.getCurrentLocation();
      } else {
        setState(() {
          _locationError = "Location permission required for current location search";
        });
      }
    } catch (e) {
      setState(() {
        _locationError = "Failed to get location: $e";
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  // Toggle location mode and handle permission/geocoding accordingly
  void _toggleLocationMode(bool useCurrentLocation) {
    setState(() {
      _useCurrentLocation = useCurrentLocation;
      _locationError = null;

      if (useCurrentLocation) {
        // Switched to current location - request permission
        _requestLocationPermission();
      } else {
        // Switched to custom location - stop location loading and pre-fill
        _isGettingLocation = false;
        if (_lastCustomLocation != null) {
          _locationController.text = _lastCustomLocation!;
        }
      }
    });
  }

  Future<void> _searchPlaces() async {
    final searchText = _searchController.text.trim();
    final customLocation = _useCurrentLocation ? null : _locationController.text.trim();

    //// print('[LocationSearch] _searchPlaces called with: "$searchText"');
    //// print('[LocationSearch] Use current location: $_useCurrentLocation');
    if (customLocation != null) {
      //// print('[LocationSearch] Custom location: "$customLocation"');
    }

    // Use category name as fallback if no search text provided
    final queryText = searchText.isEmpty ? _categories[_selectedCategory] ?? _selectedCategory : searchText;

    // Validate custom location if needed
    if (!_useCurrentLocation && (customLocation == null || customLocation.isEmpty)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Location Required',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            content: Text(
              'Please enter a city or address to search in.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        },
      );
      return;
    }

    //// print('[LocationSearch] Using query: "$queryText" (category: $_selectedCategory)');
    //// print('[LocationSearch] Starting search...');
    setState(() {
      _isSearching = true;
    });

    try {
      //// print('[LocationSearch] Calling locationService.searchNearbyPlaces');
      final places = await _locationService.searchNearbyPlaces(
        query: queryText,
        type: _selectedCategory,
        openNow: _openNow,
        customLocation: customLocation,
      );

      // Remember the custom location for next time
      if (!_useCurrentLocation && customLocation != null) {
        _lastCustomLocation = customLocation;
      }

      //// print('[LocationSearch] Search completed, found ${places.length} places');

      // Create an enhanced query description for the chat
      final searchDescription = _useCurrentLocation ? queryText : "$queryText in $customLocation";

      widget.onSearchCompleted(places, searchDescription);
    } catch (e) {
      //// print('[LocationSearch] Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.searchFailed(e.toString()))),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenHeight < 700 || screenWidth < 400; // iPhone 16 and similar

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom title bar
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF5856D6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.explore,
                            color: Color(0xFF5856D6),
                            size: settings.getScaledFontSize(isSmallScreen ? 18 : 20),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Places Explorer',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isSmallScreen ? 16 : 18),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleMedium?.color,
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
                  ),

                  // Content area
                  Container(
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxHeight: isSmallScreen ? screenHeight * 0.6 : screenHeight * 0.7,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_isGettingLocation) ...[
                          Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Color(0xFF5856D6)),
                                SizedBox(height: 12),
                                Text(
                                  'Getting your location...',
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_locationError != null) ...[
                          // Warning container with maximum elevation to ensure it appears on top
                          Stack(
                            children: [
                              Material(
                                elevation: 12, // Increased elevation for higher z-index
                                borderRadius: BorderRadius.circular(8),
                                shadowColor: Colors.red.withOpacity(0.5),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                          size: settings.getScaledFontSize(20),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _locationError!,
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(14),
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _requestLocationPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Location selection
                          Text(
                            'Search Location',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                          SizedBox(height: 4),

                          // Current location toggle
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.my_location,
                                color: _useCurrentLocation ? Color(0xFF5856D6) : Colors.grey,
                                size: settings.getScaledFontSize(20),
                              ),
                              title: Text(
                                'Use Current Location',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  fontWeight: _useCurrentLocation ? FontWeight.w600 : FontWeight.normal,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              subtitle: _locationService.currentAddress != null
                                  ? Text(
                                      _locationService.currentAddress!,
                                      style: TextStyle(
                                        fontSize: settings.getScaledFontSize(12),
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                    )
                                  : null,
                              trailing: Switch(
                                value: _useCurrentLocation,
                                onChanged: _toggleLocationMode,
                                activeColor: Color(0xFF5856D6),
                              ),
                            ),
                          ),

                          // Custom location input
                          if (!_useCurrentLocation) ...[
                            SizedBox(height: 4),
                            TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.enterCityOrAddress,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                hintText: AppLocalizations.of(context)!.tokyoParisExample,
                                hintStyle: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: Icon(Icons.location_city, color: Color(0xFF5856D6)),
                                errorText: _validationError,
                                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                                filled: true,
                              ),
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(14),
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                // Clear validation error when user starts typing
                                if (_validationError != null) {
                                  setState(() {
                                    _validationError = null;
                                  });
                                }
                              },
                            ),
                          ],

                          SizedBox(height: 16),

                          // Section header with Open now filter
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'What are you looking for?',
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.titleMedium?.color,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _openNow ? Color(0xFF5856D6).withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _openNow ? Color(0xFF5856D6) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: _openNow,
                                        onChanged: (value) {
                                          setState(() {
                                            _openNow = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF5856D6),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Open now',
                                      style: TextStyle(
                                        fontSize: settings.getScaledFontSize(12),
                                        color: _openNow ? Color(0xFF5856D6) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700),
                                        fontWeight: _openNow ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Category selection
                          _buildCategoryGrid(settings),

                          SizedBox(height: 12),

                          // Search input
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.optionalBestPizza,
                              hintStyle: TextStyle(
                                fontSize: settings.getScaledFontSize(14),
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                              filled: true,
                              suffixIcon: IconButton(
                                onPressed: _isSearching ? null : _searchPlaces,
                                icon: _isSearching
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(Icons.search),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            onSubmitted: (_) => _searchPlaces(),
                            textInputAction: TextInputAction.search,
                          ),

                          SizedBox(height: 12),
                        ],
                      ]),
                    ),
                  ),

                  // Action buttons at bottom
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                          top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                      )),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(14),
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        if (!_isGettingLocation && _locationError == null)
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : _searchPlaces,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5856D4),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isSearching
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _searchController.text.trim().isEmpty ? 'Find ${_categories[_selectedCategory]}' : 'Search',
                                      style: TextStyle(fontSize: settings.getScaledFontSize(14)),
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
        );
      },
    );
  }

  // Helper method to get brighter colors for dark mode
  Color _getBrighterColorForDarkMode(Color originalColor) {
    if (originalColor == Colors.orange) return Colors.orange.shade100;
    if (originalColor == Colors.green) return Colors.green.shade100;
    if (originalColor == Colors.blue) return Colors.blue.shade100;
    if (originalColor == Colors.purple) return Colors.purple.shade100;
    return originalColor.withOpacity(1.0);
  }

  Widget _buildCategoryGrid(SettingsProvider settings) {
    // Group categories with icons and colors
    final categoryGroups = [
      {
        'title': 'Food & Drink',
        'color': Colors.orange,
        'categories': [
          {'key': 'restaurant', 'name': 'Restaurants', 'icon': Icons.restaurant},
          {'key': 'cafe', 'name': 'Coffee', 'icon': Icons.local_cafe},
          {'key': 'bakery', 'name': 'Bakery', 'icon': Icons.cake},
          {'key': 'convenience_store', 'name': 'Desserts', 'icon': Icons.icecream},
          {'key': 'night_club', 'name': 'Bars', 'icon': Icons.nightlife},
        ]
      },
      {
        'title': 'Places & Travel',
        'color': Colors.green,
        'categories': [
          {'key': 'lodging', 'name': 'Hotels', 'icon': Icons.hotel},
          {'key': 'tourist_attraction', 'name': 'Attractions', 'icon': Icons.attractions},
          {'key': 'shopping_mall', 'name': 'Shopping', 'icon': Icons.shopping_bag},
          {'key': 'park', 'name': 'Parks', 'icon': Icons.park},
          {'key': 'subway_station', 'name': 'Transit', 'icon': Icons.train},
          {'key': 'restroom', 'name': 'Restroom', 'icon': Icons.wc},
        ]
      },
      {
        'title': 'Services',
        'color': Colors.blue,
        'categories': [
          {'key': 'gas_station', 'name': 'Gas', 'icon': Icons.local_gas_station},
          {'key': 'parking', 'name': 'Parking', 'icon': Icons.local_parking},
          {'key': 'atm', 'name': 'ATM', 'icon': Icons.atm},
          {'key': 'bank', 'name': 'Bank', 'icon': Icons.account_balance},
          {'key': 'pharmacy', 'name': 'Pharmacy', 'icon': Icons.medication},
          {'key': 'laundry', 'name': 'Laundry', 'icon': Icons.local_laundry_service},
        ]
      },
      {
        'title': 'Health & Beauty',
        'color': Colors.purple,
        'categories': [
          {'key': 'hospital', 'name': 'Healthcare', 'icon': Icons.local_hospital},
          {'key': 'gym', 'name': 'Fitness', 'icon': Icons.fitness_center},
          {'key': 'beauty_salon', 'name': 'Beauty', 'icon': Icons.face_retouching_natural},
        ]
      },
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryGroups.map((group) {
            final categories = group['categories'] as List<Map<String, dynamic>>;
            final color = group['color'] as Color;

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group header
                  Text(
                    group['title'] as String,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(10),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? _getBrighterColorForDarkMode(color) : color,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Category grid
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category['key'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['key'] as String;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 12,
                                color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? _getBrighterColorForDarkMode(color) : color),
                              ),
                              SizedBox(width: 3),
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(10),
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? _getBrighterColorForDarkMode(color) : color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
