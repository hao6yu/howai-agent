import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import '../models/ai_personality.dart';

class AIPersonalityService {
  static final AIPersonalityService _instance =
      AIPersonalityService._internal();
  factory AIPersonalityService() => _instance;
  AIPersonalityService._internal();

  final SupabaseService _supabase = SupabaseService();

  // The durable HowAI identity lives in the Supabase proxy. The client adds
  // only request-specific context and user-configured style preferences.
  static String generateConciseSystemPrompt({
    String? userName,
    String? characteristicsSummary,
    bool generateTitle = false,
    bool isPremiumUser = false,
    dynamic aiPersonality, // AIPersonality object from database
    bool userWantsPresentations = false, // Intent detection result
  }) {
    final now = DateTime.now();
    final currentDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (aiPersonality != null) {
      return aiPersonality.generateSystemPrompt(
        userName: userName,
      );
    }
    final displayName = _safeDisplayName(userName);
    return """<howai_request_context>
Local date: $currentDate
${displayName == null ? '' : 'User display name: $displayName'}
</howai_request_context>""";
  }

  // Helper method to generate time-aware search hints for the AI
  static String getTimeAwareSearchHints() {
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Calculate last week's date range
    final lastWeekEnd =
        now.subtract(Duration(days: now.weekday)); // Last Sunday
    final lastWeekStart =
        lastWeekEnd.subtract(Duration(days: 6)); // Previous Monday
    final lastWeekRange =
        "${lastWeekStart.month}/${lastWeekStart.day} to ${lastWeekEnd.month}/${lastWeekEnd.day}";

    // Calculate this week's start
    final thisWeekStart =
        now.subtract(Duration(days: now.weekday - 1)); // This Monday
    final thisWeekRange = "since ${thisWeekStart.month}/${thisWeekStart.day}";

    return """
**Time Context for Search Queries:**
- Today: $today
- This week: $thisWeekRange  
- Last week: $lastWeekRange
- Use these in search queries for accurate time-based results
""";
  }

  // Generate the complete system prompt
  static String generateSystemPrompt({
    String? userName,
    String? characteristicsSummary,
    bool generateTitle = false,
  }) {
    return generateConciseSystemPrompt(userName: userName);
  }

  // Helper method to get personality summary for debugging
  static String getPersonalitySummary() {
    return 'HowAI core policy is server-owned; the client supplies only '
        'request context and explicit style preferences.';
  }

  // Method to update specific personality aspects (for future improvements)
  static Map<String, String> getPersonalityComponents() {
    return {
      'source': 'server-owned',
      'tone': 'warm, direct, adaptable',
      'language': 'follow intentional code-switching',
    };
  }

  static String? _safeDisplayName(String? value) {
    if (value == null) return null;
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return null;
    return compact.length <= 80 ? compact : compact.substring(0, 80);
  }

  /// Sync AI personality to Supabase
  Future<String?> syncPersonalityToSupabase(AIPersonality personality) async {
    try {
      if (!_supabase.isAuthenticated) {
        debugPrint(
            '[AIPersonalityService] Not authenticated, skipping personality sync');
        return null;
      }

      final userId = _supabase.currentUser!.id;

      final data = {
        'user_id': userId,
        'ai_name': personality.aiName,
        'gender': personality.gender,
        'age': personality.age,
        'personality': personality.personality,
        'communication_style': personality.communicationStyle,
        'expertise': personality.expertise,
        'humor_level': personality.humorLevel,
        'response_length': personality.responseLength,
        'interests': personality.interests,
        'background_story': personality.backgroundStory,
        'avatar_url': personality.avatarUrl,
        'is_active': personality.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // If personality has a UUID, update it; otherwise insert
      if (personality.supabaseId != null) {
        await _supabase.client
            .from('ai_personalities')
            .update(data)
            .eq('id', personality.supabaseId!);

        debugPrint(
            '[AIPersonalityService] Updated personality in Supabase: ${personality.supabaseId}');
        return personality.supabaseId;
      } else {
        final response = await _supabase.client
            .from('ai_personalities')
            .insert(data)
            .select()
            .single();

        final uuid = response['id'] as String;
        debugPrint(
            '[AIPersonalityService] Created personality in Supabase: $uuid');
        return uuid;
      }
    } catch (e) {
      debugPrint(
          '[AIPersonalityService] Error syncing personality (silent): $e');
      return null; // Silent failure
    }
  }

  /// Load AI personalities from Supabase
  Future<List<AIPersonality>> loadPersonalitiesFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) {
        debugPrint(
            '[AIPersonalityService] Not authenticated, skipping personality load');
        return [];
      }

      final userId = _supabase.currentUser!.id;

      final response = await _supabase.client
          .from('ai_personalities')
          .select()
          .eq('user_id', userId);

      final personalities = <AIPersonality>[];
      for (final data in response) {
        personalities.add(AIPersonality.fromSupabase(data));
      }

      debugPrint(
          '[AIPersonalityService] Loaded ${personalities.length} personalities from Supabase');
      return personalities;
    } catch (e) {
      debugPrint(
          '[AIPersonalityService] Error loading personalities (silent): $e');
      return []; // Silent failure
    }
  }

  /// Delete AI personality from Supabase
  Future<bool> deletePersonalityFromSupabase(String supabaseId) async {
    try {
      if (!_supabase.isAuthenticated) {
        debugPrint(
            '[AIPersonalityService] Not authenticated, skipping personality delete');
        return false;
      }

      await _supabase.client
          .from('ai_personalities')
          .delete()
          .eq('id', supabaseId);

      debugPrint(
          '[AIPersonalityService] Deleted personality from Supabase: $supabaseId');
      return true;
    } catch (e) {
      debugPrint(
          '[AIPersonalityService] Error deleting personality (silent): $e');
      return false; // Silent failure
    }
  }
}
