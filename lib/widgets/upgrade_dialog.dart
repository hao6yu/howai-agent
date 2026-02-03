import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0078D4),
                    const Color(0xFF106ebe),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Premium icon with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$featureName Limit Reached',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upgrade to Premium for unlimited access',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Limit message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            limitMessage,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Premium benefits
                  Text(
                    '✨ Premium Benefits:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...premiumBenefits
                      .map((benefit) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0078D4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        flex: 3,
                        child: TextButton(
                          onPressed: onCancelPressed ?? () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Upgrade button
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            onUpgradePressed();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static convenience methods for common upgrade scenarios
  static void showImageAnalysisLimit(BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpgradeDialog(
        featureName: 'Image Analysis',
        limitMessage: 'You\'ve reached your lifetime image analysis limit. Go Premium to unlock unlimited access.',
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

  static void showImageGenerationLimit(BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpgradeDialog(
        featureName: 'Image Generation',
        limitMessage: 'You\'ve used your lifetime image generation limit. Go Premium to unlock unlimited creativity.',
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
        limitMessage: 'Get real-time answers from the web — available with Premium.',
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

  static void showAIInsightsFeature(BuildContext context, VoidCallback onUpgrade) {
    showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        featureName: 'AI Insights',
        limitMessage: 'Get personalized AI analysis of your communication style and preferences.',
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
