import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../widgets/custom_back_button.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onSubscribed;

  const SubscriptionScreen({Key? key, this.onSubscribed}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  AudioPlayer? _audioPlayer;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> _isPaused = ValueNotifier(false);

  Future<void> _playVoiceDemo() async {
    try {
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();

      final data =
          await rootBundle.load('assets/audio/hao_voice_demo_fixed.mp3');

      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());

      await _audioPlayer!.setAsset('assets/audio/hao_voice_demo_fixed.mp3');

      setState(() {
        _isPlaying.value = true;
        _isPaused.value = false;
      });

      await _audioPlayer!.play();

      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed ||
            state.processingState == ProcessingState.idle) {
          setState(() {
            _isPlaying.value = false;
            _isPaused.value = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.couldNotPlayDemoAudio)),
        );
      }
    }
  }

  Future<void> _pauseVoiceDemo() async {
    if (_audioPlayer != null && _isPlaying.value) {
      await _audioPlayer!.pause();
      setState(() {
        _isPaused.value = true;
        _isPlaying.value = false;
      });
    }
  }

  Future<void> _resumeVoiceDemo() async {
    if (_audioPlayer != null && _isPaused.value) {
      setState(() {
        _isPaused.value = false;
        _isPlaying.value = true;
      });
      await _audioPlayer!.play();
    }
  }

  Future<void> _stopVoiceDemo() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      setState(() {
        _isPlaying.value = false;
        _isPaused.value = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri,
          mode: launcher.LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _isPlaying.dispose();
    _isPaused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.premiumTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          // Show different content for premium vs free users
          if (subscriptionService.isPremium) {
            return _buildPremiumUserScreen(subscriptionService);
          } else {
            return _buildSubscriptionPlansScreen(
                subscriptionService, horizontalPadding, isTablet);
          }
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0078D4), Color(0xFF106ebe)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium badge with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.premiumBadge,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main title
          Text(
            AppLocalizations.of(context)!.unlockBestAIExperience,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            AppLocalizations.of(context)!.advancedAIMultiplePlatforms,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(monthlyProduct, yearlyProduct) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseYourPlan,
          style: TextStyle(
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.tapPlanToSubscribe,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),

        // Plans layout - side by side on tablets, stacked on phones
        if (isTablet && yearlyProduct != null && monthlyProduct != null)
          Row(
            children: [
              // Yearly Plan (with discount highlight)
              Expanded(
                child: _buildPlanCard(
                  title: AppLocalizations.of(context)!.yearlyPlan,
                  price: subscriptionService.getActualPrice(yearlyProduct),
                  period: AppLocalizations.of(context)!.perYear,
                  savings:
                      AppLocalizations.of(context)!.saveThreeMonthsBestValue,
                  isRecommended: true,
                  product: yearlyProduct,
                ),
              ),
              const SizedBox(width: 16),
              // Monthly Plan
              Expanded(
                child: _buildPlanCard(
                  title: AppLocalizations.of(context)!.monthlyPlan,
                  price: subscriptionService.getActualPrice(monthlyProduct),
                  period: AppLocalizations.of(context)!.perMonth,
                  isRecommended: false,
                  product: monthlyProduct,
                ),
              ),
            ],
          )
        else ...[
          // Stacked layout for phones
          // Yearly Plan (with discount highlight)
          if (yearlyProduct != null)
            _buildPlanCard(
              title: AppLocalizations.of(context)!.yearlyPlan,
              price: subscriptionService.getActualPrice(yearlyProduct),
              period: AppLocalizations.of(context)!.perYear,
              savings: AppLocalizations.of(context)!.saveThreeMonthsBestValue,
              isRecommended: true,
              product: yearlyProduct,
            ),

          const SizedBox(height: 8),

          // Monthly Plan
          if (monthlyProduct != null)
            _buildPlanCard(
              title: AppLocalizations.of(context)!.monthlyPlan,
              price: subscriptionService.getActualPrice(monthlyProduct),
              period: AppLocalizations.of(context)!.perMonth,
              isRecommended: false,
              product: monthlyProduct,
            ),
        ],
      ],
    );
  }

  Widget _buildTopBenefitsStrip() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final l10n = AppLocalizations.of(context)!;
    final benefits = <(IconData, String)>[
      (Icons.phone_in_talk, l10n.voiceCallFeatureTitle),
      (Icons.psychology, l10n.featureShowcaseDeepResearchTitle),
      (Icons.auto_awesome, l10n.knowledgeHubTitle),
      (Icons.search, l10n.realtimeInternetSearch),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0078D4).withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: benefits
            .map(
              (benefit) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0078D4).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(benefit.$1, size: isTablet ? 16 : 14),
                    const SizedBox(width: 6),
                    Text(
                      benefit.$2,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    String? savings,
    required bool isRecommended,
    required product,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () async {
        debugPrint('[SubscriptionScreen] Plan card tapped: ${product.id}, _isLoading=$_isLoading');
        if (_isLoading) {
          debugPrint('[SubscriptionScreen] TAP IGNORED — _isLoading is true (stuck state)');
          return;
        }
        setState(() => _isLoading = true);
        final subscriptionService =
            Provider.of<SubscriptionService>(context, listen: false);
        try {
          debugPrint('[SubscriptionScreen] Calling subscribe for: ${product.id}');
          await subscriptionService.subscribe(product.id)
              .timeout(const Duration(seconds: 15), onTimeout: () {
            debugPrint('[SubscriptionScreen] subscribe() TIMED OUT for ${product.id}');
          });
          debugPrint('[SubscriptionScreen] subscribe() returned. errorMessage=${subscriptionService.errorMessage}');
          if (mounted && subscriptionService.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(subscriptionService.errorMessage!),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } catch (e) {
          debugPrint('[SubscriptionScreen] subscribe() threw: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Purchase failed: ${e.toString()}'),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended
                ? const Color(0xFF0078D4)
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade200),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 20 : 16,
                isRecommended
                    ? (isTablet ? 32 : 28)
                    : (isTablet ? 20 : 16), // Extra top padding if recommended
                isTablet ? 20 : 16,
                isTablet ? 20 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact layout - all in rows
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price and period in same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0078D4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${AppLocalizations.of(context)!.firstMonthFree}',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  if (savings != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        savings,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0078D4),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.recommended,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPlaying,
      builder: (context, isPlaying, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isPaused,
          builder: (context, isPaused, __) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPlaying && !isPaused)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill,
                          color: Color(0xFF0078D4), size: 32),
                      onPressed: _playVoiceDemo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (isPlaying)
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled,
                          color: Color(0xFF0078D4), size: 32),
                      onPressed: _pauseVoiceDemo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (isPaused)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill,
                          color: Color(0xFF0078D4), size: 32),
                      onPressed: _resumeVoiceDemo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (isPlaying || isPaused) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.stop_circle,
                          color: Colors.red, size: 32),
                      onPressed: _stopVoiceDemo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isVerySmallScreen = constraints.maxWidth < 350;

                return Text(
                  AppLocalizations.of(context)!.freeVsPremium,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Table Header - responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final isVerySmallScreen = constraints.maxWidth < 350;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppLocalizations.of(context)!.features,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.free,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.premium,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),

          // Core features available to all
          _buildComparisonRow(
              AppLocalizations.of(context)!.unlimitedChatMessages, true, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.translationFeatures, true, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.basicVoiceDeviceTts, true, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.pdfCreationTools, true, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.profileUpdates, true, true),

          // Features with usage limits vs unlimited
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, child) {
              return Column(
                children: [
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.imageGeneration, true, true,
                      freeNote:
                          '${subscriptionService.limits.imageGenerationsWeekly}/week',
                      premiumNote: AppLocalizations.of(context)!.unlimited),
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.photoAnalysis, true, true,
                      freeNote:
                          '${subscriptionService.limits.imageAnalysisWeekly}/week',
                      premiumNote: AppLocalizations.of(context)!.unlimited),
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.shareMessageAsPdf,
                      true,
                      true,
                      freeNote:
                          '${subscriptionService.limits.pdfGenerationsWeekly}/week',
                      premiumNote: AppLocalizations.of(context)!.unlimited),
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.placesExplorer, true, true,
                      freeNote:
                          '${subscriptionService.limits.placesExplorerWeekly}/week',
                      premiumNote: AppLocalizations.of(context)!.unlimited),
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.documentAnalysis,
                      true,
                      true,
                      freeNote:
                          '${subscriptionService.limits.documentAnalysisWeekly}/week',
                      premiumNote: AppLocalizations.of(context)!.unlimited),
                  _buildComparisonRow(
                      AppLocalizations.of(context)!.presentationMaker,
                      true,
                      true),
                ],
              );
            },
          ),

          // Premium-only features
          _buildComparisonRow(
              AppLocalizations.of(context)!.premiumAiVoice, false, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.realtimeInternetSearch,
              false,
              true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.aiProfileInsights, false, true),
          _buildComparisonRow(
              AppLocalizations.of(context)!.featureShowcaseDeepResearchTitle,
              false,
              true),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, bool freeHas, bool premiumHas,
      {String? freeNote, String? premiumNote}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVerySmallScreen = constraints.maxWidth < 350;

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 12 : 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      freeHas ? Icons.check_circle : Icons.cancel,
                      color: freeHas ? Colors.green : Colors.grey.shade400,
                      size: isVerySmallScreen ? 18 : 20,
                    ),
                    if (freeNote != null && freeHas)
                      Text(
                        freeNote,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 9 : 10,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      premiumHas ? Icons.check_circle : Icons.cancel,
                      color: premiumHas ? Colors.green : Colors.grey.shade400,
                      size: isVerySmallScreen ? 18 : 20,
                    ),
                    if (premiumNote != null && premiumHas)
                      Text(
                        premiumNote,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 9 : 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrialHighlight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVerySmallScreen = constraints.maxWidth < 300;
          final isSmallScreen = constraints.maxWidth < 400;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                color: Colors.green.shade700,
                size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
              ),
              SizedBox(width: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.startFreeMonthToday,
                  style: TextStyle(
                    fontSize:
                        isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDevelopmentNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVerySmallScreen = constraints.maxWidth < 320;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚀 ${AppLocalizations.of(context)!.moreAIFeaturesWeekly}',
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: isVerySmallScreen ? 6 : 8),
              Text(
                AppLocalizations.of(context)!.constantlyRollingOut,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 11 : 13,
                  color: Colors.blue.shade600,
                  height: 1.3,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRestoreAndLegalSection() {
    return Column(
      children: [
        // Restore Purchases
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
                    await subscriptionService.restorePurchases();
                  } catch (e) {
                    // Silent
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
          child: Text(
            AppLocalizations.of(context)!.restorePurchases,
            style: const TextStyle(
              color: Color(0xFF0078D4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Legal Links - Responsive for small screens
        LayoutBuilder(
          builder: (context, constraints) {
            final isVerySmallScreen = constraints.maxWidth < 350;

            if (isVerySmallScreen) {
              // Stack vertically on very small screens
              return Column(
                children: [
                  TextButton(
                    onPressed: () => _launchUrl(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                    child: Text(
                      AppLocalizations.of(context)!.termsOfUse,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _launchUrl('https://haoyu.io/howai-privacy.html'),
                    child: Text(
                      AppLocalizations.of(context)!.privacyPolicy,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Horizontal layout for larger screens
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () => _launchUrl(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                    child: Text(
                      AppLocalizations.of(context)!.termsOfUse,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: Colors.grey.shade300,
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () =>
                        _launchUrl('https://haoyu.io/howai-privacy.html'),
                    child: Text(
                      AppLocalizations.of(context)!.privacyPolicy,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Premium user management screen
  Widget _buildPremiumUserScreen(SubscriptionService subscriptionService) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: Column(
            children: [
              // Premium Status Header
              _buildPremiumStatusHeader(subscriptionService),
              const SizedBox(height: 24),

              // Subscription Details Card
              _buildSubscriptionDetailsCard(subscriptionService),
              const SizedBox(height: 24),

              // Premium Features Showcase
              _buildPremiumFeaturesShowcase(),
              const SizedBox(height: 24),

              // Manage Subscription
              _buildManageSubscriptionCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Original subscription plans screen for free users
  Widget _buildSubscriptionPlansScreen(SubscriptionService subscriptionService,
      double horizontalPadding, bool isTablet) {
    final monthlyProduct = subscriptionService.monthlyProduct;
    final yearlyProduct = subscriptionService.yearlyProduct;

    return Column(
      children: [
        // Error banner for expired re-subscribe scenario
        if (subscriptionService.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.orange.shade700,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscriptionService.errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => _launchUrl('https://apps.apple.com/account/subscriptions'),
                  child: const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 800 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    const SizedBox(height: 12),

                    // Top differentiators
                    _buildTopBenefitsStrip(),
                    const SizedBox(height: 12),

                    // Subscription Plans Section
                    _buildSubscriptionPlans(monthlyProduct, yearlyProduct),
                    const SizedBox(height: 12),

                    // Trial Highlight (compact)
                    _buildTrialHighlight(),
                    const SizedBox(height: 12),

                    // Feature Comparison (Free vs Premium)
                    _buildComparisonSection(),
                    const SizedBox(height: 16),

                    // Development Note
                    _buildDevelopmentNote(),
                    const SizedBox(height: 24),

                    // Restore Purchases and Legal Links
                    _buildRestoreAndLegalSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatusHeader(SubscriptionService subscriptionService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.premiumActive,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.fullAccessToFeatures,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetailsCard(
      SubscriptionService subscriptionService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.subscriptionDetails,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(AppLocalizations.of(context)!.status,
              AppLocalizations.of(context)!.active),
          const SizedBox(height: 12),
          _buildDetailRow(AppLocalizations.of(context)!.billing,
              AppLocalizations.of(context)!.managedThroughAppStore),
          const SizedBox(height: 12),
          _buildDetailRow(AppLocalizations.of(context)!.features,
              AppLocalizations.of(context)!.unlimitedAccess),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeaturesShowcase() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.yourPremiumFeatures,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureShowcaseItem(
              Icons.image,
              AppLocalizations.of(context)!.unlimitedAiImageGeneration,
              AppLocalizations.of(context)!.createStunningImages),
          _buildFeatureShowcaseItem(
              Icons.analytics,
              AppLocalizations.of(context)!.unlimitedImageAnalysis,
              AppLocalizations.of(context)!.analyzePhotosWithAi),
          _buildFeatureShowcaseItem(
              Icons.picture_as_pdf,
              AppLocalizations.of(context)!.unlimitedPdfCreation,
              AppLocalizations.of(context)!.convertImagesToPdf),
          _buildFeatureShowcaseItem(
              Icons.record_voice_over,
              AppLocalizations.of(context)!.premiumAiVoice,
              AppLocalizations.of(context)!.naturalVoiceResponses),
          _buildFeatureShowcaseItem(
              Icons.phone_in_talk,
              AppLocalizations.of(context)!.voiceCallFeatureTitle,
              '${AppLocalizations.of(context)!.voiceCallFeatureDesc}\n${AppLocalizations.of(context)!.voiceCallPremiumLimit(10, 60)}'),
          _buildFeatureShowcaseItem(
              Icons.search,
              AppLocalizations.of(context)!.realtimeWebSearch,
              AppLocalizations.of(context)!.getLatestInformation),
          _buildFeatureShowcaseItem(
              Icons.psychology,
              AppLocalizations.of(context)!.featureShowcaseDeepResearchTitle,
              AppLocalizations.of(context)!.featureShowcaseDeepResearchDesc),
          _buildFeatureShowcaseItem(
              Icons.explore,
              AppLocalizations.of(context)!.placesExplorerTitle,
              AppLocalizations.of(context)!.placesExplorerDesc),
          _buildFeatureShowcaseItem(
              Icons.description,
              AppLocalizations.of(context)!.documentAnalysisTitle,
              AppLocalizations.of(context)!.documentAnalysisDesc),
        ],
      ),
    );
  }

  Widget _buildFeatureShowcaseItem(
      IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.green.withOpacity(0.1)
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.manageSubscription,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.subscriptionManagedMessage,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? 'https://apps.apple.com/account/subscriptions'
                      : 'https://play.google.com/store/account/subscriptions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.settings),
              label: Text(
                AppLocalizations.of(context)!.manageInAppStore,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
