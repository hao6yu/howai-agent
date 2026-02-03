import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';

class UsageDisplayWidget extends StatelessWidget {
  final bool showUpgradeButton;
  final VoidCallback? onUpgradePressed;

  const UsageDisplayWidget({
    Key? key,
    this.showUpgradeButton = true,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        // Don't show anything for premium users unless we want to show a status
        if (subscriptionService.isPremium) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0078D4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0078D4).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Color(0xFF0078D4), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Premium Active',
                    style: const TextStyle(
                      color: Color(0xFF0078D4),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  'Unlimited',
                  style: TextStyle(
                    color: const Color(0xFF0078D4),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        // Show usage for free users
        final usageSummary = subscriptionService.getUsageSummary();
        final imageUsed = usageSummary['imageAnalysisUsed'] as int;
        final imageLimit = usageSummary['imageAnalysisLimit'] as int;
        final voiceUsed = usageSummary['voiceGenerationsUsed'] as int;
        final voiceLimit = usageSummary['voiceGenerationsLimit'] as int;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lifetime Usage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),
              _UsageBar(
                label: 'Image Analysis',
                used: subscriptionService.usageStats.imageAnalysisCount,
                total: subscriptionService.limits.imageAnalysisWeekly,
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              _UsageBar(
                label: 'Voice Generation',
                used: subscriptionService.usageStats.voiceGenerationsCount,
                total: subscriptionService.limits.voiceGenerationsWeekly,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              _UsageBar(
                label: 'Image Generation',
                used: subscriptionService.usageStats.imageGenerationsCount,
                total: subscriptionService.limits.imageGenerationsWeekly,
                color: Colors.purple,
              ),
              SizedBox(height: 8),
              _UsageBar(
                label: 'PDF Generation',
                used: subscriptionService.usageStats.pdfGenerationsCount,
                total: subscriptionService.limits.pdfGenerationsWeekly,
                color: Colors.orange,
              ),
              if (_shouldShowUpgradePrompt(subscriptionService)) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nearing limit - upgrade for unlimited access',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showUpgradeButton) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUpgradePressed,
                    icon: Icon(Icons.upgrade, size: 16),
                    label: Text('Upgrade to Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8E6CFF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _shouldShowUpgradePrompt(SubscriptionService subscriptionService) {
    // Show upgrade if user has used 70% or more of any limit
    final imagePercentage = subscriptionService.limits.imageAnalysisWeekly > 0 ? subscriptionService.usageStats.imageAnalysisCount / subscriptionService.limits.imageAnalysisWeekly : 0.0;
    final voicePercentage = subscriptionService.limits.voiceGenerationsWeekly > 0 ? subscriptionService.usageStats.voiceGenerationsCount / subscriptionService.limits.voiceGenerationsWeekly : 0.0;
    final imageGenPercentage = subscriptionService.limits.imageGenerationsWeekly > 0 ? subscriptionService.usageStats.imageGenerationsCount / subscriptionService.limits.imageGenerationsWeekly : 0.0;
    final pdfPercentage = subscriptionService.limits.pdfGenerationsWeekly > 0 ? subscriptionService.usageStats.pdfGenerationsCount / subscriptionService.limits.pdfGenerationsWeekly : 0.0;

    return imagePercentage >= 0.7 || voicePercentage >= 0.7 || imageGenPercentage >= 0.7 || pdfPercentage >= 0.7;
  }
}

// Helper widget for usage bars
class _UsageBar extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final Color color;

  const _UsageBar({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isAtLimit = used >= total && total > 0;
    final isNearLimit = percentage >= 0.7 && !isAtLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              total > 0 ? '$used/$total' : '$used/∞',
              style: TextStyle(
                fontSize: 12,
                color: isAtLimit ? Colors.red.shade600 : Colors.grey.shade600,
                fontWeight: isAtLimit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey.shade200,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isAtLimit
                    ? Colors.red
                    : isNearLimit
                        ? Colors.orange
                        : color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
