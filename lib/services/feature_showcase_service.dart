import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/widgets.dart';
import '../generated/app_localizations.dart';

class FeatureShowcaseService {
  static const String _showcaseShownKey = 'feature_showcase_shown';
  static const String _lastShowcaseVersionKey = 'last_showcase_version';
  static const String _firstAppLaunchKey = 'first_app_launch_date';

  /// Check if we should show the showcase (only once per version with new features)
  static Future<bool> shouldShowShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // print('🎯 [FeatureShowcase] Checking if should show showcase...');
    // print('🎯 [FeatureShowcase] Current version: $currentVersion');

    // Store first launch date if not stored yet
    final firstLaunch = prefs.getString(_firstAppLaunchKey);
    if (firstLaunch == null) {
      await prefs.setString(_firstAppLaunchKey, DateTime.now().toIso8601String());
      // print('🎯 [FeatureShowcase] First app launch detected');
    }

    // Check if showcase was already shown for this version
    final lastShowcaseVersion = prefs.getString(_lastShowcaseVersionKey);
    final showcaseShown = prefs.getBool(_showcaseShownKey) ?? false;

    // print('🎯 [FeatureShowcase] Last showcase version: $lastShowcaseVersion');
    // print('🎯 [FeatureShowcase] Showcase shown for current version: $showcaseShown');

    // Show if:
    // 1. First-time user (never shown before), OR
    // 2. Version 1.3.4 user (and never shown for this version)
    final hasNewFeatures = _hasNewFeaturesForVersion(currentVersion);
    final isFirstTimeUser = !showcaseShown && lastShowcaseVersion == null;
    final isVersion134User = currentVersion == '1.3.4' && lastShowcaseVersion != '1.3.4';

    // print('🎯 [FeatureShowcase] Has new features for version: $hasNewFeatures');
    // print('🎯 [FeatureShowcase] Is first-time user: $isFirstTimeUser');
    // print('🎯 [FeatureShowcase] Is version 1.3.4 user: $isVersion134User');

    if (isFirstTimeUser || (isVersion134User && hasNewFeatures)) {
      // print('🎯 [FeatureShowcase] ✅ SHOULD SHOW SHOWCASE');
      // print('🎯 [FeatureShowcase] - showcaseShown: $showcaseShown');
      // print('🎯 [FeatureShowcase] - lastVersion: $lastShowcaseVersion');
      // print('🎯 [FeatureShowcase] - currentVersion: $currentVersion');
      // print('🎯 [FeatureShowcase] - hasNewFeatures: $hasNewFeatures');
      return true;
    }

    // print('🎯 [FeatureShowcase] ❌ Should NOT show showcase');
    return false;
  }

  /// Mark showcase as shown for current version
  static Future<void> markShowcaseShown() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    await prefs.setBool(_showcaseShownKey, true);
    await prefs.setString(_lastShowcaseVersionKey, currentVersion);

    // print('✅ Feature showcase marked as shown for version $currentVersion');
  }

  /// Check if current version has new features to showcase
  static bool _hasNewFeaturesForVersion(String version) {
    // Show features ONLY for version 1.3.4
    final versionNumber = version.split('.').map(int.tryParse).whereType<int>().toList();
    if (versionNumber.length >= 3) {
      // Only show for exactly version 1.3.4
      if (versionNumber[0] == 1 && versionNumber[1] == 3 && versionNumber[2] == 4) {
        return true;
      }
    }
    return false; // No showcase for other versions
  }

  /// Get list of features to showcase for current version
  static List<ShowcaseFeature> getFeaturesForCurrentVersion(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      ShowcaseFeature(
        id: 'tools_mode',
        title: l10n.featureShowcaseToolsModeTitle,
        description: l10n.featureShowcaseToolsModeDesc,
        isPremiumFeature: false,
      ),
      ShowcaseFeature(
        id: 'drawer_button',
        title: l10n.featureShowcaseDrawerButtonTitle,
        description: l10n.featureShowcaseDrawerButtonDesc,
        isPremiumFeature: false,
      ),
      ShowcaseFeature(
        id: 'quick_actions',
        title: l10n.featureShowcaseQuickActionsTitle,
        description: l10n.featureShowcaseQuickActionsDesc,
        isPremiumFeature: false,
      ),
      ShowcaseFeature(
        id: 'web_search',
        title: l10n.featureShowcaseWebSearchTitle,
        description: l10n.featureShowcaseWebSearchDesc,
        isPremiumFeature: true,
      ),
      ShowcaseFeature(
        id: 'deep_research',
        title: l10n.featureShowcaseDeepResearchTitle,
        description: l10n.featureShowcaseDeepResearchDesc,
        isPremiumFeature: true,
      ),
    ];
  }

  /// Reset showcase (for testing only)
  static Future<void> resetShowcaseForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_showcaseShownKey);
    await prefs.remove(_lastShowcaseVersionKey);
    // print('🔄 Showcase reset for testing');
  }

  /// Reset showcase and force it to show (for immediate testing)
  static Future<void> forceShowcaseForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_showcaseShownKey);
    await prefs.remove(_lastShowcaseVersionKey);
    // print('🔄 [FeatureShowcase] Showcase forced to show for testing');
  }

  /// Get showcase status (for debugging)
  static Future<Map<String, dynamic>> getShowcaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    return {
      'currentVersion': packageInfo.version,
      'showcaseShown': prefs.getBool(_showcaseShownKey) ?? false,
      'lastShowcaseVersion': prefs.getString(_lastShowcaseVersionKey) ?? 'never',
      'shouldShow': await shouldShowShowcase(),
      'firstLaunch': prefs.getString(_firstAppLaunchKey) ?? 'never',
    };
  }
}

class ShowcaseFeature {
  final String id;
  final String title;
  final String description;
  final bool isPremiumFeature;

  ShowcaseFeature({
    required this.id,
    required this.title,
    required this.description,
    this.isPremiumFeature = false,
  });
}
