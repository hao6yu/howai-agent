import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_service.dart';

// Debug flag to bypass subscription validation for development
const bool kBypassSubscriptionForDebug = false; // Set to false in production

enum SubscriptionTier {
  free,
  premium,
}

class SubscriptionLimits {
  final int imageAnalysisWeekly;
  final int voiceGenerationsWeekly;
  final int imageGenerationsWeekly; // Weekly limit for image generation
  final int pdfGenerationsWeekly; // Weekly limit for PDF generation
  final int placesExplorerWeekly; // Weekly limit for places explorer
  final int documentAnalysisWeekly; // Weekly limit for document analysis
  final bool hasPptxGeneration; // PPTX generation availability
  final bool hasWebSearch;
  final bool hasElevenLabs;
  final bool hasCustomSystemPrompt;
  final bool hasVoiceSettings;
  final bool hasUnlimitedImages;

  const SubscriptionLimits({
    required this.imageAnalysisWeekly,
    required this.voiceGenerationsWeekly,
    required this.imageGenerationsWeekly,
    required this.pdfGenerationsWeekly,
    required this.placesExplorerWeekly,
    required this.documentAnalysisWeekly,
    required this.hasPptxGeneration,
    required this.hasWebSearch,
    required this.hasElevenLabs,
    required this.hasCustomSystemPrompt,
    required this.hasVoiceSettings,
    required this.hasUnlimitedImages,
  });

  static const SubscriptionLimits free = SubscriptionLimits(
    imageAnalysisWeekly: 15, // 15 photo analysis per week
    voiceGenerationsWeekly: -1, // Device TTS is unlimited for free users
    imageGenerationsWeekly: 5, // 5 image generations per week
    pdfGenerationsWeekly: 20, // 20 PDF generations per week
    placesExplorerWeekly: 10, // 10 places explorer uses per week
    documentAnalysisWeekly: 10, // 10 document analysis uses per week
    hasPptxGeneration: false, // PPTX generation is premium only
    hasWebSearch: false,
    hasElevenLabs: false, // ElevenLabs is premium only
    hasCustomSystemPrompt: false,
    hasVoiceSettings: false,
    hasUnlimitedImages: false,
  );

  static const SubscriptionLimits premium = SubscriptionLimits(
    imageAnalysisWeekly: -1, // -1 means unlimited
    voiceGenerationsWeekly: -1,
    imageGenerationsWeekly: -1, // Unlimited for premium
    pdfGenerationsWeekly: -1, // Unlimited for premium
    placesExplorerWeekly: -1, // Unlimited for premium
    documentAnalysisWeekly: -1, // Unlimited for premium
    hasPptxGeneration: true, // PPTX generation available for premium
    hasWebSearch: true,
    hasElevenLabs: true,
    hasCustomSystemPrompt: true,
    hasVoiceSettings: true,
    hasUnlimitedImages: true,
  );
}

class UsageStats {
  final int imageAnalysisCount;
  final int voiceGenerationsCount;
  final int imageGenerationsCount; // New field for image generation tracking
  final int pdfGenerationsCount; // New field for PDF generation tracking
  final int placesExplorerCount; // New field for places explorer tracking
  final int documentAnalysisCount; // New field for document analysis tracking
  final DateTime lastReset;

  const UsageStats({
    required this.imageAnalysisCount,
    required this.voiceGenerationsCount,
    required this.imageGenerationsCount,
    required this.pdfGenerationsCount,
    required this.placesExplorerCount,
    required this.documentAnalysisCount,
    required this.lastReset,
  });

  factory UsageStats.empty() {
    return UsageStats(
      imageAnalysisCount: 0,
      voiceGenerationsCount: 0,
      imageGenerationsCount: 0,
      pdfGenerationsCount: 0,
      placesExplorerCount: 0,
      documentAnalysisCount: 0,
      lastReset: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageAnalysisCount': imageAnalysisCount,
      'voiceGenerationsCount': voiceGenerationsCount,
      'imageGenerationsCount': imageGenerationsCount,
      'pdfGenerationsCount': pdfGenerationsCount,
      'placesExplorerCount': placesExplorerCount,
      'documentAnalysisCount': documentAnalysisCount,
      'lastReset': lastReset.millisecondsSinceEpoch,
    };
  }

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      imageAnalysisCount: json['imageAnalysisCount'] ?? 0,
      voiceGenerationsCount: json['voiceGenerationsCount'] ?? 0,
      imageGenerationsCount: json['imageGenerationsCount'] ?? 0,
      pdfGenerationsCount: json['pdfGenerationsCount'] ?? 0,
      placesExplorerCount: json['placesExplorerCount'] ?? 0,
      documentAnalysisCount: json['documentAnalysisCount'] ?? 0,
      lastReset: DateTime.fromMillisecondsSinceEpoch(json['lastReset'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class SubscriptionService with ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  final SupabaseService _supabase = SupabaseService();

  factory SubscriptionService() => _instance;

  SubscriptionService._internal() {
    _initialize();
  }

  // Platform-specific Product IDs
  // iOS App Store IDs (mixed case - existing subscribers)
  static const String _iosMonthlySubscriptionId = 'com.hyu.HaoGPT.premium.monthly';
  static const String _iosYearlySubscriptionId = 'com.haoyu.HaoGPT.premium.yearly';

  // Google Play Store IDs (lowercase only - new requirement)
  static const String _androidMonthlySubscriptionId = 'com.hyu.haogpt.premium.monthly';
  static const String _androidYearlySubscriptionId = 'com.haoyu.haogpt.premium.yearly';

  // Get platform-specific product IDs
  static String get monthlySubscriptionId {
    final isIOS = Platform.isIOS;
    final productId = isIOS ? _iosMonthlySubscriptionId : _androidMonthlySubscriptionId;
    //// print('[SubscriptionService] Platform.isIOS: $isIOS, Monthly Product ID: $productId');
    return productId;
  }

  static String get yearlySubscriptionId {
    final isIOS = Platform.isIOS;
    final productId = isIOS ? _iosYearlySubscriptionId : _androidYearlySubscriptionId;
    //// print('[SubscriptionService] Platform.isIOS: $isIOS, Yearly Product ID: $productId');
    return productId;
  }

  // Get actual recurring price, with platform-specific handling
  String getActualPrice(ProductDetails product) {
    // iOS: Always use the product.price as-is (Apple handles this correctly)
    if (Platform.isIOS) {
      return product.price;
    }

    // Android: Handle free trial pricing display issues
    // First: If we have a valid price that's not "Free", use it
    if (product.price.isNotEmpty &&
        !product.price.toLowerCase().contains('free') &&
        !product.price.toLowerCase().contains('试用') && // Chinese "trial"
        !product.price.toLowerCase().contains('gratuit') && // French "free"
        !product.price.toLowerCase().contains('gratis') && // Spanish/German "free"
        !product.price.toLowerCase().contains('無料') && // Japanese "free"
        product.price != '0') {
      return product.price;
    }

    // Second: Try rawPrice (works with international currencies)
    if (product.rawPrice > 0) {
      final actualPrice = product.rawPrice / 1000000;
      final currencySymbol = product.currencySymbol.isNotEmpty ? product.currencySymbol : _getCurrencySymbol(product.currencyCode);
      final formattedPrice = '$currencySymbol${actualPrice.toStringAsFixed(2)}';
      return formattedPrice;
    }

    // Third: Fallback to hardcoded USD prices (when all else fails)
    if (product.id == monthlySubscriptionId) {
      return '\$7.99';
    } else if (product.id == yearlySubscriptionId) {
      return '\$79.99';
    }

    return 'Free Trial';
  }

  // Helper method to get currency symbol from currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return currencyCode + ' '; // Fallback to currency code
    }
  }

