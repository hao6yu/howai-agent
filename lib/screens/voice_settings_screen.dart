import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../services/subscription_service.dart';
import '../services/audio_service.dart';
import '../services/elevenlabs_service.dart';
import '../services/device_tts_service.dart';
import '../widgets/custom_back_button.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  static final List<Map<String, String>> _fallbackElevenLabsVoices =
      ElevenLabsService.availableVoices;

  // System TTS
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  FlutterTts? _flutterTts;
  List<dynamic> _systemVoices = [];
  Map<String, String>? _selectedSystemVoice;
  bool _isLoadingVoices = true;
  List<Map<String, String>> _elevenLabsVoices =
      List<Map<String, String>>.from(_fallbackElevenLabsVoices);
  String? _previewingElevenLabsVoiceId;
  bool _isPreviewingSystemVoice = false;
  bool _didRequestPremiumDefaultMigration = false;
  late final VoidCallback _audioPreviewListener;

  String get _sampleText =>
      AppLocalizations.of(context)!.voiceSamplePreviewText;

  @override
  void initState() {
    super.initState();
    _audioPreviewListener = () {
      if (!AudioService.isPlayingAudio.value &&
          mounted &&
          _previewingElevenLabsVoiceId != null) {
        setState(() {
          _previewingElevenLabsVoiceId = null;
        });
      }
    };
    AudioService.isPlayingAudio.addListener(_audioPreviewListener);
    _initSystemTTS();
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    AudioService.stopAudio();
    AudioService.isPlayingAudio.removeListener(_audioPreviewListener);
    super.dispose();
  }

  Future<void> _initSystemTTS() async {
    try {
      _flutterTts = FlutterTts();
      _flutterTts!.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPreviewingSystemVoice = false;
          });
        }
      });
      _flutterTts!.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isPreviewingSystemVoice = false;
          });
        }
      });
      await _initVoices();
    } catch (e) {
      // print('Error initializing system TTS: $e');
      setState(() {
        _isLoadingVoices = false;
      });
    }
  }

  // Helper method to get the index of the selected voice
  int? _getSelectedVoiceIndex() {
    if (_selectedSystemVoice == null || _systemVoices.isEmpty) return null;

    // Find the index of the voice that matches the selected voice
    for (int i = 0; i < _systemVoices.length; i++) {
      final voice = _systemVoices[i];
      if (voice['name'] == _selectedSystemVoice!['name'] &&
          voice['locale'] == _selectedSystemVoice!['locale']) {
        return i;
      }
    }
    return null;
  }

  // Helper method to create a safe voice map with all required properties
  Map<String, String> _createSafeVoiceMap(dynamic voice) {
    final voiceMap = <String, String>{};

    // Ensure all required properties are present and are strings
    voiceMap['name'] =
        (voice['name'] ?? AppLocalizations.of(context)!.unknownVoice)
            .toString();
    voiceMap['locale'] = (voice['locale'] ?? 'en-US').toString();
    voiceMap['language'] = (voice['language'] ?? 'en').toString();
    voiceMap['gender'] = (voice['gender'] ?? 'female').toString();

    // Add any other properties that might be needed by iOS TTS
    if (voice['quality'] != null) {
      voiceMap['quality'] = voice['quality'].toString();
    }
    if (voice['identifier'] != null) {
      voiceMap['identifier'] = voice['identifier'].toString();
    }

    return voiceMap;
  }

  Future<void> _initVoices() async {
    final voices = await _flutterTts!.getVoices;

    // Filter voices to only include those with explicit gender and locale specification
    final filteredVoices = voices.where((voice) {
      final gender = (voice['gender'] ?? '').toString().toLowerCase().trim();
      final locale = (voice['locale'] ?? '').toString().toLowerCase().trim();

      // Must have explicit gender and a valid locale
      return (gender == 'female' || gender == 'male') &&
          locale.contains('-') && // Must have a region/country
          locale.length >= 5; // Must be a valid locale format (e.g., en-us)
    }).toList();

    // Sort voices to prioritize English and female voices
    final sortedVoices = List<dynamic>.from(filteredVoices);
    sortedVoices.sort((a, b) {
      final aLocale = (a['locale'] ?? '').toString().toLowerCase().trim();
      final bLocale = (b['locale'] ?? '').toString().toLowerCase().trim();
      final aGender = (a['gender'] ?? '').toString().toLowerCase().trim();
      final bGender = (b['gender'] ?? '').toString().toLowerCase().trim();

      // Check if either is English
      final aIsEnglish = aLocale.startsWith('en-');
      final bIsEnglish = bLocale.startsWith('en-');

      // Check if either is female
      final aIsFemale = aGender == 'female';
      final bIsFemale = bGender == 'female';

      // First sort by English
      if (aIsEnglish && !bIsEnglish) return -1;
      if (!aIsEnglish && bIsEnglish) return 1;

      // If both are English, prioritize female voices
      if (aIsEnglish && bIsEnglish) {
        if (aIsFemale && !bIsFemale) return -1;
        if (!aIsFemale && bIsFemale) return 1;

        // If both are female or both are male, prioritize US English
        if (aLocale == 'en-us') return -1;
        if (bLocale == 'en-us') return 1;
      }

      // Then sort by locale
      return aLocale.compareTo(bLocale);
    });

    // 1. Prefer female US English voice with name containing 'samantha'
    dynamic femaleUSSamantha = sortedVoices.firstWhere(
      (v) =>
          (v['locale']?.toString().toLowerCase().trim() == 'en-us') &&
          (v['gender']?.toString().toLowerCase().trim() == 'female') &&
          (v['name']?.toString().toLowerCase().contains('samantha') ?? false),
      orElse: () => null,
    );
    // 2. If not found, prefer any female US English voice
    dynamic femaleUSVoice = sortedVoices.firstWhere(
      (v) =>
          (v['locale']?.toString().toLowerCase().trim() == 'en-us') &&
          (v['gender']?.toString().toLowerCase().trim() == 'female'),
      orElse: () => null,
    );
    // 3. If not found, prefer any female English voice
    dynamic femaleEnglishVoice = sortedVoices.firstWhere(
      (v) =>
          (v['locale']?.toString().toLowerCase().trim().startsWith('en-') ??
              false) &&
          (v['gender']?.toString().toLowerCase().trim() == 'female'),
      orElse: () => null,
    );

    setState(() {
      _systemVoices = sortedVoices;
      _isLoadingVoices = false;

      // Load saved voice or set default
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final savedVoice = settings.selectedSystemTTSVoice;

      if (savedVoice != null) {
        // Try to find the saved voice in the available voices by name
        final matchingVoice = sortedVoices.firstWhere(
          (v) =>
              v['name'] == savedVoice['name'] &&
              v['locale'] == savedVoice['locale'],
          orElse: () => null,
        );

        if (matchingVoice != null) {
          _selectedSystemVoice = _createSafeVoiceMap(matchingVoice);
        }
      }

      // If no saved voice or saved voice not found, use default priority
      if (_selectedSystemVoice == null) {
        dynamic defaultVoice;

        if (femaleUSSamantha != null) {
          defaultVoice = femaleUSSamantha;
        } else if (femaleUSVoice != null) {
          defaultVoice = femaleUSVoice;
        } else if (femaleEnglishVoice != null) {
          defaultVoice = femaleEnglishVoice;
        } else if (sortedVoices.isNotEmpty) {
          defaultVoice = sortedVoices.first;
        }

        if (defaultVoice != null) {
          _selectedSystemVoice = _createSafeVoiceMap(defaultVoice);

          // Save the default selection
          settings.setSelectedSystemTTSVoice(_selectedSystemVoice!);
        }
      }
    });

    // Test voice setting with error handling (outside setState)
    if (_selectedSystemVoice != null && _flutterTts != null) {
      try {
        // Add a delay to ensure TTS is fully initialized
        await Future.delayed(Duration(milliseconds: 200));

        // Try to set the voice safely
        await _flutterTts!.setVoice(_selectedSystemVoice!);
        // print('Successfully set voice: ${_selectedSystemVoice!['name']}');
      } catch (e) {
        // print('Failed to set voice, will use default: $e');
        // Don't crash if voice setting fails, just use default voice
        // Reset to null so we don't keep trying to set a problematic voice
        if (mounted) {
          setState(() {
            _selectedSystemVoice = null;
          });
        }
      }
    }
  }

  Future<void> _previewSystemVoice(SettingsProvider settings) async {
    if (_flutterTts == null) {
      await _initSystemTTS();
    }
    if (_flutterTts == null) return;

    if (_isPreviewingSystemVoice) {
      await _flutterTts!.stop();
      if (mounted) {
        setState(() {
          _isPreviewingSystemVoice = false;
        });
      }
      return;
    }

    await AudioService.stopAudio();
    if (mounted) {
      setState(() {
        _previewingElevenLabsVoiceId = null;
      });
    }

    setState(() {
      _isPreviewingSystemVoice = true;
    });

    final result = await DeviceTtsService.generateAndPlay(
      flutterTts: _flutterTts,
      message: _sampleText,
      selectedVoice: _selectedSystemVoice,
      speechRate: settings.systemTtsPlaybackSpeed,
    );

    if (result == null && mounted) {
      setState(() {
        _isPreviewingSystemVoice = false;
      });
    }
  }

  Future<void> _previewElevenLabsVoice({
    required SettingsProvider settings,
    required String voiceId,
  }) async {
    if (_isPreviewingSystemVoice) {
      await _flutterTts?.stop();
      if (mounted) {
        setState(() {
          _isPreviewingSystemVoice = false;
        });
      }
    }

    if (_previewingElevenLabsVoiceId == voiceId &&
        AudioService.isPlayingAudio.value) {
      await AudioService.stopAudio();
      if (mounted) {
        setState(() {
          _previewingElevenLabsVoiceId = null;
        });
      }
      return;
    }

    await AudioService.stopAudio();

    if (mounted) {
      setState(() {
        _previewingElevenLabsVoiceId = voiceId;
      });
    }

    try {
      final previewId =
          DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      final audioPath = await _elevenLabsService.generateAudioWithSettings(
        _sampleText,
        previewId,
        voiceId: voiceId,
        voiceSettings: const {
          'stability': 0.35,
          'similarity_boost': 0.95,
          'style': 0.6,
          'use_speaker_boost': true,
        },
      );

      if (audioPath == null || audioPath.isEmpty) {
        _showPreviewError(
            AppLocalizations.of(context)!.voiceSampleGenerateFailed);
        if (mounted) {
          setState(() {
            _previewingElevenLabsVoiceId = null;
          });
        }
        return;
      }

      final file = File(audioPath);
      if (!await file.exists() || await file.length() == 0) {
        _showPreviewError(AppLocalizations.of(context)!.voiceSampleUnavailable);
        if (mounted) {
          setState(() {
            _previewingElevenLabsVoiceId = null;
          });
        }
        return;
      }

      await AudioService.playAudio(
        audioPath,
        useSpeakerOutput: settings.useSpeakerOutput,
        playbackSpeed: settings.elevenLabsPlaybackSpeed,
      );
      if (!AudioService.isPlayingAudio.value) {
        _showPreviewError(AppLocalizations.of(context)!.voiceSamplePlayFailed);
        if (mounted) {
          setState(() {
            _previewingElevenLabsVoiceId = null;
          });
        }
      }
    } catch (_) {
      _showPreviewError(AppLocalizations.of(context)!.voiceSamplePlayFailed);
      if (mounted) {
        setState(() {
          _previewingElevenLabsVoiceId = null;
        });
      }
    }
  }

  void _showPreviewError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.voiceSettings,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Consumer2<SettingsProvider, SubscriptionService>(
        builder: (context, settings, subscriptionService, child) {
          if (subscriptionService.isPremium &&
              !_didRequestPremiumDefaultMigration) {
            _didRequestPremiumDefaultMigration = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              settings.applyPremiumVoiceDefaultsIfNeeded(isPremium: true);
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUsageIntroCard(settings, subscriptionService),
                const SizedBox(height: 20),
                // Voice Response Toggle - DISABLED: Auto-play feature removed
                // _buildVoiceResponseToggle(settings),
                // const SizedBox(height: 20),

                // Device TTS Section
                _buildDeviceTTSSection(settings),
                const SizedBox(height: 20),

                // ElevenLabs Section
                _buildElevenLabsSection(settings, subscriptionService),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceResponseToggle(SettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0078D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.record_voice_over_rounded,
                color: const Color(0xFF0078D4),
                size: settings.getScaledFontSize(22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.voiceResponse,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.automaticallyPlayAiResponses,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: settings.useVoiceResponse,
              onChanged: settings.setUseVoiceResponse,
              activeColor: const Color(0xFF0078D4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageIntroCard(
    SettingsProvider settings,
    SubscriptionService subscriptionService,
  ) {
    final isPremium = subscriptionService.isPremium;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? const Color(0xFF0078D4).withOpacity(0.25)
              : Colors.grey.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.voicePlaybackHowItWorksTitle,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(15),
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.voicePlaybackHowItWorksFree,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.voicePlaybackHowItWorksPremium,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.voicePlaybackHowItWorksTrySample,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.voicePlaybackHowItWorksSpeedNote,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTTSSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(AppLocalizations.of(context)!.voiceFreeSystemTitle),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: Colors.green,
                        size: settings.getScaledFontSize(20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.voiceDeviceTtsTitle,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(16),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .voiceDeviceTtsDescription,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.free,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: settings.getScaledFontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _previewSystemVoice(settings),
                      icon: Icon(
                        _isPreviewingSystemVoice
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        color: Colors.green,
                        size: settings.getScaledFontSize(26),
                      ),
                      tooltip: _isPreviewingSystemVoice
                          ? AppLocalizations.of(context)!.voiceStopSample
                          : AppLocalizations.of(context)!.voicePlaySample,
                    ),
                  ],
                ),
              ),

              // Voice selection section
              if (_isLoadingVoices) ...[
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: settings.getScaledFontSize(16),
                        height: settings.getScaledFontSize(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.voiceLoadingVoices,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_systemVoices.isNotEmpty) ...[
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over_rounded,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                            size: settings.getScaledFontSize(20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.selectedVoice,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _selectedSystemVoice != null
                            ? _getSelectedVoiceIndex()
                            : null,
                        isExpanded: true,
                        menuMaxHeight: 300, // Limit dropdown height
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF0078D4)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: settings.getScaledFontSize(12),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
                        ),
                        items: _systemVoices
                            .asMap()
                            .entries
                            .map<DropdownMenuItem<int>>((entry) {
                          final index = entry.key;
                          final voice = entry.value;
                          final voiceMap = _createSafeVoiceMap(voice);

                          final name = voiceMap['name'] ??
                              AppLocalizations.of(context)!.unknownVoice;
                          final locale = voiceMap['locale'] ?? '';
                          final gender = voiceMap['gender'] ?? '';

                          String displayName = name;
                          if (locale.isNotEmpty) {
                            displayName += ' ($locale)';
                          }
                          if (gender.isNotEmpty) {
                            displayName +=
                                ' • ${gender.substring(0, 1).toUpperCase() + gender.substring(1)}';
                          }

                          return DropdownMenuItem<int>(
                            value: index,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                displayName,
                                style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newIndex) async {
                          if (newIndex != null &&
                              newIndex < _systemVoices.length) {
                            final selectedVoice =
                                _createSafeVoiceMap(_systemVoices[newIndex]);

                            // Update state first
                            setState(() {
                              _selectedSystemVoice = selectedVoice;
                            });

                            // Save to settings
                            settings.setSelectedSystemTTSVoice(selectedVoice);

                            // Try to set voice with comprehensive error handling
                            if (_flutterTts != null) {
                              try {
                                // Add delay to ensure TTS is ready
                                await Future.delayed(
                                    Duration(milliseconds: 100));
                                await _flutterTts!.setVoice(selectedVoice);
                                // print('Voice successfully changed to: ${selectedVoice['name']}');
                              } catch (e) {
                                // print('Failed to change voice, keeping selection but using default: $e');
                                // Don't reset the selection here, just log the error
                                // The voice will still be saved for future use when TTS is actually played
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],

              _buildDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          size: settings.getScaledFontSize(20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.voiceSystemSpeed(
                                settings.systemTtsPlaybackSpeed
                                    .toStringAsFixed(1)),
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.voiceSystemSpeedDescription,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(12),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    Slider(
                      value: settings.systemTtsPlaybackSpeed.clamp(0.5, 1.2),
                      min: 0.5,
                      max: 1.2,
                      divisions: 7,
                      activeColor: const Color(0xFF0078D4),
                      onChanged: (value) {
                        settings.setSystemTtsPlaybackSpeed(
                          double.parse(value.toStringAsFixed(1)),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.voiceSpeedMinSystem,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(11),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.voiceSpeedMaxSystem,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(11),
                              color: Theme.of(context).brightness ==
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElevenLabsSection(
      SettingsProvider settings, SubscriptionService subscriptionService) {
    final isPremium = subscriptionService.isPremium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(AppLocalizations.of(context)!.elevenLabsAiVoices),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with premium badge
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? const Color(0xFF0078D4).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color:
                            isPremium ? const Color(0xFF0078D4) : Colors.grey,
                        size: settings.getScaledFontSize(22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .voicePremiumElevenLabsTitle,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(16),
                              fontWeight: FontWeight.w600,
                              color: isPremium
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A))
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .voicePremiumElevenLabsDesc,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? const Color(0xFF0078D4).withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isPremium
                                      ? const Color(0xFF0078D4).withOpacity(0.3)
                                      : Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              isPremium
                                  ? AppLocalizations.of(context)!.premium
                                  : AppLocalizations.of(context)!
                                      .premiumRequired,
                              style: TextStyle(
                                color: isPremium
                                    ? const Color(0xFF0078D4)
                                    : Colors.orange.shade700,
                                fontSize: settings.getScaledFontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isPremium)
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/subscription'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.upgrade,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Voice options
              if (isPremium) ...[
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.voicePremiumEngineTitle,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  settings.setPremiumTtsEngine('system'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: settings.premiumUsesSystemTts
                                    ? const Color(0xFF0078D4).withOpacity(0.08)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: settings.premiumUsesSystemTts
                                      ? const Color(0xFF0078D4)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.voiceSystemTts,
                                style: TextStyle(
                                  color: settings.premiumUsesSystemTts
                                      ? const Color(0xFF0078D4)
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  settings.setPremiumTtsEngine('elevenlabs'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: !settings.premiumUsesSystemTts
                                    ? const Color(0xFF0078D4).withOpacity(0.08)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: !settings.premiumUsesSystemTts
                                      ? const Color(0xFF0078D4)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.voiceElevenLabs,
                                style: TextStyle(
                                  color: !settings.premiumUsesSystemTts
                                      ? const Color(0xFF0078D4)
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.voiceElevenLabsSpeed(
                            settings.elevenLabsPlaybackSpeed
                                .toStringAsFixed(1)),
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      Slider(
                        value: settings.elevenLabsPlaybackSpeed.clamp(0.8, 1.5),
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        activeColor: const Color(0xFF0078D4),
                        onChanged: (value) {
                          settings.setElevenLabsPlaybackSpeed(
                            double.parse(value.toStringAsFixed(1)),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .voiceSpeedMinElevenLabs,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(11),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .voiceSpeedMaxElevenLabs,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(11),
                                color: Theme.of(context).brightness ==
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
                ),
                _buildDivider(),
                ..._elevenLabsVoices.asMap().entries.map((entry) {
                  final voice = entry.value;
                  final isSelected = settings.selectedVoiceId == voice['id'];
                  final isPreviewingThisVoice =
                      _previewingElevenLabsVoiceId == voice['id'] &&
                          AudioService.isPlayingAudio.value;
                  final isLast = entry.key == _elevenLabsVoices.length - 1;

                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              settings.setSelectedVoiceId(voice['id']!),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: isSelected
                                      ? const Color(0xFF0078D4)
                                      : Colors.grey.shade500,
                                  size: settings.getScaledFontSize(20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    voice['name']!,
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(16),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF0078D4)
                                          : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : const Color(0xFF1A1A1A)),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _previewElevenLabsVoice(
                                    settings: settings,
                                    voiceId: voice['id']!,
                                  ),
                                  icon: Icon(
                                    isPreviewingThisVoice
                                        ? Icons.stop_circle_outlined
                                        : Icons.play_circle_outline,
                                    color: const Color(0xFF0078D4),
                                    size: settings.getScaledFontSize(22),
                                  ),
                                  tooltip: isPreviewingThisVoice
                                      ? AppLocalizations.of(context)!
                                          .voiceStopSample
                                      : AppLocalizations.of(context)!
                                          .voicePlaySample,
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF0078D4),
                                    size: settings.getScaledFontSize(20),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast) _buildDivider(),
                    ],
                  );
                }).toList(),
              ] else ...[
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.grey.shade400,
                        size: settings.getScaledFontSize(32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.premiumFeature,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(16),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!
                            .voicePremiumUpgradeDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/subscription'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.upgradeToPremiumVoice,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A1A1A),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade100,
    );
  }
}
