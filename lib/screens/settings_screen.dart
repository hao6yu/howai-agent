import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/ai_personality_provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/review_service.dart';
import '../services/supabase_service.dart';
import '../models/profile.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'instructions_screen.dart';
import 'font_size_screen.dart';
import 'profile_screen.dart';
import 'voice_settings_screen.dart';
import 'usage_statistics_screen.dart';
import 'ai_personality_screen.dart';
import '../widgets/custom_back_button.dart';
import 'about_page.dart';
import '../services/feature_showcase_service.dart';

import 'package:haogpt/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAIPersonality());
  }

  Future<void> _loadAIPersonality() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final aiPersonalityProvider = Provider.of<AIPersonalityProvider>(context, listen: false);
    final currentProfileId = profileProvider.selectedProfileId;
    if (currentProfileId != null) {
      await aiPersonalityProvider.loadPersonalityForProfile(currentProfileId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.settings,
        elevation: 0,
        onBack: widget.onBack ?? () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildAccountSection(context),
          const SizedBox(height: 24),
          _buildSettingsSection(context),
          const SizedBox(height: 24),
          _buildMoreSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _buildDebugSection(context),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================== SECTION BUILDERS ====================

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      title: AppLocalizations.of(context)!.profileAndAbout,
      children: [
        _buildAccountRow(),
        _buildDivider(),
        _buildProfileRow(),
        _buildDivider(),
        _buildAIPersonalityRow(),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return _buildSection(
      title: AppLocalizations.of(context)!.settings,
      children: [
        _buildThemeSelector(),
        _buildDivider(),
        _buildLanguageSelector(),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.format_size_rounded,
          title: AppLocalizations.of(context)!.textSize,
          trailing: _buildTextSizePreview(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FontSizeScreen())),
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.record_voice_over_rounded,
          title: AppLocalizations.of(context)!.voiceSettings,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceSettingsScreen())),
        ),
        _buildDivider(),
        Consumer<SettingsProvider>(
          builder: (context, settings, _) => _buildToggleItem(
            icon: Icons.speaker_rounded,
            title: AppLocalizations.of(context)!.speakerAudio,
            value: settings.useSpeakerOutput,
            onChanged: settings.setUseSpeakerOutput,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    return _buildSection(
      title: AppLocalizations.of(context)!.advanced,
      children: [
        _buildNavItem(
          icon: Icons.workspace_premium_rounded,
          title: AppLocalizations.of(context)!.subscription,
          trailing: _buildSubscriptionBadge(),
          onTap: () => Navigator.pushNamed(context, '/subscription'),
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.analytics_rounded,
          title: AppLocalizations.of(context)!.usageStatistics,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsageStatisticsScreen())),
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.delete_outline_rounded,
          title: AppLocalizations.of(context)!.clearChatHistory,
          onTap: _showClearChatDialog,
          iconColor: Colors.red.shade400,
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.cleaning_services_rounded,
          title: AppLocalizations.of(context)!.cleanCachedFiles,
          onTap: _showClearCacheDialog,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: AppLocalizations.of(context)!.about,
      children: [
        _buildNavItem(
          icon: Icons.help_outline_rounded,
          title: AppLocalizations.of(context)!.helpAndInstructions,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstructionsScreen())),
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.info_outline_rounded,
          title: AppLocalizations.of(context)!.aboutHowAi,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
        ),
      ],
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    return _buildSection(
      title: 'Debug',
      titleColor: Colors.orange,
      children: [
        Consumer<SubscriptionService>(
          builder: (context, sub, _) => _buildToggleItem(
            icon: Icons.developer_mode,
            title: 'Test Premium Features',
            value: sub.isDebugOverrideActive && sub.isPremium,
            onChanged: (value) async {
              if (value) {
                await sub.setDebugPremiumOverride(true);
                if (mounted) _showSnackBar('Debug: Premium mode enabled', Colors.green);
              } else {
                await sub.clearDebugOverride();
                if (mounted) _showSnackBar('Debug: Using real subscription', Colors.blue);
              }
            },
          ),
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.science,
          title: 'Test Free Mode',
          onTap: () async {
            final sub = Provider.of<SubscriptionService>(context, listen: false);
            await sub.setDebugFreeOverride();
            if (mounted) _showSnackBar('Debug: Free mode enabled', Colors.orange);
          },
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.refresh,
          title: 'Reset Usage Stats',
          onTap: _showResetUsageDialog,
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.rate_review,
          title: 'Review Threshold',
          trailing: FutureBuilder<int>(
            future: ReviewService.getReviewThreshold(),
            builder: (context, snapshot) => _buildBadge('${snapshot.data ?? 5}'),
          ),
          onTap: _showReviewThresholdDialog,
        ),
        _buildDivider(),
        _buildNavItem(
          icon: Icons.lightbulb_outline,
          title: 'Reset Feature Showcase',
          onTap: _showResetShowcaseDialog,
        ),
      ],
    );
  }

  // ==================== ROW BUILDERS ====================

  Widget _buildAccountRow() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return _buildNavItem(
            icon: Icons.account_circle,
            title: auth.user?.email ?? 'Account',
            subtitle: 'Signed in',
            trailing: Icon(Icons.logout, color: Colors.grey.shade400, size: 20),
            onTap: () => _showSignOutDialog(),
          );
        }
        return _buildNavItem(
          icon: Icons.login,
          title: 'Sign In',
          subtitle: 'Sync your data across devices',
          onTap: () => Navigator.pushNamed(context, '/auth'),
        );
      },
    );
  }

  Widget _buildProfileRow() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profiles.firstWhere(
          (p) => p.id == profileProvider.selectedProfileId,
          orElse: () => Profile(id: 0, name: 'User', createdAt: null),
        );
        return _buildNavItem(
          icon: Icons.person_outline_rounded,
          title: 'User Profile',
          subtitle: profile.name,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        );
      },
    );
  }

  Widget _buildAIPersonalityRow() {
    return Consumer2<ProfileProvider, AIPersonalityProvider>(
      builder: (context, profileProvider, aiProvider, _) {
        final profileId = profileProvider.selectedProfileId;
        final personality = profileId != null ? aiProvider.getPersonalityForProfile(profileId) : null;
        return _buildNavItem(
          icon: Icons.smart_toy_outlined,
          title: 'AI Personality',
          subtitle: personality?.aiName ?? 'HowAI Agent',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIPersonalityScreen())),
        );
      },
    );
  }

  Widget _buildThemeSelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildIcon(Icons.palette_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.colorScheme,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildThemeSegmentedControl(settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSegmentedControl(SettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            icon: Icons.brightness_auto_rounded,
            isSelected: settings.themeMode == ThemeMode.system,
            onTap: () => settings.setThemeMode(ThemeMode.system),
            tooltip: AppLocalizations.of(context)!.colorSchemeSystem,
          ),
          _buildThemeOption(
            icon: Icons.wb_sunny_rounded,
            isSelected: settings.themeMode == ThemeMode.light,
            onTap: () => settings.setThemeMode(ThemeMode.light),
            tooltip: AppLocalizations.of(context)!.colorSchemeLight,
          ),
          _buildThemeOption(
            icon: Icons.dark_mode_rounded,
            isSelected: settings.themeMode == ThemeMode.dark,
            onTap: () => settings.setThemeMode(ThemeMode.dark),
            tooltip: AppLocalizations.of(context)!.colorSchemeDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0078D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildIcon(Icons.language_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.language,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildLanguageDropdown(settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageDropdown(SettingsProvider settings) {
    final languages = {
      null: AppLocalizations.of(context)!.systemDefault,
      'en': 'English',
      'zh': '中文',
      'zh_TW': '繁體中文',
      'ja': '日本語',
      'es': 'Español',
      'fr': 'Français',
      'hi': 'हिंदी',
      'ar': 'العربية',
      'ru': 'Русский',
      'pt_BR': 'Português',
      'ko': '한국어',
      'de': 'Deutsch',
      'id': 'Bahasa',
      'tr': 'Türkçe',
      'it': 'Italiano',
      'vi': 'Tiếng Việt',
      'pl': 'Polski',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: settings.selectedLocale,
          isDense: true,
          style: TextStyle(
            fontSize: settings.getScaledFontSize(14),
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          items: languages.entries.map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
          )).toList(),
          onChanged: (value) => settings.setSelectedLocale(value),
        ),
      ),
    );
  }

  // ==================== GENERIC WIDGETS ====================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) => Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: settings.getScaledFontSize(13),
                fontWeight: FontWeight.w600,
                color: titleColor ?? Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _buildIcon(icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(13),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildIcon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF0078D4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(IconData icon, {Color? color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF0078D4)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color ?? const Color(0xFF0078D4), size: 20),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100,
    );
  }

  Widget _buildTextSizePreview() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final scale = settings.fontSizeScale;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('A', style: TextStyle(
              fontSize: 12,
              color: scale <= 0.9 ? const Color(0xFF0078D4) : Colors.grey.shade400,
              fontWeight: scale <= 0.9 ? FontWeight.w600 : FontWeight.normal,
            )),
            const SizedBox(width: 2),
            Text('A', style: TextStyle(
              fontSize: 16,
              color: scale > 0.9 && scale <= 1.1 ? const Color(0xFF0078D4) : Colors.grey.shade400,
              fontWeight: scale > 0.9 && scale <= 1.1 ? FontWeight.w600 : FontWeight.normal,
            )),
            const SizedBox(width: 2),
            Text('A', style: TextStyle(
              fontSize: 20,
              color: scale > 1.1 ? const Color(0xFF0078D4) : Colors.grey.shade400,
              fontWeight: scale > 1.1 ? FontWeight.w600 : FontWeight.normal,
            )),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionBadge() {
    return Consumer<SubscriptionService>(
      builder: (context, sub, _) {
        if (sub.isPremium) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0078D4), Color(0xFF106ebe)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.premium,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
            ],
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context)!.free,
                style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0078D4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0078D4),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
      ],
    );
  }

  // ==================== DIALOGS ====================

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your data will remain on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (mounted) _showSnackBar('Signed out successfully', Colors.green);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    final isAuthenticated = Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearChatHistoryTitle),
        content: Text(
          isAuthenticated 
              ? 'This will permanently delete all your conversations from both this device and the cloud.'
              : AppLocalizations.of(context)!.clearChatHistoryWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearChatHistory();
            },
            child: Text(AppLocalizations.of(context)!.clear, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cleanCachedFiles),
        content: Text(AppLocalizations.of(context)!.deleteCachedFilesDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCache();
            },
            child: Text(AppLocalizations.of(context)!.clear, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Usage Statistics'),
        content: const Text('This will reset all usage counters for testing purposes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<SubscriptionService>(context, listen: false).resetUsageStats();
              if (mounted) _showSnackBar('Usage statistics reset', Colors.green);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showReviewThresholdDialog() async {
    final currentThreshold = await ReviewService.getReviewThreshold();
    final controller = TextEditingController(text: currentThreshold.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Threshold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set new threshold (1-20):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '1-20',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await ReviewService.resetThresholdToDefault();
              Navigator.pop(context);
              setState(() {});
              if (mounted) _showSnackBar('Threshold reset to default (5)', Colors.blue);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () async {
              final newThreshold = int.tryParse(controller.text.trim());
              if (newThreshold != null && newThreshold >= 1 && newThreshold <= 20) {
                await ReviewService.setDebugReviewThreshold(newThreshold);
                Navigator.pop(context);
                setState(() {});
                if (mounted) _showSnackBar('Threshold set to $newThreshold', Colors.green);
              }
            },
            child: const Text('Set', style: TextStyle(color: Color(0xFF0078D4))),
          ),
        ],
      ),
    );
  }

  void _showResetShowcaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Feature Showcase'),
        content: const Text('The showcase will appear next time you navigate to the chat screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await FeatureShowcaseService.resetShowcaseForTesting();
              Navigator.pop(context);
              if (mounted) _showSnackBar('Feature showcase reset', Colors.green);
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFF0078D4))),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _clearChatHistory() async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId != null) {
        if (authProvider.isAuthenticated) {
          final supabase = SupabaseService();
          final userId = supabase.currentUser?.id;
          if (userId != null) {
            await supabase.client.from('conversations').delete().eq('user_id', userId);
          }
        }

        await _databaseService.deleteAllChatMessages(profileId: currentProfileId);
        await _databaseService.deleteAllConversations(profileId: currentProfileId);

        profileProvider.clearChatHistoryNotify();
        conversationProvider.clearSelection();
        await conversationProvider.loadConversations(profileId: currentProfileId);

        if (mounted) _showSnackBar(AppLocalizations.of(context)!.chatHistoryCleared, Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackBar(AppLocalizations.of(context)!.failedToClearChat, Colors.red);
    }
  }

  Future<void> _clearCache() async {
    try {
      int deletedCount = 0;

      final docsDir = await getApplicationDocumentsDirectory();
      final pdfFiles = docsDir.listSync().where((f) => f is File && f.path.endsWith('.pdf') && f.path.contains('howai_'));
      for (final file in pdfFiles) {
        await (file as File).delete();
        deletedCount++;
      }

      final cacheDir = await getTemporaryDirectory();
      final imageFiles = cacheDir.listSync(recursive: true).where((f) => 
        f is File && (f.path.endsWith('.jpg') || f.path.endsWith('.jpeg') || f.path.endsWith('.png')) && f.path.contains('howai_'));
      for (final file in imageFiles) {
        await (file as File).delete();
        deletedCount++;
      }

      if (mounted) _showSnackBar(AppLocalizations.of(context)!.cleanedCachedFiles(deletedCount), Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar(AppLocalizations.of(context)!.failedToCleanCache, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