  // Debug override flag with three states:
  // null = use real subscription status
  // true = force premium (regardless of real status)
  // false = force free (regardless of real status)
  bool? _debugOverridePremium;
  bool get isDebugOverrideActive => _debugOverridePremium != null;
  bool get isDebugPremiumOverride => _debugOverridePremium == true;
  bool get isDebugFreeOverride => _debugOverridePremium == false;

  // Setter for debug override
  Future<void> setDebugPremiumOverride(bool value) async {
    // If turning off the override, set to null to use real subscription
    // If turning on, set to the specified value
    _debugOverridePremium = value ? true : null;

    // Save to preferences for persistence
    final prefs = await SharedPreferences.getInstance();
    if (_debugOverridePremium == null) {
      await prefs.remove('debug_override_premium');
    } else {
      await prefs.setBool('debug_override_premium', _debugOverridePremium!);
    }

    //// print('[SubscriptionService] Debug premium override set to: $_debugOverridePremium (active: $isDebugOverrideActive)');
    notifyListeners();
  }

  // Force debug mode to free (for testing free features)
  Future<void> setDebugFreeOverride() async {
    _debugOverridePremium = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('debug_override_premium', false);

    //// print('[SubscriptionService] Debug free override activated');
    notifyListeners();
  }

  // Clear debug override (use real subscription status)
  Future<void> clearDebugOverride() async {
    _debugOverridePremium = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('debug_override_premium');

    //// print('[SubscriptionService] Debug override cleared - using real subscription status');
    notifyListeners();
  }

  // Debug method to clear subscription status locally (for testing)
  Future<void> clearLocalSubscriptionForTesting() async {
    if (!kDebugMode) return; // Only work in debug mode

    _isSubscribed = false;
    _subscriptionTier = SubscriptionTier.free;
    _debugOverridePremium = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSubscribed', false);
    await prefs.setString('subscriptionTier', 'free');
    await prefs.remove('debug_override_premium');

    //// print('[SubscriptionService] Local subscription cleared for testing');
    notifyListeners();
  }

  // Get real subscription status (without debug override)
  bool get _realSubscriptionStatus => kBypassSubscriptionForDebug || (_isSubscribed && _subscriptionTier == SubscriptionTier.premium);

  // Stream subscription for purchase updates
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // In-app purchase instance
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Subscription status
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  // Subscription tier
  SubscriptionTier _subscriptionTier = SubscriptionTier.free;
  SubscriptionTier get subscriptionTier => _subscriptionTier;

  // Usage statistics
  UsageStats _usageStats = UsageStats.empty();
  UsageStats get usageStats => _usageStats;

  // List of available products
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  // Get specific products
  ProductDetails? get monthlyProduct => _products.where((p) => p.id == monthlySubscriptionId).firstOrNull;
  ProductDetails? get yearlyProduct => _products.where((p) => p.id == yearlySubscriptionId).firstOrNull;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Convenience getters for subscription status (with debug override)
  bool get isPremium {
    // If debug override is active, use that
    if (_debugOverridePremium != null) {
      return _debugOverridePremium == true;
    }
    // Otherwise use real subscription status
    return _realSubscriptionStatus;
  }

  bool get isFree => !isPremium;

  // Get current subscription limits
  SubscriptionLimits get limits => isPremium ? SubscriptionLimits.premium : SubscriptionLimits.free;

  // Feature access methods
  bool get canUseWebSearch => limits.hasWebSearch;
  bool get canUseElevenLabs => limits.hasElevenLabs;
  bool get canUseCustomSystemPrompt => limits.hasCustomSystemPrompt;
  bool get canUseVoiceSettings => limits.hasVoiceSettings;
  bool get canUsePptxGeneration => limits.hasPptxGeneration;

