import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_service.dart';

// Bypass subscription validation in debug builds so developers with real
// production subscriptions aren't shown the free tier during local testing.
// In release/profile builds this is always false — real validation applies.
// kDebugMode is a Flutter compile-time constant: true only in `flutter run`,
// always false in release/TestFlight/App Store builds. Safe to ship as-is.
const bool kBypassSubscriptionForDebug = kDebugMode;

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

class SubscriptionService with ChangeNotifier, WidgetsBindingObserver {
  static final SubscriptionService _instance = SubscriptionService._internal();
  final SupabaseService _supabase = SupabaseService();

  factory SubscriptionService() => _instance;

  SubscriptionService._internal() {
    _initialize();
  }

  // ---------------------------------------------------------------------------
  // Product IDs — platform-specific
  // ---------------------------------------------------------------------------

  // iOS App Store IDs (mixed case - existing subscribers)
  static const String _iosMonthlySubscriptionId = 'com.hyu.HaoGPT.premium.monthly';
  static const String _iosYearlySubscriptionId = 'com.haoyu.HaoGPT.premium.yearly';

  // Google Play Store IDs (lowercase only - new requirement)
  static const String _androidMonthlySubscriptionId = 'com.hyu.haogpt.premium.monthly';
  static const String _androidYearlySubscriptionId = 'com.haoyu.haogpt.premium.yearly';

  // Get platform-specific product IDs
  static String get monthlySubscriptionId {
    return Platform.isIOS ? _iosMonthlySubscriptionId : _androidMonthlySubscriptionId;
  }

  static String get yearlySubscriptionId {
    return Platform.isIOS ? _iosYearlySubscriptionId : _androidYearlySubscriptionId;
  }

  // All subscription product IDs for this platform
  static Set<String> get _allSubscriptionIds => {monthlySubscriptionId, yearlySubscriptionId};

  // ---------------------------------------------------------------------------
  // Constants for entitlement cache & throttle
  // ---------------------------------------------------------------------------

  static const String _isSubscribedKey = 'isSubscribed';
  static const String _subscriptionValidUntilMsKey = 'subscription_valid_until_ms';
  // Used for Google Play cache expiry estimation and fallback heuristic
  static const int _subscriptionCycleDays = 31;
  static const int _subscriptionGraceDays = 7;
  static const int _defaultValidatedCacheHours = 24;
  // Minimum interval between full platform store checks (app-resume throttle)
  static const Duration _minCheckInterval = Duration(hours: 1);

  // ---------------------------------------------------------------------------
  // Pricing helpers
  // ---------------------------------------------------------------------------

