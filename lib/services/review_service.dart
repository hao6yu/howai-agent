import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewService {
  static const String _aiMessagesCountKey = 'ai_messages_count';
  static const String _reviewRequestedKey = 'review_already_requested';
  static const String _reviewThresholdKey = 'review_threshold_debug'; // Debug key for threshold
  static const String _appStoreUrl = 'https://apps.apple.com/app/howai/id6746110671?action=write-review';
  static const int _defaultReviewThreshold = 20; // Default threshold

  /// Check if we should show the review request after this AI message
  static Future<bool> shouldShowReviewRequest() async {
    // Only show review request on iOS devices
    if (!Platform.isIOS) return false;

    final prefs = await SharedPreferences.getInstance();

    // Check if we've already requested a review
    final alreadyRequested = prefs.getBool(_reviewRequestedKey) ?? false;
    if (alreadyRequested) return false;

    // Get threshold (default 5, but can be overridden for debug)
    final threshold = prefs.getInt(_reviewThresholdKey) ?? _defaultReviewThreshold;

    // Check message count - show after exactly reaching threshold
    final currentCount = prefs.getInt(_aiMessagesCountKey) ?? 0;
    return currentCount == threshold;
  }

  /// Increment the AI message counter
  static Future<void> incrementAIMessage() async {
    // Only track messages on iOS devices
    if (!Platform.isIOS) return;

    final prefs = await SharedPreferences.getInstance();

    // Don't increment if we've already requested a review
    final alreadyRequested = prefs.getBool(_reviewRequestedKey) ?? false;
    if (alreadyRequested) return;

    // Increment AI message count
    final currentCount = prefs.getInt(_aiMessagesCountKey) ?? 0;
    await prefs.setInt(_aiMessagesCountKey, currentCount + 1);
  }

  /// Mark that we've already requested a review (one-time only)
  static Future<void> markReviewRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reviewRequestedKey, true);
  }

  /// Get the review request message text
  static String getReviewRequestMessage() {
    return """I'm really glad I could help you with these questions! 😊

If you're finding HowAI Agent useful, would you mind taking a moment to leave a review on the App Store? It would help other people discover our AI assistant too.

Your feedback means a lot and helps us improve! ⭐""";
  }

  /// Get the thank you message after user agrees to review
  static String getThankYouMessage() {
    return "Thank you so much! Your support means the world to us! 🙏";
  }

  /// Open the App Store review page
  static Future<void> openAppStoreReview() async {
    try {
      final uri = Uri.parse(_appStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // print('Failed to open App Store review page: $e');
    }
  }

  /// Get current status for debugging
  static Future<Map<String, dynamic>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'aiMessages': prefs.getInt(_aiMessagesCountKey) ?? 0,
      'reviewRequested': prefs.getBool(_reviewRequestedKey) ?? false,
      'threshold': prefs.getInt(_reviewThresholdKey) ?? _defaultReviewThreshold,
    };
  }

  /// Set custom review threshold for debugging (debug mode only)
  static Future<void> setDebugReviewThreshold(int threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reviewThresholdKey, threshold);
  }

  /// Get current review threshold
  static Future<int> getReviewThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reviewThresholdKey) ?? _defaultReviewThreshold;
  }

  /// Reset threshold to default
  static Future<void> resetThresholdToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewThresholdKey);
  }

  /// Reset the review state (for testing purposes)
  static Future<void> resetReviewState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_aiMessagesCountKey);
    await prefs.remove(_reviewRequestedKey);
  }
}