  // Get the allowed model based on subscription tier from environment variables
  String get allowedModel {
    if (isPremium) {
      return dotenv.env['OPENAI_CHAT_MODEL'] ?? 'gpt-5.2'; // Fallback to gpt-5.2 if not set
    } else {
      return dotenv.env['OPENAI_CHAT_MINI_MODEL'] ?? 'gpt-5-nano'; // Fallback to gpt-5-nano if not set
    }
  }

  // Usage check methods
  bool get canUseImageAnalysis {
    if (isPremium) return true;
    return _usageStats.imageAnalysisCount < limits.imageAnalysisWeekly;
  }

  bool get canUseVoiceGeneration {
    // Device TTS is always available for all users
    return true;
  }

  bool get canUseImageGeneration {
    if (isPremium) return true;
    return _usageStats.imageGenerationsCount < limits.imageGenerationsWeekly;
  }

  bool get canUsePdfGeneration {
    if (isPremium) return true;
    return _usageStats.pdfGenerationsCount < limits.pdfGenerationsWeekly;
  }

  bool get canUsePlacesExplorer {
    if (isPremium) return true;
    return _usageStats.placesExplorerCount < limits.placesExplorerWeekly;
  }

  bool get canUseDocumentAnalysis {
    if (isPremium) return true;
    return _usageStats.documentAnalysisCount < limits.documentAnalysisWeekly;
  }

  int get remainingImageAnalysis {
    if (isPremium) return -1; // Unlimited
    if (limits.imageAnalysisWeekly == -1) return -1; // Handle unlimited case
    return (limits.imageAnalysisWeekly - _usageStats.imageAnalysisCount).clamp(0, limits.imageAnalysisWeekly);
  }

  int get remainingVoiceGenerations {
    if (isPremium) return -1; // Unlimited
    if (limits.voiceGenerationsWeekly == -1) return -1; // Unlimited for free users too (device TTS)
    return (limits.voiceGenerationsWeekly - _usageStats.voiceGenerationsCount).clamp(0, limits.voiceGenerationsWeekly);
  }

  int get remainingImageGenerations {
    if (isPremium) return -1; // Unlimited
    if (limits.imageGenerationsWeekly == -1) return -1; // Handle unlimited case
    return (limits.imageGenerationsWeekly - _usageStats.imageGenerationsCount).clamp(0, limits.imageGenerationsWeekly);
  }

  int get remainingPdfGenerations {
    if (isPremium) return -1; // Unlimited
    if (limits.pdfGenerationsWeekly == -1) return -1; // Handle unlimited case
    return (limits.pdfGenerationsWeekly - _usageStats.pdfGenerationsCount).clamp(0, limits.pdfGenerationsWeekly);
  }

  int get remainingPlacesExplorer {
    if (isPremium) return -1; // Unlimited
    if (limits.placesExplorerWeekly == -1) return -1; // Handle unlimited case
    return (limits.placesExplorerWeekly - _usageStats.placesExplorerCount).clamp(0, limits.placesExplorerWeekly);
  }

  int get remainingDocumentAnalysis {
    if (isPremium) return -1; // Unlimited
    if (limits.documentAnalysisWeekly == -1) return -1; // Handle unlimited case
    return (limits.documentAnalysisWeekly - _usageStats.documentAnalysisCount).clamp(0, limits.documentAnalysisWeekly);
  }

