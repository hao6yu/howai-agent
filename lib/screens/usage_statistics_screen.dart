import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../services/subscription_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/custom_back_button.dart';
import '../core/theme/howai_theme.dart';

class UsageStatisticsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UsageStatisticsScreen({super.key, this.onBack});

  @override
  State<UsageStatisticsScreen> createState() => _UsageStatisticsScreenState();
}

class _UsageStatisticsScreenState extends State<UsageStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.usageStatistics,
        elevation: 0,
        onBack: widget.onBack ?? () => Navigator.of(context).pop(),
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Status Card
                _buildPremiumStatusCard(subscriptionService),
                const SizedBox(height: 16),

                // Weekly Usage Section
                _buildWeeklyUsageSection(subscriptionService),
                const SizedBox(height: 16),

                // Reset Information
                _buildResetInfoSection(subscriptionService),
                const SizedBox(height: 60), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumStatusCard(SubscriptionService subscriptionService) {
    final colors = context.howaiColors;

    return Container(
      key: const Key('usage_account_status'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (subscriptionService.isPremium
                      ? colors.success
                      : colors.accent)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              subscriptionService.isPremium
                  ? Icons.check_rounded
                  : Icons.person_outline_rounded,
              color: subscriptionService.isPremium
                  ? colors.success
                  : colors.accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscriptionService.isPremium
                      ? AppLocalizations.of(context)!.premiumAccount
                      : AppLocalizations.of(context)!.freeAccount,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subscriptionService.isPremium
                      ? AppLocalizations.of(context)!.unlimitedAccessAllFeatures
                      : AppLocalizations.of(context)!.weeklyUsageLimitsApply,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyUsageSection(SubscriptionService subscriptionService) {
    final colors = context.howaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Text(
              subscriptionService.isPremium
                  ? AppLocalizations.of(context)!.featureAccess
                  : AppLocalizations.of(context)!.weeklyUsage,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(17),
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildUsageItem(
                icon: Icons.photo_camera,
                title: AppLocalizations.of(context)!.photoAnalysis,
                used: subscriptionService.usageStats.imageAnalysisCount,
                limit: subscriptionService.limits.imageAnalysisWeekly,
                isPremium: subscriptionService.isPremium,
              ),
              _buildDivider(),
              _buildUsageItem(
                icon: Icons.brush,
                title: AppLocalizations.of(context)!.imageGeneration,
                used: subscriptionService.usageStats.imageGenerationsCount,
                limit: subscriptionService.limits.imageGenerationsWeekly,
                isPremium: subscriptionService.isPremium,
              ),
              _buildDivider(),
              _buildUsageItem(
                icon: Icons.picture_as_pdf,
                title: AppLocalizations.of(context)!.pdfGeneration,
                used: subscriptionService.usageStats.pdfGenerationsCount,
                limit: subscriptionService.limits.pdfGenerationsWeekly,
                isPremium: subscriptionService.isPremium,
              ),
              _buildDivider(),
              _buildUsageItem(
                icon: Icons.explore,
                title: AppLocalizations.of(context)!.placesExplorer,
                used: subscriptionService.usageStats.placesExplorerCount,
                limit: subscriptionService.limits.placesExplorerWeekly,
                isPremium: subscriptionService.isPremium,
              ),
              _buildDivider(),
              _buildUsageItem(
                icon: Icons.description,
                title: AppLocalizations.of(context)!.documentAnalysis,
                used: subscriptionService.usageStats.documentAnalysisCount,
                limit: subscriptionService.limits.documentAnalysisWeekly,
                isPremium: subscriptionService.isPremium,
              ),
              _buildDivider(),
              _buildUsageItem(
                icon: Icons.slideshow,
                title: AppLocalizations.of(context)!.presentationMaker,
                used: subscriptionService
                    .usageStats.documentAnalysisCount, // Shares quota
                limit: subscriptionService.limits.documentAnalysisWeekly,
                isPremium: subscriptionService.isPremium,
                subtitle:
                    AppLocalizations.of(context)!.sharesDocumentAnalysisQuota,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageItem({
    required IconData icon,
    required String title,
    required int used,
    required int limit,
    required bool isPremium,
    String? subtitle,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final colors = context.howaiColors;
        final percentage = isPremium ? 1.0 : (limit > 0 ? used / limit : 0.0);
        final isOverLimit = !isPremium && used >= limit;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              SizedBox(
                width: 28,
                child: Icon(
                  icon,
                  color: isPremium
                      ? colors.textSecondary
                      : isOverLimit
                          ? colors.danger
                          : colors.textSecondary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(12),
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (isPremium)
                      Text(
                        AppLocalizations.of(context)!.unlimited,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: colors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else ...[
                      Text(
                        '$used of $limit used this week',
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: isOverLimit
                              ? colors.danger
                              : colors.textSecondary,
                          fontWeight:
                              isOverLimit ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.surfaceStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isOverLimit ? colors.danger : colors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResetInfoSection(SubscriptionService subscriptionService) {
    if (subscriptionService.isPremium) {
      return const SizedBox.shrink(); // Don't show reset info for premium users
    }

    final daysUntilReset = 7 -
        DateTime.now()
            .difference(subscriptionService.usageStats.lastReset)
            .inDays;
    final resetDate =
        subscriptionService.usageStats.lastReset.add(const Duration(days: 7));
    final colors = context.howaiColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Text(
              'Usage Reset',
              style: TextStyle(
                fontSize: settings.getScaledFontSize(17),
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Icon(
                        Icons.refresh_rounded,
                        color: colors.textSecondary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Reset Schedule',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(16),
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                daysUntilReset <= 0
                                    ? 'Usage will reset soon'
                                    : daysUntilReset == 1
                                        ? 'Resets tomorrow'
                                        : 'Resets in $daysUntilReset days',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      return Text(
                        'All usage counters reset every 7 days. Your next reset date is ${resetDate.day}/${resetDate.month}/${resetDate.year}.',
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: colors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: context.howaiColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
