import 'package:flutter/material.dart';

class FeatureComparisonTable extends StatelessWidget {
  const FeatureComparisonTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = [
      FeatureRow(
        feature: 'AI Model',
        freeValue: 'GPT-5 Mini',
        premiumValue: 'gpt-5.2 (Advanced)',
        icon: Icons.psychology,
        isPremiumHighlight: true,
      ),
      FeatureRow(
        feature: 'Image Analysis',
        freeValue: '10 per week',
        premiumValue: 'Unlimited',
        icon: Icons.image_search,
        isPremiumHighlight: true,
      ),
      FeatureRow(
        feature: 'Image Generation',
        freeValue: '3 per week',
        premiumValue: 'Unlimited',
        icon: Icons.brush,
        isPremiumHighlight: true,
      ),
      FeatureRow(
        feature: 'Voice Synthesis',
        freeValue: 'Device TTS',
        premiumValue: 'ElevenLabs AI',
        icon: Icons.record_voice_over,
        isPremiumHighlight: true,
      ),
      FeatureRow(
        feature: 'Web Search',
        freeValue: 'Not Available',
        premiumValue: 'Real-time',
        icon: Icons.search,
        isPremiumHighlight: true,
        freeUnavailable: true,
      ),
      FeatureRow(
        feature: 'Voice Settings',
        freeValue: 'Basic',
        premiumValue: 'Advanced',
        icon: Icons.tune,
        isPremiumHighlight: true,
      ),
      FeatureRow(
        feature: 'Custom Prompts',
        freeValue: 'Not Available',
        premiumValue: 'Available',
        icon: Icons.edit_note,
        isPremiumHighlight: true,
        freeUnavailable: true,
      ),
      FeatureRow(
        feature: 'Priority Support',
        freeValue: 'Standard',
        premiumValue: 'Priority',
        icon: Icons.support_agent,
        isPremiumHighlight: false,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0078D4),
                          const Color(0xFF106ebe),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Feature rows
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            final isLast = index == features.length - 1;

            return _buildFeatureRow(
              feature,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(FeatureRow feature, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Feature name and icon
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  feature.icon,
                  color: const Color(0xFF0078D4),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature.feature,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Free tier value
          Expanded(
            child: Center(
              child: feature.freeUnavailable
                  ? Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 18,
                    )
                  : Text(
                      feature.freeValue,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),

          // Premium tier value
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: feature.isPremiumHighlight ? 8 : 0,
                  vertical: feature.isPremiumHighlight ? 4 : 0,
                ),
                decoration: feature.isPremiumHighlight
                    ? BoxDecoration(
                        color: const Color(0xFF0078D4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF0078D4).withOpacity(0.3),
                        ),
                      )
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (feature.isPremiumHighlight) ...[
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF0078D4),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        feature.premiumValue,
                        style: TextStyle(
                          fontSize: 13,
                          color: feature.isPremiumHighlight ? const Color(0xFF0078D4) : Colors.grey.shade600,
                          fontWeight: feature.isPremiumHighlight ? FontWeight.bold : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureRow {
  final String feature;
  final String freeValue;
  final String premiumValue;
  final IconData icon;
  final bool isPremiumHighlight;
  final bool freeUnavailable;

  FeatureRow({
    required this.feature,
    required this.freeValue,
    required this.premiumValue,
    required this.icon,
    this.isPremiumHighlight = false,
    this.freeUnavailable = false,
  });
}