  // Debug methods
  Future<void> _loadDebugOverride() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('debug_override_premium')) {
        _debugOverridePremium = prefs.getBool('debug_override_premium');
        //// print('[SubscriptionService] Debug override loaded: $_debugOverridePremium');
      } else {
        _debugOverridePremium = null;
        //// print('[SubscriptionService] No debug override found - using real subscription');
      }
    } catch (e) {
      //// print('[SubscriptionService] Error loading debug override: $e');
      _debugOverridePremium = null;
    }
  }

  // Initialize the subscription service
  Future<void> _initialize() async {
    //// print('[SubscriptionService] Initializing...');

    try {
      // Load debug override first
      await _loadDebugOverride();

      // Load usage stats first
      await _loadUsageStats();

      // Set up the in-app purchase listener
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;

      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          //// print('[SubscriptionService] Purchase stream error: $error');
          _errorMessage = "Purchase stream error: $error";
          notifyListeners();
        },
      );

      // Load products and check subscription status
      await _loadProducts();
      await checkSubscriptionStatus();

      // Load subscription status from Supabase if authenticated
      await _loadSubscriptionFromSupabase();

      //// print('[SubscriptionService] Initialization complete. isPremium: $isPremium');
    } catch (e) {
      //// print('[SubscriptionService] Error during initialization: $e');
      _errorMessage = "Initialization error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load usage statistics from local storage
  Future<void> _loadUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('usage_stats');

      if (statsJson != null) {
        final Map<String, dynamic> data = {};
        // Simple JSON parsing for basic types
        final parts = statsJson.split(',');
        for (final part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = keyValue[1].trim();
            if (key == 'imageAnalysisCount' || key == 'voiceGenerationsCount') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'imageGenerationsCount') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'pdfGenerationsCount') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'placesExplorerCount') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'documentAnalysisCount') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'lastReset') {
              data[key] = int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
            }
          }
        }
        _usageStats = UsageStats.fromJson(data);
      } else {
        _usageStats = UsageStats.empty();
      }

      // Check if we need to reset weekly usage
      await _checkAndResetWeeklyUsage();

      //// print('[SubscriptionService] Usage stats loaded: imageAnalysis=${_usageStats.imageAnalysisCount}, voiceGenerations=${_usageStats.voiceGenerationsCount}, imageGenerations=${_usageStats.imageGenerationsCount}, pdfGenerations=${_usageStats.pdfGenerationsCount}, placesExplorer=${_usageStats.placesExplorerCount}, documentAnalysis=${_usageStats.documentAnalysisCount}');
    } catch (e) {
      //// print('[SubscriptionService] Error loading usage stats: $e');
      _usageStats = UsageStats.empty();
    }
  }

  // Save usage statistics to local storage
  Future<void> _saveUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simple JSON string creation
      final statsJson =
          'imageAnalysisCount:${_usageStats.imageAnalysisCount},voiceGenerationsCount:${_usageStats.voiceGenerationsCount},imageGenerationsCount:${_usageStats.imageGenerationsCount},pdfGenerationsCount:${_usageStats.pdfGenerationsCount},placesExplorerCount:${_usageStats.placesExplorerCount},documentAnalysisCount:${_usageStats.documentAnalysisCount},lastReset:${_usageStats.lastReset.millisecondsSinceEpoch}';
      await prefs.setString('usage_stats', statsJson);
      //// print('[SubscriptionService] Usage stats saved');
    } catch (e) {
      //// print('[SubscriptionService] Error saving usage stats: $e');
    }
  }

  // Weekly reset functionality - check and reset usage if a week has passed
  Future<void> _checkAndResetWeeklyUsage() async {
    final now = DateTime.now();
    final lastReset = _usageStats.lastReset;

    // Check if a week (7 days) has passed since last reset
    final daysSinceReset = now.difference(lastReset).inDays;

    if (daysSinceReset >= 7) {
      // Reset all usage counts
      _usageStats = UsageStats(
        imageAnalysisCount: 0,
        voiceGenerationsCount: 0,
        imageGenerationsCount: 0,
        pdfGenerationsCount: 0,
        placesExplorerCount: 0,
        documentAnalysisCount: 0,
        lastReset: now,
      );

      await _saveUsageStats();
      notifyListeners();

      //// print('[SubscriptionService] Weekly usage reset completed. Days since last reset: $daysSinceReset');
    }
  }

  // Track image analysis usage
  Future<bool> tryUseImageAnalysis() async {
    if (isPremium) {
      //// print('[SubscriptionService] Image analysis used (Premium - unlimited)');
      return true;
    }

    //await _checkAndResetWeeklyUsage();

    if (_usageStats.imageAnalysisCount >= limits.imageAnalysisWeekly) {
      //// print('[SubscriptionService] Image analysis limit reached');
      return false;
    }

    _usageStats = UsageStats(
      imageAnalysisCount: _usageStats.imageAnalysisCount + 1,
      voiceGenerationsCount: _usageStats.voiceGenerationsCount,
      imageGenerationsCount: _usageStats.imageGenerationsCount,
      pdfGenerationsCount: _usageStats.pdfGenerationsCount,
      placesExplorerCount: _usageStats.placesExplorerCount,
      documentAnalysisCount: _usageStats.documentAnalysisCount,
      lastReset: _usageStats.lastReset,
    );

    await _saveUsageStats();
    notifyListeners();

    //// print('[SubscriptionService] Image analysis used. Count: ${_usageStats.imageAnalysisCount}/${limits.imageAnalysisWeekly} (weekly)');
    return true;
  }

  // Track voice generation usage (Note: Device TTS is unlimited for all users)
  Future<bool> tryUseVoiceGeneration() async {
    // Device TTS is unlimited for all users, so always allow
    if (!isPremium) {
      //// print('[SubscriptionService] Device TTS used (Free - unlimited)');
      return true;
    }

    // For premium users, also unlimited (but could use ElevenLabs)
    //// print('[SubscriptionService] Voice generation used (Premium - unlimited)');
    return true;
  }

  // Track image generation usage
  Future<bool> tryUseImageGeneration() async {
    if (isPremium) {
      //// print('[SubscriptionService] Image generation used (Premium - unlimited)');
      return true;
    }

    await _checkAndResetWeeklyUsage();

    if (_usageStats.imageGenerationsCount >= limits.imageGenerationsWeekly) {
      //// print('[SubscriptionService] Image generation limit reached');
      return false;
    }

    _usageStats = UsageStats(
      imageAnalysisCount: _usageStats.imageAnalysisCount,
      voiceGenerationsCount: _usageStats.voiceGenerationsCount,
      imageGenerationsCount: _usageStats.imageGenerationsCount + 1,
      pdfGenerationsCount: _usageStats.pdfGenerationsCount,
      placesExplorerCount: _usageStats.placesExplorerCount,
      documentAnalysisCount: _usageStats.documentAnalysisCount,
      lastReset: _usageStats.lastReset,
    );

    await _saveUsageStats();
    notifyListeners();

    //// print('[SubscriptionService] Image generation used. Count: ${_usageStats.imageGenerationsCount}/${limits.imageGenerationsWeekly} (weekly)');
    return true;
  }

  // Check if user can use ElevenLabs TTS (premium feature)
  Future<bool> tryUseElevenLabsTTS() async {
    if (!isPremium) {
      //// print('[SubscriptionService] ElevenLabs TTS not available for free users');
      return false;
    }

    if (!canUseElevenLabs) {
      //// print('[SubscriptionService] ElevenLabs feature not enabled');
      return false;
    }

    //// print('[SubscriptionService] ElevenLabs TTS authorized for premium user');
    return true;
  }

  // Track PDF generation usage
  Future<bool> tryUsePdfGeneration() async {
    if (isPremium) {
      //// print('[SubscriptionService] PDF generation used (Premium - unlimited)');
      return true;
    }

    await _checkAndResetWeeklyUsage();

    if (_usageStats.pdfGenerationsCount >= limits.pdfGenerationsWeekly) {
      //// print('[SubscriptionService] PDF generation limit reached');
      return false;
    }

    _usageStats = UsageStats(
      imageAnalysisCount: _usageStats.imageAnalysisCount,
      voiceGenerationsCount: _usageStats.voiceGenerationsCount,
      imageGenerationsCount: _usageStats.imageGenerationsCount,
      pdfGenerationsCount: _usageStats.pdfGenerationsCount + 1,
      placesExplorerCount: _usageStats.placesExplorerCount,
      documentAnalysisCount: _usageStats.documentAnalysisCount,
      lastReset: _usageStats.lastReset,
    );

    await _saveUsageStats();
    notifyListeners();

    //// print('[SubscriptionService] PDF generation used. Count: ${_usageStats.pdfGenerationsCount}/${limits.pdfGenerationsWeekly} (weekly)');
    return true;
  }

  // Track places explorer usage
  Future<bool> tryUsePlacesExplorer() async {
    if (isPremium) {
      //// print('[SubscriptionService] Places explorer used (Premium - unlimited)');
      return true;
    }

    await _checkAndResetWeeklyUsage();

    if (_usageStats.placesExplorerCount >= limits.placesExplorerWeekly) {
      //// print('[SubscriptionService] Places explorer limit reached');
      return false;
    }

    _usageStats = UsageStats(
      imageAnalysisCount: _usageStats.imageAnalysisCount,
      voiceGenerationsCount: _usageStats.voiceGenerationsCount,
      imageGenerationsCount: _usageStats.imageGenerationsCount,
      pdfGenerationsCount: _usageStats.pdfGenerationsCount,
      placesExplorerCount: _usageStats.placesExplorerCount + 1,
      documentAnalysisCount: _usageStats.documentAnalysisCount,
      lastReset: _usageStats.lastReset,
    );

    await _saveUsageStats();
    notifyListeners();

    //// print('[SubscriptionService] Places explorer used. Count: ${_usageStats.placesExplorerCount}/${limits.placesExplorerWeekly} (weekly)');
    return true;
  }

  // Track document analysis usage
  Future<bool> tryUseDocumentAnalysis() async {
    if (isPremium) {
      //// print('[SubscriptionService] Document analysis used (Premium - unlimited)');
      return true;
    }

    await _checkAndResetWeeklyUsage();

    if (_usageStats.documentAnalysisCount >= limits.documentAnalysisWeekly) {
      //// print('[SubscriptionService] Document analysis limit reached');
      return false;
    }

    _usageStats = UsageStats(
      imageAnalysisCount: _usageStats.imageAnalysisCount,
      voiceGenerationsCount: _usageStats.voiceGenerationsCount,
      imageGenerationsCount: _usageStats.imageGenerationsCount,
      pdfGenerationsCount: _usageStats.pdfGenerationsCount,
      placesExplorerCount: _usageStats.placesExplorerCount,
      documentAnalysisCount: _usageStats.documentAnalysisCount + 1,
      lastReset: _usageStats.lastReset,
    );

    await _saveUsageStats();
    notifyListeners();

    //// print('[SubscriptionService] Document analysis used. Count: ${_usageStats.documentAnalysisCount}/${limits.documentAnalysisWeekly} (weekly)');
    return true;
  }

  // Check if user can use device TTS (free feature)
  bool canUseDeviceTTS() {
    // Device TTS is always available for all users
    return true;
  }

  // Load available products from the store
  Future<void> _loadProducts() async {
    try {
      //// print('[SubscriptionService] ======== LOADING PRODUCTS ========');
      //// print('[SubscriptionService] Platform: ${Platform.operatingSystem}');
      //// print('[SubscriptionService] Platform.isIOS: ${Platform.isIOS}');
      //// print('[SubscriptionService] Platform.isAndroid: ${Platform.isAndroid}');

      final Set<String> productIds = {monthlySubscriptionId, yearlySubscriptionId};
      //// print('[SubscriptionService] Querying product IDs: $productIds');

      // Verify in-app purchase availability
      final bool available = await _inAppPurchase.isAvailable();
      //// print('[SubscriptionService] In-app purchase available: $available');

      if (!available) {
        _errorMessage = "In-app purchases are not available on this device";
        //// print('[SubscriptionService] ERROR: In-app purchases not available');
        notifyListeners();
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        //// print('[SubscriptionService] Products not found: ${response.notFoundIDs}');
        //// print('[SubscriptionService] This might indicate wrong product IDs for platform: ${Platform.operatingSystem}');
        _errorMessage = "Some products could not be found: ${response.notFoundIDs.join(", ")}";
      }

      _products = response.productDetails;
      //// print('[SubscriptionService] Products loaded: ${_products.length}');

      if (_products.isNotEmpty) {
        for (var product in _products) {
          //// print('[SubscriptionService] Product: ${product.id} - ${product.title} - ${product.price}');
          //// print('[SubscriptionService] Product currency: ${product.currencyCode} (${product.currencySymbol})');
        }
      } else {
        //// print('[SubscriptionService] ERROR: No products found for platform ${Platform.operatingSystem}');
        _errorMessage = "No subscription products found for ${Platform.operatingSystem}";
      }

      notifyListeners();
    } catch (e) {
      //// print('[SubscriptionService] Error loading products: $e');
      _errorMessage = "Error loading products: $e";
      notifyListeners();
    }
  }

  // Check current subscription status
  Future<bool> checkSubscriptionStatus() async {
    // Debug bypass
    if (kBypassSubscriptionForDebug) {
      _isSubscribed = true;
      _subscriptionTier = SubscriptionTier.premium;
      //// print('[SubscriptionService] Debug bypass enabled - setting premium status');
      return true;
    }

    try {
      //// print('[SubscriptionService] Checking subscription status...');

      // Check local storage first for rapid UI response
      final prefs = await SharedPreferences.getInstance();
      final storedStatus = prefs.getBool('isSubscribed') ?? false;
      final storedTier = prefs.getString('subscriptionTier') ?? 'free';

      // Set initial status from stored values
      _isSubscribed = storedStatus;
      _subscriptionTier = storedTier == 'premium' ? SubscriptionTier.premium : SubscriptionTier.free;

      // Verify with the store
      final bool validPurchase = await _verifyPreviousPurchases();

      // If store validation differs from local storage, update local
      if (_isSubscribed != validPurchase) {
        _isSubscribed = validPurchase;
        _subscriptionTier = validPurchase ? SubscriptionTier.premium : SubscriptionTier.free;
        await prefs.setBool('isSubscribed', validPurchase);
        await prefs.setString('subscriptionTier', _subscriptionTier == SubscriptionTier.premium ? 'premium' : 'free');
      }

      notifyListeners();
      return _isSubscribed;
    } catch (e) {
      //// print('[SubscriptionService] Error checking subscription status: $e');
      return false;
    }
  }

  // Verify previous purchases
  Future<bool> _verifyPreviousPurchases() async {
    try {
      //// print('[SubscriptionService] Verifying previous purchases...');

      await _inAppPurchase.restorePurchases();
      //// print('[SubscriptionService] Restore purchases completed');

      // Wait longer for purchases to be processed by the listener
      await Future.delayed(const Duration(seconds: 3));

      //// print('[SubscriptionService] Subscription status after restore: $_isSubscribed, tier: $_subscriptionTier');

      // Force a check of local storage as well
      final prefs = await SharedPreferences.getInstance();
      final storedSubscription = prefs.getBool('isSubscribed') ?? false;
      final storedTier = prefs.getString('subscriptionTier') ?? 'free';

      //// print('[SubscriptionService] Stored subscription: $storedSubscription, tier: $storedTier');

      // If we have a stored subscription but current status is false, use stored value
      if (storedSubscription && !_isSubscribed) {
        //// print('[SubscriptionService] Using stored subscription status');
        _isSubscribed = storedSubscription;
        _subscriptionTier = storedTier == 'premium' ? SubscriptionTier.premium : SubscriptionTier.free;
      }

      return _isSubscribed;
    } catch (e) {
      //// print('[SubscriptionService] Error verifying previous purchases: $e');
      return false;
    }
  }

  // Start the subscription purchase flow
  Future<void> subscribe([String? productId]) async {
    try {
      // Debug platform information
      //// print('[SubscriptionService] ======== PURCHASE DEBUG INFO ========');
      //// print('[SubscriptionService] Platform.isIOS: ${Platform.isIOS}');
      //// print('[SubscriptionService] Platform.isAndroid: ${Platform.isAndroid}');
      //// print('[SubscriptionService] Platform.operatingSystem: ${Platform.operatingSystem}');

      if (_products.isEmpty) {
        _errorMessage = "No products available to purchase";
        notifyListeners();
        return;
      }

      // Use provided productId or default to monthly
      final targetProductId = productId ?? monthlySubscriptionId;

      //// print('[SubscriptionService] Target Product ID: $targetProductId');
      //// print('[SubscriptionService] Available products: ${_products.map((p) => '${p.id}: ${p.title}').join(', ')}');

      final productDetails = _products.firstWhere(
        (product) => product.id == targetProductId,
        orElse: () => throw Exception("Subscription product not found: $targetProductId"),
      );

      //// print('[SubscriptionService] Starting purchase for: ${productDetails.id} (${productDetails.title})');
      //// print('[SubscriptionService] Product details: price=${productDetails.price}, currencyCode=${productDetails.currencyCode}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Verify we're using the right store
      final storeInfo = Platform.isIOS ? 'App Store' : 'Google Play';
      //// print('[SubscriptionService] Initiating purchase through: $storeInfo');

      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _errorMessage = "Failed to initiate purchase. Please try again.";
        //// print('[SubscriptionService] Purchase initiation failed');
        notifyListeners();
      } else {
        //// print('[SubscriptionService] Purchase initiated successfully');
      }
    } catch (e) {
      //// print('[SubscriptionService] Error starting subscription: $e');
      _errorMessage = "Error starting subscription: $e";
      notifyListeners();
      rethrow;
    }
  }

  // Listen to purchase updates
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    //// print('[SubscriptionService] Purchase update received: ${purchaseDetailsList.length} purchases');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      //// print('[SubscriptionService] Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        //// print('[SubscriptionService] Purchase is pending');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        //// print('[SubscriptionService] Purchase error: ${purchaseDetails.error}');
        _errorMessage = "Purchase error: ${purchaseDetails.error?.message ?? 'Unknown error'}";
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
        if (purchaseDetails.productID == monthlySubscriptionId || purchaseDetails.productID == yearlySubscriptionId) {
          await _handleValidPurchase(purchaseDetails);
        }
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        //// print('[SubscriptionService] Completing purchase for ${purchaseDetails.productID}');
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Handle a valid purchase
  Future<void> _handleValidPurchase(PurchaseDetails purchaseDetails) async {
    try {
      //// print('[SubscriptionService] Handling valid purchase for ${purchaseDetails.productID}');

      // Set subscription status
      _isSubscribed = true;
      _subscriptionTier = SubscriptionTier.premium;

      // Save subscription status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSubscribed', true);
      await prefs.setString('subscriptionTier', 'premium');

      //// print('[SubscriptionService] Premium subscription activated');

      // Sync subscription status to Supabase (silent, non-blocking)
      _syncSubscriptionToSupabase(purchaseDetails);

      // Clear any error message
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      //// print('[SubscriptionService] Error handling purchase: $e');
      _errorMessage = "Error processing purchase: $e";
      notifyListeners();
    }
  }

  // Silent background sync for subscription status
  void _syncSubscriptionToSupabase(PurchaseDetails purchaseDetails) {
    // Run in background, don't await
    Future.microtask(() async {
      try {
        if (!_supabase.isAuthenticated) {
          debugPrint('[SubscriptionService] Not authenticated, skipping subscription sync');
          return;
        }

        final userId = _supabase.currentUser!.id;
        final platform = Platform.isIOS ? 'ios' : 'android';

        // Check if record exists
        final existing = await _supabase.client.from('subscription_status').select().eq('user_id', userId).eq('platform', platform).maybeSingle();

        final data = {
          'user_id': userId,
          'platform': platform,
          'subscription_type': 'premium',
          'is_active': true,
          'purchase_token': purchaseDetails.verificationData.serverVerificationData,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing != null) {
          // Update existing record
          await _supabase.client.from('subscription_status').update(data).eq('user_id', userId).eq('platform', platform);
        } else {
          // Insert new record
          await _supabase.client.from('subscription_status').insert(data);
        }

        debugPrint('[SubscriptionService] Subscription status synced to Supabase');
      } catch (e) {
        debugPrint('[SubscriptionService] Error syncing subscription (silent): $e');
        // Silent failure - subscription still works locally
      }
    });
  }

  /// Sync current subscription status to Supabase (without purchase details)
  /// This is useful for syncing existing subscriptions after sign-in
  Future<void> syncCurrentSubscriptionToSupabase() async {
    try {
      if (!_supabase.isAuthenticated) {
        debugPrint('[SubscriptionService] Not authenticated, skipping subscription sync');
        return;
      }

      final userId = _supabase.currentUser!.id;
      final platform = Platform.isIOS ? 'ios' : 'android';

      // Check if record exists
      final existing = await _supabase.client.from('subscription_status').select().eq('user_id', userId).eq('platform', platform).maybeSingle();

      final data = {
        'user_id': userId,
        'platform': platform,
        'subscription_type': isPremium ? 'premium' : 'free',
        'is_active': isPremium,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing != null) {
        // Update existing record
        await _supabase.client.from('subscription_status').update(data).eq('user_id', userId).eq('platform', platform);
      } else {
        // Insert new record
        await _supabase.client.from('subscription_status').insert(data);
      }

      debugPrint('[SubscriptionService] Current subscription status synced to Supabase (isPremium: $isPremium)');

      // Also sync usage stats
      await syncUsageStatsToSupabase();
    } catch (e) {
      debugPrint('[SubscriptionService] Error syncing current subscription (silent): $e');
      // Silent failure - subscription still works locally
    }
  }

  /// Load subscription status from Supabase (for cross-device sync)
  Future<void> _loadSubscriptionFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) {
        debugPrint('[SubscriptionService] Not authenticated, skipping Supabase subscription load');
        return;
      }

      final userId = _supabase.currentUser!.id;

      final response = await _supabase.client.from('subscription_status').select().eq('user_id', userId).maybeSingle();

      if (response != null) {
        final isActive = response['is_active'] as bool? ?? false;

        if (isActive) {
          // Update local subscription status
          _isSubscribed = true;
          _subscriptionTier = SubscriptionTier.premium;

          debugPrint('[SubscriptionService] Loaded premium subscription from Supabase');
          notifyListeners();
        }
      }

      // Also load usage stats
      await _loadUsageStatsFromSupabase();
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading subscription from Supabase (silent): $e');
      // Silent failure - use local subscription status
    }
  }

  /// Load usage statistics from Supabase
  Future<void> _loadUsageStatsFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;

      final response = await _supabase.client.from('usage_statistics').select().eq('user_id', userId);

      // Note: Usage stats fields are final, so we just log the cloud values
      // The local stats are the source of truth and will be synced up
      for (final stat in response) {
        final featureName = stat['feature_name'] as String;
        final usageCount = stat['usage_count'] as int? ?? 0;
        debugPrint('[SubscriptionService] Cloud $featureName usage: $usageCount');
      }
      debugPrint('[SubscriptionService] Loaded usage stats from Supabase');
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading usage stats from Supabase (silent): $e');
      // Silent failure - use local usage stats
    }
  }

  // Sync usage statistics to Supabase
  Future<void> syncUsageStatsToSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;

      // Sync each feature's usage
      final features = {
        'image_analysis': _usageStats.imageAnalysisCount,
        'voice_generation': _usageStats.voiceGenerationsCount,
        'image_generation': _usageStats.imageGenerationsCount,
        'pdf_generation': _usageStats.pdfGenerationsCount,
        'places_explorer': _usageStats.placesExplorerCount,
        'document_analysis': _usageStats.documentAnalysisCount,
      };

      for (final entry in features.entries) {
        // Check if record exists
        final existing = await _supabase.client.from('usage_statistics').select().eq('user_id', userId).eq('feature_name', entry.key).maybeSingle();

        final data = {
          'user_id': userId,
          'feature_name': entry.key,
          'usage_count': entry.value,
          'last_reset_at': _usageStats.lastReset.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing != null) {
          // Update existing record
          await _supabase.client.from('usage_statistics').update(data).eq('user_id', userId).eq('feature_name', entry.key);
        } else {
          // Insert new record
          await _supabase.client.from('usage_statistics').insert(data);
        }
      }

      debugPrint('[SubscriptionService] Usage stats synced to Supabase');
    } catch (e) {
      debugPrint('[SubscriptionService] Error syncing usage stats (silent): $e');
      // Silent failure
    }
  }

  // Load subscription status from Supabase
  Future<void> loadSubscriptionFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;
      final platform = Platform.isIOS ? 'ios' : 'android';

      final response = await _supabase.client.from('subscription_status').select().eq('user_id', userId).eq('platform', platform).maybeSingle();

      if (response != null && response['is_active'] == true) {
        _isSubscribed = true;
        _subscriptionTier = SubscriptionTier.premium;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isSubscribed', true);
        await prefs.setString('subscriptionTier', 'premium');

        notifyListeners();
        debugPrint('[SubscriptionService] Subscription status loaded from Supabase');
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading subscription from Supabase (silent): $e');
      // Silent failure - use local status
    }
  }

  // Reset usage stats (for testing or administrative purposes)
  Future<void> resetUsageStats() async {
    //// print('[SubscriptionService] Resetting usage stats');
    _usageStats = UsageStats.empty();
    await _saveUsageStats();
    notifyListeners();
  }

  // Get usage summary for UI display
  Map<String, dynamic> getUsageSummary() {
    return {
      'imageAnalysisUsed': _usageStats.imageAnalysisCount,
      'imageAnalysisLimit': limits.imageAnalysisWeekly,
      'imageAnalysisRemaining': remainingImageAnalysis,
      'voiceGenerationsUsed': _usageStats.voiceGenerationsCount,
      'voiceGenerationsLimit': limits.voiceGenerationsWeekly,
      'voiceGenerationsRemaining': remainingVoiceGenerations,
      'imageGenerationsUsed': _usageStats.imageGenerationsCount,
      'imageGenerationsLimit': limits.imageGenerationsWeekly,
      'imageGenerationsRemaining': remainingImageGenerations,
      'pdfGenerationsUsed': _usageStats.pdfGenerationsCount,
      'pdfGenerationsLimit': limits.pdfGenerationsWeekly,
      'pdfGenerationsRemaining': remainingPdfGenerations,
      'placesExplorerUsed': _usageStats.placesExplorerCount,
      'placesExplorerLimit': limits.placesExplorerWeekly,
      'placesExplorerRemaining': remainingPlacesExplorer,
      'documentAnalysisUsed': _usageStats.documentAnalysisCount,
      'documentAnalysisLimit': limits.documentAnalysisWeekly,
      'documentAnalysisRemaining': remainingDocumentAnalysis,
      'lastReset': _usageStats.lastReset,
      'isPremium': isPremium,
      'subscriptionTier': _subscriptionTier.toString(),
    };
  }

  // Generate subscription prompt messages
  String getImageAnalysisLimitMessage() {
    final remaining = remainingImageAnalysis;
    if (remaining <= 0) {
      return "🔒 **Image Analysis Limit Reached**\n\nYou've used all ${limits.imageAnalysisWeekly} weekly image analyses. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited image analysis\n• Advanced gpt-5.2 model\n• Real-time web search\n• ElevenLabs voice synthesis\n• Custom AI settings\n\n[Upgrade to Premium] for unlimited access.";
    } else if (remaining <= 2) {
      return "⚠️ **Almost at your limit!**\n\nYou have only $remaining image analysis${remaining == 1 ? '' : 'es'} left this week. Consider upgrading to Premium for unlimited access!";
    }
    return "";
  }

  String getImageGenerationLimitMessage() {
    final remaining = remainingImageGenerations;
    if (remaining <= 0) {
      return "🔒 **Image Generation Limit Reached**\n\nYou've used all ${limits.imageGenerationsWeekly} weekly image generations. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited DALL-E image generation\n• Higher quality images\n• Advanced gpt-5.2 model\n• Real-time web search\n• ElevenLabs voice synthesis\n\n[Upgrade to Premium] for unlimited access.";
    } else if (remaining <= 1) {
      return "⚠️ **Almost at your limit!**\n\nYou have only $remaining image generation${remaining == 1 ? '' : 's'} left this week. Consider upgrading to Premium for unlimited access!";
    }
    return "";
  }

  String getPdfGenerationLimitMessage() {
    final remaining = remainingPdfGenerations;
    if (remaining <= 0) {
      return "🔒 **PDF Generation Limit Reached**\n\nYou've used all ${limits.pdfGenerationsWeekly} weekly PDF generations. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited PDF generation\n• Professional document quality\n• No waiting periods\n• All premium features unlocked\n\n[Upgrade to Premium] for unlimited access.";
    } else if (remaining <= 1) {
      return "⚠️ **Almost at your limit!**\n\nYou have only $remaining PDF generation${remaining == 1 ? '' : 's'} left this week. Consider upgrading to Premium for unlimited access!";
    }
    return "";
  }

  String getWebSearchLimitMessage() {
    return "🔒 **Web Search Requires Premium**\n\nReal-time internet search is a Premium feature. I can answer based on my training data, but for the most current information, you'll need to upgrade.\n\n✨ **Premium Benefits:**\n• Real-time Google search integration\n• Latest news and information\n• Current prices and data\n• Unlimited access to all features\n\n[Upgrade to Premium] for real-time web search capabilities.";
  }

  String getPlacesExplorerLimitMessage() {
    final remaining = remainingPlacesExplorer;
    if (remaining <= 0) {
      return "🔒 **Places Explorer Limit Reached**\n\nYou've used all ${limits.placesExplorerWeekly} weekly place searches. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited places exploration\n• Advanced location search\n• Real-time business info\n• All premium features unlocked\n\n[Upgrade to Premium] for unlimited access.";
    } else if (remaining <= 1) {
      return "⚠️ **Almost at your limit!**\n\nYou have only $remaining place search${remaining == 1 ? '' : 'es'} left this week. Consider upgrading to Premium for unlimited access!";
    }
    return "";
  }

  String getDocumentAnalysisLimitMessage() {
    final remaining = remainingDocumentAnalysis;
    if (remaining <= 0) {
      return "🔒 **Document Analysis Limit Reached**\n\nYou've used all ${limits.documentAnalysisWeekly} weekly document analyses. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited document analysis\n• Advanced file processing\n• PDF, Word, Excel support\n• All premium features unlocked\n\n[Upgrade to Premium] for unlimited access.";
    } else if (remaining <= 1) {
      return "⚠️ **Almost at your limit!**\n\nYou have only $remaining document analysis${remaining == 1 ? '' : 'es'} left this week. Consider upgrading to Premium for unlimited access!";
    }
    return "";
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
