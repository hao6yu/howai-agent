import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/material.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/profile_provider.dart';
import '../services/database_service.dart';
import '../services/elevenlabs_agent_service.dart';
import '../services/subscription_service.dart';
import '../services/voice_call_usage_service.dart';

/// Transcript entry collected during the call.
class _TranscriptEntry {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _TranscriptEntry({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Full-screen voice call screen using ElevenLabs Conversational AI.
///
/// On call end, creates a new conversation with the call transcript
/// and navigates back to it automatically.
class ElevenLabsCallScreen extends StatefulWidget {
  const ElevenLabsCallScreen({super.key});

  @override
  State<ElevenLabsCallScreen> createState() => _ElevenLabsCallScreenState();
}

class _ElevenLabsCallScreenState extends State<ElevenLabsCallScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isClosing = false;
  bool _isPaused = false;
  bool _isAssistantSpeaking = false;

  // Error handling
  String? _error;

  // Services
  final ElevenLabsAgentService _agentService = ElevenLabsAgentService();
  final DatabaseService _databaseService = DatabaseService();
  final VoiceCallUsageService _usageService = VoiceCallUsageService();
  ConversationClient? _client;

  // Transcript collection
  final List<_TranscriptEntry> _transcript = [];
  String? _currentTranscript;
  final Set<int> _seenFinalUserTranscriptEventIds = <int>{};

  // Animation
  late final AnimationController _orbPulseController;

  // Profile & subscription
  int? _currentProfileId;
  String _currentProfileName = 'there';
  ElevenLabsVoicePreset _selectedVoice = ElevenLabsVoicePreset.male;
  bool _isPremium = false;
  bool _initialized = false;

  // Usage tracking
  VoiceCallAllowance? _allowance;
  int? _callSessionId;
  int _maxCallSeconds = 0;
  bool _warnedOneMinuteLeft = false;
  bool _isSavingTranscript = false;
  String? _pendingEndReason;

  // Background handling
  DateTime? _wentBackgroundAt;

  // Call duration
  Timer? _callTimer;
  int _elapsedSeconds = 0;
  static const Duration _connectTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _orbPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _client = _buildConversationClient();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final profileProvider = context.read<ProfileProvider>();
    final subscriptionService = context.read<SubscriptionService>();
    _currentProfileId = profileProvider.selectedProfileId;
    final selectedProfile = profileProvider.profiles.where((profile) {
      return profile.id == _currentProfileId;
    }).firstOrNull;
    _currentProfileName = selectedProfile?.name.trim().isNotEmpty == true
        ? selectedProfile!.name.trim()
        : 'there';
    _isPremium = subscriptionService.isPremium;
    if (!_agentService.isConfiguredForVoice(voice: _selectedVoice)) {
      if (_agentService.isConfiguredForVoice(
          voice: ElevenLabsVoicePreset.male)) {
        _selectedVoice = ElevenLabsVoicePreset.male;
      } else if (_agentService.isConfiguredForVoice(
        voice: ElevenLabsVoicePreset.female,
      )) {
        _selectedVoice = ElevenLabsVoicePreset.female;
      }
    }

    // Load usage allowance
    _loadAllowance();
  }

  Future<void> _loadAllowance() async {
    if (_currentProfileId == null) return;

    final allowance = await _usageService.getVoiceCallAllowance(
      profileId: _currentProfileId!,
      isPremium: _isPremium,
    );

    if (mounted) {
      setState(() {
        _allowance = allowance;
        _maxCallSeconds = allowance.remainingForThisCallSeconds;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _wentBackgroundAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed && _wentBackgroundAt != null) {
      final backgroundSeconds =
          DateTime.now().difference(_wentBackgroundAt!).inSeconds;
      _wentBackgroundAt = null;
      // End call if backgrounded for more than 30 seconds
      if (_isConnected && backgroundSeconds > 30) {
        _closeCall(reason: 'background_timeout');
      }
    }
  }

  ConversationClient _buildConversationClient() {
    return ConversationClient(
      callbacks: ConversationCallbacks(
        onConnect: ({required String conversationId}) {
          _setStateIfMounted(() {
            _isConnected = true;
            _isConnecting = false;
            _error = null;
          });
          _startCallTimer();
          unawaited(_configureAudioSession());
        },
        onDisconnect: (details) {
          _setStateIfMounted(() {
            _isConnected = false;
            _isConnecting = false;
          });
          _callTimer?.cancel();

          // If we are not in our own close flow, treat this as an unexpected disconnect.
          if (!_isClosing) {
            final reason = _pendingEndReason ?? 'sdk_disconnect';
            unawaited(_finalizeUsageSession(endReason: reason));
            _pendingEndReason = null;
          }
        },
        onStatusChange: ({required ConversationStatus status}) {
          if (!mounted) return;
          setState(() {
            if (status == ConversationStatus.disconnected ||
                status == ConversationStatus.disconnecting) {
              _isConnected = false;
              _isConnecting = false;
            }
          });
        },
        onModeChange: ({required ConversationMode mode}) {
          _setStateIfMounted(() {
            _isAssistantSpeaking = mode == ConversationMode.speaking;
          });
        },
        onMessage: ({required String message, required Role source}) {
          if (message.trim().isEmpty) return;

          // Capture full messages from the legacy 'user_transcription' path
          // and from normal AI responses.
          _appendTranscriptEntry(
            text: message,
            isUser: source == Role.user,
          );

          _setStateIfMounted(() {
            _currentTranscript = message;
            _isAssistantSpeaking = source == Role.ai;
          });
        },
        onUserTranscript: ({required String transcript, required int eventId}) {
          // This is the finalized user transcript on current SDK protocol.
          _appendTranscriptEntry(
            text: transcript,
            isUser: true,
            userTranscriptEventId: eventId,
          );

          if (transcript.trim().isEmpty) return;
          _setStateIfMounted(() {
            _currentTranscript = transcript;
          });
        },
        onTentativeUserTranscript: (
            {required String transcript, required int eventId}) {
          if (transcript.trim().isEmpty) return;
          _setStateIfMounted(() {
            _currentTranscript = transcript;
          });
        },
        onError: (message, [context]) {
          final details = context == null ? message : '$message: $context';
          debugPrint('ElevenLabs SDK error: $details');
          _setStateIfMounted(() {
            _error =
                AppLocalizations.of(this.context)!.voiceCallConnectionIssue;
            _isConnecting = false;
          });
        },
        onEndCallRequested: () {
          _closeCall(reason: 'agent_end_call_requested');
        },
      ),
    );
  }

  void _setStateIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void _appendTranscriptEntry({
    required String text,
    required bool isUser,
    int? userTranscriptEventId,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) return;

    if (isUser && userTranscriptEventId != null) {
      if (!_seenFinalUserTranscriptEventIds.add(userTranscriptEventId)) {
        return;
      }
    }

    final now = DateTime.now();
    if (_transcript.isNotEmpty) {
      final last = _transcript.last;
      final isDuplicateOfLast = last.isUser == isUser &&
          last.text.toLowerCase() == normalized.toLowerCase() &&
          now.difference(last.timestamp).inSeconds <= 2;
      if (isDuplicateOfLast) {
        return;
      }
    }

    _transcript.add(_TranscriptEntry(
      text: normalized,
      isUser: isUser,
      timestamp: now,
    ));
  }

  Future<void> _configureAudioSession() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker |
                  AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );
      await session.setActive(true);
    } catch (e) {
      debugPrint('Could not configure call audio session: $e');
    }
  }

