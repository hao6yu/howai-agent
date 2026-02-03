import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../services/subscription_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/custom_back_button.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: subscriptionService.isPremium
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subscriptionService.isPremium ? 'PRO' : 'FREE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  subscriptionService.isPremium ? Icons.workspace_premium : Icons.star_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subscriptionService.isPremium ? AppLocalizations.of(context)!.premiumAccount : AppLocalizations.of(context)!.freeAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subscriptionService.isPremium ? AppLocalizations.of(context)!.unlimitedAccessAllFeatures : AppLocalizations.of(context)!.weeklyUsageLimitsApply,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyUsageSection(SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Text(
              subscriptionService.isPremium ? AppLocalizations.of(context)!.featureAccess : AppLocalizations.of(context)!.weeklyUsage,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(20),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                used: subscriptionService.usageStats.documentAnalysisCount, // Shares quota
                limit: subscriptionService.limits.documentAnalysisWeekly,
                isPremium: subscriptionService.isPremium,
                subtitle: AppLocalizations.of(context)!.sharesDocumentAnalysisQuota,
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
        final percentage = isPremium ? 1.0 : (limit > 0 ? used / limit : 0.0);
        final isOverLimit = !isPremium && used >= limit;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.green.withOpacity(0.1)
                      : isOverLimit
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isPremium
                      ? Colors.green
                      : isOverLimit
                          ? Colors.red
                          : Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(12),
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (isPremium)
                      Text(
                        AppLocalizations.of(context)!.unlimited,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else ...[
                      Text(
                        '$used of $limit used this week',
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: isOverLimit ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
                          fontWeight: isOverLimit ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isOverLimit ? Colors.red : Colors.blue,
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

    final daysUntilReset = 7 - DateTime.now().difference(subscriptionService.usageStats.lastReset).inDays;
    final resetDate = subscriptionService.usageStats.lastReset.add(const Duration(days: 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Text(
              'Usage Reset',
              style: TextStyle(
                fontSize: settings.getScaledFontSize(20),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
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
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                  child: Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      return Text(
                        'All usage counters reset every 7 days. Your next reset date is ${resetDate.day}/${resetDate.month}/${resetDate.year}.',
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Colors.orange.shade700,
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
      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
