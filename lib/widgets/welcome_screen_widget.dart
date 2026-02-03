import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/settings_provider.dart';
import '../services/subscription_service.dart';
import 'package:haogpt/generated/app_localizations.dart';

class WelcomeScreenWidget extends StatefulWidget {
  final Function(String) onFeatureCardTap;
  final Function(String) onExampleChipTap;
  final VoidCallback? onShowImageGenerationDialog;
  final VoidCallback? onShowTranslationDialog;
  final String displayMode; // 'grid' for tools mode, 'horizontal' for chat mode

  const WelcomeScreenWidget({
    super.key,
    required this.onFeatureCardTap,
    required this.onExampleChipTap,
    this.onShowImageGenerationDialog,
    this.onShowTranslationDialog,
    this.displayMode = 'grid', // Default to tools mode
  });

  @override
  State<WelcomeScreenWidget> createState() => _WelcomeScreenWidgetState();
}

class _WelcomeScreenWidgetState extends State<WelcomeScreenWidget> with TickerProviderStateMixin {
  String? _loadingSuggestion;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallPhone = screenHeight < 700 || screenWidth < 400;
    final isTablet = screenWidth >= 600;

    // For horizontal mode, return just the horizontal cards without hero
    if (widget.displayMode == 'horizontal') {
      return _buildHorizontalActionCards();
    }