  Future<void> _deactivateAudioSession() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      debugPrint('Could not deactivate audio session: $e');
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _elapsedSeconds = 0;
    _warnedOneMinuteLeft = false;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected || !mounted) return;

      final nextElapsed = _elapsedSeconds + 1;
      final remaining = _maxCallSeconds - nextElapsed;

      setState(() => _elapsedSeconds = nextElapsed);

      // Warn at 1 minute remaining
      if (remaining <= 60 && remaining > 0 && !_warnedOneMinuteLeft) {
        _warnedOneMinuteLeft = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.voiceCallOneMinuteRemaining,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // End call when time is up
      if (remaining <= 0) {
        _closeCall(reason: 'time_limit_reached');
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _normalizeInterestTags(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is List) {
      final tags = value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
      return tags.isEmpty ? null : tags.join(', ');
    }

    if (value is Map) {
      final tags = <String>[];
      value.forEach((key, rawValue) {
        if (key is! String || key.trim().isEmpty) return;

        final include = switch (rawValue) {
          bool v => v,
          num v => v > 0,
          String v => v.trim().isNotEmpty,
          null => false,
          _ => true,
        };

        if (include) {
          tags.add(key.trim());
        }
      });
      return tags.isEmpty ? null : tags.join(', ');
    }

    return null;
  }

  String? _normalizeCommunicationStyle(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is Map) {
      for (final key in const ['style', 'name', 'tone']) {
        final nested = value[key];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
      }

      final styles = <String>[];
      value.forEach((key, rawValue) {
        if (key is! String || key.trim().isEmpty) return;

        final include = switch (rawValue) {
          bool v => v,
          num v => v > 0,
          String v => v.trim().isNotEmpty,
          null => false,
          _ => true,
        };

        if (include) {
          styles.add(key.trim());
        }
      });
      return styles.isEmpty ? null : styles.join(', ');
    }

    return null;
  }

  Future<void> _finalizeUsageSession({
    required String endReason,
  }) async {
    final sessionId = _callSessionId;
    if (sessionId == null) return;

    // Guard against duplicate writes when close/disconnect callbacks race.
    _callSessionId = null;
    try {
      await _usageService.endVoiceCallSession(
        sessionId: sessionId,
        durationSeconds: _elapsedSeconds < 0 ? 0 : _elapsedSeconds,
        endReason: endReason,
      );
    } catch (e) {
      debugPrint('Error finalizing voice call session $sessionId: $e');
    }
  }

  Future<void> _startCall() async {
    if (_isConnecting || _isConnected) return;

    // Check profile
    if (_currentProfileId == null) {
      _setStateIfMounted(() {
        _error = AppLocalizations.of(context)!.voiceCallSelectProfileFirst;
      });
      return;
    }

    // Refresh and check allowance
    await _loadAllowance();
    if (_allowance == null || !_allowance!.allowed) {
      _setStateIfMounted(() {
        _error = AppLocalizations.of(context)!.voiceCallLimitReached;
      });
      return;
    }

    _setStateIfMounted(() {
      _isConnecting = true;
      _error = null;
      _transcript.clear();
      _seenFinalUserTranscriptEventIds.clear();
      _currentTranscript = null;
      _elapsedSeconds = 0;
      _maxCallSeconds = _allowance!.remainingForThisCallSeconds;
    });

    try {
      final profile = await _databaseService.getProfile(_currentProfileId!);
      final resolvedProfileName = (profile?.name ?? _currentProfileName).trim();
      final elevenUserName =
          resolvedProfileName.isNotEmpty ? resolvedProfileName : 'there';
      final profileCharacteristics = profile?.characteristics ?? {};

      final aiPersonalityMap =
          await _databaseService.getAIPersonalityForProfile(_currentProfileId!);
      final interestTags = _normalizeInterestTags(
            aiPersonalityMap?['interests'],
          ) ??
          _normalizeInterestTags(profileCharacteristics['interests']);
      final communicationStyle = _normalizeCommunicationStyle(
            aiPersonalityMap?['communication_style'],
          ) ??
          _normalizeCommunicationStyle(
            profileCharacteristics['communication_style'],
          );
      final dynamicVariables = <String, dynamic>{
        'user_name': elevenUserName,
      };
      if (interestTags != null) {
        dynamicVariables['interest_tags'] = interestTags;
      }
      if (communicationStyle != null) {
        dynamicVariables['communication_style'] = communicationStyle;
      }

      final agentIdForSelectedVoice =
          _agentService.agentIdForVoice(voice: _selectedVoice);

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        String errorMessage;
        if (status == PermissionStatus.permanentlyDenied) {
          errorMessage = AppLocalizations.of(context)!
              .voiceCallMicrophoneDeniedPermanently;
          // Optionally open settings
          openAppSettings();
        } else {
          errorMessage =
              AppLocalizations.of(context)!.voiceCallMicrophoneRequired;
        }
        _setStateIfMounted(() {
          _isConnecting = false;
          _error = errorMessage;
        });
        return;
      }

      // Check if service is configured
      if (agentIdForSelectedVoice == null) {
        debugPrint(
            'ElevenLabs call config issue: ${_agentService.configurationIssueForVoice(voice: _selectedVoice) ?? 'unknown'}');
        _setStateIfMounted(() {
          _isConnecting = false;
          _error = AppLocalizations.of(context)!.voiceCallNotConfigured;
        });
        return;
      }

      // Recreate client to ensure clean state
      _client?.dispose();
      _client = _buildConversationClient();

      // Start session - SDK handles signed URL internally with agentId
      await _client
          ?.startSession(
            agentId: agentIdForSelectedVoice,
            userId: 'profile_$_currentProfileId',
            dynamicVariables: dynamicVariables,
          )
          .timeout(_connectTimeout);

      // Only start usage tracking AFTER successful connection
      // (onConnect callback will fire, but we track here for safety)
      _callSessionId = await _usageService.startVoiceCallSession(
        profileId: _currentProfileId!,
        isPremium: _isPremium,
      );
    } catch (e) {
      debugPrint('ElevenLabs call start failed: $e');

      try {
        await _client?.endSession();
      } catch (_) {}

      // End usage tracking if it was started
      await _finalizeUsageSession(endReason: 'connection_failed');

      _setStateIfMounted(() {
        _isConnecting = false;
        _error = e is TimeoutException
            ? AppLocalizations.of(context)!.voiceCallConnectionTimedOut
            : AppLocalizations.of(context)!.voiceCallConnectionFailed;
      });
    }
  }

  Future<void> _toggleMute() async {
    if (!_isConnected) return;

    try {
      if (_isPaused) {
        await _client?.setMicMuted(false);
      } else {
        await _client?.setMicMuted(true);
      }
      _setStateIfMounted(() => _isPaused = !_isPaused);
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  Future<void> _closeCall({String reason = 'user_closed'}) async {
    if (_isClosing) return;
    _isClosing = true;
    _pendingEndReason = reason;
    _callTimer?.cancel();

    _setStateIfMounted(() {
      _isConnected = false;
      _isConnecting = false;
    });

    try {
      await _client?.endSession();
    } catch (e) {
      debugPrint('Error ending session: $e');
    }

    // Deactivate audio session
    await _deactivateAudioSession();

    // End usage tracking session
    await _finalizeUsageSession(endReason: reason);

    _pendingEndReason = null;
    _isClosing = false;

    // Automatically save transcript when present.
    if (_transcript.isNotEmpty && mounted) {
      await _saveTranscriptAndExit();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveTranscriptAndExit() async {
    _setStateIfMounted(() => _isSavingTranscript = true);
    final conversationId = await _saveTranscriptAsConversation();
    _setStateIfMounted(() => _isSavingTranscript = false);

    if (!mounted) return;

    if (conversationId != null) {
      Navigator.of(context).pop(conversationId);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context)!.voiceCallTranscriptSaveFailed),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<int?> _saveTranscriptAsConversation() async {
    if (_transcript.isEmpty) return null;

    try {
      final now = DateTime.now();

      // Create conversation
      final conversationData = {
        'title': AppLocalizations.of(context)!
            .voiceCallConversationTitle(_formatDateTime(now)),
        'is_pinned': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'profile_id': _currentProfileId,
      };

      final conversationId =
          await _databaseService.insertConversation(conversationData);

      // Insert all transcript entries as messages
      for (final entry in _transcript) {
        final message = ChatMessage(
          message: entry.text,
          isUserMessage: entry.isUser,
          timestamp: entry.timestamp.toIso8601String(),
          profileId: _currentProfileId,
          conversationId: conversationId,
        );
        await _databaseService.insertChatMessage(message);
      }

      return conversationId;
    } catch (e) {
      debugPrint('Error saving transcript: $e');
      return null;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  DateTime _nextWeeklyResetDateTime() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return startOfWeek.add(const Duration(days: 7));
  }

  String _formatResetDateTime(DateTime dt) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekdayNames[dt.weekday - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayName ${dt.month}/${dt.day}, $hour:$minute $period';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orbPulseController.dispose();
    _callTimer?.cancel();

    _pendingEndReason ??= 'disposed';
    unawaited(_finalizeUsageSession(endReason: _pendingEndReason!));

    _client?.dispose();
    super.dispose();
  }

  void _navigateToSubscription() {
    Navigator.of(context).pop(); // Close call screen
    Navigator.of(context).pushNamed('/subscription');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final isBlocked = _allowance != null && !_allowance!.allowed;
    final showStartButton = !_isConnected && !_isConnecting && !isBlocked;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final orbSize = isCompact ? 160.0 : 200.0;
    final verticalGap = isCompact ? 24.0 : 40.0;
    final canSwitchVoice = !_isConnected && !_isConnecting;
    final maleVoiceConfigured =
        _agentService.isConfiguredForVoice(voice: ElevenLabsVoicePreset.male);
    final femaleVoiceConfigured =
        _agentService.isConfiguredForVoice(voice: ElevenLabsVoicePreset.female);
    final blockedResetText =
        '${l10n.usageReset}: ${_formatResetDateTime(_nextWeeklyResetDateTime())}';
    final statusText = _currentTranscript ??
        (_isSavingTranscript
            ? l10n.voiceCallSavingTranscript
            : _isPaused
                ? l10n.voiceCallMicMuted
                : _isConnected
                    ? (_isAssistantSpeaking
                        ? l10n.voiceCallAiSpeaking
                        : l10n.listening)
                    : (_isConnecting
                        ? l10n.voiceCallConnecting
                        : (isBlocked
                            ? l10n.voiceCallLimitReached
                            : l10n.voiceCallTapToStart)));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => _closeCall(reason: 'back_button'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                l10n.voiceCallFeatureTitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_isConnected)
            IconButton(
              icon: Icon(
                _isPaused ? Icons.mic_off : Icons.mic,
                color: _isPaused
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
              ),
              onPressed: _toggleMute,
              tooltip: _isPaused ? l10n.voiceCallUnmute : l10n.voiceCallMute,
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Call duration / remaining time
                      if (_isConnected) ...[
                        Text(
                          l10n.voiceCallTimeRemaining(
                            _formatDuration(_maxCallSeconds - _elapsedSeconds),
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: (_maxCallSeconds - _elapsedSeconds) <= 60
                                ? Colors.orange
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.voiceCallElapsed(
                              _formatDuration(_elapsedSeconds)),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ] else if (_allowance != null && !_isConnecting) ...[
                        // Show quota info before call
                        Text(
                          _isPremium ? l10n.premium : l10n.voiceCallFreeTier,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isPremium
                                ? Colors.amber
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.voiceCallAvailableToday(
                              _allowance!.remainingTodayFormatted),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],

                      if (!_isConnected) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Voice',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              label: const Text('Male'),
                              selected:
                                  _selectedVoice == ElevenLabsVoicePreset.male,
                              onSelected: canSwitchVoice && maleVoiceConfigured
                                  ? (_) {
                                      setState(() {
                                        _selectedVoice =
                                            ElevenLabsVoicePreset.male;
                                      });
                                    }
                                  : null,
                            ),
                            ChoiceChip(
                              label: const Text('Female'),
                              selected: _selectedVoice ==
                                  ElevenLabsVoicePreset.female,
                              onSelected:
                                  canSwitchVoice && femaleVoiceConfigured
                                      ? (_) {
                                          setState(() {
                                            _selectedVoice =
                                                ElevenLabsVoicePreset.female;
                                          });
                                        }
                                      : null,
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: verticalGap),

                      // Animated orb / call button
                      AnimatedBuilder(
                        animation: _orbPulseController,
                        builder: (context, child) {
                          final t = _orbPulseController.value;
                          final pulseScale =
                              showStartButton ? (1.0 + (t * 0.08)) : 1.0;
                          final glowOpacity = showStartButton
                              ? (0.15 + (t * 0.2))
                              : (isBlocked ? 0.05 : 0.1);
                          final orbColor =
                              isBlocked ? Colors.grey : primaryColor;

                          return GestureDetector(
                            onTap: showStartButton ? _startCall : null,
                            child: Container(
                              width: orbSize,
                              height: orbSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: orbColor.withOpacity(glowOpacity),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Transform.scale(
                                scale: pulseScale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      center: const Alignment(-0.3, -0.3),
                                      radius: 1.0,
                                      colors: _isConnected
                                          ? [
                                              primaryColor.withOpacity(0.8),
                                              primaryColor,
                                              primaryColor.withOpacity(0.9),
                                            ]
                                          : isBlocked
                                              ? [
                                                  Colors.grey.shade300,
                                                  Colors.grey.shade400,
                                                  Colors.grey.shade500,
                                                ]
                                              : [
                                                  Colors.white,
                                                  primaryColor.withOpacity(0.3),
                                                  primaryColor.withOpacity(0.6),
                                                ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: orbColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isConnected
                                              ? (_isAssistantSpeaking
                                                  ? Icons.volume_up
                                                  : Icons.hearing)
                                              : isBlocked
                                                  ? Icons.block
                                                  : Icons.phone,
                                          size: isCompact ? 40 : 48,
                                          color: _isConnected
                                              ? Colors.white
                                              : (isBlocked
                                                  ? Colors.grey.shade600
                                                  : primaryColor),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _isConnecting
                                              ? l10n.voiceCallCalling
                                              : _isConnected
                                                  ? l10n.voiceCallConnected
                                                  : isBlocked
                                                      ? l10n
                                                          .voiceCallLimitReached
                                                      : l10n.speakButtonLabel,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isBlocked
                                                ? (isCompact ? 16 : 18)
                                                : (isCompact ? 18 : 20),
                                            fontWeight: FontWeight.bold,
                                            color: _isConnected
                                                ? Colors.white
                                                : (isBlocked
                                                    ? Colors.grey.shade600
                                                    : primaryColor),
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

                      SizedBox(height: verticalGap),

                      // Transcript / status display
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 150),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Error message
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Blocked message and upgrade button
                      if (isBlocked) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              Text(
                                l10n.voiceCallLimitReached,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.orange.shade300
                                      : Colors.orange.shade700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                blockedResetText,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        if (!_isPremium) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _navigateToSubscription,
                            icon: const Icon(Icons.star),
                            label: Text(l10n.voiceCallUpgradePrompt),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ],
                      ],

                      SizedBox(height: verticalGap),

                      // Saving indicator
                      if (_isSavingTranscript)
                        const CircularProgressIndicator(),

                      // End call button (when connected)
                      if (_isConnected)
                        FilledButton.icon(
                          onPressed: () => _closeCall(),
                          icon: const Icon(Icons.call_end),
                          label: Text(l10n.voiceCallEndCall),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
