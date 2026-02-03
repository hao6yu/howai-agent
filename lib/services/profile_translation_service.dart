import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';

class ProfileTranslationService {
  static const String _translationHistoryKey = 'translationHistory';
  static const int _maxHistorySize = 5;

  /// Add a language to user's translation history in their profile
  static Future<void> addTranslationChoice(BuildContext context, String languageCode) async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId == null) {
        return;
      }

      final currentProfile = profileProvider.profiles.firstWhere(
        (p) => p.id == currentProfileId,
        orElse: () => throw Exception('Profile not found'),
      );

      // Get current translation history from profile preferences
      final currentPreferences = Map<String, dynamic>.from(currentProfile.preferences);
      List<String> history = List<String>.from(currentPreferences[_translationHistoryKey] ?? []);

      // Remove if already exists to move it to front
      history.removeWhere((code) => code == languageCode);

      // Add to front
      history.insert(0, languageCode);

      // Keep only the most recent choices
      if (history.length > _maxHistorySize) {
        history = history.take(_maxHistorySize).toList();
      }

      // Update profile preferences
      currentPreferences[_translationHistoryKey] = history;

      await profileProvider.updateProfilePreferences(currentProfileId, currentPreferences);
    } catch (e) {
      // Silently handle error
    }
  }

  /// Get user's translation history from their profile
  static List<String> getTranslationHistory(BuildContext context) {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId == null) {
        return [];
      }

      final currentProfile = profileProvider.profiles.firstWhere(
        (p) => p.id == currentProfileId,
        orElse: () => throw Exception('Profile not found'),
      );

      final history = List<String>.from(currentProfile.preferences[_translationHistoryKey] ?? []);
      return history;
    } catch (e) {
      return [];
    }
  }

  /// Clear translation history for current profile
  static Future<void> clearTranslationHistory(BuildContext context) async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentProfileId = profileProvider.selectedProfileId;

      if (currentProfileId == null) return;

      final currentProfile = profileProvider.profiles.firstWhere(
        (p) => p.id == currentProfileId,
        orElse: () => throw Exception('Profile not found'),
      );

      final currentPreferences = Map<String, dynamic>.from(currentProfile.preferences);
      currentPreferences.remove(_translationHistoryKey);

      await profileProvider.updateProfilePreferences(currentProfileId, currentPreferences);
    } catch (e) {
      // Silently handle error
    }
  }
}