    // Default grid mode (tools mode)
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(isTablet, isLandscape),
            ),
            child: Column(
              children: [
                // Hero section
                SizedBox(height: _getTopSpacing(isTablet, isLandscape)),
                _buildResponsiveHero(isTablet, isSmallPhone, isLandscape),
                SizedBox(height: _getMiddleSpacing(isTablet, isLandscape)),

                // All feature cards in unified grid
                _buildAllFeatureCards(isTablet, isSmallPhone, isLandscape),

                // Additional spacing at bottom
                SizedBox(height: _getActionBottomPadding(isTablet, isLandscape)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getTopSpacing(bool isTablet, bool isLandscape) {
    if (isLandscape) return 4;
    if (isTablet) return 8;
    return 6;
  }

  double _getMiddleSpacing(bool isTablet, bool isLandscape) {
    if (isLandscape) return 6;
    if (isTablet) return 12;
    return 8;
  }

  double _getActionBottomPadding(bool isTablet, bool isLandscape) {
    if (isLandscape) return 8;
    return isTablet ? 16 : 12;
  }

  double _getHorizontalPadding(bool isTablet, bool isLandscape) {
    if (isLandscape && isTablet) return 60;
    if (isTablet) return 28;
    if (isLandscape) return 32;
    return 20;
  }

  Widget _buildResponsiveHero(bool isTablet, bool isSmallPhone, bool isLandscape) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate optimal font size that fits in one line
                    final double availableWidth = constraints.maxWidth;
                    final double optimalFontSize = _getOptimalSubtitleFontSize(isTablet, isLandscape, availableWidth);

                    return Text(
                      AppLocalizations.of(context)!.aiAgentReady,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(optimalFontSize),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getSubtitleFontSize(bool isTablet, bool isLandscape) {
    if (isLandscape) return isTablet ? 16 : 14;
    return isTablet ? 18 : 16;
  }

  double _getOptimalSubtitleFontSize(bool isTablet, bool isLandscape, double availableWidth) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base font size calculation
    double baseFontSize = _getSubtitleFontSize(isTablet, isLandscape);

    // Estimate text width (rough calculation - actual width depends on font metrics)
    // Average character width is approximately 0.6 * font size for most fonts
    const String sampleText = "Your intelligent AI agent - ready to assist with any task";
    double estimatedTextWidth = sampleText.length * baseFontSize * 0.6;

    // If text doesn't fit, scale down the font size
    if (estimatedTextWidth > availableWidth) {
      baseFontSize = (availableWidth / (sampleText.length * 0.6)).clamp(10.0, baseFontSize);
    }

    // Additional responsive adjustments for different screen sizes
    if (screenWidth < 380) {
      // Very small phones - aggressive scaling
      baseFontSize = baseFontSize.clamp(10.0, 13.0);
    } else if (screenWidth < 430) {
      // Small phones like iPhone 16 - moderate scaling
      baseFontSize = baseFontSize.clamp(11.0, 14.0);
    } else if (isLandscape && screenWidth < 800) {
      // Small tablets in landscape - ensure text fits
      baseFontSize = baseFontSize.clamp(12.0, 15.0);
    }

    return baseFontSize;
  }

  Widget _buildAllFeatureCards(bool isTablet, bool isSmallPhone, bool isLandscape) {
    final allFeatures = _getAllFeatures();
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate grid dimensions based on screen size and orientation with better detection
    int crossAxisCount = _getCrossAxisCount(screenWidth, isLandscape);
    double childAspectRatio = _getCardAspectRatio(screenWidth, isLandscape);
    double spacing = _getCardSpacing(screenWidth, isLandscape);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: allFeatures.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(allFeatures[index], isTablet, isSmallPhone, isLandscape, index);
      },
    );
  }

  Widget _buildHorizontalActionCards() {
    final allFeatures = _getAllFeatures();

    return Container(
      height: 40, // Increased height for better visibility
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: allFeatures.length,
        itemBuilder: (context, index) {
          final item = allFeatures[index];

          return Container(
            margin: EdgeInsets.only(right: index < allFeatures.length - 1 ? 6 : 0),
            child: Stack(
              children: [
                // Main card
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _handleCardTap(item, item['premiumOnly'] == true, false),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Consumer<SettingsProvider>(
                          builder: (context, settings, child) {
                            return Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(13),
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // PRO indicator - positioned relative to the entire card
                if (item['premiumOnly'] == true || _hasUsageLimit(item))
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      Icons.star,
                      size: 8,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth, bool isLandscape) {
    if (screenWidth >= 1200) {
      // Large iPad Pro (12.9") and larger displays
      return isLandscape ? 5 : 4;
    } else if (screenWidth >= 1000) {
      // iPad Pro (11"), iPad Air, and similar large tablets - 4 cards in portrait
      return isLandscape ? 4 : 4;
    } else if (screenWidth >= 700) {
      // Regular iPad and medium tablets - 4 cards in portrait for better space utilization
      return isLandscape ? 3 : 4;
    } else if (screenWidth >= 600) {
      // Small tablets and large phones in landscape
      return isLandscape ? 3 : 2;
    } else {
      // Regular phones
      return isLandscape ? 2 : 2;
    }
  }

  double _getCardAspectRatio(double screenWidth, bool isLandscape) {
    if (screenWidth >= 1200) {
      // Large iPad Pro (12.9") - balanced for content
      return isLandscape ? 1.8 : 1.3;
    } else if (screenWidth >= 1000) {
      // iPad Pro (11"), iPad Air - balanced for content
      return isLandscape ? 1.7 : 1.35;
    } else if (screenWidth >= 700) {
      // Regular iPad - balanced for content
      return isLandscape ? 1.5 : 1.4;
    } else if (screenWidth >= 600) {
      // Small tablets - balanced for content
      return isLandscape ? 1.4 : 1.5;
    } else if (screenWidth < 415) {
      // iPhone 16 and smaller phones - avoid overflow
      return isLandscape ? 1.6 : 1.4;
    } else {
      // Regular phones - avoid overflow
      return isLandscape ? 1.5 : 1.4;
    }
  }

  double _getCardSpacing(double screenWidth, bool isLandscape) {
    if (screenWidth >= 1200) {
      // Large iPad Pro (12.9") - extra generous spacing for premium look
      return isLandscape ? 20 : 18;
    } else if (screenWidth >= 1000) {
      // iPad Pro (11"), iPad Air - comfortable spacing
      return isLandscape ? 18 : 16;
    } else if (screenWidth >= 700) {
      // Regular iPad - balanced spacing
      return isLandscape ? 16 : 14;
    } else if (screenWidth >= 600) {
      // Small tablets - moderate spacing
      return isLandscape ? 14 : 12;
    } else {
      // Phones - optimized spacing for smaller screens
      return isLandscape ? 12 : 10;
    }
  }

  Widget _buildFeatureCard(Map<String, dynamic> item, bool isTablet, bool isSmallPhone, bool isLandscape, int index) {
    final isLoading = _loadingSuggestion == item['text'];
    final isPremiumOnly = item['premiumOnly'] == true;

    // Debug: Print info about problematic cards
    if (item['title'] == 'AI Image Generation' || item['title'] == 'Professional Writing' || item['title'] == 'Idea Generation' || item['title'] == 'Local Discovery') {
      // print('DEBUG CARD: ${item['title']} - Premium: $isPremiumOnly, Type: ${item['type']}, Icon: ${item['icon']}');
    }

    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isPremium = subscriptionService.isPremium;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, animationValue, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Add perspective
                  ..rotateX(-0.02 * math.pi) // Slight tilt for 3D effect
                  ..rotateY(math.sin(index * 0.3) * 0.01) // Subtle Y rotation variation
                  ..scale(0.95 + (0.05 * animationValue), 0.95 + (0.05 * animationValue), 1.0), // Scale animation
                alignment: Alignment.center,
                child: Opacity(
                  opacity: animationValue,
                  child: Container(
                    decoration: BoxDecoration(
                      // Clean gradient without type colors
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 0.3, 0.7, 1.0],
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? [
                                Color(0xFF2C2C2E),
                                Color(0xFF2C2C2E).withValues(alpha: 0.95),
                                Color(0xFF1C1C1E).withValues(alpha: 0.9),
                                Color(0xFF1C1C1E).withValues(alpha: 0.85),
                              ]
                            : [
                                Colors.white,
                                Color(0xFFFBFBFB),
                                Color(0xFFF8F9FA),
                                Color(0xFFF5F6F7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(_getCardRadius(isTablet) * 3.5),
                      // Modern border system
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        width: 0.5,
                      ),
                      // Enhanced 3D shadow system with multiple layers
                      boxShadow: [
                        // Primary shadow for depth - more pronounced
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 1,
                        ),
                        // Secondary shadow for ambient lighting - deeper
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                          spreadRadius: 2,
                        ),
                        // Tertiary shadow for extra depth
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
                          blurRadius: 48,
                          offset: const Offset(0, 20),
                          spreadRadius: 4,
                        ),
                        // Inner highlight for 3D effect
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.8),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(_getCardRadius(isTablet) * 3.5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(_getCardRadius(isTablet) * 3.5),
                        onTap: isLoading ? null : () => _handleCardTap(item, isPremiumOnly, isPremium),
                        onTapDown: (_) {
                          // Add subtle haptic feedback
                          HapticFeedback.selectionClick();
                        },
                        // Enhanced interaction colors with type-based theming
                        splashColor: _getTypeColor(item['type']).withValues(alpha: 0.15),
                        highlightColor: _getTypeColor(item['type']).withValues(alpha: 0.08),
                        hoverColor: _getTypeColor(item['type']).withValues(alpha: 0.05),
                        child: Stack(
                          children: [
                            // Main card content - consistent centering for all cards
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(_getCardPadding(isTablet, isLandscape)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Modern icon container with enhanced design
                                    Container(
                                      width: _getIconSize(isTablet, isLandscape),
                                      height: _getIconSize(isTablet, isLandscape),
                                      decoration: BoxDecoration(
                                        // Enhanced gradient with shimmer effect
                                        gradient: RadialGradient(
                                          center: Alignment.topLeft,
                                          radius: 1.2,
                                          stops: [0.0, 0.3, 0.7, 1.0],
                                          colors: [
                                            _getTypeColor(item['type']).withValues(alpha: 0.25),
                                            _getTypeColor(item['type']).withValues(alpha: 0.18),
                                            _getTypeColor(item['type']).withValues(alpha: 0.12),
                                            _getTypeColor(item['type']).withValues(alpha: 0.06),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(_getIconRadius(isTablet, isLandscape) * 1.2),
                                        // Softer border
                                        border: Border.all(
                                          color: _getTypeColor(item['type']).withValues(alpha: 0.15),
                                          width: 0.8,
                                        ),
                                        // Enhanced 3D shadow system for icons
                                        boxShadow: [
                                          // Primary icon shadow - more pronounced
                                          BoxShadow(
                                            color: _getTypeColor(item['type']).withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 1,
                                          ),
                                          // Secondary icon shadow for depth
                                          BoxShadow(
                                            color: _getTypeColor(item['type']).withValues(alpha: 0.12),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                            spreadRadius: 2,
                                          ),
                                          // Subtle ambient shadow
                                          BoxShadow(
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: _getTypeColor(item['type']),
                                          size: _getIconImageSize(isTablet, isLandscape),
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: _getTitleSpacing(isTablet, isLandscape)),

                                    // Title
                                    Consumer<SettingsProvider>(
                                      builder: (context, settings, child) {
                                        final locale = Localizations.localeOf(context);
                                        final isChinese = locale.languageCode == 'zh';

                                        return Text(
                                          item['title'],
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(_getTitleFontSize(isTablet, isLandscape)),
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E),
                                            height: isChinese ? 1.0 : 1.2, // Even tighter for Chinese
                                            letterSpacing: isChinese ? 0.2 : null, // Reduced spacing
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          strutStyle: isChinese
                                              ? StrutStyle(
                                                  height: 1.0,
                                                  forceStrutHeight: true,
                                                )
                                              : null,
                                        );
                                      },
                                    ),

                                    SizedBox(height: _getDescriptionSpacing(isTablet, isLandscape)),

                                    // Description
                                    Consumer<SettingsProvider>(
                                      builder: (context, settings, child) {
                                        final locale = Localizations.localeOf(context);
                                        final isChinese = locale.languageCode == 'zh';

                                        return Text(
                                          item['description'],
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(_getDescriptionFontSize(isTablet, isLandscape)),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade600,
                                            height: isChinese ? 1.1 : 1.3, // Even tighter for Chinese
                                            letterSpacing: isChinese ? 0.1 : null, // Minimal spacing
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          strutStyle: isChinese
                                              ? StrutStyle(
                                                  height: 1.1,
                                                  forceStrutHeight: true,
                                                )
                                              : null,
                                        );
                                      },
                                    ),

                                    // Usage limit indicator hidden for space saving

                                    // Loading indicator
                                    if (isLoading)
                                      Padding(
                                        padding: EdgeInsets.only(top: _getDescriptionSpacing(isTablet, isLandscape)),
                                        child: SizedBox(
                                          width: _getLoadingIndicatorSize(isTablet, isLandscape),
                                          height: _getLoadingIndicatorSize(isTablet, isLandscape),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(item['type'])),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Premium badge positioned at top right corner - non-intrusive positioning
                            if (isPremiumOnly || _hasUsageLimit(item))
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Enhanced PRO badge with shimmer effect
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFE55C), // Brighter gold
                                            Color(0xFFFFD700),
                                            Color(0xFFFFA500),
                                            Color(0xFFFF8C00), // Deeper orange
                                          ],
                                          stops: [0.0, 0.3, 0.7, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Color(0xFFFFE55C).withValues(alpha: 0.9),
                                          width: 0.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFFFFA500).withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                            spreadRadius: 0.5,
                                          ),
                                          BoxShadow(
                                            color: Color(0xFFFFD700).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                                        ),
                                      ),
                                    ),

                                    // NEW badge below PRO badge with animation
                                    if (item['isNew'] == true)
                                      Padding(
                                        padding: EdgeInsets.only(top: 3),
                                        child: TweenAnimationBuilder<double>(
                                          duration: Duration(milliseconds: 1500),
                                          tween: Tween(begin: 0.7, end: 1.0),
                                          curve: Curves.easeInOut,
                                          builder: (context, scale, child) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF00FF7F), // Brighter green
                                                    Color(0xFF00E676),
                                                    Color(0xFF00C851),
                                                    Color(0xFF00A040), // Deeper green
                                                  ],
                                                  stops: [0.0, 0.3, 0.7, 1.0],
                                                ),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Color(0xFF00FF7F).withValues(alpha: 0.9),
                                                  width: 0.8,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFF00C851).withValues(alpha: 0.5),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                    spreadRadius: 0.5,
                                                  ),
                                                  BoxShadow(
                                                    color: Color(0xFF00E676).withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                'NEW',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            // NEW badge for non-premium features - positioned at top right
                            if (item['isNew'] == true && !(isPremiumOnly || _hasUsageLimit(item)))
                              Positioned(
                                top: 5,
                                right: 5,
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 1500),
                                  tween: Tween(begin: 0.7, end: 1.0),
                                  curve: Curves.easeInOut,
                                  builder: (context, scale, child) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF00FF7F), // Brighter green
                                            Color(0xFF00E676),
                                            Color(0xFF00C851),
                                            Color(0xFF00A040), // Deeper green
                                          ],
                                          stops: [0.0, 0.3, 0.7, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Color(0xFF00FF7F).withValues(alpha: 0.9),
                                          width: 0.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF00C851).withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                            spreadRadius: 0.5,
                                          ),
                                          BoxShadow(
                                            color: Color(0xFF00E676).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Responsive sizing methods
  double _getCardRadius(bool isTablet) => isTablet ? 4 : 3;

  double _getCardPadding(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      // Large iPad Pro - ultra minimal padding
      return isLandscape ? 4 : 5;
    } else if (screenWidth >= 1000) {
      // iPad Pro/Air - ultra minimal padding
      return isLandscape ? 5 : 6;
    } else if (isLandscape) {
      return isTablet ? 6 : 4;
    }
    return isTablet ? 6 : 4;
  }

  double _getIconSize(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 380) {
      // Very small phones - smaller icons
      return isLandscape ? 40 : 42;
    } else if (screenWidth < 415) {
      // Small phones like iPhone 16 - slightly smaller
      return isLandscape ? 42 : 44;
    } else if (isLandscape) {
      return isTablet ? 50 : 42;
    }
    return isTablet ? 54 : 46;
  }

  double _getIconRadius(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 380) {
      return isLandscape ? 12 : 14;
    } else if (screenWidth < 415) {
      return isLandscape ? 13 : 15;
    } else if (isLandscape) {
      return isTablet ? 16 : 14;
    }
    return isTablet ? 18 : 16;
  }

  double _getIconImageSize(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 380) {
      // Very small phones - smaller icon images
      return isLandscape ? 22 : 24;
    } else if (screenWidth < 415) {
      // Small phones like iPhone 16 - slightly smaller
      return isLandscape ? 23 : 26;
    } else if (isLandscape) {
      return isTablet ? 28 : 24;
    }
    return isTablet ? 32 : 28;
  }

  double _getTitleSpacing(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final locale = Localizations.localeOf(context);
    final isChinese = locale.languageCode == 'zh';

    // Balanced spacing to avoid overflow
    final adjustment = isChinese ? 0.3 : 0.0;

    if (screenWidth >= 1200) {
      // Large iPad Pro - prevent overflow
      return isLandscape ? (2 + adjustment) : (2 + adjustment);
    } else if (screenWidth >= 1000) {
      // iPad Pro/Air - prevent overflow
      return isLandscape ? (2.5 + adjustment) : (2.5 + adjustment);
    } else if (isLandscape) {
      return isTablet ? (3 + adjustment) : (2.5 + adjustment);
    }
    return isTablet ? (2.5 + adjustment) : (2 + adjustment);
  }

  double _getTitleFontSize(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Special handling for iPhone 16 landscape (narrow height)
    if (isLandscape && screenHeight < 400) {
      return 12; // Very compact for landscape on small phones
    } else if (screenWidth < 380) {
      // Very small phones (iPhone SE, iPhone 12 mini)
      return isLandscape ? 13 : 14;
    } else if (screenWidth < 415) {
      // Small phones (iPhone 16, iPhone 15)
      return isLandscape ? 13 : 15;
    } else if (screenWidth >= 1200) {
      // Large iPad Pro - optimized for landscape overflow prevention
      return isLandscape ? 14 : 17;
    } else if (screenWidth >= 1000) {
      // iPad Pro/Air - slightly smaller for better fit
      return isLandscape ? 15 : 17;
    } else if (isLandscape) {
      return isTablet ? 15 : 14;
    }
    return isTablet ? 17 : 16;
  }

  double _getDescriptionSpacing(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final locale = Localizations.localeOf(context);
    final isChinese = locale.languageCode == 'zh';

    // Balanced spacing to avoid overflow
    final adjustment = isChinese ? 0.2 : 0.0;

    if (screenWidth < 380) {
      return 0.5 + adjustment; // Minimal spacing for very small screens
    } else if (screenWidth < 415) {
      return 0.8 + adjustment; // Balanced spacing for small screens
    } else if (screenWidth >= 1200) {
      // Large iPad Pro - prevent overflow
      return isLandscape ? (1 + adjustment) : (1 + adjustment);
    } else if (screenWidth >= 1000) {
      // iPad Pro/Air - prevent overflow
      return isLandscape ? (1.3 + adjustment) : (1.3 + adjustment);
    }

    if (isLandscape) return isTablet ? (1.5 + adjustment) : (1.3 + adjustment);
    return isTablet ? (1.3 + adjustment) : (1 + adjustment);
  }

  double _getDescriptionFontSize(bool isTablet, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Special handling for iPhone 16 landscape (narrow height)
    if (isLandscape && screenHeight < 400) {
      return 10; // Very compact for landscape on small phones
    } else if (screenWidth < 380) {
      // Very small phones - smaller description text
      return isLandscape ? 11 : 11.5;
    } else if (screenWidth < 415) {
      // Small phones like iPhone 16 - slightly smaller
      return isLandscape ? 10.5 : 12;
    } else if (screenWidth >= 1200) {
      // Large iPad Pro - smaller description text to prevent overflow
      return isLandscape ? 11 : 13;
    } else if (screenWidth >= 1000) {
      // iPad Pro/Air - slightly smaller description
      return isLandscape ? 12 : 13;
    } else if (isLandscape) {
      return isTablet ? 12 : 12;
    }
    return isTablet ? 13 : 13;
  }

  double _getLoadingIndicatorSize(bool isTablet, bool isLandscape) {
    if (isLandscape) return 16;
    return isTablet ? 20 : 18;
  }

  Future<void> _handleCardTap(Map<String, dynamic> item, bool isPremiumOnly, bool isPremium) async {
    HapticFeedback.lightImpact();

    // Check for PPTX generation - has usage limit for free users
    if (item['action'] == 'pptx') {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      if (!subscriptionService.isPremium) {
        // For free users, check if they have remaining document analysis uses (used as proxy for PPTX)
        if (subscriptionService.remainingDocumentAnalysis <= 0) {
          _showPptxUpgradeDialog(context);
          return;
        }
      }
    }

    // Check for AI image generation - show dialog instead of text input
    if (item['title'] == AppLocalizations.of(context)!.featureAiImageGeneration) {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      if (subscriptionService.canUseImageGeneration && widget.onShowImageGenerationDialog != null) {
        widget.onShowImageGenerationDialog!();
        return;
      } else if (!subscriptionService.canUseImageGeneration) {
        _showImageGenerationUpgradeDialog(context);
        return;
      }
    }

    // Check for Translation - show dialog instead of text input
    if (item['title'] == 'Translation') {
      if (widget.onShowTranslationDialog != null) {
        widget.onShowTranslationDialog!();
        return;
      }
    }

    // Only show upgrade dialog for truly premium-only features, not features with usage limits
    if (isPremiumOnly && !isPremium && !_hasUsageLimit(item)) {
      _showUpgradeDialog(context);
      return;
    }

    setState(() {
      _loadingSuggestion = item['text'];
    });

    await Future.delayed(const Duration(milliseconds: 150));

    if (item['action'] == 'photo') {
      widget.onFeatureCardTap('photo');
    } else if (item['action'] == 'pdf') {
      widget.onFeatureCardTap('pdf');
    } else if (item['action'] == 'pptx') {
      // For PPTX generation, show dialog but make sure it sends to chat when completed
      widget.onFeatureCardTap('pptx');
    } else if (item['action'] == 'file') {
      widget.onFeatureCardTap('file');
    } else if (item['action'] == 'location') {
      widget.onFeatureCardTap('location');
    } else if (item['action'] == 'voice') {
      // Focus the text input for voice interaction
      widget.onExampleChipTap('');
    } else if (item['action'] == 'translate') {
      // Handle translate action - already handled above, should not reach here
      return;
    } else {
      widget.onExampleChipTap(item['input'] ?? item['text']);
    }

    if (mounted) {
      setState(() {
        _loadingSuggestion = null;
      });
    }
  }

  List<Map<String, dynamic>> _getAllFeatures() {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;

    // Strategic feature ordering for optimal user experience and conversion
    final allFeatures = [
      // === TOP TIER: PRIORITIZED FEATURES ===
      {
        'icon': Icons.chat_bubble_outline,
        'title': l10n.featureSmartChatTitle,
        'description': l10n.featureSmartChatDesc,
        'text': l10n.featureSmartChatText,
        'input': l10n.featureSmartChatInput,
        'action': 'chat',
        'type': 'conversation',
        'priority': 100,
      },
      {
        'icon': Icons.explore,
        'title': l10n.featurePlacesExplorerTitle,
        'description': l10n.featurePlacesExplorerDesc,
        'text': l10n.inputFindPlaces,
        'input': l10n.inputFindPlaces,
        'action': 'location',
        'type': 'location',
        'priority': 95,
      },
      {
        'icon': Icons.brush,
        'title': l10n.featureAiImageGeneration,
        'description': l10n.featureAiImageGenerationDesc,
        'text': l10n.inputGenerateImage,
        'input': "Create an image of ",
        'action': 'chat',
        'type': 'creative',
        'priority': 90,
        'premiumOnly': true,
      },
      {
        'icon': Icons.camera,
        'title': l10n.featurePhotoAnalysis,
        'description': l10n.featurePhotoAnalysisDesc,
        'text': l10n.inputAnalyzePhotos,
        'input': l10n.inputAnalyzePhotos,
        'action': 'photo',
        'type': 'visual',
        'priority': 88,
      },
      {
        'icon': Icons.description,
        'title': l10n.featureDocumentAnalysis,
        'description': l10n.featureDocumentAnalysisDesc,
        'text': l10n.inputAnalyzeDocuments,
        'input': l10n.inputAnalyzeDocuments,
        'action': 'file',
        'type': 'document',
        'priority': 85,
      },

      // === TIER 3: HIGH-UTILITY FEATURES (Frequently used) ===
      {
        'icon': Icons.help,
        'title': l10n.featureProblemSolving,
        'description': l10n.featureProblemSolvingDesc,
        'text': l10n.inputSolveProblem,
        'input': "Help me solve this problem: ",
        'action': 'chat',
        'type': 'conversation',
        'priority': 80,
      },
      {
        'icon': Icons.picture_as_pdf,
        'title': l10n.featurePhotoToPdfTitle,
        'description': l10n.featurePhotoToPdfDesc,
        'text': l10n.featurePhotoToPdfText,
        'input': l10n.featurePhotoToPdfInput,
        'action': 'pdf',
        'type': 'document',
        'priority': 91,
      },
      // Presentation Maker removed - feature deprecated

      // === TIER 4: LANGUAGE & COMMUNICATION FEATURES ===
      {
        'icon': Icons.translate,
        'title': l10n.featureAiTranslationTitle,
        'description': l10n.featureAiTranslationDesc,
        'text': l10n.featureAiTranslationText,
        'input': l10n.featureAiTranslationInput,
        'action': 'translate',
        'type': 'conversation',
        'priority': 91,
      },

      {
        'icon': Icons.edit_note,
        'title': l10n.featureMessageFineTuningTitle,
        'description': l10n.featureMessageFineTuningDesc,
        'text': l10n.featureMessageFineTuningText,
        'input': l10n.featureMessageFineTuningInput,
        'action': 'chat',
        'type': 'conversation',
        'priority': 73,
      },

      // === TIER 5: PROFESSIONAL CONTENT CREATION ===
      {
        'icon': Icons.email,
        'title': l10n.featureProfessionalWritingTitle,
        'description': l10n.featureProfessionalWritingDesc,
        'text': l10n.featureProfessionalWritingText,
        'input': l10n.featureProfessionalWritingInput,
        'action': 'chat',
        'type': 'creative',
        'priority': 67,
      },
      {
        'icon': Icons.description,
        'title': l10n.featureIdeaGeneration,
        'description': l10n.featureIdeaGenerationDesc,
        'text': l10n.inputBrainstormIdeas,
        'input': "Help me brainstorm creative ideas for ",
        'action': 'chat',
        'type': 'creative',
        'priority': 60,
      },
      {
        'icon': Icons.summarize_rounded,
        'title': l10n.featureSmartSummarizationTitle,
        'description': l10n.featureSmartSummarizationDesc,
        'text': l10n.featureSmartSummarizationText,
        'input': l10n.featureSmartSummarizationInput,
        'action': 'chat',
        'type': 'conversation',
        'priority': 58,
      },

      // === TIER 6: EDUCATIONAL & LEARNING ===
      {
        'icon': Icons.help_rounded,
        'title': l10n.featureConceptExplanation,
        'description': l10n.featureConceptExplanationDesc,
        'text': l10n.inputExplainConcept,
        'input': "Explain this concept in simple terms: ",
        'action': 'chat',
        'type': 'learning',
        'priority': 50,
      },
      {
        'icon': Icons.build_rounded,
        'title': l10n.featureStepByStepGuides,
        'description': l10n.featureStepByStepGuidesDesc,
        'text': l10n.inputShowHowTo,
        'input': "Show me step-by-step how to ",
        'action': 'chat',
        'type': 'learning',
        'priority': 48,
      },

      // === TIER 7: CREATIVE & SPECIALIZED ===
      {
        'icon': Icons.edit,
        'title': l10n.featureCreativeWriting,
        'description': l10n.featureCreativeWritingDesc,
        'text': l10n.inputCreativeStory,
        'input': "Write a creative story about ",
        'action': 'chat',
        'type': 'creative',
        'priority': 45,
      },

      // === TIER 8: PLANNING & ORGANIZATION ===
      {
        'icon': Icons.calendar_today_rounded,
        'title': l10n.featureSmartPlanningTitle,
        'description': l10n.featureSmartPlanningDesc,
        'text': l10n.featureSmartPlanningText,
        'input': l10n.featureSmartPlanningInput,
        'action': 'chat',
        'type': 'planning',
        'priority': 35,
      },
      {
        'icon': Icons.movie_rounded,
        'title': l10n.featureEntertainmentGuideTitle,
        'description': l10n.featureEntertainmentGuideDesc,
        'text': l10n.featureEntertainmentGuideText,
        'input': l10n.featureEntertainmentGuideInput,
        'action': 'chat',
        'type': 'conversation',
        'priority': 32,
      },
    ];

    // === CONTEXTUAL FEATURES: Strategic time-based insertion ===
    if (hour >= 6 && hour < 12) {
      // Morning: High-priority productivity features
      allFeatures.addAll([
        {
          'icon': Icons.today_rounded,
          'title': l10n.featureDailyProductivity,
          'description': l10n.featureDailyProductivityDesc,
          'text': l10n.inputPlanDay,
          'input': "Help me plan my day for maximum productivity",
          'action': 'chat',
          'type': 'planning',
          'priority': 77, // Insert after Problem Solving
        },
        {
          'icon': Icons.wb_sunny_rounded,
          'title': l10n.featureMorningOptimization,
          'description': l10n.featureMorningOptimizationDesc,
          'text': l10n.inputMorningRoutine,
          'input': "Create a morning routine for ",
          'action': 'chat',
          'type': 'planning',
          'priority': 42, // Insert in specialized section
        },
      ]);
    }

    // Sort by priority (highest first) for optimal feature positioning
    allFeatures.sort((a, b) => ((b['priority'] ?? 0) as int).compareTo((a['priority'] ?? 0) as int));

    return allFeatures;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'conversation':
        return const Color(0xFF007AFF);
      case 'visual':
        return const Color(0xFF34C759);
      case 'document':
        return const Color(0xFFFF9500);
      case 'voice':
        return const Color(0xFFAF52DE);
      case 'learning':
        return const Color(0xFF34C759);
      case 'creative':
        return const Color(0xFFAF52DE);
      case 'planning':
        return const Color(0xFF32D74B);
      case 'location':
        return const Color(0xFF5856D6);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenHeight < 900 || screenWidth < 400; // Include iPhone 16 and similar
            final isVerySmallScreen = screenHeight < 860 && screenWidth < 400; // iPhone 16 specifically

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 6 : 8, vertical: isVerySmallScreen ? 3 : 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : 12),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.premiumFeatureTitle,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(isVerySmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                AppLocalizations.of(context)!.premiumFeatureDesc,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                  height: 1.4,
                ),
              ),
              actions: [
                // Responsive button layout
                if (isSmallScreen)
                  // Horizontal layout for small screens
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.maybeLater,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: isVerySmallScreen ? 6 : 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0078D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.upgradeNow,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 14 : 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, '/subscription');
                          },
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Vertical layout for larger screens
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.maybeLater,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.upgradeNow,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/subscription');
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // Check if feature has usage limits for free users
  bool _hasUsageLimit(Map<String, dynamic> item) {
    // Check for specific actions with limits
    if (item['action'] == 'location' || item['action'] == 'file' || item['action'] == 'photo' || item['action'] == 'pptx') {
      return true;
    }

    // Check for AI image generation by checking the title or input text
    final l10n = AppLocalizations.of(context)!;
    if (item['title'] == l10n.featureAiImageGeneration || item['input'] == l10n.inputGenerateImage) {
      return true;
    }

    return false;
  }

  void _showImageGenerationUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.brush,
                        size: settings.getScaledFontSize(48),
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'AI Image Generation - Premium Feature',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create stunning artwork and images from your imagination. This feature is available for Premium subscribers.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/subscription');
                            },
                            child: Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPptxUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF9500).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.slideshow,
                        size: settings.getScaledFontSize(48),
                        color: Color(0xFFFF9500),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Presentation Maker - Premium Feature',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create professional PowerPoint presentations with AI assistance. This feature is available for Premium subscribers only.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '✨ Premium Benefits:',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: 8),
                          ...['• Create professional PPTX presentations', '• Unlimited presentation generation', '• Custom themes and layouts', '• All premium AI features unlocked'].map(
                            (benefit) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                benefit,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(13),
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF9500),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/subscription');
                            },
                            child: Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
