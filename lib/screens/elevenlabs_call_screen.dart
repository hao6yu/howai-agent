import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/agent/agent_action_contracts.dart';
import '../core/theme/howai_theme.dart';
import '../models/chat_message.dart';
import '../providers/profile_provider.dart';
import '../services/database_service.dart';
import '../services/device_timezone_service.dart';
import '../services/elevenlabs_voice_session_service.dart';
import '../services/openai_realtime_voice_service.dart';
import '../services/personal_memory_service.dart';
import '../services/reminder_service.dart';
import '../services/subscription_service.dart';
import '../services/voice_action_approval.dart';
import '../services/voice_session_service.dart';
import '../services/voice_call_usage_service.dart';
import '../services/voice_web_search_service.dart';
import '../services/vision_frame_encoder.dart';

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

/// Full-screen provider-neutral voice call screen.
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
  final DatabaseService _databaseService = DatabaseService();
  final VoiceCallUsageService _usageService = VoiceCallUsageService();
  final ReminderService _reminderService = ReminderService();
  final VoiceWebSearchService _voiceWebSearchService = VoiceWebSearchService();
  VoiceSessionService? _voiceSessionService;
  VoiceSessionProvider? _activeProvider;

  // Transcript collection
  final List<_TranscriptEntry> _transcript = [];
  String? _currentTranscript;
  final Set<String> _seenFinalTranscriptEventIds = <String>{};

  // Animation
  late final AnimationController _orbPulseController;

  // Profile & subscription
  int? _currentProfileId;
  String _currentProfileName = 'there';
  String _selectedVoice = 'marin';
  bool _isPremium = false;
  bool _initialized = false;
  bool _preferenceLoadScheduled = false;
  bool _forceBackupProvider = false;
  bool _showBackupOption = false;

  // Camera vision
  CameraController? _cameraController;
  List<CameraDescription> _cameras = const [];
  int _selectedCameraIndex = 0;
  bool _visionEnabled = false;
  bool _visionInitializing = false;
  bool _visionCaptureInProgress = false;
  String? _visionError;
  bool _visionNeedsSettings = false;
  DateTime? _lastAutomaticVisionFrameAt;
  int _visionGeneration = 0;
  Completer<Map<String, dynamic>>? _pendingVisionStreamFrame;

  // Shared action approval
  ActionProposal? _pendingVoiceProposal;
  VoiceToolCall? _pendingVoiceToolCall;
  int? _pendingProposalSpeechTurnCount;
  bool _isActionBusy = false;
  int _userSpeechTurnCount = 0;

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

    if (!_preferenceLoadScheduled) {
      _preferenceLoadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadVoicePreference());
      });
    }
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVoice = prefs.getString('realtime_voice_name');
    if (savedVoice == 'marin' || savedVoice == 'cedar') {
      _selectedVoice = savedVoice!;
    }
    if (!mounted) return;
    setState(() {});
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
      unawaited(_suspendVisionCamera());
      return;
    }

    if (state == AppLifecycleState.resumed && _wentBackgroundAt != null) {
      final backgroundSeconds =
          DateTime.now().difference(_wentBackgroundAt!).inSeconds;
      _wentBackgroundAt = null;
      // End call if backgrounded for more than 30 seconds
      if (_isConnected && backgroundSeconds > 30) {
        _closeCall(reason: 'background_timeout');
      } else if (_visionEnabled) {
        unawaited(_initializeVisionCamera());
      }
    }
  }

  VoiceSessionCallbacks _voiceCallbacks() {
    return VoiceSessionCallbacks(
      onConnected: () {
        _setStateIfMounted(() {
          _isConnected = true;
          _isConnecting = false;
          _error = null;
          _showBackupOption = false;
        });
        _startCallTimer();
      },
      onDisconnected: (reason) {
        _setStateIfMounted(() {
          _isConnected = false;
          _isConnecting = false;
        });
        _callTimer?.cancel();
        if (!_isClosing) {
          unawaited(_handleUnexpectedDisconnect(reason));
        }
      },
      onUserSpeechStarted: () {
        _userSpeechTurnCount += 1;
        if (_visionEnabled && _isConnected && !_isAssistantSpeaking) {
          unawaited(_shareVisionFrame(requestResponse: false));
        }
      },
      onTranscript: (update) {
        if (update.text.trim().isEmpty) return;
        if (update.isFinal) {
          _appendTranscriptEntry(
            text: update.text,
            isUser: update.isUser,
            transcriptEventId: update.eventId,
          );
        }
        _setStateIfMounted(() {
          _currentTranscript = update.text;
          if (!update.isUser) {
            _isAssistantSpeaking = !update.isFinal;
          }
        });
      },
      onSpeakingChanged: (speaking) {
        _setStateIfMounted(() => _isAssistantSpeaking = speaking);
      },
      onError: (message) {
        debugPrint('Voice session error: $message');
        _setStateIfMounted(() {
          _error = AppLocalizations.of(context)!.voiceCallConnectionIssue;
          _isConnecting = false;
        });
      },
      onToolCall: _handleVoiceToolCall,
    );
  }

  Future<void> _handleUnexpectedDisconnect(String reason) async {
    await _finalizeUsageSession(endReason: reason);
    await _deactivateAudioSession();
    if (!mounted) return;
    setState(() {
      _error = AppLocalizations.of(context)!.voiceCallConnectionIssue;
      _showBackupOption =
          _activeProvider == VoiceSessionProvider.openAIRealtime;
    });
  }

  void _setStateIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  bool _appendTranscriptEntry({
    required String text,
    required bool isUser,
    String? transcriptEventId,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) return false;

    if (transcriptEventId != null) {
      if (!_seenFinalTranscriptEventIds.add(transcriptEventId)) {
        return false;
      }
    }

    final now = DateTime.now();
    if (_transcript.isNotEmpty) {
      final last = _transcript.last;
      final isDuplicateOfLast = last.isUser == isUser &&
          last.text.toLowerCase() == normalized.toLowerCase() &&
          now.difference(last.timestamp).inSeconds <= 2;
      if (isDuplicateOfLast) {
        return false;
      }
    }

    _transcript.add(_TranscriptEntry(
      text: normalized,
      isUser: isUser,
      timestamp: now,
    ));
    return true;
  }

  Future<void> _handleVoiceToolCall(VoiceToolCall call) async {
    if (call.name == VoiceWebSearchService.toolName) {
      await _handleVoiceWebSearch(call);
      return;
    }

    final approvalCommand = parseVoicePendingActionCommand(call);
    if (approvalCommand != null) {
      final pendingCall = _pendingVoiceToolCall;
      if (_pendingVoiceProposal == null || pendingCall == null) {
        await _sendVoiceToolResult(
          call.callId,
          const {
            'status': 'failed',
            'message': 'There is no pending action to review.',
          },
        );
        return;
      }
      if (approvalCommand.proposalId != pendingCall.callId) {
        await _sendVoiceToolResult(
          call.callId,
          const {
            'status': 'failed',
            'message':
                'That confirmation does not match the pending action. Ask the user to review it again.',
          },
        );
        return;
      }
      if (_isActionBusy) {
        await _sendVoiceToolResult(
          call.callId,
          const {
            'status': 'failed',
            'message': 'The pending action is already being processed.',
          },
        );
        return;
      }
      final pendingTurnCount = _pendingProposalSpeechTurnCount;
      if (!hasNewUserTurnForPendingAction(
        pendingAtUserTurn: pendingTurnCount,
        currentUserTurn: _userSpeechTurnCount,
      )) {
        await _sendVoiceToolResult(
          call.callId,
          const {
            'status': 'failed',
            'message':
                'Wait for a new, explicit user response before confirming or canceling the pending action.',
          },
        );
        return;
      }
      await _decideVoiceProposal(
        approvalCommand.decision == VoicePendingActionDecision.approve
            ? AgentActionDecision.approved
            : AgentActionDecision.rejected,
        responseCallId: call.callId,
        isRevision: approvalCommand.isRevision,
      );
      return;
    }

    if (_pendingVoiceProposal != null) {
      await _sendVoiceToolResult(
        call.callId,
        const {
          'status': 'failed',
          'message': 'Finish reviewing the current action first.',
        },
      );
      return;
    }

    try {
      final proposal = await _reminderService.proposeToolCall(
        {
          'name': call.name,
          'arguments': call.arguments,
          'call_id': call.callId,
        },
        origin: AgentActionOrigin.voice,
      );
      _setStateIfMounted(() {
        _pendingVoiceProposal = proposal;
        _pendingVoiceToolCall = call;
        _pendingProposalSpeechTurnCount = _userSpeechTurnCount;
        _currentTranscript =
            'Review the proposed action below before it becomes active.';
      });
      await _sendVoiceToolResult(
        call.callId,
        {
          'status': 'awaiting_confirmation',
          'proposal_id': call.callId,
          'summary': proposal.summary,
          'message':
              'Briefly repeat the proposal and ask the user to confirm, cancel, or revise it by voice.',
        },
      );
    } catch (error) {
      await _sendVoiceToolResult(
        call.callId,
        {
          'status': 'failed',
          'message': error is ReminderServiceException
              ? error.message
              : 'The action proposal could not be prepared.',
        },
      );
    }
  }

  Future<void> _handleVoiceWebSearch(VoiceToolCall call) async {
    final query = call.arguments['query']?.toString().trim() ?? '';
    if (query.isEmpty) {
      await _sendVoiceToolResult(
        call.callId,
        const {
          'status': 'failed',
          'message': 'Ask the user for a more specific search question.',
        },
      );
      return;
    }

    _setStateIfMounted(() {
      _currentTranscript = 'Searching the live web…';
    });
    try {
      final timezone = await DeviceTimezoneService.currentIdentifier();
      final result = await _voiceWebSearchService.search(
        query: query,
        timezone: timezone,
      );
      await _sendVoiceToolResult(
        call.callId,
        {
          'status': 'succeeded',
          'answer': result.answer,
          'source_names': result.sourceNames,
          'message':
              'Answer the user directly and concisely from this verified result. Mention source names naturally when useful, but never speak URLs or citation syntax.',
        },
      );
    } on VoiceWebSearchException catch (error) {
      await _sendVoiceToolResult(
        call.callId,
        {
          'status': 'unavailable',
          'message': error.message,
        },
      );
    } catch (error) {
      debugPrint('Voice live search failed: $error');
      await _sendVoiceToolResult(
        call.callId,
        const {
          'status': 'unavailable',
          'message': 'Live search is temporarily unavailable.',
        },
      );
    }
  }

  Future<bool> _sendVoiceToolResult(
    String callId,
    Map<String, dynamic> result,
  ) async {
    try {
      await _voiceSessionService?.sendToolResult(
        callId: callId,
        result: result,
      );
      return true;
    } catch (error) {
      debugPrint('Could not return voice tool result: $error');
      _setStateIfMounted(() {
        _error = AppLocalizations.of(context)!.voiceCallConnectionIssue;
      });
      return false;
    }
  }

  Future<void> _decideVoiceProposal(
    AgentActionDecision decision, {
    String? responseCallId,
    bool isRevision = false,
  }) async {
    final proposal = _pendingVoiceProposal;
    final toolCall = _pendingVoiceToolCall;
    if (proposal == null || toolCall == null || _isActionBusy) return;

    _setStateIfMounted(() => _isActionBusy = true);
    try {
      final result = await _reminderService.decide(
        proposal: proposal,
        decision: decision,
        channel: AgentActionOrigin.voice,
      );
      final toolResult = decision == AgentActionDecision.rejected
          ? <String, dynamic>{
              'status': isRevision ? 'revision_requested' : 'rejected',
              'message': isRevision
                  ? 'The pending proposal was canceled. Prepare a corrected proposal using the user’s requested changes.'
                  : 'The pending proposal was canceled.',
            }
          : <String, dynamic>{
              'status': result?.isSuccess == true ? 'succeeded' : 'failed',
              'message': result?.displayMessage ??
                  'The action could not be completed.',
              'resource_type': result?.resourceType,
              'resource_id': result?.resourceId,
            };
      _setStateIfMounted(() {
        _pendingVoiceProposal = null;
        _pendingVoiceToolCall = null;
        _pendingProposalSpeechTurnCount = null;
        _currentTranscript = decision == AgentActionDecision.rejected
            ? (isRevision ? 'Let’s update that.' : 'Action canceled.')
            : result?.displayMessage;
      });
      if (responseCallId != null) {
        await _sendVoiceToolResult(responseCallId, toolResult);
      } else {
        await _voiceSessionService?.sendConversationEvent(
          message: decision == AgentActionDecision.rejected
              ? (isRevision
                  ? 'The user tapped to revise the pending action. The old proposal is canceled.'
                  : 'The user tapped Cancel. The pending action is canceled.')
              : 'The user tapped to approve the pending action. Result: ${toolResult['message']}',
        );
      }
    } catch (error) {
      _setStateIfMounted(() {
        _error = error.toString();
      });
    } finally {
      _setStateIfMounted(() => _isActionBusy = false);
    }
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
    final l10n = AppLocalizations.of(context)!;

    // Check profile
    if (_currentProfileId == null) {
      _setStateIfMounted(() {
        _error = l10n.voiceCallSelectProfileFirst;
      });
      return;
    }

    _setStateIfMounted(() {
      _isConnecting = true;
      _error = null;
      _showBackupOption = false;
      _transcript.clear();
      _seenFinalTranscriptEventIds.clear();
      _currentTranscript = null;
      _pendingVoiceProposal = null;
      _pendingVoiceToolCall = null;
      _pendingProposalSpeechTurnCount = null;
      _isPaused = false;
      _elapsedSeconds = 0;
      _userSpeechTurnCount = 0;
      _maxCallSeconds =
          VoiceCallLimits.forTier(isPremium: _isPremium).perCallSeconds;
    });

    try {
      final profile = await _databaseService.getProfile(_currentProfileId!);
      final resolvedProfileName = (profile?.name ?? _currentProfileName).trim();
      final userName =
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

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        String errorMessage;
        if (status == PermissionStatus.permanentlyDenied) {
          errorMessage = l10n.voiceCallMicrophoneDeniedPermanently;
          // Optionally open settings
          openAppSettings();
        } else {
          errorMessage = l10n.voiceCallMicrophoneRequired;
        }
        _setStateIfMounted(() {
          _isConnecting = false;
          _error = errorMessage;
        });
        return;
      }

      // Configure and activate the route before WebRTC connects. Changing the
      // audio session after the data channel opens can interrupt the opening
      // greeting that Realtime starts immediately.
      await _configureAudioSession();

      final timezone = await DeviceTimezoneService.currentIdentifier();
      final localDateTime = _localDateTimeForPrompt(DateTime.now());
      final options = VoiceSessionStartOptions(
        voice: _selectedVoice,
        userId:
            _reminderService.currentUser?.id ?? 'profile_$_currentProfileId',
        userName: userName,
        timezone: timezone,
        localDateTime: localDateTime,
        interestTags: interestTags,
        communicationStyle: communicationStyle,
      );
      await _connectVoiceSession(options);

      final service = _voiceSessionService;
      if (service is OpenAIRealtimeVoiceService) {
        _isPremium = service.isPaid;
        _maxCallSeconds = service.maxDurationSeconds;
      } else {
        await _loadAllowance();
        if (_allowance != null) {
          _maxCallSeconds = _allowance!.remainingForThisCallSeconds;
        }
      }

      // Only start usage tracking AFTER successful connection
      _callSessionId = await _usageService.startVoiceCallSession(
        profileId: _currentProfileId!,
        isPremium: _isPremium,
      );
      _setStateIfMounted(() {});
    } catch (e) {
      debugPrint('Voice call start failed: $e');
      await _voiceSessionService?.dispose();
      _voiceSessionService = null;
      _activeProvider = null;
      await _deactivateAudioSession();

      // End usage tracking if it was started
      await _finalizeUsageSession(endReason: 'connection_failed');

      _setStateIfMounted(() {
        _isConnecting = false;
        _error = e is VoiceSessionException
            ? e.message
            : e is TimeoutException
                ? l10n.voiceCallConnectionTimedOut
                : l10n.voiceCallConnectionFailed;
        _showBackupOption = e is VoiceSessionException && !e.fallbackAllowed;
      });
    }
  }

  Future<void> _connectVoiceSession(VoiceSessionStartOptions options) async {
    await _voiceSessionService?.dispose();
    final callbacks = _voiceCallbacks();

    if (_forceBackupProvider) {
      final backup = ElevenLabsVoiceSessionService(callbacks: callbacks);
      _voiceSessionService = backup;
      _activeProvider = backup.provider;
      await backup.connect(options).timeout(_connectTimeout);
      return;
    }

    final realtime = OpenAIRealtimeVoiceService(callbacks: callbacks);
    _voiceSessionService = realtime;
    _activeProvider = realtime.provider;
    try {
      await realtime.connect(options);
    } on VoiceSessionException catch (error) {
      if (!error.fallbackAllowed) rethrow;
      await realtime.dispose();
      final backup = ElevenLabsVoiceSessionService(callbacks: callbacks);
      _voiceSessionService = backup;
      _activeProvider = backup.provider;
      await backup.connect(options).timeout(_connectTimeout);
    }
  }

  String _localDateTimeForPrompt(DateTime value) {
    String two(int part) => part.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  Future<void> _startWithBackupProvider() async {
    _forceBackupProvider = true;
    _showBackupOption = false;
    await _startCall();
  }

  Future<void> _selectVoiceForNextCall(String voice) async {
    if (voice != 'marin' && voice != 'cedar') return;
    final changedDuringCall = _isConnected || _isConnecting;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('realtime_voice_name', voice);
    if (!mounted) return;
    setState(() => _selectedVoice = voice);
    Navigator.of(context).pop();
    if (changedDuringCall) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${voice == 'marin' ? 'Marin' : 'Cedar'} will be used on your next call.',
          ),
        ),
      );
    }
  }

  void _showVoiceOptions() {
    final theme = Theme.of(context);
    final colors = theme.extension<HowAIColors>() ??
        (theme.brightness == Brightness.dark
            ? HowAIColors.dark
            : HowAIColors.light);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: colors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isConnected || _isConnecting
                      ? 'Changes apply to your next call.'
                      : 'Choose how HowAI sounds.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _VoiceOptionTile(
                  label: 'Marin',
                  description: 'Warm and natural',
                  selected: _selectedVoice == 'marin',
                  onTap: () => unawaited(_selectVoiceForNextCall('marin')),
                ),
                const SizedBox(height: 8),
                _VoiceOptionTile(
                  label: 'Cedar',
                  description: 'Clear and grounded',
                  selected: _selectedVoice == 'cedar',
                  onTap: () => unawaited(_selectVoiceForNextCall('cedar')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleVision() async {
    if (_visionEnabled) {
      await _disableVision();
      return;
    }

    if (_visionInitializing) return;

    if (_isConnected && _voiceSessionService?.supportsVision != true) {
      _setStateIfMounted(() {
        _visionError =
            'Vision requires HowAI Realtime voice. End this backup call and start a new one to use the camera.';
        _visionNeedsSettings = false;
      });
      return;
    }

    _setStateIfMounted(() {
      _visionEnabled = true;
      _visionGeneration += 1;
      _visionError = null;
      _visionNeedsSettings = false;
    });
    await _initializeVisionCamera();
  }

  Future<void> _initializeVisionCamera({int? cameraIndex}) async {
    if (!_visionEnabled || _visionInitializing) return;
    _setStateIfMounted(() {
      _visionInitializing = true;
      _visionError = null;
      _visionNeedsSettings = false;
    });

    try {
      final cameras = _cameras.isEmpty ? await availableCameras() : _cameras;
      if (cameras.isEmpty) {
        throw CameraException(
          'camera_unavailable',
          'No camera is available on this device.',
        );
      }
      _cameras = cameras;
      final preferredIndex = cameraIndex ??
          (_cameraController == null
              ? cameras.indexWhere(
                  (camera) => camera.lensDirection == CameraLensDirection.back,
                )
              : _selectedCameraIndex);
      _selectedCameraIndex =
          preferredIndex >= 0 && preferredIndex < cameras.length
              ? preferredIndex
              : 0;

      final previousController = _cameraController;
      _cameraController = null;
      await previousController?.dispose();

      final controller = CameraController(
        cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      // Vision should feel like a live camera, never a still-photo capture.
      // Explicitly keep the torch/flash off for both preview and sampled frames.
      await controller.setFlashMode(FlashMode.off);
      if (!_visionEnabled || !mounted) {
        await controller.dispose();
        return;
      }
      _cameraController = controller;
      await controller.startImageStream(_handleVisionStreamFrame);
      _setStateIfMounted(() {});
    } on CameraException catch (error) {
      debugPrint('Could not initialize voice vision: ${error.code}');
      final needsSettings = error.code == 'CameraAccessDeniedWithoutPrompt' ||
          error.code == 'CameraAccessRestricted';
      _setStateIfMounted(() {
        _visionEnabled = false;
        _visionGeneration += 1;
        _visionNeedsSettings = needsSettings;
        _visionError = switch (error.code) {
          'CameraAccessDenied' =>
            'Camera access was not granted. Turn it on when you want to use vision.',
          'CameraAccessDeniedWithoutPrompt' =>
            'Camera access is off. Enable it in Settings to use voice vision.',
          'CameraAccessRestricted' =>
            'Camera access is restricted on this device.',
          _ => 'The camera could not start. Please try again.',
        };
      });
      await _suspendVisionCamera();
    } catch (error) {
      debugPrint('Could not initialize voice vision: $error');
      _setStateIfMounted(() {
        _visionEnabled = false;
        _visionGeneration += 1;
        _visionNeedsSettings = false;
        _visionError = 'The camera could not start. Please try again.';
      });
      await _suspendVisionCamera();
    } finally {
      _setStateIfMounted(() => _visionInitializing = false);
    }
  }

  Future<void> _suspendVisionCamera() async {
    final pendingFrame = _pendingVisionStreamFrame;
    _pendingVisionStreamFrame = null;
    if (pendingFrame != null && !pendingFrame.isCompleted) {
      pendingFrame.completeError(
        StateError('The camera stream was stopped'),
      );
    }
    final controller = _cameraController;
    _cameraController = null;
    try {
      await controller?.dispose();
    } catch (_) {}
  }

  Future<void> _disableVision() async {
    _setStateIfMounted(() {
      _visionEnabled = false;
      _visionInitializing = false;
      _visionCaptureInProgress = false;
      _visionError = null;
      _visionNeedsSettings = false;
      _lastAutomaticVisionFrameAt = null;
      _visionGeneration += 1;
    });
    await _suspendVisionCamera();
  }

  Future<void> _switchVisionCamera() async {
    if (_cameras.length < 2 ||
        _visionInitializing ||
        _visionCaptureInProgress) {
      return;
    }
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeVisionCamera(cameraIndex: nextIndex);
  }

  void _handleVisionStreamFrame(CameraImage image) {
    final completer = _pendingVisionStreamFrame;
    final controller = _cameraController;
    if (completer == null || completer.isCompleted || controller == null) {
      return;
    }
    _pendingVisionStreamFrame = null;
    try {
      completer.complete({
        'width': image.width,
        'height': image.height,
        'format': image.format.group.name,
        'rotation': _visionFrameRotation(controller),
        'mirror':
            controller.description.lensDirection == CameraLensDirection.front,
        'planes': image.planes
            .map(
              (plane) => {
                // Camera plugins may reuse their native buffers after this
                // callback, so copy only the single frame we actually need.
                'bytes': Uint8List.fromList(plane.bytes),
                'bytesPerRow': plane.bytesPerRow,
                'bytesPerPixel': plane.bytesPerPixel ?? 1,
              },
            )
            .toList(growable: false),
      });
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }
  }

  int _visionFrameRotation(CameraController controller) {
    final deviceDegrees = switch (controller.value.deviceOrientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeLeft => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeRight => 270,
    };
    final sensorDegrees = controller.description.sensorOrientation;
    if (controller.description.lensDirection == CameraLensDirection.front) {
      return (sensorDegrees + deviceDegrees) % 360;
    }
    return (sensorDegrees - deviceDegrees + 360) % 360;
  }

  Future<Map<String, dynamic>> _nextVisionStreamFrame(
    CameraController controller,
  ) {
    if (!controller.value.isStreamingImages) {
      throw StateError('The live camera stream is not ready');
    }
    final existing = _pendingVisionStreamFrame;
    if (existing != null && !existing.isCompleted) {
      return existing.future;
    }
    final completer = Completer<Map<String, dynamic>>();
    _pendingVisionStreamFrame = completer;
    return completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        if (identical(_pendingVisionStreamFrame, completer)) {
          _pendingVisionStreamFrame = null;
        }
        throw TimeoutException('Timed out waiting for a live camera frame');
      },
    );
  }

  Future<void> _shareVisionFrame({
    required bool requestResponse,
  }) async {
    if (!_visionEnabled || _visionCaptureInProgress || !_isConnected) return;
    final service = _voiceSessionService;
    final controller = _cameraController;
    if (service == null || !service.supportsVision) return;
    if (controller == null || !controller.value.isInitialized) return;

    final now = DateTime.now();
    final generation = _visionGeneration;
    if (!requestResponse &&
        _lastAutomaticVisionFrameAt != null &&
        now.difference(_lastAutomaticVisionFrameAt!) <
            const Duration(seconds: 2)) {
      return;
    }

    _setStateIfMounted(() {
      _visionCaptureInProgress = true;
      _visionError = null;
    });
    try {
      final rawFrame = await _nextVisionStreamFrame(controller);
      final bytes = await compute(encodeVisionStreamFrame, rawFrame);
      if (!_visionEnabled ||
          !_isConnected ||
          generation != _visionGeneration ||
          service != _voiceSessionService) {
        return;
      }
      await service.sendImageFrame(
        bytes: bytes,
        message: requestResponse
            ? 'The user deliberately shared this current camera frame. Respond to what is visible and relevant. If their intent is unclear, briefly describe the key visible content and ask how you can help.'
            : null,
        requestResponse: requestResponse,
      );
      if (!requestResponse) {
        _lastAutomaticVisionFrameAt = now;
      } else {
        _setStateIfMounted(() {
          _currentTranscript = 'Looking at what you shared…';
        });
      }
    } catch (error) {
      debugPrint('Could not share voice vision frame: $error');
      _setStateIfMounted(() {
        _visionError =
            'I could not read that frame. Hold the camera steady and try again.';
      });
    } finally {
      _setStateIfMounted(() => _visionCaptureInProgress = false);
    }
  }

  Future<void> _toggleMute() async {
    if (!_isConnected) return;

    try {
      await _voiceSessionService?.setMuted(!_isPaused);
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
      await _voiceSessionService?.disconnect(reason: reason);
      await _voiceSessionService?.dispose();
      _voiceSessionService = null;
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
      final userTurns = _transcript.where((entry) => entry.isUser).length;
      if (_isPremium && userTurns >= 5 && _currentProfileId != null) {
        final memoryMessages = _transcript
            .map((entry) => <String, String>{
                  'role': entry.isUser ? 'user' : 'assistant',
                  'content': entry.text,
                })
            .toList(growable: false);
        unawaited(PersonalMemoryService().learnFromConversation(
          source: MemoryLearningSource.voice,
          sourceId: conversationId.toString(),
          profileId: _currentProfileId!,
          messages: memoryMessages,
        ));
      }
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

  Widget _buildVisionChoiceTile({
    required ThemeData theme,
    required HowAIColors colors,
  }) {
    final canChange = !_visionInitializing && !_isConnecting;
    return Semantics(
      button: true,
      toggled: _visionEnabled,
      label: 'Camera vision',
      hint:
          'Optional beta feature. Double tap to turn camera vision on or off.',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canChange ? () => unawaited(_toggleVision()) : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: colors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Camera vision',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'BETA',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_visionInitializing)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    ExcludeSemantics(
                      child: Switch.adaptive(
                        value: _visionEnabled,
                        onChanged: canChange
                            ? (_) => unawaited(_toggleVision())
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionCameraStage({
    required HowAIColors colors,
    required double height,
  }) {
    final controller = _cameraController;
    final initialized = controller?.value.isInitialized == true;
    Widget preview;
    if (_visionInitializing || !initialized) {
      preview = ColoredBox(
        color: colors.surface,
        child: Center(
          child: _visionInitializing
              ? const CircularProgressIndicator()
              : Icon(
                  Icons.videocam_off_outlined,
                  size: 42,
                  color: colors.textTertiary,
                ),
        ),
      );
    } else {
      final previewSize = controller!.value.previewSize;
      preview = previewSize == null
          ? CameraPreview(controller)
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            );
    }

    return Semantics(
      container: true,
      label: 'Live camera preview for HowAI voice vision.',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.divider),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              preview,
              if (_isConnected)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.48),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _formatDuration(_elapsedSeconds),
                      style: TextStyle(
                        color: (_maxCallSeconds - _elapsedSeconds) <= 60
                            ? const Color(0xFFFF8A80)
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              if (_cameras.length > 1)
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton.filledTonal(
                    tooltip: 'Switch camera',
                    onPressed: _visionInitializing || _visionCaptureInProgress
                        ? null
                        : () => unawaited(_switchVisionCamera()),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.48),
                    ),
                    icon: const Icon(Icons.cameraswitch_rounded),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orbPulseController.dispose();
    _callTimer?.cancel();

    _pendingEndReason ??= 'disposed';
    unawaited(_finalizeUsageSession(endReason: _pendingEndReason!));

    unawaited(_voiceSessionService?.dispose() ?? Future<void>.value());
    unawaited(_cameraController?.dispose() ?? Future<void>.value());
    _voiceWebSearchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final howaiColors = theme.extension<HowAIColors>() ??
        (isDark ? HowAIColors.dark : HowAIColors.light);
    final primaryColor = howaiColors.accent;

    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final orbSize = isCompact ? 142.0 : 166.0;
    final verticalGap = isCompact ? 14.0 : 20.0;
    final activityLabel = _isSavingTranscript
        ? l10n.voiceCallSavingTranscript
        : _isPaused
            ? l10n.voiceCallMicMuted
            : _isConnected
                ? (_isAssistantSpeaking
                    ? l10n.voiceCallAiSpeaking
                    : l10n.listening)
                : (_isConnecting
                    ? l10n.voiceCallConnecting
                    : (_error == null ? 'Tap to start' : 'Tap to try again'));
    final statusText = _currentTranscript ?? activityLabel;

    return Scaffold(
      backgroundColor: howaiColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _closeCall(reason: 'back_button'),
        ),
        title: const Text(
          'HowAI Voice',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Voice options',
            onPressed: _showVoiceOptions,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final visionHeight = min(
              300.0,
              max(
                200.0,
                constraints.maxHeight *
                    (constraints.maxHeight < 700 ? 0.30 : 0.32),
              ),
            );
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 16 : 24,
                12,
                isCompact ? 16 : 24,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: _visionEnabled
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    SizedBox(height: _isConnected ? 4 : verticalGap),

                    if (!_isConnected) ...[
                      _buildVisionChoiceTile(
                        theme: theme,
                        colors: howaiColors,
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (_visionEnabled) ...[
                      _buildVisionCameraStage(
                        colors: howaiColors,
                        height: visionHeight,
                      ),
                      const SizedBox(height: 12),
                      if (!_isConnected)
                        FilledButton.icon(
                          onPressed: _isConnecting ||
                                  _cameraController?.value.isInitialized != true
                              ? null
                              : () => unawaited(_startCall()),
                          icon: _isConnecting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.mic_rounded),
                          label: Text(
                            _isConnecting ? 'Connecting…' : 'Start voice',
                          ),
                        ),
                    ] else ...[
                      // Animated orb / call button
                      AnimatedBuilder(
                        animation: _orbPulseController,
                        builder: (context, child) {
                          final t = _orbPulseController.value;
                          return _RealtimeVoiceOrb(
                            size: orbSize,
                            animationValue: t,
                            accent: primaryColor,
                            disabled: false,
                            connecting: _isConnecting,
                            connected: _isConnected,
                            assistantSpeaking: _isAssistantSpeaking,
                            muted: _isPaused,
                            onTap: !_isConnected && !_isConnecting
                                ? () => unawaited(_startCall())
                                : null,
                          );
                        },
                      ),
                      SizedBox(height: verticalGap),
                      Text(
                        activityLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _isAssistantSpeaking
                              ? howaiColors.accent
                              : howaiColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!_isConnected && !_isConnecting) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _showVoiceOptions,
                              icon: const Icon(
                                Icons.graphic_eq_rounded,
                                size: 18,
                              ),
                              label: Text(
                                'Voice: ${_selectedVoice == 'marin' ? 'Marin' : 'Cedar'}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    if (_currentTranscript != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: howaiColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: howaiColors.divider),
                        ),
                        child: Text(
                          statusText,
                          maxLines: _pendingVoiceProposal == null ? 4 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: howaiColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    if (_pendingVoiceProposal != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _VoiceApprovalPanel(
                          proposal: _pendingVoiceProposal!,
                          isBusy: _isActionBusy,
                          onApprove: () => unawaited(
                            _decideVoiceProposal(
                              AgentActionDecision.approved,
                            ),
                          ),
                          onReject: () => unawaited(
                            _decideVoiceProposal(
                              AgentActionDecision.rejected,
                            ),
                          ),
                        ),
                      ),

                    // Error message
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    if (_visionError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 460),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: howaiColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _visionError!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: howaiColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_visionNeedsSettings) ...[
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: openAppSettings,
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    if (_showBackupOption && !_forceBackupProvider) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isConnecting
                            ? null
                            : () => unawaited(_startWithBackupProvider()),
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Use backup voice'),
                      ),
                    ],

                    SizedBox(height: verticalGap),

                    // Saving indicator
                    if (_isSavingTranscript) const CircularProgressIndicator(),

                    // End call button (when connected)
                    if (_isConnected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VoiceControlButton(
                            icon: _visionEnabled
                                ? Icons.videocam_rounded
                                : Icons.videocam_outlined,
                            label: _visionEnabled ? 'Vision on' : 'Use camera',
                            foregroundColor: _visionEnabled
                                ? howaiColors.accent
                                : howaiColors.textPrimary,
                            backgroundColor: _visionEnabled
                                ? howaiColors.accentSoft
                                : howaiColors.surface,
                            onTap: () => unawaited(_toggleVision()),
                          ),
                          SizedBox(width: isCompact ? 14 : 22),
                          _VoiceControlButton(
                            icon: _isPaused
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            label: _isPaused
                                ? l10n.voiceCallUnmute
                                : l10n.voiceCallMute,
                            foregroundColor: _isPaused
                                ? howaiColors.danger
                                : howaiColors.textPrimary,
                            backgroundColor: howaiColors.surface,
                            onTap: _toggleMute,
                          ),
                          SizedBox(width: isCompact ? 14 : 22),
                          _VoiceControlButton(
                            icon: Icons.call_end_rounded,
                            label: l10n.voiceCallEndCall,
                            foregroundColor: Colors.white,
                            backgroundColor: howaiColors.danger,
                            onTap: () => _closeCall(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VoiceOptionTile extends StatelessWidget {
  const _VoiceOptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HowAIColors>() ??
        (theme.brightness == Brightness.dark
            ? HowAIColors.dark
            : HowAIColors.light);

    return Semantics(
      button: true,
      selected: selected,
      label: '$label voice',
      child: Material(
        color: selected ? colors.accentSoft : colors.canvas,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? colors.accent : colors.surfaceStrong,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 20,
                    color: selected ? Colors.white : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 21,
                    color: colors.accent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RealtimeVoiceOrb extends StatelessWidget {
  const _RealtimeVoiceOrb({
    required this.size,
    required this.animationValue,
    required this.accent,
    required this.disabled,
    required this.connecting,
    required this.connected,
    required this.assistantSpeaking,
    required this.muted,
    required this.onTap,
  });

  final double size;
  final double animationValue;
  final Color accent;
  final bool disabled;
  final bool connecting;
  final bool connected;
  final bool assistantSpeaking;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HowAIColors>() ??
        (theme.brightness == Brightness.dark
            ? HowAIColors.dark
            : HowAIColors.light);
    final activeAccent = disabled ? colors.textTertiary : accent;
    final pulseStrength = assistantSpeaking
        ? 0.09
        : connected
            ? 0.055
            : 0.035;
    final scale = 0.96 + (animationValue * pulseStrength);

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: connected ? 'HowAI voice is connected' : 'Start HowAI voice',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeAccent.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.82 + (animationValue * pulseStrength * 0.45),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeAccent.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Container(
                width: size * 0.66,
                height: size * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: disabled
                        ? [
                            colors.surfaceStrong,
                            colors.surface,
                          ]
                        : [
                            activeAccent.withValues(alpha: 0.92),
                            activeAccent,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeAccent.withValues(
                        alpha: disabled ? 0.05 : 0.22,
                      ),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: connecting
                      ? const SizedBox.square(
                          dimension: 34,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : muted
                          ? const Icon(
                              Icons.mic_off_rounded,
                              color: Colors.white,
                              size: 36,
                            )
                          : disabled
                              ? Icon(
                                  Icons.lock_outline_rounded,
                                  color: colors.textSecondary,
                                  size: 34,
                                )
                              : _VoiceWaveform(
                                  value: animationValue,
                                  active: connected,
                                  energetic: assistantSpeaking,
                                  color: Colors.white,
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform({
    required this.value,
    required this.active,
    required this.energetic,
    required this.color,
  });

  final double value;
  final bool active;
  final bool energetic;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final amplitude = energetic
        ? 16.0
        : active
            ? 10.0
            : 5.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (index) {
        final wave = (sin((value * pi * 2) + (index * 0.9)) + 1) / 2;
        final base = index.isEven ? 13.0 : 20.0;
        return Container(
          width: 4,
          height: base + (wave * amplitude),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _VoiceApprovalPanel extends StatelessWidget {
  const _VoiceApprovalPanel({
    required this.proposal,
    required this.onApprove,
    required this.onReject,
    required this.isBusy,
  });

  final ActionProposal proposal;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HowAIColors>() ??
        (theme.brightness == Brightness.dark
            ? HowAIColors.dark
            : HowAIColors.light);

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Approval needed. ${proposal.summary}',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notification_add_outlined,
                    size: 19,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Approval needed',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isBusy)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              proposal.summary,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Confirm, revise, or cancel by voice. Buttons remain available as a fallback.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isBusy ? null : onReject,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: isBusy ? null : onApprove,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(88, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceControlButton extends StatelessWidget {
  const _VoiceControlButton({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 58,
                child: Icon(icon, color: foregroundColor, size: 25),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