  // Get actual recurring price, with platform-specific handling
  String getActualPrice(ProductDetails product) {
    // iOS: Always use the product.price as-is (Apple handles this correctly)
    if (Platform.isIOS) {
      return product.price;
    }

    // Android: Handle free trial pricing display issues
    if (product.price.isNotEmpty &&
        !product.price.toLowerCase().contains('free') &&
        !product.price.toLowerCase().contains('试用') &&
        !product.price.toLowerCase().contains('gratuit') &&
        !product.price.toLowerCase().contains('gratis') &&
        !product.price.toLowerCase().contains('無料') &&
        product.price != '0') {
      return product.price;
    }

    if (product.rawPrice > 0) {
      final actualPrice = product.rawPrice / 1000000;
      final currencySymbol = product.currencySymbol.isNotEmpty ? product.currencySymbol : _getCurrencySymbol(product.currencyCode);
      return '$currencySymbol${actualPrice.toStringAsFixed(2)}';
    }

    if (product.id == monthlySubscriptionId) {
      return '\$7.99';
    } else if (product.id == yearlySubscriptionId) {
      return '\$79.99';
    }

    return 'Free Trial';
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'KRW': return '₩';
      case 'INR': return '₹';
      case 'BRL': return 'R\$';
      case 'RUB': return '₽';
      case 'CAD': return 'C\$';
      case 'AUD': return 'A\$';
      default: return '$currencyCode ';
    }
  }

  // ---------------------------------------------------------------------------
  // Debug override (for development/testing only)
  // ---------------------------------------------------------------------------

  bool? _debugOverridePremium;
  bool get isDebugOverrideActive => _debugOverridePremium != null;
  bool get isDebugPremiumOverride => _debugOverridePremium == true;
  bool get isDebugFreeOverride => _debugOverridePremium == false;

  Future<void> setDebugPremiumOverride(bool value) async {
    _debugOverridePremium = value ? true : null;
    final prefs = await SharedPreferences.getInstance();
    if (_debugOverridePremium == null) {
      await prefs.remove('debug_override_premium');
    } else {
      await prefs.setBool('debug_override_premium', _debugOverridePremium!);
    }
    notifyListeners();
  }

  Future<void> setDebugFreeOverride() async {
    _debugOverridePremium = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('debug_override_premium', false);
    notifyListeners();
  }

  Future<void> clearDebugOverride() async {
    _debugOverridePremium = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('debug_override_premium');
    notifyListeners();
  }

  Future<void> clearLocalSubscriptionForTesting() async {
    if (!kDebugMode) return;

    _isSubscribed = false;
    _subscriptionTier = SubscriptionTier.free;
    _debugOverridePremium = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSubscribedKey, false);
    await prefs.setString('subscriptionTier', 'free');
    await prefs.remove('debug_override_premium');
    await prefs.remove(_subscriptionValidUntilMsKey);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Core state
  // ---------------------------------------------------------------------------

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  SubscriptionTier _subscriptionTier = SubscriptionTier.free;
  SubscriptionTier get subscriptionTier => _subscriptionTier;

  UsageStats _usageStats = UsageStats.empty();
  UsageStats get usageStats => _usageStats;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  ProductDetails? get monthlyProduct => _products.where((p) => p.id == monthlySubscriptionId).firstOrNull;
  ProductDetails? get yearlyProduct => _products.where((p) => p.id == yearlySubscriptionId).firstOrNull;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isRestoringPurchases = false;
  bool _foundSubscriptionDuringRestore = false;

  // Throttle: tracks when the last full platform check completed
  DateTime? _lastFullCheckTime;
  bool _isCheckingStatus = false;

  // Get real subscription status (without debug override)
  bool get _realSubscriptionStatus => kBypassSubscriptionForDebug || (_isSubscribed && _subscriptionTier == SubscriptionTier.premium);

  // Convenience getters for subscription status (with debug override)
  bool get isPremium {
    if (_debugOverridePremium != null) {
      return _debugOverridePremium == true;
    }
    return _realSubscriptionStatus;
  }

  bool get isFree => !isPremium;

  SubscriptionLimits get limits => isPremium ? SubscriptionLimits.premium : SubscriptionLimits.free;

  // Feature access methods
  bool get canUseWebSearch => limits.hasWebSearch;
  bool get canUseElevenLabs => limits.hasElevenLabs;
  bool get canUseCustomSystemPrompt => limits.hasCustomSystemPrompt;
  bool get canUseVoiceSettings => limits.hasVoiceSettings;
  bool get canUsePptxGeneration => limits.hasPptxGeneration;

  String get allowedModel {
    if (isPremium) {
      return dotenv.env['OPENAI_CHAT_MODEL'] ?? 'gpt-5.2';
    } else {
      return dotenv.env['OPENAI_CHAT_MINI_MODEL'] ?? 'gpt-5-nano';
    }
  }

  // ---------------------------------------------------------------------------
  // Usage check methods
  // ---------------------------------------------------------------------------

  bool get canUseImageAnalysis {
    if (isPremium) return true;
    return _usageStats.imageAnalysisCount < limits.imageAnalysisWeekly;
  }

  bool get canUseVoiceGeneration => true; // Device TTS always available

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
    if (isPremium) return -1;
    if (limits.imageAnalysisWeekly == -1) return -1;
    return (limits.imageAnalysisWeekly - _usageStats.imageAnalysisCount).clamp(0, limits.imageAnalysisWeekly);
  }

  int get remainingVoiceGenerations {
    if (isPremium) return -1;
    if (limits.voiceGenerationsWeekly == -1) return -1;
    return (limits.voiceGenerationsWeekly - _usageStats.voiceGenerationsCount).clamp(0, limits.voiceGenerationsWeekly);
  }

  int get remainingImageGenerations {
    if (isPremium) return -1;
    if (limits.imageGenerationsWeekly == -1) return -1;
    return (limits.imageGenerationsWeekly - _usageStats.imageGenerationsCount).clamp(0, limits.imageGenerationsWeekly);
  }

  int get remainingPdfGenerations {
    if (isPremium) return -1;
    if (limits.pdfGenerationsWeekly == -1) return -1;
    return (limits.pdfGenerationsWeekly - _usageStats.pdfGenerationsCount).clamp(0, limits.pdfGenerationsWeekly);
  }

  int get remainingPlacesExplorer {
    if (isPremium) return -1;
    if (limits.placesExplorerWeekly == -1) return -1;
    return (limits.placesExplorerWeekly - _usageStats.placesExplorerCount).clamp(0, limits.placesExplorerWeekly);
  }

  int get remainingDocumentAnalysis {
    if (isPremium) return -1;
    if (limits.documentAnalysisWeekly == -1) return -1;
    return (limits.documentAnalysisWeekly - _usageStats.documentAnalysisCount).clamp(0, limits.documentAnalysisWeekly);
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    try {
      WidgetsBinding.instance.addObserver(this);

      await _loadDebugOverride();
      await _loadUsageStats();

      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          _errorMessage = "Purchase stream error: $error";
          notifyListeners();
        },
      );

      await _loadProducts();
      await checkSubscriptionStatus();
      debugPrint('[SubscriptionService] Init complete: isSubscribed=$_isSubscribed, tier=$_subscriptionTier');

      // Sync from Supabase (non-blocking, informational only — does NOT grant premium)
      _loadSubscriptionFromSupabase();
    } catch (e) {
      _errorMessage = "Initialization error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDebugOverride() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('debug_override_premium')) {
        _debugOverridePremium = prefs.getBool('debug_override_premium');
      } else {
        _debugOverridePremium = null;
      }
    } catch (e) {
      _debugOverridePremium = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Usage stats persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('usage_stats');

      if (statsJson != null) {
        final Map<String, dynamic> data = {};
        final parts = statsJson.split(',');
        for (final part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = keyValue[1].trim();
            if (key == 'lastReset') {
              data[key] = int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
            } else {
              data[key] = int.tryParse(value) ?? 0;
            }
          }
        }
        _usageStats = UsageStats.fromJson(data);
      } else {
        _usageStats = UsageStats.empty();
      }

      await _checkAndResetWeeklyUsage();
    } catch (e) {
      _usageStats = UsageStats.empty();
    }
  }

  Future<void> _saveUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson =
          'imageAnalysisCount:${_usageStats.imageAnalysisCount},voiceGenerationsCount:${_usageStats.voiceGenerationsCount},imageGenerationsCount:${_usageStats.imageGenerationsCount},pdfGenerationsCount:${_usageStats.pdfGenerationsCount},placesExplorerCount:${_usageStats.placesExplorerCount},documentAnalysisCount:${_usageStats.documentAnalysisCount},lastReset:${_usageStats.lastReset.millisecondsSinceEpoch}';
      await prefs.setString('usage_stats', statsJson);
    } catch (e) {
      // Silent failure
    }
  }

  Future<void> _checkAndResetWeeklyUsage() async {
    final now = DateTime.now();
    final daysSinceReset = now.difference(_usageStats.lastReset).inDays;

    if (daysSinceReset >= 7) {
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
    }
  }

  // ---------------------------------------------------------------------------
  // Usage tracking methods
  // ---------------------------------------------------------------------------

  Future<bool> tryUseImageAnalysis() async {
    if (isPremium) return true;
    if (_usageStats.imageAnalysisCount >= limits.imageAnalysisWeekly) return false;

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
    return true;
  }

  Future<bool> tryUseVoiceGeneration() async {
    return true; // Device TTS unlimited for all
  }

  Future<bool> tryUseImageGeneration() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.imageGenerationsCount >= limits.imageGenerationsWeekly) return false;

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
    return true;
  }

  Future<bool> tryUseElevenLabsTTS() async {
    if (!isPremium) return false;
    if (!canUseElevenLabs) return false;
    return true;
  }

  Future<bool> tryUsePdfGeneration() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.pdfGenerationsCount >= limits.pdfGenerationsWeekly) return false;

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
    return true;
  }

  Future<bool> tryUsePlacesExplorer() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.placesExplorerCount >= limits.placesExplorerWeekly) return false;

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
    return true;
  }

  Future<bool> tryUseDocumentAnalysis() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.documentAnalysisCount >= limits.documentAnalysisWeekly) return false;

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
    return true;
  }

  bool canUseDeviceTTS() => true;

  // ---------------------------------------------------------------------------
  // Load products from the store
  // ---------------------------------------------------------------------------

  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = _allSubscriptionIds;

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _errorMessage = "In-app purchases are not available on this device";
        notifyListeners();
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = "Some products could not be found: ${response.notFoundIDs.join(", ")}";
      }

      _products = response.productDetails;

      if (_products.isEmpty) {
        _errorMessage = "No subscription products found for ${Platform.operatingSystem}";
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = "Error loading products: $e";
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Subscription status check — uses platform-native APIs
  // ---------------------------------------------------------------------------

  /// Full platform-store check. Use [checkSubscriptionStatusThrottled] from
  /// app-resume to avoid hitting the store on every foreground event.
  Future<bool> checkSubscriptionStatus() async {
    if (kBypassSubscriptionForDebug) {
      _isSubscribed = true;
      _subscriptionTier = SubscriptionTier.premium;
      return true;
    }

    // Prevent overlapping checks
    if (_isCheckingStatus) {
      return _isSubscribed;
    }
    _isCheckingStatus = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final previousStatus = _isSubscribed;

      // Start from clean state — guilty until proven innocent.
      bool hasActiveSubscription = false;

      // Primary check: ask the platform store directly
      if (Platform.isIOS) {
        hasActiveSubscription = await _verifyViaStoreKit2();
      } else if (Platform.isAndroid) {
        hasActiveSubscription = await _verifyViaGooglePlay();
      }

      // Offline fallback: use cached entitlement if platform check returned false
      if (!hasActiveSubscription) {
        hasActiveSubscription = await _hasCachedValidatedEntitlement(prefs);
        if (hasActiveSubscription) {
          debugPrint('[SubscriptionService] Using cached entitlement (offline/error fallback)');
        }
      }

      _isSubscribed = hasActiveSubscription;
      _subscriptionTier = hasActiveSubscription ? SubscriptionTier.premium : SubscriptionTier.free;
      await prefs.setBool(_isSubscribedKey, hasActiveSubscription);
      await prefs.setString('subscriptionTier', hasActiveSubscription ? 'premium' : 'free');

      if (previousStatus != _isSubscribed) {
        debugPrint('[SubscriptionService] Subscription status changed: $previousStatus -> $_isSubscribed');
      }

      _lastFullCheckTime = DateTime.now();
      notifyListeners();
      return _isSubscribed;
    } catch (e) {
      debugPrint('[SubscriptionService] Error checking subscription status: $e');
      _isSubscribed = false;
      _subscriptionTier = SubscriptionTier.free;
      notifyListeners();
      return false;
    } finally {
      _isCheckingStatus = false;
    }
  }

  /// Throttled variant — skips the platform store query if the last full check
  /// was less than [_minCheckInterval] ago. Used by app-resume lifecycle.
  Future<bool> checkSubscriptionStatusThrottled() async {
    if (_lastFullCheckTime != null &&
        DateTime.now().difference(_lastFullCheckTime!) < _minCheckInterval) {
      debugPrint('[SubscriptionService] Subscription check throttled '
          '(last check ${DateTime.now().difference(_lastFullCheckTime!).inMinutes} min ago)');
      return _isSubscribed;
    }
    return checkSubscriptionStatus();
  }

  // ---------------------------------------------------------------------------
  // iOS: StoreKit 2 verification via SK2Transaction.transactions()
  // ---------------------------------------------------------------------------

  Future<bool> _verifyViaStoreKit2() async {
    try {
      debugPrint('[SubscriptionService] SK2: Querying transactions...');
      final transactions = await SK2Transaction.transactions();
      debugPrint('[SubscriptionService] SK2: Found ${transactions.length} transactions');

      DateTime? latestExpiry;

      for (final t in transactions) {
        // Check all subscription product IDs (monthly + yearly)
        if (!_allSubscriptionIds.contains(t.productId)) continue;

        final expStr = t.expirationDate;
        if (expStr == null) {
          debugPrint('[SubscriptionService] SK2: Transaction has no expirationDate, skipping');
          continue;
        }

        // StoreKit 2 pigeon bridge sends dates as "yyyy-MM-dd HH:mm:ss" strings.
        // Dart's DateTime.tryParse requires ISO 8601 (with 'T' separator),
        // so we normalise the space to 'T' before parsing.
        DateTime? expDate;
        final expMs = int.tryParse(expStr);
        if (expMs != null) {
          // In case a future version sends epoch-ms
          expDate = DateTime.fromMillisecondsSinceEpoch(expMs);
        } else {
          // Normalise "yyyy-MM-dd HH:mm:ss" → "yyyy-MM-ddTHH:mm:ss"
          expDate = DateTime.tryParse(expStr.replaceFirst(' ', 'T'));
        }
        if (expDate == null) {
          debugPrint('[SubscriptionService] SK2: Could not parse expirationDate: $expStr');
          continue;
        }

        // Track the latest expiration across all transactions
        if (latestExpiry == null || expDate.isAfter(latestExpiry)) {
          latestExpiry = expDate;
        }
      }

      final prefs = await SharedPreferences.getInstance();

      if (latestExpiry != null && latestExpiry.isAfter(DateTime.now())) {
        debugPrint('[SubscriptionService] SK2: Active subscription, expires $latestExpiry');
        await _setValidatedEntitlementCache(prefs, expiresAtMs: latestExpiry.millisecondsSinceEpoch);
        return true;
      }

      if (latestExpiry != null) {
        debugPrint('[SubscriptionService] SK2: Subscription expired on $latestExpiry');
      } else {
        debugPrint('[SubscriptionService] SK2: No subscription transactions found');
      }
      await _clearValidatedEntitlementCache(prefs);
      return false;
    } catch (e) {
      debugPrint('[SubscriptionService] SK2 verification error: $e');
      return false; // Caller falls back to cached entitlement
    }
  }

  // ---------------------------------------------------------------------------
  // Android: Google Play Billing verification via queryPastPurchases()
  // ---------------------------------------------------------------------------

  Future<bool> _verifyViaGooglePlay() async {
    try {
      debugPrint('[SubscriptionService] Google Play: Querying past purchases...');
      final androidAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

      // queryPastPurchases calls BillingClient.queryPurchases for both
      // inapp and subs. Google Play only returns currently active purchases.
      final result = await androidAddition.queryPastPurchases();

      if (result.error != null) {
        debugPrint('[SubscriptionService] Google Play query error: ${result.error}');
      }

      for (final purchase in result.pastPurchases) {
        if (!_allSubscriptionIds.contains(purchase.productID)) continue;

        final billingPurchase = purchase.billingClientPurchase;

        // Google only returns this purchase if it's currently active
        debugPrint('[SubscriptionService] Google Play: Active subscription found '
            '(autoRenewing=${billingPurchase.isAutoRenewing})');

        // Cache entitlement — estimate expiry from now + cycle + grace.
        final expMs = DateTime.now().millisecondsSinceEpoch +
            const Duration(days: _subscriptionCycleDays + _subscriptionGraceDays).inMilliseconds;
        final prefs = await SharedPreferences.getInstance();
        await _setValidatedEntitlementCache(prefs, expiresAtMs: expMs);
        return true;
      }

      debugPrint('[SubscriptionService] Google Play: No active subscription found');
      final prefs = await SharedPreferences.getInstance();
      await _clearValidatedEntitlementCache(prefs);
      return false;
    } catch (e) {
      debugPrint('[SubscriptionService] Google Play verification error: $e');
      return false; // Caller falls back to cached entitlement
    }
  }

  // ---------------------------------------------------------------------------
  // Entitlement cache (offline fallback)
  // ---------------------------------------------------------------------------

  Future<bool> _hasCachedValidatedEntitlement(SharedPreferences prefs) async {
    final validUntilMs = prefs.getInt(_subscriptionValidUntilMsKey);
    if (validUntilMs == null) return false;
    return DateTime.now().millisecondsSinceEpoch < validUntilMs;
  }

  Future<void> _setValidatedEntitlementCache(SharedPreferences prefs, {int? expiresAtMs}) async {
    final fallbackValidUntil = DateTime.now()
        .add(const Duration(hours: _defaultValidatedCacheHours))
        .millisecondsSinceEpoch;
    await prefs.setInt(
      _subscriptionValidUntilMsKey,
      expiresAtMs ?? fallbackValidUntil,
    );
  }

  Future<void> _clearValidatedEntitlementCache(SharedPreferences prefs) async {
    await prefs.remove(_subscriptionValidUntilMsKey);
  }

  /// Background call to replace the 24h fallback cache with the real expiry
  /// from the platform store. Called after a fresh purchase is trusted.
  void _updateCacheWithRealExpiry() {
    Future<void> doUpdate() async {
      try {
        if (Platform.isIOS) {
          await _verifyViaStoreKit2();
        } else if (Platform.isAndroid) {
          await _verifyViaGooglePlay();
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Background cache update failed (non-fatal): $e');
      }
    }
    doUpdate();
  }

  // ---------------------------------------------------------------------------
  // Last-resort fallback: transaction date heuristic (unknown platforms only)
  // ---------------------------------------------------------------------------

  bool _isLikelyActiveByTransactionDate(PurchaseDetails purchaseDetails) {
    final transactionDateRaw = purchaseDetails.transactionDate;
    if (transactionDateRaw == null || transactionDateRaw.isEmpty) return false;

    final transactionMs = int.tryParse(transactionDateRaw);
    if (transactionMs == null) return false;

    final transactionTime = DateTime.fromMillisecondsSinceEpoch(transactionMs, isUtc: true).toLocal();
    final daysSinceTransaction = DateTime.now().difference(transactionTime).inDays;
    final activeWindowDays = _subscriptionCycleDays + _subscriptionGraceDays;
    return daysSinceTransaction <= activeWindowDays;
  }

  // ---------------------------------------------------------------------------
  // Restore purchases (used by "Restore Purchases" button)
  // ---------------------------------------------------------------------------

  Future<bool> restorePurchases() async {
    try {
      debugPrint('[SubscriptionService] Restoring purchases...');
      _isRestoringPurchases = true;
      _foundSubscriptionDuringRestore = false;

      await _inAppPurchase.restorePurchases();

      // Purchases are received through purchaseStream; give it time to flush.
      await Future.delayed(const Duration(seconds: 2));
      return _foundSubscriptionDuringRestore;
    } catch (e) {
      debugPrint('[SubscriptionService] Error restoring purchases: $e');
      return false;
    } finally {
      _isRestoringPurchases = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Purchase flow
  // ---------------------------------------------------------------------------

  Future<void> subscribe([String? productId]) async {
    try {
      if (_products.isEmpty) {
        _errorMessage = "No products available to purchase";
        notifyListeners();
        return;
      }

      final targetProductId = productId ?? monthlySubscriptionId;
      final productDetails = _products.firstWhere(
        (product) => product.id == targetProductId,
        orElse: () => throw Exception("Subscription product not found: $targetProductId"),
      );

      debugPrint('[SubscriptionService] Starting purchase for: ${productDetails.id}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _errorMessage = "Failed to initiate purchase. Please try again.";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error starting subscription: $e";
      notifyListeners();
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Purchase stream listener
  // ---------------------------------------------------------------------------

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('[SubscriptionService] Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Waiting for user/store action
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('[SubscriptionService] Purchase error: ${purchaseDetails.error}');
        _errorMessage = "Purchase error: ${purchaseDetails.error?.message ?? 'Unknown error'}";
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (_allSubscriptionIds.contains(purchaseDetails.productID)) {
          await _handleSubscriptionPurchase(purchaseDetails);
        }
      }

      // Complete the purchase — important!
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSubscriptionPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // If StoreKit returns a restored-but-expired transaction during a buy
      // attempt (not a manual restore), do NOT overwrite the current subscription
      // state — the user may have another active subscription (e.g. monthly) that
      // SK2 verification for this specific product won't see. Just show an error.
      final isExpiredRestoreDuringBuy = purchaseDetails.status == PurchaseStatus.restored
          && !_isRestoringPurchases;

      if (isExpiredRestoreDuringBuy) {
        final isEntitled = await _validateSubscriptionEntitlement(purchaseDetails);
        if (!isEntitled) {
          _errorMessage = 'Your previous subscription has expired. Please re-subscribe via the App Store subscription management.';
          debugPrint('[SubscriptionService] Restored expired transaction — leaving current subscription state unchanged');
          notifyListeners();
          return;
        }
        // If somehow the restored transaction IS valid (e.g. renewed), fall through
      }

      final isEntitled = await _validateSubscriptionEntitlement(purchaseDetails);

      _isSubscribed = isEntitled;
      _subscriptionTier = isEntitled ? SubscriptionTier.premium : SubscriptionTier.free;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSubscribedKey, isEntitled);
      await prefs.setString('subscriptionTier', isEntitled ? 'premium' : 'free');

      if (isEntitled) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          // Immediate 24h cache so the user isn't blocked
          await _setValidatedEntitlementCache(prefs);
          // Fire-and-forget: update cache with real expiry from platform API
          _updateCacheWithRealExpiry();
        }
        _foundSubscriptionDuringRestore = true;

        // Sync to Supabase (silent, non-blocking)
        _syncSubscriptionToSupabase(purchaseDetails);

        _errorMessage = null;
        debugPrint('[SubscriptionService] Subscription entitlement confirmed');
      } else {
        await _clearValidatedEntitlementCache(prefs);
        _errorMessage = null;
        debugPrint('[SubscriptionService] Subscription entitlement not active');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[SubscriptionService] Error handling purchase: $e');
      _errorMessage = "Error processing purchase: $e";
      notifyListeners();
    }
  }

  Future<bool> _validateSubscriptionEntitlement(PurchaseDetails purchaseDetails) async {
    // Fresh purchase (not a restore): trusted immediately — Apple/Google
    // already validated it.
    if (purchaseDetails.status == PurchaseStatus.purchased && !_isRestoringPurchases) {
      return true;
    }

    // Restored purchase: verify with platform store API to check expiry.
    if (Platform.isIOS) {
      return _verifyViaStoreKit2();
    } else if (Platform.isAndroid) {
      return _verifyViaGooglePlay();
    }

    // Unknown platform fallback
    return _isLikelyActiveByTransactionDate(purchaseDetails);
  }

  // ---------------------------------------------------------------------------
  // Supabase sync (non-blocking, informational)
  // ---------------------------------------------------------------------------

  void _syncSubscriptionToSupabase(PurchaseDetails purchaseDetails) {
    Future.microtask(() async {
      try {
        if (!_supabase.isAuthenticated) return;

        final userId = _supabase.currentUser!.id;
        final platform = Platform.isIOS ? 'ios' : 'android';

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
          await _supabase.client.from('subscription_status').update(data).eq('user_id', userId).eq('platform', platform);
        } else {
          await _supabase.client.from('subscription_status').insert(data);
        }

        debugPrint('[SubscriptionService] Subscription status synced to Supabase');
      } catch (e) {
        debugPrint('[SubscriptionService] Error syncing subscription (silent): $e');
      }
    });
  }

  Future<void> syncCurrentSubscriptionToSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;
      final platform = Platform.isIOS ? 'ios' : 'android';

      final existing = await _supabase.client.from('subscription_status').select().eq('user_id', userId).eq('platform', platform).maybeSingle();

      final data = {
        'user_id': userId,
        'platform': platform,
        'subscription_type': isPremium ? 'premium' : 'free',
        'is_active': isPremium,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing != null) {
        await _supabase.client.from('subscription_status').update(data).eq('user_id', userId).eq('platform', platform);
      } else {
        await _supabase.client.from('subscription_status').insert(data);
      }

      debugPrint('[SubscriptionService] Current subscription status synced to Supabase (isPremium: $isPremium)');

      await syncUsageStatsToSupabase();
    } catch (e) {
      debugPrint('[SubscriptionService] Error syncing current subscription (silent): $e');
    }
  }

  /// Load subscription info from Supabase — informational only.
  /// Does NOT grant premium. The platform store is the source of truth.
  Future<void> _loadSubscriptionFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;

      final response = await _supabase.client.from('subscription_status').select().eq('user_id', userId).maybeSingle();

      if (response != null) {
        final isActive = response['is_active'] as bool? ?? false;
        debugPrint('[SubscriptionService] Supabase subscription record: is_active=$isActive (informational only)');
      }

      await _loadUsageStatsFromSupabase();
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading subscription from Supabase (silent): $e');
    }
  }

  Future<void> _loadUsageStatsFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;
      final response = await _supabase.client.from('usage_statistics').select().eq('user_id', userId);

      for (final stat in response) {
        final featureName = stat['feature_name'] as String;
        final usageCount = stat['usage_count'] as int? ?? 0;
        debugPrint('[SubscriptionService] Cloud $featureName usage: $usageCount');
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading usage stats from Supabase (silent): $e');
    }
  }

  Future<void> syncUsageStatsToSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;

      final features = {
        'image_analysis': _usageStats.imageAnalysisCount,
        'voice_generation': _usageStats.voiceGenerationsCount,
        'image_generation': _usageStats.imageGenerationsCount,
        'pdf_generation': _usageStats.pdfGenerationsCount,
        'places_explorer': _usageStats.placesExplorerCount,
        'document_analysis': _usageStats.documentAnalysisCount,
      };

      for (final entry in features.entries) {
        final existing = await _supabase.client.from('usage_statistics').select().eq('user_id', userId).eq('feature_name', entry.key).maybeSingle();

        final data = {
          'user_id': userId,
          'feature_name': entry.key,
          'usage_count': entry.value,
          'last_reset_at': _usageStats.lastReset.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing != null) {
          await _supabase.client.from('usage_statistics').update(data).eq('user_id', userId).eq('feature_name', entry.key);
        } else {
          await _supabase.client.from('usage_statistics').insert(data);
        }
      }

      debugPrint('[SubscriptionService] Usage stats synced to Supabase');
    } catch (e) {
      debugPrint('[SubscriptionService] Error syncing usage stats (silent): $e');
    }
  }

  /// Public method for loading subscription from Supabase after sign-in.
  /// Does NOT grant premium — only logs the cloud state and loads usage stats.
  Future<void> loadSubscriptionFromSupabase() async {
    await _loadSubscriptionFromSupabase();
  }

  // ---------------------------------------------------------------------------
  // Usage stats helpers
  // ---------------------------------------------------------------------------

  Future<void> resetUsageStats() async {
    _usageStats = UsageStats.empty();
    await _saveUsageStats();
    notifyListeners();
  }

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

  // ---------------------------------------------------------------------------
  // Limit messages for UI
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkSubscriptionStatusThrottled();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }
}
