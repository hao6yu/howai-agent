import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../providers/profile_provider.dart';
import '../services/database_service.dart';
import '../services/elevenlabs_agent_service.dart';

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
/// and offers to navigate to it.
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
  ConversationClient? _client;
  
  // Transcript collection
  final List<_TranscriptEntry> _transcript = [];
  String? _currentTranscript;
  
  // Animation
  late final AnimationController _orbPulseController;
  
  // Profile
  int? _currentProfileId;
  
  // Background handling
  DateTime? _wentBackgroundAt;
  
  // Call duration
  Timer? _callTimer;
  int _elapsedSeconds = 0;

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
    final profileProvider = context.read<ProfileProvider>();
    _currentProfileId = profileProvider.selectedProfileId;
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
          });
          _callTimer?.cancel();
        },
        onStatusChange: ({required ConversationStatus status}) {
          if (!mounted) return;
          setState(() {
            if (status == ConversationStatus.disconnected ||
                status == ConversationStatus.disconnecting) {
              _isConnected = false;
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
          
          // Add to transcript
          _transcript.add(_TranscriptEntry(
            text: message.trim(),
            isUser: source == Role.user,
            timestamp: DateTime.now(),
          ));
          
          _setStateIfMounted(() {
            _currentTranscript = message;
            _isAssistantSpeaking = source == Role.ai;
          });
        },
        onUserTranscript: ({required String transcript, required int eventId}) {
          if (transcript.trim().isEmpty) return;
          _setStateIfMounted(() {
            _currentTranscript = transcript;
          });
        },
        onError: (message, [context]) {
          final details = context == null ? message : '$message: $context';
          debugPrint('ElevenLabs SDK error: $details');
          _setStateIfMounted(() {
            _error = details;
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

  void _startCallTimer() {
    _callTimer?.cancel();
    _elapsedSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isConnected && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startCall() async {
    if (_isConnecting || _isConnected) return;
    
    _setStateIfMounted(() {
      _isConnecting = true;
      _error = null;
      _transcript.clear();
      _currentTranscript = null;
      _elapsedSeconds = 0;
    });

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _setStateIfMounted(() {
          _isConnecting = false;
          _error = 'Microphone permission is required for voice calls.';
        });
        return;
      }

      // Check if service is configured
      if (!_agentService.isConfigured) {
        _setStateIfMounted(() {
          _isConnecting = false;
          _error = 'ElevenLabs Agent is not configured. Please check your settings.';
        });
        return;
      }

      // Get signed URL
      final signedUrl = await _agentService.resolveSignedUrl();
      
      // Recreate client to ensure clean state
      _client?.dispose();
      _client = _buildConversationClient();
      
      // Start session
      await _client?.startSession(
        agentId: _agentService.agentId,
      );
      
    } catch (e) {
      debugPrint('ElevenLabs call start failed: $e');
      _setStateIfMounted(() {
        _isConnecting = false;
        _error = 'Failed to connect: ${e.toString()}';
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

    _isClosing = false;

    // If we have transcript, offer to save it
    if (_transcript.isNotEmpty && mounted) {
      await _showSaveTranscriptDialog();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSaveTranscriptDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Call Ended'),
        content: Text(
          'Your ${_formatDuration(_elapsedSeconds)} call has been recorded.\n\n'
          'Would you like to save the transcript as a new conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save & View'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final conversationId = await _saveTranscriptAsConversation();
      if (conversationId != null && mounted) {
        // Pop back to chat screen with the new conversation ID
        Navigator.of(context).pop(conversationId);
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<int?> _saveTranscriptAsConversation() async {
    if (_transcript.isEmpty) return null;

    try {
      final now = DateTime.now();
      
      // Create conversation
      final conversationData = {
        'title': 'Voice Call - ${_formatDateTime(now)}',
        'is_pinned': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'profile_id': _currentProfileId,
      };
      
      final conversationId = await _databaseService.insertConversation(conversationData);
      
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orbPulseController.dispose();
    _callTimer?.cancel();
    _client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    
    final showStartButton = !_isConnected && !_isConnecting;
    final statusText = _currentTranscript ??
        (_isPaused
            ? 'Mic is muted'
            : _isConnected
                ? (_isAssistantSpeaking ? 'AI is speaking...' : 'Listening...')
                : (_isConnecting ? 'Connecting...' : 'Tap to start'));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => _closeCall(reason: 'back_button'),
        ),
        title: Text(
          'Voice Call',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        actions: [
          if (_isConnected)
            IconButton(
              icon: Icon(
                _isPaused ? Icons.mic_off : Icons.mic,
                color: _isPaused ? Colors.red : (isDark ? Colors.white : Colors.black87),
              ),
              onPressed: _toggleMute,
              tooltip: _isPaused ? 'Unmute' : 'Mute',
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Call duration
                if (_isConnected)
                  Text(
                    _formatDuration(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Animated orb / call button
                AnimatedBuilder(
                  animation: _orbPulseController,
                  builder: (context, child) {
                    final t = _orbPulseController.value;
                    final pulseScale = showStartButton ? (1.0 + (t * 0.08)) : 1.0;
                    final glowOpacity = showStartButton ? (0.15 + (t * 0.2)) : 0.1;
                    
                    return GestureDetector(
                      onTap: showStartButton ? _startCall : null,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(glowOpacity),
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
                                    : [
                                        Colors.white,
                                        primaryColor.withOpacity(0.3),
                                        primaryColor.withOpacity(0.6),
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isConnected 
                                        ? (_isAssistantSpeaking ? Icons.volume_up : Icons.hearing)
                                        : Icons.phone,
                                    size: 48,
                                    color: _isConnected ? Colors.white : primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isConnecting 
                                        ? 'Calling...'
                                        : _isConnected 
                                            ? 'Connected' 
                                            : 'Speak',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _isConnected ? Colors.white : primaryColor,
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
                
                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 40),
                
                // End call button (when connected)
                if (_isConnected)
                  FilledButton.icon(
                    onPressed: () => _closeCall(),
                    icon: const Icon(Icons.call_end),
                    label: const Text('End Call'),
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
      ),
    );
  }
}
