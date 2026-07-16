import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/howai_theme.dart';

class UpgradeDialog extends StatelessWidget {
  final String featureName;
  final String limitMessage;
  final List<String> premiumBenefits;
  final VoidCallback onUpgradePressed;
  final VoidCallback? onCancelPressed;

  const UpgradeDialog({
    Key? key,
    required this.featureName,
    required this.limitMessage,
    required this.premiumBenefits,
    required this.onUpgradePressed,
    this.onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.howaiColors;
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: colors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$featureName limit reached',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              limitMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Included with Pro',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  for (final benefit in premiumBenefits)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: colors.success,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      onCancelPressed ?? () => Navigator.of(context).pop(),
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    onUpgradePressed();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.textPrimary,
                    foregroundColor: colors.canvas,
                  ),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Static convenience methods for common upgrade scenarios
  static void showImageAnalysisLimit(
      BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpgradeDialog(
        featureName: 'Image Analysis',
        limitMessage:
            'You\'ve reached your lifetime image analysis limit. Go Premium to unlock unlimited access.',
        premiumBenefits: [
          'Unlimited image analysis',
          'Smarter AI insights from your photos',
          'Real-time web search for current data',
          'Natural voice replies from your AI',
          'Customizable AI settings',
        ],
        onUpgradePressed: onUpgrade,
      ),
    );
  }

  static void showImageGenerationLimit(
      BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpgradeDialog(
        featureName: 'Image Generation',
        limitMessage:
            'You\'ve used your lifetime image generation limit. Go Premium to unlock unlimited creativity.',
        premiumBenefits: [
          'Unlimited AI image generation',
          'Higher-quality, detailed visuals',
          'Access to advanced AI models',
          'Real-time web search built in',
          'Voice replies that feel natural',
        ],
        onUpgradePressed: onUpgrade,
      ),
    );
  }

  static void showWebSearchLimit(BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        featureName: 'Web Search',
        limitMessage:
            'Get real-time answers from the web — available with Premium.',
        premiumBenefits: [
          'Live web search powered by AI',
          'Access to current events and trending info',
          'Real-time data like prices, facts, and news',
          'Unlimited use of all Pro features',
        ],
        onUpgradePressed: onUpgrade,
      ),
    );
  }

  static void showAIInsightsFeature(
      BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        featureName: 'AI Insights',
        limitMessage:
            'Get personalized AI analysis of your communication style and preferences.',
        premiumBenefits: [
          'Detailed personality analysis based on your conversations',
          'Communication style insights and recommendations',
          'Interest and preference tracking over time',
          'Personalized AI responses tailored to you',
          'Unlimited access to all premium features',
        ],
        onUpgradePressed: onUpgrade,
      ),
    );
  }
}
