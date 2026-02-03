import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import '../services/location_service.dart';
import '../providers/settings_provider.dart';
import 'street_view_modal.dart';

class PlaceResultWidget extends StatefulWidget {
  final List<PlaceResult> places;
  final String searchQuery;
  final VoidCallback? onRetry;
  final bool enableRouteFeatures;

  const PlaceResultWidget({
    super.key,
    required this.places,
    required this.searchQuery,
    this.onRetry,
    this.enableRouteFeatures = true, // Default to enabled for backward compatibility
  });

  @override
  State<PlaceResultWidget> createState() => _PlaceResultWidgetState();
}

class _PlaceResultWidgetState extends State<PlaceResultWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final LocationService _locationService = LocationService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(PlaceResultWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      // Search query changed
    }
  }

  String _getPlaceDescription(PlaceResult place) {
    final types = place.types;

    if (types.contains('restaurant') || types.contains('food') || types.contains('meal_takeaway')) {
      return '🍽️ Restaurant & Dining';
    } else if (types.contains('cafe')) {
      return '☕ Coffee Shop & Café';
    } else if (types.contains('bakery') || types.contains('dessert')) {
      return '🧁 Sweet Food & Bakery';
    } else if (types.contains('convenience_store') || types.contains('ice_cream')) {
      return '🍦 Ice Cream & Desserts';
    } else if (types.contains('lodging') || types.contains('hotel')) {
      return '🏨 Accommodation & Lodging';
    } else if (types.contains('tourist_attraction') || types.contains('museum')) {
      return '🎭 Tourist Attraction & Culture';
    } else if (types.contains('shopping_mall') || types.contains('store') || types.contains('clothing_store')) {
      return '🛍️ Shopping & Retail';
    } else if (types.contains('parking')) {
      return '🅿️ Parking Garage';
    } else if (types.contains('hospital') || types.contains('doctor')) {
      return '🏥 Healthcare & Medical';
    } else if (types.contains('pharmacy')) {
      return '💊 Pharmacy & Medicine';
    } else if (types.contains('gas_station') || types.contains('car_repair')) {
      return '⛽ Automotive Services';
    } else if (types.contains('car_wash')) {
      return '🚗 Car Wash & Service';
    } else if (types.contains('bank')) {
      return '🏦 Banking Services';
    } else if (types.contains('atm')) {
      return '🏧 ATM & Cash Machine';
    } else if (types.contains('gym') || types.contains('spa')) {
      return '💪 Health & Fitness';
    } else if (types.contains('beauty_salon') || types.contains('hair_care')) {
      return '💅 Beauty & Personal Care';
    } else if (types.contains('laundry')) {
      return '👕 Laundromat & Dry Cleaning';
    } else if (types.contains('school') || types.contains('university')) {
      return '🎓 Education & Learning';
    } else if (types.contains('church') || types.contains('place_of_worship')) {
      return '⛪ Places of Worship';
    } else if (types.contains('park') || types.contains('zoo')) {
      return '🌳 Parks & Recreation';
    } else if (types.contains('movie_theater') || types.contains('night_club')) {
      return '🎬 Entertainment & Nightlife';
    } else if (types.contains('subway_station') || types.contains('restroom')) {
      return '🚻 Public Restroom & Facilities';
    } else {
      return '📍 Local Business';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return _buildEmptyState();
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Get screen dimensions for responsive layout
        final screenSize = MediaQuery.of(context).size;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // View buttons (moved to top, no header)
            _buildViewButtons(settings),

            // Main content area - let content determine height
            _buildCardView(settings),
          ],
        );
      },
    );
  }

  Widget _buildHeader(SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Use same device detection logic as build method
    final isMiniPhone = (screenWidth <= 390 && screenHeight <= 850) || (screenWidth <= 850 && screenHeight <= 390);
    final isStandardPhone = (screenWidth <= 410 && screenHeight <= 880) || (screenWidth <= 880 && screenHeight <= 410);
    final isPlusProPhone = (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    final isUltraCompact = isMiniPhone;
    final isVerySmall = isStandardPhone && !isMiniPhone;
    final isSmall = isPlusProPhone && !isStandardPhone;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isUltraCompact ? 6 : (isVerySmall ? 8 : (isSmall ? 12 : 16)), vertical: isUltraCompact ? 4 : (isVerySmall ? 6 : (isSmall ? 8 : 12))),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5856D6), Color(0xFF5856D6).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5856D6).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: settings.getScaledFontSize(isUltraCompact ? 14 : (isVerySmall ? 16 : (isSmall ? 18 : 20))),
            ),
          ),
          SizedBox(width: isUltraCompact ? 6 : (isVerySmall ? 8 : 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.foundPlaces(widget.places.length),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: settings.getScaledFontSize(isUltraCompact ? 10 : (isVerySmall ? 12 : (isSmall ? 14 : 16))),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_locationService.currentAddress != null)
                  Text(
                    AppLocalizations.of(context)!.nearLocation(_locationService.currentAddress!),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: settings.getScaledFontSize(isUltraCompact ? 8 : (isVerySmall ? 9 : (isSmall ? 10 : 12))),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.white,
                fontSize: settings.getScaledFontSize(10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButtons(SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Use same device detection logic
    final isMiniPhone = (screenWidth <= 390 && screenHeight <= 850) || (screenWidth <= 850 && screenHeight <= 390);
    final isStandardPhone = (screenWidth <= 410 && screenHeight <= 880) || (screenWidth <= 880 && screenHeight <= 410);
    final isPlusProPhone = (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    final isUltraCompact = isMiniPhone;
    final isVerySmall = isStandardPhone && !isMiniPhone;
    final isSmall = isPlusProPhone && !isStandardPhone;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              icon: Icons.view_carousel,
              label: 'Card',
              isActive: true, // Currently viewing cards
              isActionButton: false, // This is the current view, not an action
              onTap: () {
                // Already in cards view, do nothing
              },
              settings: settings,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildViewButton(
              icon: Icons.format_list_bulleted,
              label: 'List',
              isActive: false,
              isActionButton: true, // This opens full screen
              onTap: () => _openFullScreenList(),
              settings: settings,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildViewButton(
              icon: Icons.map_outlined,
              label: 'Map',
              isActive: false,
              isActionButton: true, // This opens full screen
              onTap: () => _openFullScreenMap(),
              settings: settings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isActionButton,
    required VoidCallback onTap,
    required SettingsProvider settings,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    // Better colors for dark mode
    final activeColor = isDark ? Colors.purple.shade300 : Color(0xFF5856D6);
    final inactiveColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8, horizontal: isTablet ? 8 : 6),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? activeColor.withOpacity(0.15) : activeColor.withOpacity(0.1)) : (isDark ? Colors.grey.shade700 : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : (isDark ? Colors.grey.shade500 : Colors.grey.shade300),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: settings.getScaledFontSize(isTablet ? 18 : 16),
            ),
            SizedBox(width: isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: settings.getScaledFontSize(isTablet ? 13 : 11),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenMap() async {
    // Open full-screen map and wait for it to close
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenMapView(
          places: widget.places,
          searchQuery: widget.searchQuery,
          enableRouteFeatures: widget.enableRouteFeatures,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
        barrierDismissible: true,
        opaque: false,
      ),
    );
  }

  void _openFullScreenList() async {
    // Open full-screen list view and wait for the result
    final selectedPlaceIndex = await Navigator.of(context).push<int>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenListView(
          places: widget.places,
          searchQuery: widget.searchQuery,
          enableRouteFeatures: widget.enableRouteFeatures,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
        barrierDismissible: true,
        opaque: true,
      ),
    );

    // If a place was selected, navigate to that card
    if (selectedPlaceIndex != null && selectedPlaceIndex >= 0 && selectedPlaceIndex < widget.places.length) {
      setState(() {
        _currentIndex = selectedPlaceIndex;
      });

      // Animate to the selected card
      _pageController.animateToPage(
        selectedPlaceIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showPhotoGallery(PlaceResult place, SettingsProvider settings) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            // Full screen photo
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _EnhancedPhotoGalleryWidget(
                    place: place,
                    settings: settings,
                    locationService: _locationService,
                    buildPhotoPlaceholder: () => _buildPhotoPlaceholder(place, settings),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Place info overlay
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      place.address,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: settings.getScaledFontSize(14),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${place.rating}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: settings.getScaledFontSize(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${place.userRatingsTotal} reviews',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: settings.getScaledFontSize(12),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: place.isOpen ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView(SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.height < 950 && screenSize.width < 450;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Place cards (swipeable) - connected to tab bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: _getResponsiveCardHeight(screenSize), // Dynamic height based on screen size
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.places.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(screenSize.width >= 600 ? 16 : 12), // More padding for tablets
                child: _buildPlaceCard(widget.places[index], settings),
              );
            },
          ),
        ),

        // Page indicator back outside the cards, under the entire widget
        if (widget.places.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: _buildSimplePageIndicator(settings),
          ),
      ],
    );
  }

  double _calculateOptimalCardHeight(Size screenSize, SettingsProvider settings) {
    final isTablet = screenSize.width >= 600;
    final isLandscape = screenSize.width > screenSize.height;

    // Base content height estimation
    double baseContentHeight = 120; // Header + rating + address + AI insights
    double actionButtonsHeight = 40; // Action buttons row
    double photoHeight = isLandscape && !isTablet ? 0 : 200; // Photo section
    double padding = 32; // Total padding

    double estimatedHeight = baseContentHeight + actionButtonsHeight + photoHeight + padding;

    // Responsive adjustments
    if (isTablet) {
      estimatedHeight *= 1.2; // More space for tablets
    } else if (screenSize.width < 400) {
      estimatedHeight *= 0.9; // Compact for small screens
    }

    // Clamp to reasonable bounds
    return estimatedHeight.clamp(300.0, screenSize.height * 0.7);
  }

  double _getResponsiveCardHeight(Size screenSize) {
    final isTablet = screenSize.width >= 600;
    final isLandscape = screenSize.width > screenSize.height;

    if (isTablet) {
      // iPad gets more height for better action button visibility
      return 480;
    } else if (screenSize.width < 400) {
      // Small phones get compact height
      return 320;
    } else {
      // Standard phones
      return 360;
    }
  }

  Widget _buildEmptyState() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: settings.getScaledFontSize(48),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noPlacesFound,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(16),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.trySearchingElse,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(14),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              if (widget.onRetry != null) ...[
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5856D6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.tryAgain,
                    style: TextStyle(fontSize: settings.getScaledFontSize(14)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(PlaceResult place, SettingsProvider settings) {
    // Get screen dimensions and orientation for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenSize.width >= 600;
    final isHorizontalLayout = isLandscape && !isTablet;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLandscape && !isTablet
          ? Row(
              // Horizontal layout for landscape on phones
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPhotoSection(place, settings),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: _buildInfoSection(place, settings),
                  ),
                ),
              ],
            )
          : Column(
              // Vertical layout for portrait or tablets
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo section - use flexible instead of expanded to allow content to dictate size
                Flexible(
                  flex: isTablet ? 3 : 2,
                  child: _buildPhotoSection(place, settings),
                ),

                // Info section - flexible and scrollable
                Flexible(
                  flex: 3, // Give more space to info section
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: _buildInfoSection(place, settings),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPhotoSection(PlaceResult place, SettingsProvider settings) {
    // Get layout information for responsive design
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenSize.width >= 600;
    final isHorizontalLayout = isLandscape && !isTablet;

    // Determine border radius based on layout
    final borderRadius = isHorizontalLayout
        ? BorderRadius.horizontal(left: Radius.circular(20)) // Left side only for horizontal layout
        : BorderRadius.vertical(top: Radius.circular(20)); // Top only for vertical layout

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100,
      ),
      child: Stack(
        children: [
          // Photo or placeholder
          ClipRRect(
            borderRadius: borderRadius,
            child: place.photoReference != null
                ? GestureDetector(
                    onTap: () => _showPhotoGallery(place, settings),
                    child: Image.network(
                      _locationService.getPhotoUrl(place.photoReference!, maxWidth: 600),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(place, settings),
                    ),
                  )
                : _buildPhotoPlaceholder(place, settings),
          ),

          // Overlay with status badges
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                // Open/Closed status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    place.isOpen ? AppLocalizations.of(context)!.open : AppLocalizations.of(context)!.closed,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: settings.getScaledFontSize(10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (place.priceLevel != 'Unknown') ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      place.priceLevel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.getScaledFontSize(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Distance badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF5856D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                place.getDistanceText(
                  locale: Localizations.localeOf(context).toString(),
                  countryCode: Localizations.localeOf(context).countryCode,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: settings.getScaledFontSize(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Photo gallery indicator
          if (place.photoReference != null || place.photoReferences.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => _showPhotoGallery(place, settings),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        place.photoReferences.isNotEmpty ? 'Photos' : 'View photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: settings.getScaledFontSize(10),
                          fontWeight: FontWeight.w500,
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

  Widget _buildPhotoPlaceholder(PlaceResult place, SettingsProvider settings) {
    IconData icon = Icons.place;
    Color color = Color(0xFF5856D6);

    // Choose icon based on place type
    if (place.types.contains('restaurant') || place.types.contains('food')) {
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (place.types.contains('cafe')) {
      icon = Icons.local_cafe;
      color = Colors.brown;
    } else if (place.types.contains('bakery')) {
      icon = Icons.cake;
      color = Colors.pink;
    } else if (place.types.contains('convenience_store')) {
      icon = Icons.icecream;
      color = Colors.cyan;
    } else if (place.types.contains('lodging')) {
      icon = Icons.hotel;
      color = Colors.blue;
    } else if (place.types.contains('tourist_attraction')) {
      icon = Icons.attractions;
      color = Colors.purple;
    } else if (place.types.contains('shopping_mall') || place.types.contains('store')) {
      icon = Icons.shopping_bag;
      color = Colors.green;
    } else if (place.types.contains('parking')) {
      icon = Icons.local_parking;
      color = Colors.indigo;
    } else if (place.types.contains('hospital')) {
      icon = Icons.local_hospital;
      color = Colors.red;
    } else if (place.types.contains('pharmacy')) {
      icon = Icons.medication;
      color = Colors.red.shade300;
    } else if (place.types.contains('gas_station')) {
      icon = Icons.local_gas_station;
      color = Colors.yellow.shade700;
    } else if (place.types.contains('car_wash')) {
      icon = Icons.car_repair;
      color = Colors.teal;
    } else if (place.types.contains('bank')) {
      icon = Icons.account_balance;
      color = Colors.blue.shade700;
    } else if (place.types.contains('atm')) {
      icon = Icons.atm;
      color = Colors.green.shade700;
    } else if (place.types.contains('gym')) {
      icon = Icons.fitness_center;
      color = Colors.orange.shade700;
    } else if (place.types.contains('beauty_salon')) {
      icon = Icons.face_retouching_natural;
      color = Colors.pink.shade400;
    } else if (place.types.contains('laundry')) {
      icon = Icons.local_laundry_service;
      color = Colors.blue.shade400;
    } else if (place.types.contains('night_club')) {
      icon = Icons.nightlife;
      color = Colors.deepPurple;
    } else if (place.types.contains('park')) {
      icon = Icons.park;
      color = Colors.green.shade600;
    } else if (place.types.contains('subway_station')) {
      icon = Icons.wc;
      color = Colors.grey.shade600;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(
          icon,
          size: settings.getScaledFontSize(48),
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoSection(PlaceResult place, SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Use same device detection logic for iPhone 16 Pro Max
    final isIPhone16ProMax = (screenWidth == 440 && screenHeight == 956) || (screenWidth == 956 && screenHeight == 440);
    final isVerySmallScreen = isIPhone16ProMax || (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    return Container(
      padding: EdgeInsets.fromLTRB(
        isIPhone16ProMax ? 10 : (isVerySmallScreen ? 12 : 16), // left
        isIPhone16ProMax ? 10 : (isVerySmallScreen ? 12 : 16), // top
        isIPhone16ProMax ? 10 : (isVerySmallScreen ? 12 : 16), // right
        isIPhone16ProMax ? 10 : (isVerySmallScreen ? 12 : 16), // bottom - increased for scrollable content
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and rating - constrained to prevent overflow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(isIPhone16ProMax ? 16 : (isVerySmallScreen ? 17 : 18)),
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1C1C1E),
                    height: 1.2,
                  ),
                  maxLines: isVerySmallScreen ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6),
              if (place.rating > 0) _buildRatingWidget(place, settings),
            ],
          ),

          SizedBox(height: isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 5)),

          // Place description
          Text(
            _getPlaceDescription(place),
            style: TextStyle(
              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 12 : 13),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Color(0xFF5856D6),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isIPhone16ProMax ? 5 : (isVerySmallScreen ? 6 : 8)),

          // Address - clickable to copy
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: settings.getScaledFontSize(isVerySmallScreen ? 13 : 15),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
              SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: () => _copyAddressFromCard(place),
                  child: Text(
                    place.address,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(isVerySmallScreen ? 13 : 15),
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                      height: 1.2,
                    ),
                    maxLines: isVerySmallScreen ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isIPhone16ProMax ? 6 : (isVerySmallScreen ? 8 : 10)),

          // AI Insights - compact preview (if available)
          if (place.aiSummary != null || place.reviewSummary != null) ...[
            _buildCompactAIInsights(place, settings),
            SizedBox(height: isIPhone16ProMax ? 4 : (isVerySmallScreen ? 6 : 8)),
          ],

          // Action buttons - responsive to screen size
          Row(
            children: [
              Expanded(
                child: _buildResponsiveActionButton(
                  icon: Icons.directions,
                  fullLabel: AppLocalizations.of(context)!.directions,
                  shortLabel: 'Directions',
                  onTap: () => _openDirections(place),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Color(0xFF5856D6),
                  settings: settings,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 5)),
              Expanded(
                child: _buildResponsiveActionButton(
                  icon: Icons.info_outline,
                  fullLabel: AppLocalizations.of(context)!.details,
                  shortLabel: 'Details',
                  onTap: () => _showPlaceDetails(place),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade600,
                  settings: settings,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 5)),
              Expanded(
                child: _buildResponsiveActionButton(
                  icon: Icons.streetview,
                  fullLabel: 'Street',
                  shortLabel: 'Street',
                  onTap: () => _openStreetView(place),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                  settings: settings,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 5)),
              Expanded(
                child: _buildResponsiveActionButton(
                  icon: Icons.share,
                  fullLabel: AppLocalizations.of(context)!.share,
                  shortLabel: 'Share',
                  onTap: () => _sharePlace(place),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green.shade600,
                  settings: settings,
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16), // Only top margin to connect with cards
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              GestureDetector(
                onTap: _currentIndex > 0 ? _goToPreviousPage : null,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex > 0 ? Color(0xFF5856D6) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _currentIndex > 0
                        ? [
                            BoxShadow(
                              color: Color(0xFF5856D6).withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Page indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
                ),
                child: Text(
                  '${_currentIndex + 1} of ${widget.places.length}',
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),

              // Next button
              GestureDetector(
                onTap: _currentIndex < widget.places.length - 1 ? _goToNextPage : null,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex < widget.places.length - 1 ? Color(0xFF5856D6) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _currentIndex < widget.places.length - 1
                        ? [
                            BoxShadow(
                              color: Color(0xFF5856D6).withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInlinePageIndicator(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          GestureDetector(
            onTap: _currentIndex > 0 ? _goToPreviousPage : null,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_currentIndex > 0 ? Color(0xFF5856D6) : Colors.grey.shade400).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1} of ${widget.places.length}',
              style: TextStyle(
                fontSize: settings.getScaledFontSize(12),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Next button
          GestureDetector(
            onTap: _currentIndex < widget.places.length - 1 ? _goToNextPage : null,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_currentIndex < widget.places.length - 1 ? Color(0xFF5856D6) : Colors.grey.shade400).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPageIndicator(SettingsProvider settings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        if (_currentIndex > 0)
          GestureDetector(
            onTap: _goToPreviousPage,
            child: Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

        // Page indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_currentIndex + 1}/${widget.places.length}',
            style: TextStyle(
              fontSize: settings.getScaledFontSize(10),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        // Next button
        if (_currentIndex < widget.places.length - 1)
          GestureDetector(
            onTap: _goToNextPage,
            child: Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSimplePageIndicator(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          GestureDetector(
            onTap: _currentIndex > 0 ? _goToPreviousPage : null,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentIndex > 0 ? Color(0xFF5856D6) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
            ),
            child: Text(
              '${_currentIndex + 1} of ${widget.places.length}',
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),

          // Next button
          GestureDetector(
            onTap: _currentIndex < widget.places.length - 1 ? _goToNextPage : null,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentIndex < widget.places.length - 1 ? Color(0xFF5856D6) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentIndex < widget.places.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildRatingWidget(PlaceResult place, SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Use same detection logic for iPhone 16 Pro Max
    final isIPhone16ProMax = (screenWidth == 440 && screenHeight == 956) || (screenWidth == 956 && screenHeight == 440);
    final isVerySmallScreen = isIPhone16ProMax || (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = screenWidth >= 600; // iPad support

    // Better colors for dark mode
    final starColor = isDark ? Colors.amber.shade400 : Colors.amber;
    final ratingTextColor = isDark ? Colors.amber.shade300 : Colors.amber.shade700;
    final reviewLinkColor = isDark ? Colors.blue.shade300 : Color(0xFF0066CC);

    return GestureDetector(
      onTap: place.userRatingsTotal > 0 ? () => _showRatingBreakdown(place) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : (isVerySmallScreen ? 6 : 8), vertical: isTablet ? 6 : (isVerySmallScreen ? 2 : 4)),
        decoration: BoxDecoration(
          color: isDark ? Colors.amber.withOpacity(0.15) : Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.amber.withOpacity(0.4) : Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: settings.getScaledFontSize(isTablet ? 16 : (isVerySmallScreen ? 12 : 14)),
              color: starColor,
            ),
            SizedBox(width: 2),
            Text(
              place.rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: settings.getScaledFontSize(isTablet ? 16 : (isVerySmallScreen ? 12 : 14)),
                fontWeight: FontWeight.w600,
                color: ratingTextColor,
              ),
            ),
            if (place.userRatingsTotal > 0) ...[
              SizedBox(width: 2),
              Text(
                '(${place.userRatingsTotal})',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(isTablet ? 12 : (isVerySmallScreen ? 9 : 10)),
                  color: place.userRatingsTotal > 0
                      ? reviewLinkColor // Better contrast for dark mode
                      : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
                  decoration: place.userRatingsTotal > 0 ? TextDecoration.underline : null,
                  fontWeight: place.userRatingsTotal > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
            // Add small arrow to indicate it's clickable
            if (place.userRatingsTotal > 0 && (!isVerySmallScreen || isTablet)) ...[
              SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: settings.getScaledFontSize(isTablet ? 14 : 12),
                color: reviewLinkColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAIInsights(PlaceResult place, SettingsProvider settings) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final isIPhone16ProMax = (screenWidth == 440 && screenHeight == 956) || (screenWidth == 956 && screenHeight == 440);
    final isVerySmallScreen = isIPhone16ProMax || (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    String aiText = '';
    if (place.aiSummary != null && place.aiSummary!.isNotEmpty) {
      aiText = place.aiSummary!;
    } else if (place.reviewSummary != null && place.reviewSummary!.isNotEmpty) {
      aiText = place.reviewSummary!;
    }

    if (aiText.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade800.withOpacity(0.2) : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(6), // Smaller radius
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade300.withOpacity(0.5) : Colors.purple.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Important: don't take more space than needed
        children: [
          // Header with AI badge - more compact
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: settings.getScaledFontSize(isVerySmallScreen ? 10 : 12), // Smaller icon
                color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Colors.purple.shade600,
              ),
              SizedBox(width: 3),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(isVerySmallScreen ? 9 : 10), // Smaller text
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Colors.purple.shade600,
                ),
              ),
              SizedBox(width: 3),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade400 : Colors.purple.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(6), // Even smaller
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3), // Reduced spacing
          // AI insights text - more compact
          Text(
            aiText,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(isVerySmallScreen ? 10 : 11), // Smaller text
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : Colors.grey.shade700,
              height: 1.2, // Tighter line height
            ),
            maxLines: 2, // Always limit to 2 lines for compactness
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required SettingsProvider settings,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Use same detection logic for iPhone 16 Pro Max
    final isIPhone16ProMax = (screenWidth == 440 && screenHeight == 956) || (screenWidth == 956 && screenHeight == 440);
    final isVerySmallScreen = isIPhone16ProMax || (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isIPhone16ProMax ? 6 : (isVerySmallScreen ? 8 : 10),
            horizontal: isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 6),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: settings.getScaledFontSize(isVerySmallScreen ? 15 : 17), color: color),
              SizedBox(width: isVerySmallScreen ? 2 : 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(isVerySmallScreen ? 11 : 13),
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveActionButton({
    required IconData icon,
    required String fullLabel,
    required String shortLabel,
    required VoidCallback onTap,
    required Color color,
    required SettingsProvider settings,
    required double screenWidth,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enhanced device detection with iPad support
    final isTablet = screenWidth >= 600; // iPad or larger tablet
    final isIPhone16ProMax = (screenWidth == 440 && screenHeight == 956) || (screenWidth == 956 && screenHeight == 440);
    final isVerySmallScreen = isIPhone16ProMax || (screenWidth <= 450 && screenHeight <= 970) || (screenWidth <= 970 && screenHeight <= 450);

    // Determine which label to use based on screen width and available space
    // iPad gets full labels, phones get responsive behavior
    String displayLabel;
    bool showIconOnly = false;

    if (isTablet) {
      // iPad and tablets - always show full labels with more space
      displayLabel = fullLabel;
    } else if (screenWidth < 350) {
      // Very narrow screens - icon only
      showIconOnly = true;
      displayLabel = '';
    } else if (screenWidth < 400 || isVerySmallScreen) {
      // Small screens - use abbreviated labels
      displayLabel = _getAbbreviatedLabel(fullLabel);
    } else {
      // Normal screens - use full labels
      displayLabel = fullLabel;
    }

    // Better color contrast for dark mode
    Color actionColor = color;
    if (isDark) {
      // Ensure better contrast in dark mode
      if (color == Color(0xFF5856D6)) {
        actionColor = Colors.purple.shade300;
      } else if (color == Colors.grey.shade600) {
        actionColor = Colors.grey.shade300;
      } else if (color == Colors.blue.shade600) {
        actionColor = Colors.blue.shade300;
      } else if (color == Colors.green.shade600) {
        actionColor = Colors.green.shade300;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12 : (isIPhone16ProMax ? 6 : (isVerySmallScreen ? 8 : 10)),
            horizontal: showIconOnly ? (isTablet ? 12 : 8) : (isTablet ? 10 : (isIPhone16ProMax ? 3 : (isVerySmallScreen ? 4 : 6))),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: actionColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
            // Add subtle background for better visibility
            color: isDark ? actionColor.withOpacity(0.05) : Colors.transparent,
          ),
          child: showIconOnly
              ? Icon(
                  icon,
                  size: settings.getScaledFontSize(isTablet ? 20 : (isVerySmallScreen ? 15 : 17)),
                  color: actionColor,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: settings.getScaledFontSize(isTablet ? 18 : (isVerySmallScreen ? 15 : 17)),
                      color: actionColor,
                    ),
                    SizedBox(width: isTablet ? 6 : (isVerySmallScreen ? 2 : 4)),
                    Flexible(
                      child: Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(isTablet ? 15 : (isVerySmallScreen ? 11 : 13)),
                          fontWeight: FontWeight.w600,
                          color: actionColor,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _getAbbreviatedLabel(String fullLabel) {
    // Create shorter versions of common labels
    switch (fullLabel.toLowerCase()) {
      case 'directions':
        return 'Go';
      case 'details':
        return 'Info';
      case 'street view':
      case 'street':
        return 'Street';
      case 'share':
        return 'Share';
      default:
        // If it's a longer label, truncate to first 6 characters
        return fullLabel.length > 6 ? fullLabel.substring(0, 6) : fullLabel;
    }
  }

  void _openDirections(PlaceResult place) async {
    _showNavigationOptions(place, context);
  }

  void _showNavigationOptions(PlaceResult place, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NavigationOptionsSheet(place: place),
    );
  }

  void _showPlaceDetails(PlaceResult place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(place: place),
    );
  }

  void _openStreetView(PlaceResult place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreetViewModal(place: place),
    );
  }

  void _sharePlace(PlaceResult place) async {
    final String shareText = _buildShareText(place);
    Share.share(
      shareText,
      subject: '📍 Check out ${place.name}',
    );
  }

  void _showRatingBreakdown(PlaceResult place) async {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: Container(
          width: isTablet ? screenSize.width * 0.6 : null,
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : double.infinity,
          ),
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Overall rating
              Row(
                children: [
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (index) => Icon(
                                  Icons.star,
                                  size: isTablet ? 24 : 20,
                                  color: index < place.rating.round() ? Colors.amber : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                )),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${place.userRatingsTotal} global ratings',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Rating breakdown (Amazon style)
              ...List.generate(5, (index) {
                final starCount = 5 - index;
                // Simulated percentage distribution based on common patterns
                final percentage = _getSimulatedPercentage(starCount, place.rating);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 3 : 2),
                  child: Row(
                    children: [
                      Text(
                        '$starCount star',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isDark ? Colors.lightBlue.shade200 : Color(0xFF0066CC),
                          decoration: TextDecoration.underline,
                          fontWeight: isDark ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: isTablet ? 18 : 16,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(isTablet ? 9 : 8),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(isTablet ? 9 : 8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isDark ? Colors.lightBlue.shade200 : Color(0xFF0066CC),
                          decoration: TextDecoration.underline,
                          fontWeight: isDark ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 24),

              // See reviews button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAllReviews(place);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.blue.shade600 : Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'See recent reviews',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getSimulatedPercentage(int starRating, double overallRating) {
    // Simulate realistic percentage distribution based on overall rating
    if (overallRating >= 4.5) {
      switch (starRating) {
        case 5:
          return 75.0;
        case 4:
          return 15.0;
        case 3:
          return 6.0;
        case 2:
          return 2.0;
        case 1:
          return 2.0;
      }
    } else if (overallRating >= 4.0) {
      switch (starRating) {
        case 5:
          return 60.0;
        case 4:
          return 25.0;
        case 3:
          return 10.0;
        case 2:
          return 3.0;
        case 1:
          return 2.0;
      }
    } else if (overallRating >= 3.5) {
      switch (starRating) {
        case 5:
          return 45.0;
        case 4:
          return 30.0;
        case 3:
          return 15.0;
        case 2:
          return 6.0;
        case 1:
          return 4.0;
      }
    } else {
      switch (starRating) {
        case 5:
          return 30.0;
        case 4:
          return 25.0;
        case 3:
          return 25.0;
        case 2:
          return 12.0;
        case 1:
          return 8.0;
      }
    }
    return 0.0;
  }

  void _showAllReviews(PlaceResult place) async {
    // Fetch detailed reviews using the new Google Places API
    final placeDetails = await _getPlaceDetailsWithReviews(place.placeId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewsBottomSheet(
        place: place,
        placeDetails: placeDetails,
      ),
    );
  }

  Future<PlaceDetails?> _getPlaceDetailsWithReviews(String placeId) async {
    try {
      final String url = 'https://places.googleapis.com/v1/places/$placeId';
      final apiKey = dotenv.env['GOOGLE_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'displayName,rating,nationalPhoneNumber,websiteUri,regularOpeningHours,reviews,photos',
        },
      );

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);

        // Parse reviews from new API format
        List<PlaceReview> reviews = [];
        if (data['reviews'] != null) {
          for (var reviewData in data['reviews']) {
            reviews.add(PlaceReview(
              authorName: reviewData['authorAttribution']?['displayName'] ?? 'Anonymous',
              rating: reviewData['rating'] ?? 0,
              text: reviewData['text']?['text'] ?? '',
              relativeTime: reviewData['relativePublishTimeDescription'] ?? '',
            ));
          }
        }

        return PlaceDetails(
          name: data['displayName']?['text'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          phoneNumber: data['nationalPhoneNumber'],
          website: data['websiteUri'],
          openingHours: data['regularOpeningHours']?['weekdayDescriptions'] != null ? List<String>.from(data['regularOpeningHours']['weekdayDescriptions']) : [],
          reviews: reviews,
          photoReferences: data['photos'] != null ? (data['photos'] as List).map((p) => p['name'] as String).toList() : [],
        );
      }
    } catch (e) {
      // Error fetching reviews
    }

    return null;
  }

  String _buildShareText(PlaceResult place) {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('📍 ${place.name}');
    buffer.writeln('');

    // Basic info
    buffer.writeln('📍 Address: ${place.address}');
    buffer.writeln('📏 Distance: ${place.getDistanceText(
      locale: Localizations.localeOf(context).toString(),
      countryCode: Localizations.localeOf(context).countryCode,
    )}');

    // Rating if available
    if (place.rating > 0) {
      String ratingStars = '⭐' * place.rating.round();
      buffer.writeln('⭐ Rating: ${place.rating.toStringAsFixed(1)}/5.0 $ratingStars');
      if (place.userRatingsTotal > 0) {
        buffer.writeln('   (${place.userRatingsTotal} reviews)');
      }
    }

    // Price level if available
    if (place.priceLevel != 'Unknown') {
      String priceSymbols = '';
      switch (place.priceLevel) {
        case 'Inexpensive':
          priceSymbols = '\$ ';
          break;
        case 'Moderate':
          priceSymbols = '\$\$ ';
          break;
        case 'Expensive':
          priceSymbols = '\$\$\$ ';
          break;
        case 'Very Expensive':
          priceSymbols = '\$\$\$\$ ';
          break;
      }
      buffer.writeln('💰 Price: $priceSymbols(${place.priceLevel})');
    }

    // Status
    buffer.writeln('🕒 Status: ${place.isOpen ? "Open" : "Closed"}');

    // Google Maps link
    buffer.writeln('');
    buffer.writeln('🗺️ Get Directions:');
    buffer.writeln('https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}');

    // Footer
    buffer.writeln('');
    buffer.writeln('📱 Shared via HowAI Places Explorer');

    return buffer.toString();
  }

  void _copyAddressFromCard(PlaceResult place) async {
    await Clipboard.setData(ClipboardData(text: place.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.content_copy, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.addressCopied),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5856D6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Helper class for map navigation options
class _MapNavigationOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MapNavigationOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

// Full-screen map view that shows all places
class _FullScreenMapView extends StatefulWidget {
  final List<PlaceResult> places;
  final String searchQuery;
  final bool enableRouteFeatures;

  const _FullScreenMapView({
    required this.places,
    required this.searchQuery,
    required this.enableRouteFeatures,
  });

  @override
  State<_FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<_FullScreenMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  MapType _currentMapType = MapType.normal;
  bool _showTraffic = false;
  PlaceResult? _selectedPlace;
  bool _showPlaceCard = false;
  bool _showMapTypeDropdown = false;
  bool _showRoute = false;
  String? _routeDistance;
  String? _routeDuration;
  String _travelMode = ''; // No travel mode selected by default
  String? _transitDetails; // Store transit line info (bus numbers, etc.)

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _createMarkers() {
    _markers = widget.places.asMap().entries.map((entry) {
      final index = entry.key;
      final place = entry.value;
      final isSelected = _selectedPlace?.placeId == place.placeId;

      return Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.latitude, place.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueGreen : _getMarkerColor(place),
        ),
        onTap: () => _showPlaceOnMap(place),
      );
    }).toSet();
  }

  double _getMarkerColor(PlaceResult place) {
    final types = place.types;
    if (types.contains('restaurant') || types.contains('food')) {
      return BitmapDescriptor.hueOrange;
    } else if (types.contains('cafe')) {
      return BitmapDescriptor.hueYellow;
    } else if (types.contains('bakery')) {
      return BitmapDescriptor.hueMagenta;
    } else if (types.contains('convenience_store')) {
      return BitmapDescriptor.hueCyan;
    } else if (types.contains('lodging') || types.contains('hotel')) {
      return BitmapDescriptor.hueBlue;
    } else if (types.contains('tourist_attraction') || types.contains('museum')) {
      return BitmapDescriptor.hueViolet;
    } else if (types.contains('shopping_mall') || types.contains('store')) {
      return BitmapDescriptor.hueGreen;
    } else if (types.contains('parking')) {
      return BitmapDescriptor.hueAzure;
    } else if (types.contains('hospital')) {
      return BitmapDescriptor.hueRose;
    } else if (types.contains('pharmacy')) {
      return BitmapDescriptor.hueRed;
    } else if (types.contains('gas_station')) {
      return BitmapDescriptor.hueYellow;
    } else if (types.contains('car_wash')) {
      return BitmapDescriptor.hueCyan;
    } else if (types.contains('bank')) {
      return BitmapDescriptor.hueBlue;
    } else if (types.contains('atm')) {
      return BitmapDescriptor.hueGreen;
    } else if (types.contains('gym')) {
      return BitmapDescriptor.hueOrange;
    } else if (types.contains('beauty_salon')) {
      return BitmapDescriptor.hueMagenta;
    } else if (types.contains('laundry')) {
      return BitmapDescriptor.hueAzure;
    } else if (types.contains('night_club')) {
      return BitmapDescriptor.hueViolet;
    } else if (types.contains('park')) {
      return BitmapDescriptor.hueGreen;
    } else if (types.contains('subway_station')) {
      return BitmapDescriptor.hueRed;
    } else {
      return BitmapDescriptor.hueRed;
    }
  }

  void _showPlaceOnMap(PlaceResult place) {
    setState(() {
      _selectedPlace = place;
      _showPlaceCard = true;
      // Recreate markers to show selection highlight
      _createMarkers();
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.latitude, place.longitude),
          zoom: 16.0,
        ),
      ),
    );

    // Route generation is now manual via Walk/Transit/Drive buttons
  }

  // Show options for the tapped location
  Future<void> _showLocationOptions(LatLng position) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.whatWouldYouLikeToDo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Search for place option
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF5856D6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Color(0xFF5856D6)),
                      ),
                      title: Text(AppLocalizations.of(context)!.searchForBusinessHere, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                      subtitle: Text(AppLocalizations.of(context)!.findRestaurantsShopsAndServicesAtThisLocation, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600)),
                      onTap: () {
                        Navigator.pop(context);
                        _findPlaceAtLocation(position);
                      },
                    ),

                    Divider(),

                    // Open in Google Maps option
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.map, color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green),
                      ),
                      title: Text(AppLocalizations.of(context)!.openInGoogleMaps, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                      subtitle: Text(AppLocalizations.of(context)!.viewThisLocationInTheNativeGoogleMapsApp, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600)),
                      onTap: () {
                        Navigator.pop(context);
                        _openInGoogleMaps(position);
                      },
                    ),

                    Divider(),

                    // Get directions option
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.directions, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue),
                      ),
                      title: Text(AppLocalizations.of(context)!.getDirections, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                      subtitle: Text(AppLocalizations.of(context)!.navigateToThisLocation, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600)),
                      onTap: () {
                        Navigator.pop(context);
                        _getDirectionsToLocation(position);
                      },
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Find place at tapped location using Google Places API
  Future<void> _findPlaceAtLocation(LatLng position) async {
    try {
      // Searching for place at coordinates

      // Use LocationService to search for nearby places at this exact location
      final LocationService locationService = LocationService();

      // Try using searchNearbyPlacesAtLocation with much larger radius
      // Starting search at coordinates
      var places = await locationService.searchNearbyPlacesAtLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 800, // Much larger radius to catch visible places
        query: 'point_of_interest',
      );
      // Found places with 800m radius

      // If no results, try with 'establishment' query and larger radius
      if (places.isEmpty) {
        //// print('🔍 [Search] Trying establishment with 1000m radius...');
        places = await locationService.searchNearbyPlacesAtLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          radius: 1000,
          query: 'establishment',
        );
        //// print('🔍 [Search] Found ${places.length} places with establishment');
        if (places.isNotEmpty) {
          //// print('🔍 [Search] First place: ${places.first.name} at ${places.first.distance}m');
        }
      }

      // If still no results, try with no specific query and large radius
      if (places.isEmpty) {
        //// print('🔍 [Search] Trying no query with 1200m radius...');
        places = await locationService.searchNearbyPlacesAtLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          radius: 1200,
          query: '',
        );
        //// print('🔍 [Search] Found ${places.length} places with no query');
        if (places.isNotEmpty) {
          //// print('🔍 [Search] First place: ${places.first.name} at ${places.first.distance}m');
        }
      }

      //// print('🔍 [Final] Total places found after all searches: ${places.length}');

      if (places.isNotEmpty) {
        final nearestPlace = places.first;
        //// print('🗺️ [MapTap] Selected place: ${nearestPlace.name} at ${nearestPlace.distance.toStringAsFixed(1)}m');

        // Check if this place already exists in our widget.places list
        final existingPlace = widget.places.any((place) => place.placeId == nearestPlace.placeId);
        //// print('🗺️ [MapTap] Place already exists in list: $existingPlace');

        if (existingPlace) {
          // If place already exists, just show it
          setState(() {
            _selectedPlace = nearestPlace;
            _showPlaceCard = true;
            _createMarkers(); // Recreate markers to show selection
          });
        } else {
          // Add the found place as a new marker only if it doesn't exist
          final newMarker = Marker(
            markerId: MarkerId(nearestPlace.placeId),
            position: LatLng(nearestPlace.latitude, nearestPlace.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen, // Use green to highlight the found place
            ),
            onTap: () => _showPlaceOnMap(nearestPlace),
          );

          // Show this place on the map
          setState(() {
            _selectedPlace = nearestPlace;
            _showPlaceCard = true;
            // Add the new marker to existing markers
            _markers.add(newMarker);
          });
        }

        // Animate to the exact place coordinates
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(nearestPlace.latitude, nearestPlace.longitude),
              zoom: 17.0,
            ),
          ),
        );

        // Route generation is now manual via Walk/Transit/Drive buttons
      } else {
        //// print('🗺️ [MapTap] No places found after all search attempts at ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      //// print('🗺️ [MapTap] Error finding place: $e');
    }
  }

  // Open location in Google Maps app
  Future<void> _openInGoogleMaps(LatLng position) async {
    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error opening Google Maps
    }
  }

  // Get directions to location
  Future<void> _getDirectionsToLocation(LatLng position) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch directions';
      }
    } catch (e) {
      //// print('Error opening directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open directions'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _fitCameraToMarkers() {
    if (_mapController == null || widget.places.isEmpty) return;

    if (widget.places.length == 1) {
      final place = widget.places.first;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(place.latitude, place.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      double minLat = widget.places.first.latitude;
      double maxLat = widget.places.first.latitude;
      double minLng = widget.places.first.longitude;
      double maxLng = widget.places.first.longitude;

      for (final place in widget.places) {
        minLat = minLat < place.latitude ? minLat : place.latitude;
        maxLat = maxLat > place.latitude ? maxLat : place.latitude;
        minLng = minLng < place.longitude ? minLng : place.longitude;
        maxLng = maxLng > place.longitude ? maxLng : place.longitude;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Calculate center point
        double centerLat = 0;
        double centerLng = 0;
        for (final place in widget.places) {
          centerLat += place.latitude;
          centerLng += place.longitude;
        }
        centerLat /= widget.places.length;
        centerLng /= widget.places.length;

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: SafeArea(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GoogleMap(
                      key: Key('googlemap_${_currentMapType.toString()}'),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        Future.delayed(Duration(milliseconds: 500), () {
                          _fitCameraToMarkers();
                        });
                      },
                      markers: _markers,
                      polylines: widget.enableRouteFeatures ? _polylines : {},
                      initialCameraPosition: CameraPosition(
                        target: LatLng(centerLat, centerLng),
                        zoom: 12.0,
                      ),
                      mapType: _currentMapType,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      compassEnabled: false,
                      trafficEnabled: _showTraffic,
                      buildingsEnabled: true,
                      onTap: (LatLng position) async {
                        if (_showPlaceCard) {
                          setState(() {
                            _showPlaceCard = false;
                            _selectedPlace = null;
                            // Recreate markers to remove selection highlight
                            _createMarkers();
                          });
                        }
                        // Clear route when tapping elsewhere on the map
                        if (_showRoute) {
                          _clearRoute();
                        }
                      },
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Map controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildMapControl(Icons.add, () => _zoomIn()),
                        SizedBox(height: 8),
                        _buildMapControl(Icons.remove, () => _zoomOut()),
                        SizedBox(height: 8),
                        _buildMapControl(Icons.center_focus_strong, () => _fitCameraToMarkers()),
                        SizedBox(height: 8),
                        if (widget.enableRouteFeatures) ...[
                          _buildRouteControl(),
                          SizedBox(height: 8),
                        ],
                        _buildMapTypeDropdownCompact(),
                        SizedBox(height: 8),
                        _buildTrafficControl(),
                      ],
                    ),
                  ),

                  // Map type dropdown options overlay
                  _buildMapTypeOptions(),

                  // Place card
                  if (_showPlaceCard && _selectedPlace != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildPlaceCard(_selectedPlace!, settings),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Color(0xFF5856D6), size: 20),
      ),
    );
  }

  Widget _buildMapTypeDropdownCompact() {
    final mapTypes = [
      {'type': MapType.normal, 'icon': Icons.map, 'label': 'Map'},
      {'type': MapType.satellite, 'icon': Icons.satellite_alt, 'label': 'Satellite'},
      {'type': MapType.hybrid, 'icon': Icons.layers, 'label': 'Hybrid'},
      {'type': MapType.terrain, 'icon': Icons.terrain, 'label': 'Terrain'},
    ];

    final currentMapType = mapTypes.firstWhere((type) => type['type'] == _currentMapType);

    return Container(
      width: 40, // Fixed width to prevent layout shifts
      height: 40,
      child: Stack(
        children: [
          // Main button - always at the same position
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  //// print('🎯 Main map type button tapped. Current dropdown state: $_showMapTypeDropdown');
                  setState(() {
                    _showMapTypeDropdown = !_showMapTypeDropdown;
                  });
                  //// print('🎯 Dropdown toggled to: $_showMapTypeDropdown');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    currentMapType['icon'] as IconData,
                    size: 20,
                    color: Color(0xFF5856D6),
                  ),
                ),
              ),
            ),
          ),

          // Dropdown options overlay - positioned as an overlay
          if (_showMapTypeDropdown)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Close dropdown when tapping outside
                  setState(() {
                    _showMapTypeDropdown = false;
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Separate overlay for dropdown options that won't affect layout
  Widget _buildMapTypeOptions() {
    if (!_showMapTypeDropdown) return SizedBox.shrink();

    final mapTypes = [
      {'type': MapType.normal, 'icon': Icons.map, 'label': 'Map'},
      {'type': MapType.satellite, 'icon': Icons.satellite_alt, 'label': 'Satellite'},
      {'type': MapType.hybrid, 'icon': Icons.layers, 'label': 'Hybrid'},
      {'type': MapType.terrain, 'icon': Icons.terrain, 'label': 'Terrain'},
    ];

    // Calculate the correct position based on the map controls layout
    // Controls are positioned: zoom in, zoom out, center, route, map type, traffic
    // So map type is the 5th control (index 4)
    final controlIndex = 4; // 0: zoom in, 1: zoom out, 2: center, 3: route, 4: map type
    final topPosition = 16.0 + (controlIndex * (40.0 + 8.0)); // 16px top margin + (index * (button height + spacing))

    return Positioned(
      top: topPosition,
      right: 64, // 40px (button width) + 8px spacing + 16px margin
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: mapTypes.where((type) => type['type'] != _currentMapType).map((mapTypeData) {
          final mapType = mapTypeData['type'] as MapType;
          final icon = mapTypeData['icon'] as IconData;

          return Container(
            margin: EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  //// print('🎯 Map type button tapped: ${mapTypeData['label']}');
                  setState(() {
                    _currentMapType = mapType;
                    _showMapTypeDropdown = false;
                  });

                  //// print('🗺️ Map type changed to: ${mapTypeData['label']} (${mapType.toString()})');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🗺️ Map type changed to ${mapTypeData['label']}'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF5856D6),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRouteControl() {
    return GestureDetector(
      onTap: () {
        if (_showRoute) {
          _clearRoute();
        } else if (_selectedPlace != null) {
          _showRouteToPlace(_selectedPlace!);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _showRoute ? Color(0xFF5856D6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.navigation,
          color: _showRoute ? Colors.white : Color(0xFF5856D6),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTrafficControl() {
    return GestureDetector(
      onTap: () => _toggleTraffic(),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _showTraffic ? Colors.red.shade500 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.traffic,
          color: _showTraffic ? Colors.white : Color(0xFF5856D6),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPlaceCard(PlaceResult place, SettingsProvider settings) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Main content with padding for close button
                Padding(
                  padding: EdgeInsets.only(right: 40), // Space for close button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(18),
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      // Rating, distance and photos info
                      Row(
                        children: [
                          if (place.rating > 0) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    place.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(11),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6),
                          ],
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                                SizedBox(width: 2),
                                Text(
                                  place.getDistanceText(
                                    locale: Localizations.localeOf(context).toString(),
                                    countryCode: Localizations.localeOf(context).countryCode,
                                  ),
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(11),
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6),
                          // Photos button inline with rating and distance
                          GestureDetector(
                            onTap: () => _showPhotoGalleryFromMap(place, settings),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_camera, size: 12, color: Colors.orange.shade600),
                                  SizedBox(width: 2),
                                  Text(
                                    AppLocalizations.of(context)!.photos,
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(11),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Travel mode and route information - only show if route features are enabled
                      if (widget.enableRouteFeatures) ...[
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Travel mode switcher - always show when route features enabled
                            Row(
                              children: [
                                _buildTravelModeButton(
                                  icon: Icons.directions_walk,
                                  label: AppLocalizations.of(context)!.walk,
                                  mode: 'walking',
                                  isSelected: _travelMode == 'walking',
                                  settings: settings,
                                ),
                                SizedBox(width: 4),
                                _buildTravelModeButton(
                                  icon: Icons.directions_transit,
                                  label: AppLocalizations.of(context)!.transit,
                                  mode: 'transit',
                                  isSelected: _travelMode == 'transit',
                                  settings: settings,
                                ),
                                SizedBox(width: 4),
                                _buildTravelModeButton(
                                  icon: Icons.directions_car,
                                  label: AppLocalizations.of(context)!.drive,
                                  mode: 'driving',
                                  isSelected: _travelMode == 'driving',
                                  settings: settings,
                                ),
                                Spacer(),
                                if (_routeDistance != null && _routeDuration != null)
                                  GestureDetector(
                                    onTap: _clearRoute,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Route info display - only show when route is calculated
                            if (_routeDistance != null && _routeDuration != null) ...[
                              SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getRouteColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _getRouteColor().withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getRouteIcon(),
                                          size: 14,
                                          color: _getRouteColor(),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '$_routeDistance • $_routeDuration ${_getTravelModeLabel()}',
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(11),
                                            color: _getRouteColor(),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Transit details
                                  if (_travelMode == 'transit' && _transitDetails != null) ...[
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.train, size: 12, color: Colors.orange.shade700),
                                          SizedBox(width: 4),
                                          Text(
                                            _transitDetails!,
                                            style: TextStyle(
                                              fontSize: settings.getScaledFontSize(10),
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _copyAddressFromMap(place),
                        child: Text(
                          place.address,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(14),
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button positioned at top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPlaceCard = false;
                        _selectedPlace = null;
                        // Recreate markers to remove selection highlight
                        _createMarkers();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: settings.getScaledFontSize(16),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Action buttons - same as card view
            Column(
              children: [
                // First row: Main actions
                Row(
                  children: [
                    Expanded(
                      child: _buildMapActionButton(
                        icon: Icons.directions,
                        label: AppLocalizations.of(context)!.go,
                        onTap: () => _showNavigationOptions(place),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Color(0xFF5856D6),
                        settings: settings,
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: _buildMapActionButton(
                        icon: Icons.info_outline,
                        label: AppLocalizations.of(context)!.info,
                        onTap: () => _showPlaceDetails(place),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                        settings: settings,
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: _buildMapActionButton(
                        icon: Icons.streetview,
                        label: AppLocalizations.of(context)!.street,
                        onTap: () => _openStreetViewMap(place),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600,
                        settings: settings,
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: _buildMapActionButton(
                        icon: Icons.share,
                        label: AppLocalizations.of(context)!.share,
                        onTap: () => _sharePlace(place),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green.shade600,
                        settings: settings,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });
  }

  void _openDirections(PlaceResult place) async {
    try {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error opening directions
    }
  }

  void _sharePlace(PlaceResult place) async {
    final String ratingText = place.rating > 0 ? '${place.rating.toStringAsFixed(1)} ⭐ (${place.userRatingsTotal} reviews)' : 'No rating available';
    final String shareText = '${place.name}\n${place.address}\n$ratingText';
    await Share.share(shareText);
  }

  void _showPhotoGalleryFromMap(PlaceResult place, SettingsProvider settings) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            // Full screen photo with enhanced gallery
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _EnhancedPhotoGalleryWidget(
                    place: place,
                    settings: settings,
                    locationService: LocationService(),
                    buildPhotoPlaceholder: () => _buildPhotoPlaceholderForMap(place, settings),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Place info overlay
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.getScaledFontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      place.address,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: settings.getScaledFontSize(14),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${place.rating}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: settings.getScaledFontSize(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${place.userRatingsTotal} reviews',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: settings.getScaledFontSize(12),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: place.isOpen ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: settings.getScaledFontSize(12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholderForMap(PlaceResult place, SettingsProvider settings) {
    IconData icon = Icons.place;
    Color color = Color(0xFF5856D6);

    // Choose icon based on place type (same logic as main widget)
    if (place.types.contains('restaurant') || place.types.contains('food')) {
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (place.types.contains('cafe')) {
      icon = Icons.local_cafe;
      color = Colors.brown;
    } else if (place.types.contains('bakery')) {
      icon = Icons.cake;
      color = Colors.pink;
    } else if (place.types.contains('convenience_store')) {
      icon = Icons.icecream;
      color = Colors.cyan;
    } else if (place.types.contains('lodging')) {
      icon = Icons.hotel;
      color = Colors.blue;
    } else if (place.types.contains('tourist_attraction')) {
      icon = Icons.attractions;
      color = Colors.purple;
    } else if (place.types.contains('shopping_mall') || place.types.contains('store')) {
      icon = Icons.shopping_bag;
      color = Colors.green;
    } else if (place.types.contains('parking')) {
      icon = Icons.local_parking;
      color = Colors.indigo;
    } else if (place.types.contains('hospital')) {
      icon = Icons.local_hospital;
      color = Colors.red;
    } else if (place.types.contains('pharmacy')) {
      icon = Icons.medication;
      color = Colors.red.shade300;
    } else if (place.types.contains('gas_station')) {
      icon = Icons.local_gas_station;
      color = Colors.yellow.shade700;
    } else if (place.types.contains('car_wash')) {
      icon = Icons.car_repair;
      color = Colors.teal;
    } else if (place.types.contains('bank')) {
      icon = Icons.account_balance;
      color = Colors.blue.shade700;
    } else if (place.types.contains('atm')) {
      icon = Icons.atm;
      color = Colors.green.shade700;
    } else if (place.types.contains('gym')) {
      icon = Icons.fitness_center;
      color = Colors.orange.shade700;
    } else if (place.types.contains('beauty_salon')) {
      icon = Icons.face_retouching_natural;
      color = Colors.pink.shade400;
    } else if (place.types.contains('laundry')) {
      icon = Icons.local_laundry_service;
      color = Colors.blue.shade400;
    } else if (place.types.contains('night_club')) {
      icon = Icons.nightlife;
      color = Colors.deepPurple;
    } else if (place.types.contains('park')) {
      icon = Icons.park;
      color = Colors.green.shade600;
    } else if (place.types.contains('subway_station')) {
      icon = Icons.wc;
      color = Colors.grey.shade600;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: settings.getScaledFontSize(48),
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noPhotosAvailable,
              style: TextStyle(
                color: color,
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapInlineOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required SettingsProvider settings,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(14),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapCategorySection({
    required BuildContext context,
    required String title,
    required Color color,
    required List<_MapNavigationOption> options,
    required SettingsProvider settings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        // Options grid
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: options.length >= 3 ? 3 : options.length,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 3.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _buildMapCompactOption(
                context: context,
                icon: option.icon,
                title: option.title,
                color: color,
                onTap: option.onTap,
                settings: settings,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapCompactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required SettingsProvider settings,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(9),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyAddress(PlaceResult place) async {
    await Clipboard.setData(ClipboardData(text: place.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Address copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5856D6),
      ),
    );
  }

  void _openGoogleMaps(PlaceResult place) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openAppleMaps(PlaceResult place) async {
    final url = 'https://maps.apple.com/?daddr=${place.latitude},${place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openTransit(PlaceResult place) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=transit';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openStreetViewMap(PlaceResult place) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreetViewModal(place: place),
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required SettingsProvider settings,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              SizedBox(width: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(11),
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationOptions(PlaceResult place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NavigationOptionsSheet(place: place),
    );
  }

  void _showPlaceDetails(PlaceResult place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(place: place),
    );
  }

  void _copyAddressFromMap(PlaceResult place) async {
    await Clipboard.setData(ClipboardData(text: place.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.content_copy, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.addressCopied),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5856D6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showRouteToPlace(PlaceResult place) async {
    final LocationService locationService = LocationService();
    await locationService.getCurrentLocation();

    if (locationService.currentPosition == null) {
      //// print('[Map Route] Current location not available');
      return;
    }

    final origin = locationService.currentPosition!;
    await _calculateRoute(origin.latitude, origin.longitude, place.latitude, place.longitude, mode: _travelMode);
  }

  Future<void> _calculateRoute(double originLat, double originLng, double destLat, double destLng, {String mode = 'driving'}) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        //// print('[Map Route] Google Maps API key not found');
        return;
      }

      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=$originLat,$originLng'
          '&destination=$destLat,$destLng'
          '&mode=$mode'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final distance = route['legs'][0]['distance']['text'];
          final duration = route['legs'][0]['duration']['text'];

          // Parse transit details if available
          String? transitInfo;
          if (mode == 'transit' && route['legs'][0]['steps'] != null) {
            final steps = route['legs'][0]['steps'] as List;
            final transitSteps = steps.where((step) => step['travel_mode'] == 'TRANSIT').toList();

            if (transitSteps.isNotEmpty) {
              List<String> transitLines = [];
              for (var step in transitSteps) {
                if (step['transit_details'] != null) {
                  final transit = step['transit_details'];
                  final line = transit['line'];
                  if (line != null) {
                    String lineInfo = '';
                    if (line['short_name'] != null) {
                      lineInfo = line['short_name'];
                    } else if (line['name'] != null) {
                      lineInfo = line['name'];
                    }
                    if (lineInfo.isNotEmpty && !transitLines.contains(lineInfo)) {
                      transitLines.add(lineInfo);
                    }
                  }
                }
              }
              if (transitLines.isNotEmpty) {
                transitInfo = transitLines.join(' • ');
              }
            }
          }

          final decodedPoints = _decodePolyline(polylinePoints);

          setState(() {
            _polylines.clear();

            // Add border polyline for better visibility
            _polylines.add(
              Polyline(
                polylineId: PolylineId('route_border'),
                points: decodedPoints,
                color: Colors.white,
                width: mode == 'walking' ? 7 : 8,
              ),
            );

            // Add main route polyline
            Color routeColor;
            if (mode == 'walking') {
              routeColor = Colors.blue.shade700;
            } else if (mode == 'transit') {
              routeColor = Colors.orange.shade700;
            } else {
              routeColor = Colors.purple.shade600;
            }

            _polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: decodedPoints,
                color: routeColor,
                width: mode == 'walking' ? 4 : 5,
              ),
            );

            _showRoute = true;
            _routeDistance = distance;
            _routeDuration = duration;
            _travelMode = mode;
            _transitDetails = transitInfo;
          });

          //// print('[Map Route] Route calculated: $distance, $duration');
        }
      }
    } catch (e) {
      //// print('[Map Route] Error calculating route: $e');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _showRoute = false;
      _routeDistance = null;
      _routeDuration = null;
      _travelMode = ''; // Clear travel mode selection
      _transitDetails = null;
    });
  }

  void _switchTravelMode(String mode) {
    if (_selectedPlace != null && mode != _travelMode) {
      setState(() {
        _travelMode = mode;
      });
      _showRouteToPlace(_selectedPlace!);
    }
  }

  Color _getRouteColor() {
    if (_travelMode == 'walking') {
      return Colors.blue.shade700;
    } else if (_travelMode == 'transit') {
      return Colors.orange.shade700;
    } else {
      return Colors.purple.shade600;
    }
  }

  IconData _getRouteIcon() {
    if (_travelMode == 'walking') {
      return Icons.directions_walk;
    } else if (_travelMode == 'transit') {
      return Icons.directions_transit;
    } else {
      return Icons.navigation;
    }
  }

  String _getTravelModeLabel() {
    if (_travelMode == 'walking') {
      return 'walking';
    } else if (_travelMode == 'transit') {
      return 'transit';
    } else {
      return 'driving';
    }
  }

  Widget _buildTravelModeButton({
    required IconData icon,
    required String label,
    required String mode,
    required bool isSelected,
    required SettingsProvider settings,
  }) {
    Color color;
    if (mode == 'walking') {
      color = Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade700;
    } else if (mode == 'transit') {
      color = Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade200 : Colors.orange.shade700;
    } else {
      color = Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Colors.purple.shade600;
    }

    return GestureDetector(
      onTap: () => _switchTravelMode(mode),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : color,
            ),
            SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(10),
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAddressFromCard(PlaceResult place) async {
    await Clipboard.setData(ClipboardData(text: place.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.content_copy, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.addressCopied),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5856D6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Helper class for navigation options
class _NavigationOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

// Navigation options sheet for detailed direction choices
class NavigationOptionsSheet extends StatelessWidget {
  final PlaceResult place;

  const NavigationOptionsSheet({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.directions, color: Color(0xFF5856D6), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.getDirections,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(16),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            place.name,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(12),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Copy Address - inline style
                      _buildInlineOption(
                        icon: Icons.content_copy,
                        title: AppLocalizations.of(context)!.copyAddress,
                        color: Colors.blue,
                        onTap: () => _copyAddress(context),
                        settings: settings,
                      ),

                      SizedBox(height: 8),

                      // Maps
                      _buildCategorySection(
                        title: AppLocalizations.of(context)!.mapsAndNavigation,
                        color: Colors.green,
                        options: [
                          _NavigationOption(
                            icon: Icons.map,
                            title: AppLocalizations.of(context)!.googleMaps,
                            onTap: () => _openGoogleMaps(context),
                          ),
                          _NavigationOption(
                            icon: Icons.navigation,
                            title: AppLocalizations.of(context)!.appleMaps,
                            onTap: () => _openAppleMaps(context),
                          ),
                          _NavigationOption(
                            icon: Icons.navigation,
                            title: AppLocalizations.of(context)!.waze,
                            onTap: () => _openWaze(context),
                          ),
                          _NavigationOption(
                            icon: Icons.directions_walk,
                            title: AppLocalizations.of(context)!.walking,
                            onTap: () => _openWalkingDirections(context),
                          ),
                          _NavigationOption(
                            icon: Icons.directions_bike,
                            title: AppLocalizations.of(context)!.cycling,
                            onTap: () => _openCyclingDirections(context),
                          ),
                          _NavigationOption(
                            icon: Icons.train,
                            title: AppLocalizations.of(context)!.transit,
                            onTap: () => _openPublicTransit(context),
                          ),
                        ],
                        settings: settings,
                      ),

                      SizedBox(height: 8),

                      // Rideshare
                      _buildCategorySection(
                        title: AppLocalizations.of(context)!.rideshare,
                        color: Colors.purple,
                        options: [
                          _NavigationOption(
                            icon: Icons.local_taxi,
                            title: AppLocalizations.of(context)!.uber,
                            onTap: () => _openUber(context),
                          ),
                          _NavigationOption(
                            icon: Icons.local_taxi,
                            title: AppLocalizations.of(context)!.lyft,
                            onTap: () => _openLyft(context),
                          ),
                        ],
                        settings: settings,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInlineOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required SettingsProvider settings,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(14),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required Color color,
    required List<_NavigationOption> options,
    required SettingsProvider settings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        // Options grid
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: options.length >= 3 ? 3 : options.length,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 3.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _buildCompactOption(
                icon: option.icon,
                title: option.title,
                color: color,
                onTap: option.onTap,
                settings: settings,
                context: context,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required SettingsProvider settings,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color, size: 14),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(11),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyAddress(BuildContext context) async {
    Navigator.pop(context);
    await Clipboard.setData(ClipboardData(text: place.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Address copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5856D6),
      ),
    );
  }

  void _openGoogleMaps(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openAppleMaps(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://maps.apple.com/?daddr=${place.latitude},${place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openPublicTransit(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=transit';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openWalkingDirections(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=walking';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openCyclingDirections(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=bicycling';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openUber(BuildContext context) async {
    Navigator.pop(context);
    final url = 'uber://?action=setPickup&dropoff[latitude]=${place.latitude}&dropoff[longitude]=${place.longitude}&dropoff[nickname]=${Uri.encodeComponent(place.name)}';
    final fallbackUrl = 'https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=${place.latitude}&dropoff[longitude]=${place.longitude}&dropoff[nickname]=${Uri.encodeComponent(place.name)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _openLyft(BuildContext context) async {
    Navigator.pop(context);
    final url = 'lyft://ridetype?id=lyft&destination[latitude]=${place.latitude}&destination[longitude]=${place.longitude}';
    final fallbackUrl = 'https://lyft.com/ride?destination[latitude]=${place.latitude}&destination[longitude]=${place.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _openWaze(BuildContext context) async {
    Navigator.pop(context);
    final url = 'waze://?ll=${place.latitude},${place.longitude}&navigate=yes&z=10';
    final fallbackUrl = 'https://waze.com/ul?ll=${place.latitude},${place.longitude}&navigate=yes&z=10';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _openStreetView(BuildContext context) async {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreetViewModal(place: place),
      ),
    );
  }
}

// Place details sheet showing comprehensive information
class PlaceDetailsSheet extends StatefulWidget {
  final PlaceResult place;

  const PlaceDetailsSheet({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  bool _isStatusExpanded = false;
  bool _showCopiedFeedback = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.place.name,
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(20),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  _getPlaceDescription(),
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Color(0xFF5856D6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Quick Overview Cards
                      _buildQuickOverview(settings),
                      SizedBox(height: 16),

                      // AI Insights Section (if available)
                      if (widget.place.aiSummary != null || widget.place.reviewSummary != null) ...[
                        _buildInfoCard(
                          title: AppLocalizations.of(context)!.aiInsights,
                          icon: Icons.auto_awesome,
                          color: Colors.purple,
                          child: _buildAIInsightsContent(settings),
                        ),
                        SizedBox(height: 12),
                      ],

                      // Location & Contact Information
                      _buildInfoCard(
                        title: AppLocalizations.of(context)!.locationAndContact,
                        icon: Icons.location_on,
                        color: Colors.red,
                        child: _buildLocationContactContent(settings),
                      ),
                      SizedBox(height: 12),

                      // Status & Hours
                      _buildInfoCard(
                        title: AppLocalizations.of(context)!.hoursAndAvailability,
                        icon: Icons.access_time,
                        color: widget.place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red),
                        child: _buildExpandableStatusContent(settings),
                      ),
                      SizedBox(height: 12),

                      // Services & Amenities
                      _buildInfoCard(
                        title: AppLocalizations.of(context)!.servicesAndAmenities,
                        icon: Icons.miscellaneous_services,
                        color: Colors.orange,
                        child: _buildServicesAmenitiesContent(settings),
                      ),

                      SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openDirections(context),
                              icon: Icon(Icons.directions, size: 16),
                              label: Text(AppLocalizations.of(context)!.directions),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5856D6),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _sharePlace(context),
                              icon: Icon(Icons.share, size: 16),
                              label: Text(AppLocalizations.of(context)!.share),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPlaceDescription() {
    final types = widget.place.types;

    if (types.contains('restaurant') || types.contains('food') || types.contains('meal_takeaway')) {
      return '🍽️ Restaurant & Dining';
    } else if (types.contains('cafe')) {
      return '☕ Coffee Shop & Café';
    } else if (types.contains('bakery') || types.contains('dessert')) {
      return '🧁 Sweet Food & Bakery';
    } else if (types.contains('convenience_store') || types.contains('ice_cream')) {
      return '🍦 Ice Cream & Desserts';
    } else if (types.contains('lodging') || types.contains('hotel')) {
      return '🏨 Accommodation & Lodging';
    } else if (types.contains('tourist_attraction') || types.contains('museum')) {
      return '🎭 Tourist Attraction & Culture';
    } else if (types.contains('shopping_mall') || types.contains('store') || types.contains('clothing_store')) {
      return '🛍️ Shopping & Retail';
    } else if (types.contains('parking')) {
      return '🅿️ Parking Garage';
    } else if (types.contains('hospital') || types.contains('doctor')) {
      return '🏥 Healthcare & Medical';
    } else if (types.contains('pharmacy')) {
      return '💊 Pharmacy & Medicine';
    } else if (types.contains('gas_station') || types.contains('car_repair')) {
      return '⛽ Automotive Services';
    } else if (types.contains('car_wash')) {
      return '🚗 Car Wash & Service';
    } else if (types.contains('bank')) {
      return '🏦 Banking Services';
    } else if (types.contains('atm')) {
      return '🏧 ATM & Cash Machine';
    } else if (types.contains('gym') || types.contains('spa')) {
      return '💪 Health & Fitness';
    } else if (types.contains('beauty_salon') || types.contains('hair_care')) {
      return '💅 Beauty & Personal Care';
    } else if (types.contains('laundry')) {
      return '👕 Laundromat & Dry Cleaning';
    } else if (types.contains('school') || types.contains('university')) {
      return '🎓 Education & Learning';
    } else if (types.contains('church') || types.contains('place_of_worship')) {
      return '⛪ Places of Worship';
    } else if (types.contains('park') || types.contains('zoo')) {
      return '🌳 Parks & Recreation';
    } else if (types.contains('movie_theater') || types.contains('night_club')) {
      return '🎬 Entertainment & Nightlife';
    } else if (types.contains('subway_station') || types.contains('restroom')) {
      return '🚻 Public Restroom & Facilities';
    } else {
      return '📍 Local Business';
    }
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required SettingsProvider settings,
    Color? statusColor,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    Widget child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (statusColor ?? Color(0xFF5856D6)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: statusColor ?? Color(0xFF5856D6),
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(15),
                  fontWeight: FontWeight.w500,
                  color: statusColor ?? (isClickable ? Color(0xFF5856D6) : Colors.black87),
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
        if (isClickable)
          Icon(
            Icons.open_in_new,
            size: 16,
            color: Color(0xFF5856D6),
          ),
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }

  void _callPlace(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWebsite(String website) async {
    final uri = Uri.parse(website);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyAddressFromDetails() async {
    await Clipboard.setData(ClipboardData(text: widget.place.address));

    // Show in-modal feedback
    setState(() {
      _showCopiedFeedback = true;
    });

    // Hide feedback after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCopiedFeedback = false;
        });
      }
    });
  }

  Widget _buildOpeningHoursSection(List<String> openingHours, SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF5856D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule,
                color: Color(0xFF5856D6),
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.openingHours,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: openingHours
                .map((hour) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        hour,
                        style: TextStyle(
                          fontSize: settings.getScaledFontSize(14),
                          color: Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAISummarySection(String aiSummary, SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.purple,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.aiSummary,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(10),
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Text(
            aiSummary,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _openDirections(BuildContext context) async {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NavigationOptionsSheet(place: widget.place),
    );
  }

  void _sharePlace(BuildContext context) async {
    Navigator.pop(context);
    final String shareText = _buildShareText();
    Share.share(
      shareText,
      subject: '📍 Check out ${widget.place.name}',
    );
  }

  String _buildShareText() {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('📍 ${widget.place.name}');
    buffer.writeln('');

    // Basic info
    buffer.writeln('📍 Address: ${widget.place.address}');
    buffer.writeln('📏 Distance: ${widget.place.getDistanceText(
      locale: Localizations.localeOf(context).toString(),
      countryCode: Localizations.localeOf(context).countryCode,
    )}');

    // Rating if available
    if (widget.place.rating > 0) {
      String ratingStars = '⭐' * widget.place.rating.round();
      buffer.writeln('⭐ Rating: ${widget.place.rating.toStringAsFixed(1)}/5.0 $ratingStars');
      if (widget.place.userRatingsTotal > 0) {
        buffer.writeln('   (${widget.place.userRatingsTotal} reviews)');
      }
    }

    // Price level if available
    if (widget.place.priceLevel != 'Unknown') {
      String priceSymbols = '';
      switch (widget.place.priceLevel) {
        case 'Inexpensive':
          priceSymbols = '\$ ';
          break;
        case 'Moderate':
          priceSymbols = '\$\$ ';
          break;
        case 'Expensive':
          priceSymbols = '\$\$\$ ';
          break;
        case 'Very Expensive':
          priceSymbols = '\$\$\$\$ ';
          break;
      }
      buffer.writeln('💰 Price: $priceSymbols(${widget.place.priceLevel})');
    }

    // Status
    buffer.writeln('🕒 Status: ${widget.place.isOpen ? "Open" : "Closed"}');

    // Google Maps link
    buffer.writeln('');
    buffer.writeln('🗺️ Get Directions:');
    buffer.writeln('https://www.google.com/maps/dir/?api=1&destination=${widget.place.latitude},${widget.place.longitude}');

    // Footer
    buffer.writeln('');
    buffer.writeln('📱 Shared via HowAI Places Explorer');

    return buffer.toString();
  }

  Widget _buildExpandableStatusSection(SettingsProvider settings) {
    return GestureDetector(
      onTap: widget.place.openingHours.isNotEmpty
          ? () {
              setState(() {
                _isStatusExpanded = !_isStatusExpanded;
              });
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (widget.place.isOpen ? Colors.green : Colors.red).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.place.isOpen ? Icons.check_circle : Icons.cancel,
                        color: widget.place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red),
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.place.isOpen ? AppLocalizations.of(context)!.currentlyOpen : AppLocalizations.of(context)!.currentlyClosed,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(15),
                        fontWeight: FontWeight.w600,
                        color: widget.place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.place.openingHours.isNotEmpty)
                Icon(
                  _isStatusExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
            ],
          ),

          // Tap hint
          if (widget.place.openingHours.isNotEmpty && !_isStatusExpanded) ...[
            SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.tapToViewOpeningHours,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(12),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],

          // Opening Hours (expandable)
          if (_isStatusExpanded && widget.place.openingHours.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.place.openingHours
                    .map((hour) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            hour,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(13),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, SettingsProvider settings) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFF5856D6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(0xFF5856D6),
            size: 16,
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: settings.getScaledFontSize(16),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(PlaceResult place, SettingsProvider settings) {
    List<Map<String, dynamic>> amenities = [];

    // Core Facilities
    if (place.hasRestroom == true) {
      amenities.add({'icon': Icons.wc, 'label': 'Restroom', 'color': Colors.blue});
    }
    if (place.hasParking == true) {
      amenities.add({'icon': Icons.local_parking, 'label': 'Parking', 'color': Colors.green});
    }
    if (place.hasEvCharger == true) {
      amenities.add({'icon': Icons.ev_station, 'label': 'EV Charger', 'color': Colors.orange});
    }

    // Accessibility & Family
    if (place.wheelchairAccessible == true) {
      amenities.add({'icon': Icons.accessible, 'label': 'Wheelchair Access', 'color': Colors.purple});
    }
    if (place.allowsDogs == true) {
      amenities.add({'icon': Icons.pets, 'label': 'Pet Friendly', 'color': Colors.brown});
    }
    if (place.goodForChildren == true) {
      amenities.add({'icon': Icons.child_friendly, 'label': 'Kid Friendly', 'color': Colors.pink});
    }

    // Service Options
    if (place.takeout == true) {
      amenities.add({'icon': Icons.takeout_dining, 'label': 'Takeout', 'color': Colors.teal});
    }
    if (place.delivery == true) {
      amenities.add({'icon': Icons.delivery_dining, 'label': 'Delivery', 'color': Colors.red});
    }
    if (place.dineIn == true) {
      amenities.add({'icon': Icons.restaurant, 'label': 'Dine In', 'color': Colors.indigo});
    }
    if (place.curbsidePickup == true) {
      amenities.add({'icon': Icons.drive_eta, 'label': 'Curbside Pickup', 'color': Colors.cyan});
    }

    if (amenities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500, size: 20),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.facilityInformationNotAvailable,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(14),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: amenities
            .map((amenity) => _buildAmenityChip(
                  icon: amenity['icon'],
                  label: amenity['label'],
                  color: amenity['color'],
                  settings: settings,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAmenityChip({
    required IconData icon,
    required String label,
    required Color color,
    required SettingsProvider settings,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(12),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // New redesigned UI components
  Widget _buildQuickOverview(SettingsProvider settings) {
    return Row(
      children: [
        // Rating & Reviews
        if (widget.place.rating > 0) ...[
          Expanded(
            child: _buildOverviewCard(
              icon: Icons.star,
              title: '${widget.place.rating.toStringAsFixed(1)}',
              subtitle: '${widget.place.userRatingsTotal} reviews',
              color: Colors.amber,
              settings: settings,
              onTap: widget.place.userRatingsTotal > 0 ? () => _showRatingBreakdown(widget.place) : null,
              isClickable: widget.place.userRatingsTotal > 0,
            ),
          ),
          SizedBox(width: 8),
        ],
        // Price Level
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.attach_money,
            title: widget.place.priceLevel != 'Unknown' ? widget.place.priceLevel : 'N/A',
            subtitle: AppLocalizations.of(context)!.priceLevel,
            color: Colors.green,
            settings: settings,
          ),
        ),
        SizedBox(width: 8),
        // Distance
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.directions,
            title: widget.place.getDistanceText(
              locale: Localizations.localeOf(context).toString(),
              countryCode: Localizations.localeOf(context).countryCode,
            ),
            subtitle: AppLocalizations.of(context)!.distance,
            color: Colors.blue,
            settings: settings,
          ),
        ),
        // Reservable (if available)
        if (widget.place.reservable == true) ...[
          SizedBox(width: 8),
          Expanded(
            child: _buildOverviewCard(
              icon: Icons.event_available,
              title: 'Reserve',
              subtitle: 'Available',
              color: Colors.purple,
              settings: settings,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required SettingsProvider settings,
    VoidCallback? onTap,
    bool isClickable = false,
  }) {
    Widget cardContent = Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              fontWeight: FontWeight.bold,
              color: color, // Keep original color (amber for rating)
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(10),
              color: isClickable ? Color(0xFF0066CC) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
              decoration: isClickable ? TextDecoration.underline : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color, size: 18),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
          // Card Content
          Padding(
            padding: EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsContent(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Insights header with NEW badge
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(8),
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.aiGeneratedInsights,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(10),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // AI Summary (if available)
        if (widget.place.aiSummary != null) ...[
          Text(
            widget.place.aiSummary!,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800,
              height: 1.3,
            ),
          ),
        ],

        // Review Insights (if available)
        if (widget.place.reviewSummary != null) ...[
          if (widget.place.aiSummary != null) SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.rate_review, color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Colors.purple.shade600, size: 14),
              SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.reviewAnalysis,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(10),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Colors.purple.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            widget.place.reviewSummary!,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationContactContent(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address
        _buildInfoRow(
          icon: Icons.location_on,
          title: AppLocalizations.of(context)!.address,
          content: widget.place.address,
          settings: settings,
          isClickable: true,
          onTap: () => _copyAddressFromDetails(),
        ),

        // Phone (if available)
        if (widget.place.phoneNumber != null) ...[
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone,
            title: AppLocalizations.of(context)!.phone,
            content: widget.place.phoneNumber!,
            settings: settings,
            isClickable: true,
            onTap: () => _callPlace(widget.place.phoneNumber!),
          ),
        ],

        // Website (if available)
        if (widget.place.website != null) ...[
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.language,
            title: AppLocalizations.of(context)!.website,
            content: 'Visit Official Website',
            settings: settings,
            isClickable: true,
            onTap: () => _openWebsite(widget.place.website!),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandableStatusContent(SettingsProvider settings) {
    return GestureDetector(
      onTap: widget.place.openingHours.isNotEmpty
          ? () {
              setState(() {
                _isStatusExpanded = !_isStatusExpanded;
              });
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (widget.place.isOpen ? Colors.green : Colors.red).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.place.isOpen ? Icons.check_circle : Icons.cancel,
                        color: widget.place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red),
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.place.isOpen ? AppLocalizations.of(context)!.currentlyOpen : AppLocalizations.of(context)!.currentlyClosed,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(15),
                        fontWeight: FontWeight.w600,
                        color: widget.place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.place.openingHours.isNotEmpty)
                Icon(
                  _isStatusExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
            ],
          ),

          // Tap hint
          if (widget.place.openingHours.isNotEmpty && !_isStatusExpanded) ...[
            SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.tapToViewOpeningHours,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(12),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],

          // Opening Hours (expandable)
          if (_isStatusExpanded && widget.place.openingHours.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.place.openingHours
                    .map((hour) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            hour,
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(13),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesAmenitiesContent(SettingsProvider settings) {
    List<Map<String, dynamic>> services = [];
    List<Map<String, dynamic>> amenities = [];

    // Service Options
    if (widget.place.takeout == true) {
      services.add({'icon': Icons.takeout_dining, 'label': 'Takeout', 'color': Colors.teal});
    }
    if (widget.place.delivery == true) {
      services.add({'icon': Icons.delivery_dining, 'label': 'Delivery', 'color': Colors.red});
    }
    if (widget.place.dineIn == true) {
      services.add({'icon': Icons.restaurant, 'label': 'Dine In', 'color': Colors.indigo});
    }
    if (widget.place.curbsidePickup == true) {
      services.add({'icon': Icons.drive_eta, 'label': 'Curbside Pickup', 'color': Colors.cyan});
    }
    if (widget.place.reservable == true) {
      services.add({'icon': Icons.event_available, 'label': 'Reservations', 'color': Colors.purple});
    }

    // Amenities
    if (widget.place.hasRestroom == true) {
      amenities.add({'icon': Icons.wc, 'label': 'Restroom', 'color': Colors.blue});
    }
    if (widget.place.hasParking == true) {
      amenities.add({'icon': Icons.local_parking, 'label': 'Parking', 'color': Colors.green});
    }
    if (widget.place.hasEvCharger == true) {
      amenities.add({'icon': Icons.ev_station, 'label': 'EV Charger', 'color': Colors.orange});
    }
    if (widget.place.wheelchairAccessible == true) {
      amenities.add({'icon': Icons.accessible, 'label': 'Wheelchair Access', 'color': Colors.purple});
    }
    if (widget.place.allowsDogs == true) {
      amenities.add({'icon': Icons.pets, 'label': 'Pet Friendly', 'color': Colors.brown});
    }
    if (widget.place.goodForChildren == true) {
      amenities.add({'icon': Icons.child_friendly, 'label': 'Kid Friendly', 'color': Colors.pink});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Services Section
        if (services.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context)!.services,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(12),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: services
                .map((service) => _buildServiceChip(
                      icon: service['icon'],
                      label: service['label'],
                      color: service['color'],
                      settings: settings,
                    ))
                .toList(),
          ),
        ],

        // Amenities Section
        if (amenities.isNotEmpty) ...[
          if (services.isNotEmpty) SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.amenities,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(12),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: amenities
                .map((amenity) => _buildServiceChip(
                      icon: amenity['icon'],
                      label: amenity['label'],
                      color: amenity['color'],
                      settings: settings,
                    ))
                .toList(),
          ),
        ],

        // No information available
        if (services.isEmpty && amenities.isEmpty)
          Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500, size: 16),
              SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.serviceInformationNotAvailable,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(12),
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required SettingsProvider settings,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(11),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                content,
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(13),
                  color: isClickable ? (Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : Colors.grey.shade800),
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isClickable && title != AppLocalizations.of(context)!.address) Icon(Icons.open_in_new, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600),
        if (isClickable && title == AppLocalizations.of(context)!.address) ...[
          if (_showCopiedFeedback) ...[
            Icon(Icons.check_circle, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green.shade600),
            SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.copied,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(11),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green.shade600,
              ),
            ),
          ] else
            Icon(Icons.content_copy, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade600),
        ],
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: row,
      );
    }

    return row;
  }

  Widget _buildServiceChip({
    required IconData icon,
    required String label,
    required Color color,
    required SettingsProvider settings,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color, size: 12),
          SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(10),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingBreakdown(PlaceResult place) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Overall rating
              Row(
                children: [
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (index) => Icon(
                                  Icons.star,
                                  size: 20,
                                  color: index < place.rating.round() ? Colors.amber : Colors.grey.shade400,
                                )),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${place.userRatingsTotal} global ratings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Rating breakdown (Amazon style)
              ...List.generate(5, (index) {
                final starCount = 5 - index;
                // Simulated percentage distribution based on common patterns
                final percentage = _getSimulatedPercentage(starCount, place.rating);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$starCount star',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0066CC),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0066CC),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 20),

              // See reviews button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAllReviews(place);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('See recent reviews'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getSimulatedPercentage(int starRating, double overallRating) {
    // Simulate realistic percentage distribution based on overall rating
    if (overallRating >= 4.5) {
      switch (starRating) {
        case 5:
          return 75.0;
        case 4:
          return 15.0;
        case 3:
          return 6.0;
        case 2:
          return 2.0;
        case 1:
          return 2.0;
      }
    } else if (overallRating >= 4.0) {
      switch (starRating) {
        case 5:
          return 60.0;
        case 4:
          return 25.0;
        case 3:
          return 10.0;
        case 2:
          return 3.0;
        case 1:
          return 2.0;
      }
    } else if (overallRating >= 3.5) {
      switch (starRating) {
        case 5:
          return 45.0;
        case 4:
          return 30.0;
        case 3:
          return 15.0;
        case 2:
          return 6.0;
        case 1:
          return 4.0;
      }
    } else {
      switch (starRating) {
        case 5:
          return 30.0;
        case 4:
          return 25.0;
        case 3:
          return 25.0;
        case 2:
          return 12.0;
        case 1:
          return 8.0;
      }
    }
    return 0.0;
  }

  void _showAllReviews(PlaceResult place) async {
    final reviews = await _getPlaceDetailsWithReviews(place.placeId);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewsBottomSheet(
        place: place,
        placeDetails: reviews,
      ),
    );
  }

  Future<PlaceDetails?> _getPlaceDetailsWithReviews(String placeId) async {
    try {
      final String url = 'https://places.googleapis.com/v1/places/$placeId';
      final apiKey = dotenv.env['GOOGLE_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'displayName,rating,nationalPhoneNumber,websiteUri,regularOpeningHours,reviews,photos',
        },
      );

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);

        // Parse reviews from new API format
        List<PlaceReview> reviews = [];
        if (data['reviews'] != null) {
          for (var reviewData in data['reviews']) {
            reviews.add(PlaceReview(
              authorName: reviewData['authorAttribution']?['displayName'] ?? 'Anonymous',
              rating: reviewData['rating'] ?? 0,
              text: reviewData['text']?['text'] ?? '',
              relativeTime: reviewData['relativePublishTimeDescription'] ?? '',
            ));
          }
        }

        return PlaceDetails(
          name: data['displayName']?['text'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          phoneNumber: data['nationalPhoneNumber'],
          website: data['websiteUri'],
          openingHours: data['regularOpeningHours']?['weekdayDescriptions'] != null ? List<String>.from(data['regularOpeningHours']['weekdayDescriptions']) : [],
          reviews: reviews,
          photoReferences: data['photos'] != null ? (data['photos'] as List).map((p) => p['name'] as String).toList() : [],
        );
      }
    } catch (e) {
      // Error fetching reviews
    }

    return null;
  }
}

class _PhotoGalleryWidget extends StatefulWidget {
  final List<String> photos;
  final PlaceResult place;
  final SettingsProvider settings;
  final LocationService locationService;
  final Widget Function() buildPhotoPlaceholder;

  const _PhotoGalleryWidget({
    required this.photos,
    required this.place,
    required this.settings,
    required this.locationService,
    required this.buildPhotoPlaceholder,
  });

  @override
  State<_PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();
}

class _EnhancedPhotoGalleryWidget extends StatefulWidget {
  final PlaceResult place;
  final SettingsProvider settings;
  final LocationService locationService;
  final Widget Function() buildPhotoPlaceholder;

  const _EnhancedPhotoGalleryWidget({
    required this.place,
    required this.settings,
    required this.locationService,
    required this.buildPhotoPlaceholder,
  });

  @override
  State<_EnhancedPhotoGalleryWidget> createState() => _EnhancedPhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<_PhotoGalleryWidget> {
  late PageController _pageController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //// print('🖼️ [DEBUG] PhotoGalleryWidget: ${widget.photos.length} photos for ${widget.place.name}');

    if (widget.photos.isEmpty) {
      //// print('🖼️ [DEBUG] No photos available, showing placeholder');
      return widget.buildPhotoPlaceholder();
    }

    //// print('🖼️ [DEBUG] Showing photo gallery with ${widget.photos.length} photos');
    return Stack(
      children: [
        // Photo PageView
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemCount: widget.photos.length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                widget.locationService.getPhotoUrl(widget.photos[index], maxWidth: 1200),
                fit: BoxFit.contain, // Changed from cover to contain to show full image
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5856D6)),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.unableToLoadPhoto,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Photo navigation arrows (if multiple photos)
        if (widget.photos.length > 1) ...[
          // Left arrow
          if (_currentPhotoIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Right arrow
          if (_currentPhotoIndex < widget.photos.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Photo counter
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPhotoIndex + 1} / ${widget.photos.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.settings.getScaledFontSize(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EnhancedPhotoGalleryWidgetState extends State<_EnhancedPhotoGalleryWidget> {
  late PageController _pageController;
  int _currentPhotoIndex = 0;
  List<String> _allPhotos = [];
  bool _isLoadingMorePhotos = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAllPhotos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPhotos() async {
    // Start with photos from search results
    List<String> initialPhotos = widget.place.photoReferences.isNotEmpty ? widget.place.photoReferences : (widget.place.photoReference != null ? [widget.place.photoReference!] : <String>[]);

    setState(() {
      _allPhotos = initialPhotos;
      _isLoadingMorePhotos = true;
    });

    // Try to get more photos from Place Details API
    try {
      final additionalPhotos = await widget.locationService.getPlacePhotos(widget.place.placeId);

      if (additionalPhotos.isNotEmpty) {
        // Merge and deduplicate photos
        Set<String> photoSet = Set<String>.from(_allPhotos);
        photoSet.addAll(additionalPhotos);

        setState(() {
          _allPhotos = photoSet.toList();
          _isLoadingMorePhotos = false;
        });
      } else {
        setState(() {
          _isLoadingMorePhotos = false;
        });
      }
    } catch (e) {
      //// print('🖼️ [ERROR] Failed to load additional photos: $e');
      setState(() {
        _isLoadingMorePhotos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //// print('🖼️ [DEBUG] EnhancedPhotoGallery: ${_allPhotos.length} photos total for ${widget.place.name}');

    if (_allPhotos.isEmpty && !_isLoadingMorePhotos) {
      //// print('🖼️ [DEBUG] No photos available, showing placeholder');
      return widget.buildPhotoPlaceholder();
    }

    if (_allPhotos.isEmpty && _isLoadingMorePhotos) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5856D6)),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loadingPhotos,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Enhanced Photo PageView with zoom and better display
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, // Black background for better photo viewing
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemCount: _allPhotos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true, // Allow panning
                scaleEnabled: true, // Allow zooming
                minScale: 0.5,
                maxScale: 3.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Image.network(
                      widget.locationService.getPhotoUrl(_allPhotos[index], maxWidth: 1200),
                      fit: BoxFit.contain, // Show full image without cropping
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.loadingPhoto,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.unableToLoadPhoto,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
          ),
        ),

        // Photo navigation arrows (if multiple photos)
        if (_allPhotos.length > 1) ...[
          // Left arrow
          if (_currentPhotoIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Right arrow
          if (_currentPhotoIndex < _allPhotos.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Photo counter with loading indicator
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_currentPhotoIndex + 1} / ${_allPhotos.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.settings.getScaledFontSize(10),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isLoadingMorePhotos) ...[
                    SizedBox(width: 6),
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Reviews Bottom Sheet Widget
class _ReviewsBottomSheet extends StatelessWidget {
  final PlaceResult place;
  final PlaceDetails? placeDetails;

  const _ReviewsBottomSheet({
    required this.place,
    this.placeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reviews for ${place.name}',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(18),
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${place.rating.toStringAsFixed(1)} (${place.userRatingsTotal} total reviews)',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            placeDetails?.reviews.isNotEmpty == true ? 'Showing ${placeDetails!.reviews.length} recent reviews' : 'Recent reviews from Google',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(12),
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              // Reviews list
              Expanded(
                child: placeDetails?.reviews.isNotEmpty == true
                    ? ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: placeDetails!.reviews.length,
                        itemBuilder: (context, index) {
                          final review = placeDetails!.reviews[index];
                          return _buildReviewItem(review, settings, context);
                        },
                      )
                    : _buildNoReviewsState(settings, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(PlaceReview review, SettingsProvider settings, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple.withOpacity(0.2),
                child: Text(
                  review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName.isNotEmpty ? review.authorName : 'Anonymous',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                              5,
                              (index) => Icon(
                                    Icons.star,
                                    size: 14,
                                    color: index < review.rating ? Colors.amber : Colors.grey.shade400,
                                  )),
                        ),
                        SizedBox(width: 8),
                        Text(
                          review.relativeTime,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(12),
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.text.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review.text,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(13),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoReviewsState(SettingsProvider settings, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No recent reviews to display',
            style: TextStyle(
              fontSize: settings.getScaledFontSize(16),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Google only provides a sample of recent reviews through the API.\nAll ${place.userRatingsTotal} reviews are available on Google Maps.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// Full-screen list view that shows all places
class _FullScreenListView extends StatefulWidget {
  final List<PlaceResult> places;
  final String searchQuery;
  final bool enableRouteFeatures;

  const _FullScreenListView({
    required this.places,
    required this.searchQuery,
    required this.enableRouteFeatures,
  });

  @override
  State<_FullScreenListView> createState() => _FullScreenListViewState();
}

class _FullScreenListViewState extends State<_FullScreenListView> {
  final LocationService _locationService = LocationService();
  String _sortBy = 'distance'; // distance, rating, name

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.foundPlaces(widget.places.length),
              style: TextStyle(
                fontSize: settings.getScaledFontSize(18),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'distance',
                    child: Row(
                      children: [
                        Icon(Icons.near_me, size: 18),
                        SizedBox(width: 8),
                        Text('Distance'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rating',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 18),
                        SizedBox(width: 8),
                        Text('Rating'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha, size: 18),
                        SizedBox(width: 8),
                        Text('Name'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _getSortedPlaces().length,
            itemBuilder: (context, index) {
              final place = _getSortedPlaces()[index];
              return _buildListItem(place, settings, index);
            },
          ),
        );
      },
    );
  }

  List<PlaceResult> _getSortedPlaces() {
    final places = List<PlaceResult>.from(widget.places);

    switch (_sortBy) {
      case 'rating':
        places.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        places.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'distance':
      default:
        // Places are likely already sorted by distance from the API
        break;
    }

    return places;
  }

  Widget _buildListItem(PlaceResult place, SettingsProvider settings, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openPlaceDetails(place),
        borderRadius: BorderRadius.circular(16),
        splashColor: Color(0xFF5856D6).withOpacity(0.1),
        highlightColor: Color(0xFF5856D6).withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Place image or icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF5856D6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: place.photoReference != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _locationService.getPhotoUrl(place.photoReference!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceIcon(place),
                        ),
                      )
                    : _buildPlaceIcon(place),
              ),

              SizedBox(width: 16),

              // Place info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place name
                    Text(
                      place.name,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Rating and type
                    Row(
                      children: [
                        if (place.rating > 0) ...[
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          _getPlaceTypeText(place),
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(12),
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Review snippet (if available)
                    if (place.reviewSummary != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        margin: EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '"${place.reviewSummary!}"',
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(9),
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.lightBlue.shade200 : Colors.blue.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Address
                    Text(
                      place.address,
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(10),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // Status and distance
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1)) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.withOpacity(0.15) : Colors.red.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(10),
                              fontWeight: FontWeight.w500,
                              color: place.isOpen ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade400 : Colors.green) : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade400 : Colors.red),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          place.getDistanceText(
                            locale: Localizations.localeOf(context).toString(),
                            countryCode: Localizations.localeOf(context).countryCode,
                          ),
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(12),
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade200 : Color(0xFF5856D6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceIcon(PlaceResult place) {
    IconData icon;
    Color color;

    final types = place.types;
    if (types.contains('restaurant') || types.contains('food')) {
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (types.contains('cafe')) {
      icon = Icons.local_cafe;
      color = Colors.brown;
    } else if (types.contains('lodging')) {
      icon = Icons.hotel;
      color = Colors.blue;
    } else if (types.contains('shopping_mall')) {
      icon = Icons.shopping_bag;
      color = Colors.green;
    } else if (types.contains('gas_station')) {
      icon = Icons.local_gas_station;
      color = Colors.red;
    } else {
      icon = Icons.place;
      color = Color(0xFF5856D6);
    }

    return Icon(
      icon,
      color: color,
      size: 32,
    );
  }

  String _getPlaceTypeText(PlaceResult place) {
    final types = place.types;
    if (types.contains('restaurant')) return 'Restaurant';
    if (types.contains('cafe')) return 'Café';
    if (types.contains('lodging')) return 'Hotel';
    if (types.contains('shopping_mall')) return 'Shopping';
    if (types.contains('gas_station')) return 'Gas Station';
    if (types.contains('hospital')) return 'Hospital';
    if (types.contains('bank')) return 'Bank';
    return 'Business';
  }

  void _openPlaceDetails(PlaceResult place) {
    // Find the index of the selected place in the original list
    final placeIndex = widget.places.indexWhere((p) => p.placeId == place.placeId);

    // Close the list view and pass back the selected place index
    Navigator.of(context).pop(placeIndex >= 0 ? placeIndex : null);
  }
}

// Place Result data class
