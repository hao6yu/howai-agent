import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/ai_personality_provider.dart';

class SubscriptionBanner extends StatefulWidget {
  final VoidCallback? onUpgradePressed;

  const SubscriptionBanner({
    Key? key,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  State<SubscriptionBanner> createState() => _SubscriptionBannerState();
}

class _SubscriptionBannerState extends State<SubscriptionBanner> {
  // Instance variable to track if banner is dismissed for current session
  // This will reset when app restarts since it's not persisted
  bool _isDismissedForSession = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        // Hide banner entirely for premium users - they already have the compact badge
        if (subscriptionService.isPremium) {
          return const SizedBox.shrink();
        }

        // Hide banner if dismissed for current session
        if (_isDismissedForSession) {
          return const SizedBox.shrink();
        }

        // For free users, show engaging upgrade prompts
        return _buildCreativeUpgradeBanner(context, subscriptionService);
      },
    );
  }

  Widget _buildCreativeUpgradeBanner(BuildContext context, SubscriptionService subscriptionService) {
    // Rotate between different creative messages with improved readability
    final messages = [
      {
        'emoji': '🚀',
        'title': 'Unlock your full potential',
        'subtitle': 'Premium features are waiting for you',
        'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
        'buttonTextColor': Color(0xFF667eea),
      },
      {
        'emoji': '✨',
        'title': 'Ready for unlimited creativity?',
        'subtitle': 'Remove all limits with Premium',
        'gradient': [Color(0xFFe91e63), Color(0xFF9c27b0)], // Improved contrast with darker colors
        'buttonTextColor': Color(0xFFe91e63),
      },
      {
        'emoji': '🎯',
        'title': 'Take your AI experience further',
        'subtitle': 'Premium unlocks everything',
        'gradient': [Color(0xFF2196f3), Color(0xFF00bcd4)], // Better blue contrast
        'buttonTextColor': Color(0xFF2196f3),
      },
      {
        'emoji': '💎',
        'title': 'Discover Premium features',
        'subtitle': 'Unlimited access to advanced AI',
        'gradient': [Color(0xFF4caf50), Color(0xFF009688)], // Better green contrast
        'buttonTextColor': Color(0xFF4caf50),
      },
      {
        'emoji': '🌟',
        'title': 'Supercharge your workflow',
        'subtitle': 'Premium makes everything possible',
        'gradient': [Color(0xFFff9800), Color(0xFFf57c00)], // Replaced yellow with orange for better contrast
        'buttonTextColor': Color(0xFFff9800),
      },
    ];

    // Use time-based rotation so it changes over time
    final messageIndex = (DateTime.now().hour ~/ 4) % messages.length;
    final message = messages[messageIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: message['gradient'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (message['gradient'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InkWell(
              onTap: widget.onUpgradePressed ??
                  () {
                    Navigator.pushNamed(context, '/subscription');
                  },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 40, 8), // Add more right padding for close button
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Consumer<SettingsProvider>(
                          builder: (context, settings, child) {
                            return Text(
                              message['emoji'] as String,
                              style: TextStyle(fontSize: settings.getScaledFontSize(18)),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message['title'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: settings.getScaledFontSize(12),
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message['subtitle'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: settings.getScaledFontSize(10),
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Upgrade',
                                style: TextStyle(
                                  color: message['buttonTextColor'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: settings.getScaledFontSize(13),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: message['buttonTextColor'] as Color,
                                size: settings.getScaledFontSize(14),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Close button positioned absolutely in top-right corner
            Positioned(
              top: 1,
              right: 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDismissedForSession = true;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact version for smaller spaces
class CompactSubscriptionBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const CompactSubscriptionBadge({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        if (subscriptionService.isPremium) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0078D4),
                    const Color(0xFF106ebe),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: settings.getScaledFontSize(16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: settings.getScaledFontSize(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: onTap ??
              () {
                Navigator.pushNamed(context, '/subscription');
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.orange.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: settings.getScaledFontSize(16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.getScaledFontSize(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class BrandedAppTitle extends StatelessWidget {
  final VoidCallback? onTap;

  const BrandedAppTitle({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Consumer2<ProfileProvider, AIPersonalityProvider>(
              builder: (context, profileProvider, aiPersonalityProvider, child) {
                // Get AI name from current profile's AI personality
                String aiName = 'HowAI'; // Default fallback

                if (profileProvider.selectedProfileId != null) {
                  final personality = aiPersonalityProvider.getPersonalityForProfile(profileProvider.selectedProfileId!);
                  if (personality != null && personality.aiName.isNotEmpty) {
                    aiName = personality.aiName;
                  }
                }

                return GestureDetector(
                  onTap: onTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main app title
                      Text(
                        aiName,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Status badge positioned at top-right corner
                      Positioned(
                        top: -settings.getScaledFontSize(4),
                        right: -settings.getScaledFontSize(28),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: settings.getScaledFontSize(3),
                            vertical: settings.getScaledFontSize(1.5),
                          ),
                          decoration: BoxDecoration(
                            gradient: subscriptionService.isPremium
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF0078D4),
                                      const Color(0xFF106ebe),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(settings.getScaledFontSize(4)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: settings.getScaledFontSize(3),
                                offset: Offset(0, settings.getScaledFontSize(0.8)),
                              ),
                            ],
                          ),
                          child: Text(
                            subscriptionService.isPremium ? 'PRO' : 'FREE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
