import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'subscription_entitlement_policy.dart';
import 'supabase_service.dart';

// No automatic bypass—use the debug-only toggle in Settings to test premium.
const bool kBypassSubscriptionForDebug = false;

@visibleForTesting
bool resolvePremiumStatus({
  required bool realStatus,
  required bool isDebugBuild,
  bool? debugOverride,
}) {
  if (isDebugBuild && debugOverride != null) {
    return debugOverride;
  }
  return realStatus;
}

enum SubscriptionTier {
  free,
  premium,
}

class _TrustedServerEntitlement {
  final bool active;
  final DateTime? expiresAt;
  final String? source;

  const _TrustedServerEntitlement({
    required this.active,
    required this.expiresAt,
    required this.source,
  });

  int? get cacheValidUntilMs {
    final expiry = expiresAt;
    if (expiry == null || !expiry.isAfter(DateTime.now())) return null;
    return expiry.millisecondsSinceEpoch;
  }
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
      lastReset: DateTime.fromMillisecondsSinceEpoch(
          json['lastReset'] ?? DateTime.now().millisecondsSinceEpoch),
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
  static const String _iosMonthlySubscriptionId =
      'com.hyu.HaoGPT.premium.monthly';
  static const String _iosYearlySubscriptionId =
      'com.haoyu.HaoGPT.premium.yearly';

  // Google Play Store IDs (lowercase only - new requirement)
  static const String _androidMonthlySubscriptionId =
      'com.hyu.haogpt.premium.monthly';
  static const String _androidYearlySubscriptionId =
      'com.haoyu.haogpt.premium.yearly';

  // Get platform-specific product IDs
  static String get monthlySubscriptionId {
    return Platform.isIOS
        ? _iosMonthlySubscriptionId
        : _androidMonthlySubscriptionId;
  }

  static String get yearlySubscriptionId {
    return Platform.isIOS
        ? _iosYearlySubscriptionId
        : _androidYearlySubscriptionId;
  }

  // All subscription product IDs for this platform
  static Set<String> get _allSubscriptionIds =>
      {monthlySubscriptionId, yearlySubscriptionId};

  // ---------------------------------------------------------------------------
  // Constants for entitlement cache & throttle
  // ---------------------------------------------------------------------------

  static const String _isSubscribedKey = 'isSubscribed';
  static const String _subscriptionValidUntilMsKey =
      'subscription_valid_until_ms';
  static const String _subscriptionCacheUserIdKey =
      'subscription_cache_user_id';
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
      final currencySymbol = product.currencySymbol.isNotEmpty
          ? product.currencySymbol
          : _getCurrencySymbol(product.currencyCode);
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
        return '$currencyCode ';
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
    if (!kDebugMode) return;
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
    if (!kDebugMode) return;
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
    await prefs.remove(_subscriptionCacheUserIdKey);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Core state
  // ---------------------------------------------------------------------------

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  StreamSubscription<AuthState>? _authSubscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  SubscriptionTier _subscriptionTier = SubscriptionTier.free;
  SubscriptionTier get subscriptionTier => _subscriptionTier;

  UsageStats _usageStats = UsageStats.empty();
  UsageStats get usageStats => _usageStats;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  ProductDetails? get monthlyProduct =>
      _products.where((p) => p.id == monthlySubscriptionId).firstOrNull;
  ProductDetails? get yearlyProduct =>
      _products.where((p) => p.id == yearlySubscriptionId).firstOrNull;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Completer<bool>? _restoreEventCompleter;
  Future<bool>? _activeRestoreAttempt;

  // Throttle: tracks when the last full platform check completed
  DateTime? _lastFullCheckTime;
  Future<bool>? _activeStatusCheck;
  String? _activeStatusCheckUserId;
  String? _lastKnownEntitlementUserId;
  int _identityGeneration = 0;

  // Get real subscription status (without debug override)
  bool get _realSubscriptionStatus =>
      kBypassSubscriptionForDebug ||
      (_isSubscribed && _subscriptionTier == SubscriptionTier.premium);

