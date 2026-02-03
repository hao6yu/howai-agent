import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_personality_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/subscription_service.dart';
import '../models/ai_personality.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/upgrade_dialog.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/image_editing_service.dart';

class AIPersonalityScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AIPersonalityScreen({super.key, this.onBack});

  @override
  State<AIPersonalityScreen> createState() => _AIPersonalityScreenState();
}

class _AIPersonalityScreenState extends State<AIPersonalityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _backgroundController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _hasChanges = false;
  XFile? _avatarImage;
  String? _currentAvatarPath;

  String _selectedGender = 'neutral';
  int _selectedAge = 25;
  String _selectedPersonality = 'friendly';
  String _selectedCommunicationStyle = 'casual';
  String _selectedExpertise = 'general';
  String _selectedHumorLevel = 'dry';
  String _selectedResponseLength = 'moderate';

  @override
  void initState() {
    super.initState();
    // Defer loading until after the build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersonality();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _interestsController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonality() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final personalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
    final currentProfileId = profileProvider.selectedProfileId;

    if (currentProfileId != null) {
      await personalityProvider.loadPersonalityForProfile(currentProfileId);
      final personality = personalityProvider.getPersonalityForProfile(currentProfileId);

      if (personality != null) {
        setState(() {
          _nameController.text = personality.aiName;
          _interestsController.text = personality.interests;
          _backgroundController.text = personality.backgroundStory;
          _currentAvatarPath = personality.avatarPath;
          _selectedGender = personality.gender;
          _selectedAge = personality.age;
          _selectedPersonality = personality.personality;
          _selectedCommunicationStyle = personality.communicationStyle;
          _selectedExpertise = personality.expertise;
          _selectedHumorLevel = personality.humorLevel;
          _selectedResponseLength = personality.responseLength;
        });
      }
    }
  }

  Future<void> _savePersonality() async {
    if (!_hasChanges) return;

    setState(() => _isLoading = true);

    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final personalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        final existingPersonality = personalityProvider.getPersonalityForProfile(currentProfileId);

        // Handle avatar path
        String? finalAvatarPath = _currentAvatarPath;
        if (_avatarImage != null) {
          finalAvatarPath = _avatarImage!.path;
        }

        final personality = AIPersonality(
          id: existingPersonality?.id,
          profileId: currentProfileId,
          aiName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'HowAI Agent',
          gender: _selectedGender,
          age: _selectedAge,
          personality: _selectedPersonality,
          communicationStyle: _selectedCommunicationStyle,
          expertise: _selectedExpertise,
          humorLevel: _selectedHumorLevel,
          responseLength: _selectedResponseLength,
          interests: _interestsController.text.trim(),
          backgroundStory: _backgroundController.text.trim(),
          avatarPath: finalAvatarPath,
          createdAt: existingPersonality?.createdAt ?? DateTime.now(),
        );

        final success = existingPersonality != null ? await personalityProvider.updatePersonality(personality) : await personalityProvider.createPersonality(personality);

        if (success && mounted) {
          setState(() => _hasChanges = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.aiPersonalitySettingsSaved),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.saveFailedTryAgain),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingAi(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetToDefault),
        content: Text(AppLocalizations.of(context)!.resetToDefaultConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.reset, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        final personalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
        final currentProfileId = profileProvider.selectedProfileId;

        if (currentProfileId != null) {
          final success = await personalityProvider.resetToDefault(currentProfileId);
          if (success) {
            await _loadPersonality();
            setState(() => _hasChanges = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.resetToDefaultSettings),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.resetFailedAi(e.toString())),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _pickAvatarImage() async {
    try {
      // Use the quick avatar picker (camera or gallery + direct crop)
      final editedFile = await ImageEditingService.quickAvatarPicker(context);

      if (editedFile != null) {
        // Copy to app documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/ai_avatars');
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        final fileName = 'ai_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentPath = '${profileDir.path}/$fileName';

        // Copy the edited image to permanent location
        await editedFile.copy(permanentPath);

        setState(() {
          _avatarImage = XFile(permanentPath);
        });

        // Auto-save the AI personality immediately
        await _savePersonalityWithNewAvatar(permanentPath);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.aiAvatarUpdated),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // debugPrint('Error picking/editing AI avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedUpdateAiAvatarMsg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _savePersonalityWithNewAvatar(String avatarPath) async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final personalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        final existingPersonality = personalityProvider.getPersonalityForProfile(currentProfileId);

        final personality = AIPersonality(
          id: existingPersonality?.id,
          profileId: currentProfileId,
          aiName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'HowAI Agent',
          gender: _selectedGender,
          age: _selectedAge,
          personality: _selectedPersonality,
          communicationStyle: _selectedCommunicationStyle,
          expertise: _selectedExpertise,
          humorLevel: _selectedHumorLevel,
          responseLength: _selectedResponseLength,
          interests: _interestsController.text.trim(),
          backgroundStory: _backgroundController.text.trim(),
          avatarPath: avatarPath, // Update with new avatar path
          createdAt: existingPersonality?.createdAt ?? DateTime.now(),
        );

        if (existingPersonality != null) {
          await personalityProvider.updatePersonality(personality);
        } else {
          await personalityProvider.createPersonality(personality);
        }

        // Reset the _hasChanges flag since we just saved
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      // debugPrint('Error auto-saving AI personality with new avatar: $e');
    }
  }

  Future<String?> _resolveAvatarPath(String? avatarPath) async {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isPremium = subscriptionService.isPremium;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context)!.aiPersonality,
            centerTitle: true,
            onBack: widget.onBack ?? () => Navigator.of(context).pop(),
            actions: [
              if (isPremium) ...[
                // Reset button
                IconButton(
                  onPressed: _isLoading ? null : _resetToDefault,
                  icon: Icon(Icons.refresh_rounded),
                  tooltip: 'Reset to Default',
                ),
                // Save button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_hasChanges) ? null : _savePersonality,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
          body: isPremium ? _buildPremiumContent() : _buildFreemiumContent(),
        );
      },
    );
  }

  Widget _buildPremiumContent() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact form without section dividers
              _buildCompactCard([
                _buildNameWithAvatar(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Personality',
                        value: _selectedPersonality,
                        items: [
                          DropdownMenuItem(value: 'friendly', child: Text(AppLocalizations.of(context)!.friendly)),
                          DropdownMenuItem(value: 'professional', child: Text(AppLocalizations.of(context)!.professional)),
                          DropdownMenuItem(value: 'witty', child: Text(AppLocalizations.of(context)!.witty)),
                          DropdownMenuItem(value: 'caring', child: Text(AppLocalizations.of(context)!.caring)),
                          DropdownMenuItem(value: 'energetic', child: Text(AppLocalizations.of(context)!.energetic)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPersonality = value!);
                          _markChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Humor Level',
                        value: _selectedHumorLevel,
                        items: [
                          DropdownMenuItem(value: 'none', child: Text(AppLocalizations.of(context)!.serious)),
                          DropdownMenuItem(value: 'light', child: Text(AppLocalizations.of(context)!.light)),
                          DropdownMenuItem(value: 'dry', child: Text(AppLocalizations.of(context)!.dry)),
                          DropdownMenuItem(value: 'moderate', child: Text(AppLocalizations.of(context)!.moderate)),
                          DropdownMenuItem(value: 'heavy', child: Text(AppLocalizations.of(context)!.heavy)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedHumorLevel = value!);
                          _markChanged();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Communication',
                        value: _selectedCommunicationStyle,
                        items: [
                          DropdownMenuItem(value: 'casual', child: Text(AppLocalizations.of(context)!.casual)),
                          DropdownMenuItem(value: 'formal', child: Text(AppLocalizations.of(context)!.formal)),
                          DropdownMenuItem(value: 'tech-savvy', child: Text(AppLocalizations.of(context)!.techSavvy)),
                          DropdownMenuItem(value: 'supportive', child: Text(AppLocalizations.of(context)!.supportive)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCommunicationStyle = value!);
                          _markChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Response Length',
                        value: _selectedResponseLength,
                        items: [
                          DropdownMenuItem(value: 'concise', child: Text(AppLocalizations.of(context)!.concise)),
                          DropdownMenuItem(value: 'moderate', child: Text(AppLocalizations.of(context)!.moderate)),
                          DropdownMenuItem(value: 'detailed', child: Text(AppLocalizations.of(context)!.detailed)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedResponseLength = value!);
                          _markChanged();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Expertise Area',
                  value: _selectedExpertise,
                  items: [
                    DropdownMenuItem(value: 'general', child: Text(AppLocalizations.of(context)!.generalKnowledge)),
                    DropdownMenuItem(value: 'technology', child: Text(AppLocalizations.of(context)!.technology)),
                    DropdownMenuItem(value: 'business', child: Text(AppLocalizations.of(context)!.business)),
                    DropdownMenuItem(value: 'creative', child: Text(AppLocalizations.of(context)!.creative)),
                    DropdownMenuItem(value: 'academic', child: Text(AppLocalizations.of(context)!.academic)),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedExpertise = value!);
                    _markChanged();
                  },
                ),
                const SizedBox(height: 12),
                _buildCompactTextField(
                  controller: _interestsController,
                  label: 'Interests & Hobbies',
                  hint: 'e.g. Programming, Music, Photography, Travel, Reading, Gaming, Art, Sports, Cooking, etc.',
                  maxLines: 3,
                  onChanged: () => _markChanged(),
                ),
                const SizedBox(height: 10),
                _buildCompactTextField(
                  controller: _backgroundController,
                  label: 'Background Story (Optional)',
                  hint: 'Describe your AI\'s background story, experience, expertise areas, or personality traits to make conversations more personal and engaging...',
                  maxLines: 4,
                  onChanged: () => _markChanged(),
                ),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreemiumContent() {
    return Consumer2<SettingsProvider, AIPersonalityProvider>(
      builder: (context, settings, personalityProvider, child) {
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        final currentProfileId = profileProvider.selectedProfileId;
        final personality = currentProfileId != null ? personalityProvider.getPersonalityForProfile(currentProfileId) : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Compact Premium Feature Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0078D4).withOpacity(0.08),
                      const Color(0xFF106ebe).withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0078D4).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Personality Customization',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0078D4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upgrade to customize personality, communication style & more',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => UpgradeDialog(
                            featureName: 'AI Personality Customization',
                            limitMessage: 'Customize your AI assistant\'s personality, communication style, and expertise areas',
                            premiumBenefits: [
                              'Custom AI names and personalities',
                              'Adjustable communication styles',
                              'Specialized expertise areas',
                              'Humor and response length controls',
                              'Personal background stories',
                            ],
                            onUpgradePressed: () {
                              // Handle upgrade logic
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        minimumSize: Size(0, 36),
                      ),
                      child: Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Read-only current settings preview
              if (personality != null) ...[
                _buildReadOnlySection(
                  'Current Settings (Preview)',
                  [
                    _buildReadOnlyNameWithAvatar(personality),
                    const SizedBox(height: 12),
                    _buildReadOnlyTwoColumnRow(
                      'Personality',
                      _getPersonalityDisplayText(personality.personality),
                      'Humor',
                      _getHumorLevelDisplayText(personality.humorLevel),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyTwoColumnRow(
                      'Communication',
                      _getCommunicationStyleDisplayText(personality.communicationStyle),
                      'Response Length',
                      _getResponseLengthDisplayText(personality.responseLength),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyItem('Expertise', _getExpertiseDisplayText(personality.expertise)),
                    if (personality.interests.isNotEmpty) _buildReadOnlyItem('Interests', personality.interests),
                    if (personality.backgroundStory.isNotEmpty) _buildReadOnlyItem('Background', personality.backgroundStory),
                  ],
                ),
              ],
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlySection(String title, List<Widget> children) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: (_) => onChanged?.call(),
              style: TextStyle(
                fontSize: settings.getScaledFontSize(16),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: settings.getScaledFontSize(16),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
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
                  borderSide: const BorderSide(color: Color(0xFF0078D4)),
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: (_) => onChanged?.call(),
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: settings.getScaledFontSize(13),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade500,
                  height: 1.3,
                ),
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
                  borderSide: const BorderSide(color: Color(0xFF0078D4)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                isDense: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
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
                  borderSide: const BorderSide(color: Color(0xFF0078D4)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                isDense: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0078D4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF0078D4),
                thumbColor: const Color(0xFF0078D4),
                overlayColor: const Color(0xFF0078D4).withOpacity(0.2),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadOnlyItem(String label, String value) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(13),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(15),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800,
                  height: 1.4,
                ),
                maxLines: null, // Allow unlimited lines for all readonly items
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyNameWithAvatar(AIPersonality personality) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Compact AI Avatar (Read-only)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0078D4).withOpacity(0.1),
                      const Color(0xFF0078D4).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFF0078D4).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: FutureBuilder<String?>(
                  future: _resolveAvatarPath(personality.avatarPath),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: FileImage(File(snapshot.data!)),
                      );
                    }
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/icon/hao_avatar.png'),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Name info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Agent Name',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(13),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      personality.aiName,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(15),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
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

  Widget _buildNameWithAvatar() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Row(
          children: [
            // Compact AI Avatar
            GestureDetector(
              onTap: _pickAvatarImage,
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0078D4).withOpacity(0.1),
                          const Color(0xFF0078D4).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF0078D4).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0078D4).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _avatarImage != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage: FileImage(File(_avatarImage!.path)),
                          )
                        : FutureBuilder<String?>(
                            future: _resolveAvatarPath(_currentAvatarPath),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return CircleAvatar(
                                  radius: 30,
                                  backgroundImage: FileImage(File(snapshot.data!)),
                                );
                              }
                              return CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage('assets/icon/hao_avatar.png'),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0078D4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Name Field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Agent Name',
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => _markChanged(),
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Alex, Agent, Helper, etc.',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade400,
                        fontSize: settings.getScaledFontSize(13),
                      ),
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
                        borderSide: const BorderSide(color: Color(0xFF0078D4)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                      isDense: true,
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

  // Helper methods for display text
  String _getGenderDisplayText(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Neutral';
    }
  }

  String _getPersonalityDisplayText(String personality) {
    switch (personality) {
      case 'friendly':
        return 'Friendly & Approachable';
      case 'professional':
        return 'Professional & Rigorous';
      case 'witty':
        return 'Witty & Humorous';
      case 'caring':
        return 'Caring & Compassionate';
      case 'energetic':
        return 'Energetic & Vibrant';
      default:
        return personality;
    }
  }

  String _getCommunicationStyleDisplayText(String style) {
    switch (style) {
      case 'casual':
        return 'Casual & Relaxed';
      case 'formal':
        return 'Formal & Structured';
      case 'tech-savvy':
        return 'Tech-Oriented';
      case 'supportive':
        return 'Supportive & Encouraging';
      default:
        return style;
    }
  }

  String _getExpertiseDisplayText(String expertise) {
    switch (expertise) {
      case 'general':
        return 'General Knowledge';
      case 'technology':
        return 'Technology Expert';
      case 'business':
        return 'Business Analysis';
      case 'creative':
        return 'Creative Design';
      case 'academic':
        return 'Academic Research';
      default:
        return expertise;
    }
  }

  String _getHumorLevelDisplayText(String level) {
    switch (level) {
      case 'none':
        return 'Serious & Professional';
      case 'light':
        return 'Occasionally Humorous';
      case 'dry':
        return 'Dry & Witty';
      case 'moderate':
        return 'Moderately Humorous';
      case 'heavy':
        return 'Frequently Humorous';
      default:
        return level;
    }
  }

  String _getResponseLengthDisplayText(String length) {
    switch (length) {
      case 'concise':
        return 'Concise & Brief';
      case 'moderate':
        return 'Moderate Detail';
      case 'detailed':
        return 'Detailed & Comprehensive';
      default:
        return length;
    }
  }

  Widget _buildReadOnlyTwoColumnRow(String label1, String value1, String label2, String value2) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Row(
          children: [
            Expanded(
              child: _buildReadOnlyItem(label1, value1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadOnlyItem(label2, value2),
            ),
          ],
        );
      },
    );
  }
}
