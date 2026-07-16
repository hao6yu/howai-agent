import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/subscription_service.dart';
import '../services/image_editing_service.dart';
import '../models/profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/upgrade_dialog.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme/howai_theme.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  XFile? _avatarImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        final profile = await _databaseService.getProfile(currentProfileId);
        if (profile != null) {
          _nameController.text = profile.name;
        }
      }
    } catch (e) {
      // debugPrint('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        final profile = await _databaseService.getProfile(currentProfileId);
        if (profile != null) {
          var updatedProfile = Profile(
            id: currentProfileId,
            name: _nameController.text.trim(),
            createdAt: profile.createdAt,
            characteristics: profile.characteristics,
            preferences: profile.preferences,
            avatarPath: profile.avatarPath, // Preserve existing avatar path
          );

          // Only update avatar path if a new image was selected
          if (_avatarImage != null) {
            updatedProfile =
                updatedProfile.copyWith(avatarPath: _avatarImage!.path);
          }

          await _databaseService.updateProfile(updatedProfile);
          await profileProvider.updateProfile(updatedProfile);
          await profileProvider.loadProfiles();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.profileUpdated),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back after successful update
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      // debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdateFailed),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    try {
      // Use the quick avatar picker (camera or gallery + direct crop)
      final editedFile = await ImageEditingService.quickAvatarPicker(context);

      if (editedFile != null) {
        // Copy to app documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profiles');
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentPath = '${profileDir.path}/$fileName';

        // Copy the edited image to permanent location
        await editedFile.copy(permanentPath);

        setState(() {
          _avatarImage = XFile(permanentPath);
        });

        // Auto-save the profile immediately
        await _saveProfileWithNewAvatar(permanentPath);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.avatarUpdatedSaved),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // debugPrint('Error picking/editing avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedUpdateAvatar),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveProfileWithNewAvatar(String avatarPath) async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        final profile = await _databaseService.getProfile(currentProfileId);
        if (profile != null) {
          final updatedProfile = Profile(
            id: currentProfileId,
            name: profile.name, // Keep existing name
            createdAt: profile.createdAt,
            characteristics: profile.characteristics,
            preferences: profile.preferences,
            avatarPath: avatarPath, // Update with new avatar path
          );

          await _databaseService.updateProfile(updatedProfile);
          await profileProvider.updateProfile(updatedProfile);
          await profileProvider.loadProfiles();
        }
      }
    } catch (e) {
      // debugPrint('Error auto-saving profile with new avatar: $e');
    }
  }

  Future<String?> _resolveAvatarPath(String? avatarPath) async {
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

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final selectedProfile = profileProvider.profiles.firstWhere(
      (p) => p.id == profileProvider.selectedProfileId,
      orElse: () => Profile(id: 0, name: '', createdAt: null),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.editProfile,
        onBack: widget.onBack ?? () => Navigator.of(context).pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: TextButton.styleFrom(
                foregroundColor: context.howaiColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  : Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Avatar Section
                  _buildAvatarSection(selectedProfile),
                  const SizedBox(height: 24),

                  // Name Section
                  _buildNameSection(),
                  const SizedBox(height: 24),

                  // AI Insights Section
                  _buildAIInsightsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection(Profile selectedProfile) {
    final colors = context.howaiColors;

    return Column(
      children: [
        GestureDetector(
          onTap: _pickAvatarImage,
          child: Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: Border.all(
                    color: colors.divider,
                    width: 1,
                  ),
                ),
                child: _avatarImage != null
                    ? CircleAvatar(
                        radius: 44,
                        backgroundImage: FileImage(File(_avatarImage!.path)),
                      )
                    : FutureBuilder<String?>(
                        future: _resolveAvatarPath(selectedProfile.avatarPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return CircleAvatar(
                              radius: 44,
                              backgroundImage: FileImage(File(snapshot.data!)),
                            );
                          }
                          return CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              selectedProfile.name.isNotEmpty
                                  ? selectedProfile.name
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: colors.accent,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: colors.canvas,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.tapToChangePhoto,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    final colors = context.howaiColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.displayName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterYourName,
            hintStyle: TextStyle(
              color: colors.textTertiary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.accent, width: 1.4),
            ),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    return Consumer2<SettingsProvider, SubscriptionService>(
      builder: (context, settings, subscriptionService, child) {
        final colors = context.howaiColors;
        return Container(
          key: const Key('profile_ai_insights_group'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Icon(
                      Icons.psychology_outlined,
                      color: colors.textSecondary,
                      size: settings.getScaledFontSize(21),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'AI Insights',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(18),
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (!subscriptionService.isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.surfaceStrong,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: settings.getScaledFontSize(10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          subscriptionService.isPremium
                              ? 'How AI understands you'
                              : 'Unlock personalized AI analysis',
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(14),
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show content based on subscription status
              if (subscriptionService.isPremium)
                _buildAIInsightsContent(settings)
              else
                _buildAIInsightsPaywall(settings, subscriptionService),
            ],
          ),
        );
      },
    );
  }

  // Premium users see the actual AI insights content
  Widget _buildAIInsightsContent(SettingsProvider settings) {
    return FutureBuilder<Profile?>(
      future: _databaseService.getProfile(
          Provider.of<ProfileProvider>(context, listen: false)
                  .selectedProfileId ??
              0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data;
        final characteristics = profile?.characteristics ?? {};

        if (characteristics.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: settings.getScaledFontSize(48),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Learning in progress...',
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chat more to help AI understand your preferences',
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: characteristics.entries.map((entry) {
            return _buildInsightItem(entry.key, entry.value, settings);
          }).toList(),
        );
      },
    );
  }

  // Free users see a premium paywall with preview
  Widget _buildAIInsightsPaywall(
      SettingsProvider settings, SubscriptionService subscriptionService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0078D4).withOpacity(0.05),
            const Color(0xFF106ebe).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0078D4).withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          // Blurred preview content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Preview insight items (blurred/obscured)
                _buildPreviewInsightItem('Communication Style',
                    'Friendly, direct, analytical...', settings),
                const SizedBox(height: 8),
                _buildPreviewInsightItem(
                    'Interests', 'Technology, productivity, AI...', settings),
                const SizedBox(height: 8),
                _buildPreviewInsightItem(
                    'Personality', 'Curious, detail-oriented...', settings),
                const SizedBox(height: 8),
                _buildPreviewInsightItem(
                    'Expertise', 'Intermediate to advanced...', settings),
              ],
            ),
          ),

          // Overlay with upgrade prompt
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: settings.getScaledFontSize(40),
                      color: const Color(0xFF0078D4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unlock AI Insights',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get personalized AI analysis of your communication style, interests, and preferences based on your conversations.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        UpgradeDialog.showAIInsightsFeature(context, () {
                          Navigator.pushNamed(context, '/subscription');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: settings.getScaledFontSize(24),
                          vertical: settings.getScaledFontSize(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: settings.getScaledFontSize(20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(16),
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  // Preview insight item for paywall (dimmed/blurred effect)
  Widget _buildPreviewInsightItem(
      String title, String preview, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade500
                : Colors.grey.shade400,
            size: settings.getScaledFontSize(20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(13),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
      String key, dynamic value, SettingsProvider settings) {
    final colors = context.howaiColors;
    final icons = {
      'communication_style': Icons.chat_bubble_outline,
      'topics_of_interest': Icons.interests_outlined,
      'personality_traits': Icons.psychology_outlined,
      'knowledge_level': Icons.school_outlined,
      'preferred_conversation_patterns': Icons.format_quote_outlined,
    };

    final titles = {
      'communication_style': 'Communication Style',
      'topics_of_interest': 'Interests',
      'personality_traits': 'Personality',
      'knowledge_level': 'Expertise',
      'preferred_conversation_patterns': 'Conversation Style',
    };

    final valueText = value is List ? value.join(', ') : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(
            icons[key] ?? Icons.info_outline,
            color: colors.textSecondary,
            size: settings.getScaledFontSize(20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[key] ?? key,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(13),
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