  // Convenience getters for subscription status (with debug override)
  bool get isPremium => resolvePremiumStatus(
        realStatus: _realSubscriptionStatus,
        isDebugBuild: kDebugMode,
        debugOverride: _debugOverridePremium,
      );

  bool get isFree => !isPremium;

  SubscriptionLimits get limits =>
      isPremium ? SubscriptionLimits.premium : SubscriptionLimits.free;

  // Feature access methods
  bool get canUseWebSearch => limits.hasWebSearch;
  bool get canUseElevenLabs => limits.hasElevenLabs;
  bool get canUseCustomSystemPrompt => limits.hasCustomSystemPrompt;
  bool get canUseVoiceSettings => limits.hasVoiceSettings;
  bool get canUsePptxGeneration => limits.hasPptxGeneration;

  String get allowedModel {
    if (isPremium) {
      return AppConfig.openAIChatModel;
    } else {
      return AppConfig.openAIChatMiniModel;
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
    return (limits.imageAnalysisWeekly - _usageStats.imageAnalysisCount)
        .clamp(0, limits.imageAnalysisWeekly);
  }

  int get remainingVoiceGenerations {
    if (isPremium) return -1;
    if (limits.voiceGenerationsWeekly == -1) return -1;
    return (limits.voiceGenerationsWeekly - _usageStats.voiceGenerationsCount)
        .clamp(0, limits.voiceGenerationsWeekly);
  }

  int get remainingImageGenerations {
    if (isPremium) return -1;
    if (limits.imageGenerationsWeekly == -1) return -1;
    return (limits.imageGenerationsWeekly - _usageStats.imageGenerationsCount)
        .clamp(0, limits.imageGenerationsWeekly);
  }

  int get remainingPdfGenerations {
    if (isPremium) return -1;
    if (limits.pdfGenerationsWeekly == -1) return -1;
    return (limits.pdfGenerationsWeekly - _usageStats.pdfGenerationsCount)
        .clamp(0, limits.pdfGenerationsWeekly);
  }

  int get remainingPlacesExplorer {
    if (isPremium) return -1;
    if (limits.placesExplorerWeekly == -1) return -1;
    return (limits.placesExplorerWeekly - _usageStats.placesExplorerCount)
        .clamp(0, limits.placesExplorerWeekly);
  }

  int get remainingDocumentAnalysis {
    if (isPremium) return -1;
    if (limits.documentAnalysisWeekly == -1) return -1;
    return (limits.documentAnalysisWeekly - _usageStats.documentAnalysisCount)
        .clamp(0, limits.documentAnalysisWeekly);
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    try {
      WidgetsBinding.instance.addObserver(this);

      await _loadDebugOverride();
      await _loadUsageStats();
      _lastKnownEntitlementUserId = _currentEntitlementUserId;
      _authSubscription = _supabase.authStateChanges.listen(
        (authState) {
          unawaited(_handleAuthStateChange(authState.session?.user));
        },
        onError: (Object error, StackTrace stackTrace) {
          _errorMessage = 'Subscription account status could not be refreshed.';
          debugPrint('[SubscriptionService] Auth stream failed: $error');
          notifyListeners();
        },
      );

      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
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
      debugPrint(
          '[SubscriptionService] Init complete: isSubscribed=$_isSubscribed, tier=$_subscriptionTier');

      // Reconcile again after startup so a restored auth session can recover
      // server-granted access even if StoreKit has no readable transaction.
      unawaited(_loadSubscriptionFromSupabase());
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
      if (!kDebugMode) {
        _debugOverridePremium = null;
        await prefs.remove('debug_override_premium');
        return;
      }
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
              data[key] =
                  int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
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
    if (_usageStats.imageAnalysisCount >= limits.imageAnalysisWeekly) {
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
    return true;
  }

  Future<bool> tryUseVoiceGeneration() async {
    return true; // Device TTS unlimited for all
  }

  Future<bool> tryUseImageGeneration() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.imageGenerationsCount >= limits.imageGenerationsWeekly) {
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
    if (_usageStats.pdfGenerationsCount >= limits.pdfGenerationsWeekly) {
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
    return true;
  }

  Future<bool> tryUsePlacesExplorer() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.placesExplorerCount >= limits.placesExplorerWeekly) {
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
    return true;
  }

  Future<bool> tryUseDocumentAnalysis() async {
    if (isPremium) return true;
    await _checkAndResetWeeklyUsage();
    if (_usageStats.documentAnalysisCount >= limits.documentAnalysisWeekly) {
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

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage =
            "Some products could not be found: ${response.notFoundIDs.join(", ")}";
      }

      _products = response.productDetails;

      if (_products.isEmpty) {
        _errorMessage =
            "No subscription products found for ${Platform.operatingSystem}";
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

  String? get _currentEntitlementUserId {
    final user = _supabase.currentUser;
    if (user == null || user.isAnonymous) return null;
    return user.id;
  }

  Future<void> _handleAuthStateChange(User? user) async {
    final userId = user == null || user.isAnonymous ? null : user.id;
    if (userId == _lastKnownEntitlementUserId) return;

    _lastKnownEntitlementUserId = userId;
    _identityGeneration++;
    _lastFullCheckTime = null;

    // Downgrade in memory before any async work so a newly signed-in free
    // account can never see the previous account's Pro controls.
    _isSubscribed = false;
    _subscriptionTier = SubscriptionTier.free;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await _applyResolvedSubscription(
      active: false,
      expectedUserId: userId,
      generation: _identityGeneration,
      prefs: prefs,
    );
    if (userId != null) {
      await checkSubscriptionStatus();
    }
  }

  Future<void> _applyResolvedSubscription({
    required bool active,
    required String? expectedUserId,
    required int generation,
    required SharedPreferences prefs,
  }) async {
    if (generation != _identityGeneration ||
        _currentEntitlementUserId != expectedUserId) {
      debugPrint(
          '[SubscriptionService] Ignoring stale entitlement result after account change');
      return;
    }

    final previousStatus = _isSubscribed;
    _isSubscribed = active;
    _subscriptionTier =
        active ? SubscriptionTier.premium : SubscriptionTier.free;

    // These legacy values are display/debug mirrors only. They are never read
    // as authorization and are cleared on every account transition.
    await prefs.setBool(_isSubscribedKey, active);
    await prefs.setString('subscriptionTier', active ? 'premium' : 'free');

    if (previousStatus != active) {
      debugPrint(
          '[SubscriptionService] Subscription status changed: $previousStatus -> $active');
    }
    notifyListeners();
  }

  /// Full platform-store check. Use [checkSubscriptionStatusThrottled] from
  /// app-resume to avoid hitting the store on every foreground event.
  Future<bool> checkSubscriptionStatus() async {
    if (kBypassSubscriptionForDebug) {
      _isSubscribed = true;
      _subscriptionTier = SubscriptionTier.premium;
      return true;
    }

    final userId = _currentEntitlementUserId;
    if (userId != _lastKnownEntitlementUserId) {
      _lastKnownEntitlementUserId = userId;
      _identityGeneration++;
      _lastFullCheckTime = null;
      _isSubscribed = false;
      _subscriptionTier = SubscriptionTier.free;
      notifyListeners();
    }
    final existingCheck = _activeStatusCheck;
    if (existingCheck != null && _activeStatusCheckUserId == userId) {
      return existingCheck;
    }
    final generation = _identityGeneration;
    final check = _checkSubscriptionStatusForUser(userId, generation);
    _activeStatusCheck = check;
    _activeStatusCheckUserId = userId;
    try {
      return await check;
    } finally {
      if (identical(_activeStatusCheck, check)) {
        _activeStatusCheck = null;
        _activeStatusCheckUserId = null;
      }
    }
  }

  Future<bool> _checkSubscriptionStatusForUser(
    String? userId,
    int generation,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Store purchases belong to a signed-in HowAI account. Anonymous or signed
    // out sessions must never inherit the device owner's App Store status.
    if (userId == null) {
      await _applyResolvedSubscription(
        active: false,
        expectedUserId: null,
        generation: generation,
        prefs: prefs,
      );
      return false;
    }

    try {
      _TrustedServerEntitlement? entitlement =
          await _fetchTrustedServerEntitlement(expectedUserId: userId);

      // Refresh store-backed entitlements through the server. StoreKit/Play is
      // evidence, not authorization: the server enforces account ownership.
      final shouldRefreshStore = entitlement?.active != true ||
          entitlement?.source == 'app_store' ||
          entitlement?.source == 'play_store';
      if (shouldRefreshStore) {
        final refreshed = Platform.isIOS
            ? await _syncVerifiedAppleEntitlement(expectedUserId: userId)
            : Platform.isAndroid
                ? await _syncVerifiedGoogleEntitlement(expectedUserId: userId)
                : null;
        entitlement = refreshed ?? entitlement;
      }

      if (entitlement != null) {
        if (entitlement.active) {
          await _setValidatedEntitlementCache(
            prefs,
            userId: userId,
            expiresAtMs: entitlement.cacheValidUntilMs,
          );
        } else {
          await _clearValidatedEntitlementCache(prefs);
        }
        await _applyResolvedSubscription(
          active: entitlement.active,
          expectedUserId: userId,
          generation: generation,
          prefs: prefs,
        );
        _lastFullCheckTime = DateTime.now();
        return entitlement.active;
      }

      // A short, server-created, account-bound cache keeps verified subscribers
      // working during a temporary outage without crossing account boundaries.
      final cached =
          await _hasCachedValidatedEntitlement(prefs, userId: userId);
      if (cached) {
        debugPrint(
            '[SubscriptionService] Using user-bound offline entitlement cache');
      }
      await _applyResolvedSubscription(
        active: cached,
        expectedUserId: userId,
        generation: generation,
        prefs: prefs,
      );
      _lastFullCheckTime = DateTime.now();
      return cached;
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Error checking subscription status: $e');
      final cached =
          await _hasCachedValidatedEntitlement(prefs, userId: userId);
      await _applyResolvedSubscription(
        active: cached,
        expectedUserId: userId,
        generation: generation,
        prefs: prefs,
      );
      return cached;
    }
  }

  /// Throttled variant — skips the platform store query if the last full check
  /// was less than [_minCheckInterval] ago. Used by app-resume lifecycle.
  Future<bool> checkSubscriptionStatusThrottled() async {
    if (_lastKnownEntitlementUserId != _currentEntitlementUserId) {
      return checkSubscriptionStatus();
    }
    if (_lastFullCheckTime != null &&
        DateTime.now().difference(_lastFullCheckTime!) < _minCheckInterval) {
      debugPrint('[SubscriptionService] Subscription check throttled '
          '(last check ${DateTime.now().difference(_lastFullCheckTime!).inMinutes} min ago)');
      return _isSubscribed;
    }
    return checkSubscriptionStatus();
  }

  // ---------------------------------------------------------------------------
  // Entitlement cache (offline fallback)
  // ---------------------------------------------------------------------------

  Future<bool> _hasCachedValidatedEntitlement(
    SharedPreferences prefs, {
    required String userId,
  }) async {
    final cachedUserId = prefs.getString(_subscriptionCacheUserIdKey);
    final validUntilMs = prefs.getInt(_subscriptionValidUntilMsKey);
    final active = isUserBoundEntitlementCacheActive(
      currentUserId: userId,
      cachedUserId: cachedUserId,
      validUntilMs: validUntilMs,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (!active && cachedUserId != null && cachedUserId != userId) {
      await _clearValidatedEntitlementCache(prefs);
    }
    return active;
  }

  Future<void> _setValidatedEntitlementCache(
    SharedPreferences prefs, {
    required String userId,
    int? expiresAtMs,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final validUntil = boundedEntitlementCacheExpiry(
      nowMs: nowMs,
      maximumOfflineAgeMs:
          const Duration(hours: _defaultValidatedCacheHours).inMilliseconds,
      entitlementExpiresAtMs: expiresAtMs,
    );
    if (validUntil <= nowMs) {
      await _clearValidatedEntitlementCache(prefs);
      return;
    }
    await prefs.setString(_subscriptionCacheUserIdKey, userId);
    await prefs.setInt(
      _subscriptionValidUntilMsKey,
      validUntil,
    );
  }

  Future<void> _clearValidatedEntitlementCache(SharedPreferences prefs) async {
    await prefs.remove(_subscriptionValidUntilMsKey);
    await prefs.remove(_subscriptionCacheUserIdKey);
  }

  // ---------------------------------------------------------------------------
  // Restore purchases (used by "Restore Purchases" button)
  // ---------------------------------------------------------------------------

  Future<bool> restorePurchases() {
    final activeAttempt = _activeRestoreAttempt;
    if (activeAttempt != null) return activeAttempt;

    late final Future<bool> attempt;
    attempt = _restorePurchases().whenComplete(() {
      if (identical(_activeRestoreAttempt, attempt)) {
        _activeRestoreAttempt = null;
      }
    });
    _activeRestoreAttempt = attempt;
    return attempt;
  }

  Future<bool> _restorePurchases() async {
    final userId = _currentEntitlementUserId;
    if (userId == null) {
      _errorMessage =
          'Sign in to a HowAI account before purchasing or restoring Pro.';
      notifyListeners();
      return false;
    }

    final eventCompleter = Completer<bool>();
    _restoreEventCompleter = eventCompleter;

    try {
      debugPrint('[SubscriptionService] Restoring purchases...');
      _errorMessage = null;
      notifyListeners();

      await _inAppPurchase.restorePurchases(applicationUserName: userId);

      // StoreKit sends restored transactions through purchaseStream. Recheck
      // the trusted server in parallel so an entitlement already recovered by
      // the backend also resolves the button promptly. An empty StoreKit 2
      // restore does not emit an event, so keep a bounded wait for that case.
      final statusCheck = checkSubscriptionStatus()
          .timeout(const Duration(seconds: 18), onTimeout: () => false)
          .catchError((Object _) => false);
      unawaited(statusCheck.then((active) {
        if (active) _completeRestoreEvent(true);
      }));

      final restored = await eventCompleter.future.timeout(
        const Duration(seconds: 18),
        onTimeout: () => false,
      );
      final active = restored || await statusCheck;
      if (active) {
        _errorMessage = null;
        return true;
      }

      _errorMessage =
          'No active App Store or Google Play subscription was found for this HowAI account.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[SubscriptionService] Error restoring purchases: $e');
      _errorMessage =
          'Unable to restore purchases right now. Please try again.';
      _completeRestoreEvent(false);
      notifyListeners();
      return false;
    } finally {
      if (identical(_restoreEventCompleter, eventCompleter)) {
        _restoreEventCompleter = null;
      }
    }
  }

  void _completeRestoreEvent(bool restored) {
    final completer = _restoreEventCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(restored);
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
        orElse: () =>
            throw Exception("Subscription product not found: $targetProductId"),
      );

      debugPrint(
          '[SubscriptionService] Starting purchase for: ${productDetails.id}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName:
            _supabase.isAuthenticated ? _supabase.currentUser?.id : null,
      );

      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

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

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    if (purchaseDetailsList.isEmpty) {
      _completeRestoreEvent(false);
      return;
    }

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      var purchaseWasDelivered = false;
      debugPrint(
          '[SubscriptionService] Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Waiting for user/store action
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint(
            '[SubscriptionService] Purchase error: ${purchaseDetails.error}');
        _errorMessage =
            "Purchase error: ${purchaseDetails.error?.message ?? 'Unknown error'}";
        _completeRestoreEvent(false);
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _completeRestoreEvent(false);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (_allSubscriptionIds.contains(purchaseDetails.productID)) {
          purchaseWasDelivered =
              await _handleSubscriptionPurchase(purchaseDetails);
        }
      }

      // Finish a subscription transaction only after the trusted backend has
      // granted access. If verification is temporarily unavailable, leaving it
      // unfinished lets the next launch recover its signed StoreKit evidence.
      final isSubscription =
          _allSubscriptionIds.contains(purchaseDetails.productID);
      if (purchaseDetails.pendingCompletePurchase &&
          (!isSubscription || purchaseWasDelivered)) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> _handleSubscriptionPurchase(
      PurchaseDetails purchaseDetails) async {
    try {
      final userId = _currentEntitlementUserId;
      final prefs = await SharedPreferences.getInstance();
      if (userId == null) {
        await _applyResolvedSubscription(
          active: false,
          expectedUserId: null,
          generation: _identityGeneration,
          prefs: prefs,
        );
        _errorMessage =
            'Sign in to a HowAI account before purchasing or restoring Pro.';
        _completeRestoreEvent(false);
        notifyListeners();
        return false;
      }

      final entitlement = Platform.isIOS
          ? await _syncVerifiedAppleEntitlement(
              expectedUserId: userId,
              purchase: purchaseDetails,
            )
          : Platform.isAndroid
              ? await _syncVerifiedGoogleEntitlement(
                  expectedUserId: userId,
                  purchase: purchaseDetails,
                )
              : null;
      final isEntitled = entitlement?.active == true;

      if (isEntitled) {
        await _setValidatedEntitlementCache(
          prefs,
          userId: userId,
          expiresAtMs: entitlement!.cacheValidUntilMs,
        );
        await _applyResolvedSubscription(
          active: true,
          expectedUserId: userId,
          generation: _identityGeneration,
          prefs: prefs,
        );
        _completeRestoreEvent(true);
        _errorMessage = null;
        debugPrint(
            '[SubscriptionService] Server-verified subscription entitlement confirmed');
      } else {
        await _clearValidatedEntitlementCache(prefs);
        await _applyResolvedSubscription(
          active: false,
          expectedUserId: userId,
          generation: _identityGeneration,
          prefs: prefs,
        );
        _errorMessage =
            'The store purchase could not be verified for this HowAI account.';
        _completeRestoreEvent(false);
        debugPrint(
            '[SubscriptionService] Purchase was not granted without server verification');
      }

      notifyListeners();
      return isEntitled;
    } catch (e) {
      debugPrint('[SubscriptionService] Error handling purchase: $e');
      _errorMessage = "Error processing purchase: $e";
      _completeRestoreEvent(false);
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Supabase sync
  // ---------------------------------------------------------------------------

  Future<void> syncCurrentSubscriptionToSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      // app_entitlements is the only authorization source. The legacy
      // subscription_status table is intentionally no longer client-writable.
      await checkSubscriptionStatus();
      await syncUsageStatsToSupabase();
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Error syncing current subscription (silent): $e');
    }
  }

  Future<_TrustedServerEntitlement?> _fetchTrustedServerEntitlement({
    required String expectedUserId,
  }) async {
    if (_currentEntitlementUserId != expectedUserId) return null;

    try {
      final response = await _supabase.client.functions.invoke(
          'entitlement-status',
          body: const {}).timeout(const Duration(seconds: 10));
      final data = response.data;
      if (data is! Map) return null;
      final entitlement = data['entitlement'];
      if (entitlement is! Map) return null;

      final active = entitlement['active'] == true;
      final expiresAtRaw = entitlement['expires_at'];
      final expiresAt = expiresAtRaw is String
          ? DateTime.tryParse(expiresAtRaw)?.toLocal()
          : null;
      if (_currentEntitlementUserId != expectedUserId) return null;
      return _TrustedServerEntitlement(
        active: active,
        expiresAt: expiresAt,
        source: entitlement['source'] is String
            ? entitlement['source'] as String
            : null,
      );
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Trusted entitlement refresh failed (using user-bound cache): $e');
      return null;
    }
  }

  Future<void> _refreshSubscriptionFromTrustedServer() async {
    await checkSubscriptionStatus();
  }

  Future<_TrustedServerEntitlement?> _syncVerifiedAppleEntitlement({
    List<SK2Transaction>? transactions,
    PurchaseDetails? purchase,
    required String expectedUserId,
  }) async {
    if (!Platform.isIOS || _currentEntitlementUserId != expectedUserId) {
      return null;
    }

    try {
      var signedTransaction = selectStoreKitTransactionJws(
        purchaseVerificationData:
            purchase?.verificationData.serverVerificationData,
      );
      SK2Transaction? unfinishedTransaction;
      if (signedTransaction == null) {
        final availableTransactions =
            transactions ?? await SK2Transaction.unfinishedTransactions();
        final latest =
            _latestAppleSubscriptionTransaction(availableTransactions);
        signedTransaction = selectStoreKitTransactionJws(
          fallbackVerificationData: latest?.receiptData,
        );
        if (transactions == null && signedTransaction != null) {
          unfinishedTransaction = latest;
        }
      }
      if (signedTransaction == null) {
        debugPrint(
            '[SubscriptionService] No signed StoreKit 2 transaction available for server verification');
        return null;
      }

      final response = await _supabase.client.functions.invoke(
        'verify-apple-entitlement',
        body: {'signed_transaction': signedTransaction},
      ).timeout(const Duration(seconds: 15));

      final data = response.data;
      final entitlement = data is Map ? data['entitlement'] : null;
      if (entitlement is! Map || _currentEntitlementUserId != expectedUserId) {
        return null;
      }
      final active = entitlement['active'] == true;
      final expiresAtRaw = entitlement['expires_at'];
      final expiresAt = expiresAtRaw is String
          ? DateTime.tryParse(expiresAtRaw)?.toLocal()
          : null;
      debugPrint(
          '[SubscriptionService] Server-verified Apple entitlement synced (active: $active)');
      if (active && unfinishedTransaction != null) {
        final transactionId = int.tryParse(unfinishedTransaction.id);
        if (transactionId != null) {
          try {
            await SK2Transaction.finish(transactionId);
          } catch (e) {
            debugPrint(
                '[SubscriptionService] Verified unfinished StoreKit transaction could not be finished: $e');
          }
        }
      }
      return _TrustedServerEntitlement(
        active: active,
        expiresAt: expiresAt,
        source: 'app_store',
      );
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Server Apple entitlement sync failed (silent): $e');
      return null;
    }
  }

  Future<_TrustedServerEntitlement?> _syncVerifiedGoogleEntitlement({
    required String expectedUserId,
    PurchaseDetails? purchase,
  }) async {
    if (!Platform.isAndroid || _currentEntitlementUserId != expectedUserId) {
      return null;
    }

    try {
      final purchases = <PurchaseDetails>[];
      if (purchase != null) purchases.add(purchase);
      if (purchases.isEmpty) {
        final addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final result = await addition.queryPastPurchases();
        if (result.error != null) {
          debugPrint(
              '[SubscriptionService] Google Play query failed: ${result.error}');
          return null;
        }
        purchases.addAll(result.pastPurchases);
      }

      _TrustedServerEntitlement? inactiveDecision;
      for (final candidate in purchases) {
        if (!_allSubscriptionIds.contains(candidate.productID)) continue;
        final token = candidate.verificationData.serverVerificationData.trim();
        if (token.isEmpty) continue;

        final response = await _supabase.client.functions.invoke(
          'verify-google-entitlement',
          body: {
            'purchase_token': token,
            'product_id': candidate.productID,
          },
        ).timeout(const Duration(seconds: 15));
        final data = response.data;
        final entitlement = data is Map ? data['entitlement'] : null;
        if (entitlement is! Map ||
            _currentEntitlementUserId != expectedUserId) {
          continue;
        }
        final active = entitlement['active'] == true;
        final expiresAtRaw = entitlement['expires_at'];
        final expiresAt = expiresAtRaw is String
            ? DateTime.tryParse(expiresAtRaw)?.toLocal()
            : null;
        final decision = _TrustedServerEntitlement(
          active: active,
          expiresAt: expiresAt,
          source: 'play_store',
        );
        if (decision.active) return decision;
        inactiveDecision ??= decision;
      }

      return inactiveDecision ??
          _TrustedServerEntitlement(
            active: false,
            expiresAt: null,
            source: 'play_store',
          );
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Server Google Play entitlement sync failed: $e');
      return null;
    }
  }

  SK2Transaction? _latestAppleSubscriptionTransaction(
    List<SK2Transaction> transactions,
  ) {
    SK2Transaction? latest;
    DateTime? latestDate;

    for (final transaction in transactions) {
      if (!_allSubscriptionIds.contains(transaction.productId)) continue;
      if (transaction.receiptData?.trim().isEmpty ?? true) continue;

      final candidateDate = _parseStoreKitDate(transaction.expirationDate) ??
          _parseStoreKitDate(transaction.purchaseDate);
      if (candidateDate == null) continue;

      if (latestDate == null || candidateDate.isAfter(latestDate)) {
        latest = transaction;
        latestDate = candidateDate;
      }
    }

    return latest;
  }

  DateTime? _parseStoreKitDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final epochMilliseconds = int.tryParse(value);
    if (epochMilliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(epochMilliseconds);
    }

    // StoreKit's bridge may send "yyyy-MM-dd HH:mm:ss" instead of ISO 8601.
    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  /// Reconcile the signed-in account with the server-owned entitlement.
  /// The private app_entitlements table is never queried by the app directly.
  Future<void> _loadSubscriptionFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      await _refreshSubscriptionFromTrustedServer();
      await _loadUsageStatsFromSupabase();
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Error loading subscription from Supabase (silent): $e');
    }
  }

  Future<void> _loadUsageStatsFromSupabase() async {
    try {
      if (!_supabase.isAuthenticated) return;

      final userId = _supabase.currentUser!.id;
      final response = await _supabase.client
          .from('usage_statistics')
          .select()
          .eq('user_id', userId);

      for (final stat in response) {
        final featureName = stat['feature_name'] as String;
        final usageCount = stat['usage_count'] as int? ?? 0;
        debugPrint(
            '[SubscriptionService] Cloud $featureName usage: $usageCount');
      }
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Error loading usage stats from Supabase (silent): $e');
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
        final existing = await _supabase.client
            .from('usage_statistics')
            .select()
            .eq('user_id', userId)
            .eq('feature_name', entry.key)
            .maybeSingle();

        final data = {
          'user_id': userId,
          'feature_name': entry.key,
          'usage_count': entry.value,
          'last_reset_at': _usageStats.lastReset.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing != null) {
          await _supabase.client
              .from('usage_statistics')
              .update(data)
              .eq('user_id', userId)
              .eq('feature_name', entry.key);
        } else {
          await _supabase.client.from('usage_statistics').insert(data);
        }
      }

      debugPrint('[SubscriptionService] Usage stats synced to Supabase');
    } catch (e) {
      debugPrint(
          '[SubscriptionService] Error syncing usage stats (silent): $e');
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
      return "🔒 **Image Generation Limit Reached**\n\nYou've used all ${limits.imageGenerationsWeekly} weekly image generations. Your limit will reset next week!\n\n✨ **Premium Benefits:**\n• Unlimited image generation\n• Higher quality images\n• Advanced gpt-5.2 model\n• Real-time web search\n• ElevenLabs voice synthesis\n\n[Upgrade to Premium] for unlimited access.";
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
    _authSubscription?.cancel();
    super.dispose();
  }
}
