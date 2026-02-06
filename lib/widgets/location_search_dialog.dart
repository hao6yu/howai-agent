import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haogpt/generated/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../services/location_service.dart';

class LocationSearchDialog extends StatefulWidget {
  final Function(List<PlaceResult>, String) onSearchCompleted;

  const LocationSearchDialog({
    super.key,
    required this.onSearchCompleted,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();
  bool _isSearching = false;
  bool _isGettingLocation = false;
  String? _locationError;
  String _selectedCategory = 'restaurant';
  bool _openNow = false; // Track "open now" filter
  bool _useCurrentLocation = true; // Toggle for location type
  String? _lastCustomLocation; // Remember last custom location
  String? _validationError; // Show validation errors prominently

  final Map<String, String> _categories = {
    'restaurant': 'Restaurants',
    'cafe': 'Coffee Shops',
    'bakery': 'Sweet Food & Bakery',
    'convenience_store': 'Ice Cream & Desserts',
    'lodging': 'Hotels',
    'tourist_attraction': 'Attractions',
    'shopping_mall': 'Shopping',
    'gas_station': 'Gas Stations',
    'parking': 'Parking Garage',
    'hospital': 'Healthcare',
    'pharmacy': 'Pharmacy',
    'bank': 'Banks',
    'atm': 'ATM',
    'gym': 'Fitness',
    'beauty_salon': 'Beauty & Spa',
    'laundry': 'Laundromat',
    'car_wash': 'Car Wash',
    'night_club': 'Nightlife',
    'park': 'Parks',
    'subway_station': 'Public Transit',
    'restroom': 'Public Restroom',
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // Add listener to update button text when search field changes
    _searchController.addListener(() {
      setState(() {
        // Rebuild to update button text
      });
    });

    // Add listener for location controller
    _locationController.addListener(() {
      setState(() {
        // Rebuild to update UI state
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    // Only request location permission if using current location
    if (!_useCurrentLocation) return;

    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      bool hasPermission = await _locationService.checkLocationPermission();
      if (hasPermission) {
        await _locationService.getCurrentLocation();
      } else {
        setState(() {
          _locationError =
              "Location permission required for current location search";
        });
      }
    } catch (e) {
      setState(() {
        _locationError = "Failed to get location: $e";
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  // Toggle location mode and handle permission/geocoding accordingly
  void _toggleLocationMode(bool useCurrentLocation) {
    setState(() {
      _useCurrentLocation = useCurrentLocation;
      _locationError = null;

      if (useCurrentLocation) {
        // Switched to current location - request permission
        _requestLocationPermission();
      } else {
        // Switched to custom location - stop location loading and pre-fill
        _isGettingLocation = false;
        if (_lastCustomLocation != null) {
          _locationController.text = _lastCustomLocation!;
        }
      }
    });
  }

  Future<void> _searchPlaces() async {
    final searchText = _searchController.text.trim();
    final customLocation =
        _useCurrentLocation ? null : _locationController.text.trim();

    //// print('[LocationSearch] _searchPlaces called with: "$searchText"');
    //// print('[LocationSearch] Use current location: $_useCurrentLocation');
    if (customLocation != null) {
      //// print('[LocationSearch] Custom location: "$customLocation"');
    }

    // Use category name as fallback if no search text provided
    final queryText = searchText.isEmpty
        ? _categories[_selectedCategory] ?? _selectedCategory
        : searchText;

    // Validate custom location if needed
    if (!_useCurrentLocation &&
        (customLocation == null || customLocation.isEmpty)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Location Required',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            content: Text(
              'Please enter a city or address to search in.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        },
      );
      return;
    }

    //// print('[LocationSearch] Using query: "$queryText" (category: $_selectedCategory)');
    //// print('[LocationSearch] Starting search...');
    setState(() {
      _isSearching = true;
    });

    try {
      //// print('[LocationSearch] Calling locationService.searchNearbyPlaces');
      final places = await _locationService.searchNearbyPlaces(
        query: queryText,
        type: _selectedCategory,
        openNow: _openNow,
        customLocation: customLocation,
      );

      // Remember the custom location for next time
      if (!_useCurrentLocation && customLocation != null) {
        _lastCustomLocation = customLocation;
      }

      //// print('[LocationSearch] Search completed, found ${places.length} places');

      // Create an enhanced query description for the chat
      final searchDescription =
          _useCurrentLocation ? queryText : "$queryText in $customLocation";

      widget.onSearchCompleted(places, searchDescription);
    } catch (e) {
      //// print('[LocationSearch] Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.searchFailed(e.toString()))),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen =
            screenHeight < 700 || screenWidth < 400; // iPhone 16 and similar

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom title bar
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF5856D6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.explore,
                            color: Color(0xFF5856D6),
                            size: settings
                                .getScaledFontSize(isSmallScreen ? 18 : 20),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Places Explorer',
                            style: TextStyle(
                              fontSize: settings
                                  .getScaledFontSize(isSmallScreen ? 16 : 18),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(9),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content area
                  Container(
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxHeight: isSmallScreen
                          ? screenHeight * 0.6
                          : screenHeight * 0.7,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isGettingLocation) ...[
                              Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                        color: Color(0xFF5856D6)),
                                    SizedBox(height: 12),
                                    Text(
                                      'Getting your location...',
                                      style: TextStyle(
                                        fontSize:
                                            settings.getScaledFontSize(14),
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (_locationError != null) ...[
                              // Warning container with maximum elevation to ensure it appears on top
                              Stack(
                                children: [
                                  Material(
                                    elevation:
                                        12, // Increased elevation for higher z-index
                                    borderRadius: BorderRadius.circular(8),
                                    shadowColor: Colors.red.withOpacity(0.5),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.red, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              Icons.warning,
                                              color: Colors.white,
                                              size: settings
                                                  .getScaledFontSize(20),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              _locationError!,
                                              style: TextStyle(
                                                fontSize: settings
                                                    .getScaledFontSize(14),
                                                color: Colors.red.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _requestLocationPermission,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      'Try Again',
                                      style: TextStyle(
                                        fontSize:
                                            settings.getScaledFontSize(16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Location selection
                              Text(
                                'Search Location',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                              SizedBox(height: 4),

                              // Current location toggle
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.my_location,
                                    color: _useCurrentLocation
                                        ? Color(0xFF5856D6)
                                        : Colors.grey,
                                    size: settings.getScaledFontSize(20),
                                  ),
                                  title: Text(
                                    'Use Current Location',
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(14),
                                      fontWeight: _useCurrentLocation
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                  subtitle: _locationService.currentAddress !=
                                          null
                                      ? Text(
                                          _locationService.currentAddress!,
                                          style: TextStyle(
                                            fontSize:
                                                settings.getScaledFontSize(12),
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        )
                                      : null,
                                  trailing: Switch(
                                    value: _useCurrentLocation,
                                    onChanged: _toggleLocationMode,
                                    activeColor: Color(0xFF5856D6),
                                  ),
                                ),
                              ),

                              // Custom location input
                              if (!_useCurrentLocation) ...[
                                SizedBox(height: 4),
                                TextField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .enterCityOrAddress,
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    hintText: AppLocalizations.of(context)!
                                        .tokyoParisExample,
                                    hintStyle: TextStyle(
                                      fontSize: settings.getScaledFontSize(14),
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    prefixIcon: Icon(Icons.location_city,
                                        color: Color(0xFF5856D6)),
                                    errorText: _validationError,
                                    fillColor: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                    filled: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    // Clear validation error when user starts typing
                                    if (_validationError != null) {
                                      setState(() {
                                        _validationError = null;
                                      });
                                    }
                                  },
                                ),
                              ],

                              SizedBox(height: 16),

                              // Section header with Open now filter
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'What are you looking for?',
                                      style: TextStyle(
                                        fontSize:
                                            settings.getScaledFontSize(14),
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _openNow
                                          ? Color(0xFF5856D6).withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _openNow
                                            ? Color(0xFF5856D6)
                                            : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade300),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: Checkbox(
                                            value: _openNow,
                                            onChanged: (value) {
                                              setState(() {
                                                _openNow = value ?? false;
                                              });
                                            },
                                            activeColor: Color(0xFF5856D6),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Open now',
                                          style: TextStyle(
                                            fontSize:
                                                settings.getScaledFontSize(12),
                                            color: _openNow
                                                ? Color(0xFF5856D6)
                                                : (Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700),
                                            fontWeight: _openNow
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12),

                              // Category selection
                              _buildCategoryGrid(settings),

                              SizedBox(height: 12),

                              // Search input
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .optionalBestPizza,
                                  hintStyle: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  fillColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  filled: true,
                                  suffixIcon: IconButton(
                                    onPressed:
                                        _isSearching ? null : _searchPlaces,
                                    icon: _isSearching
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Icon(Icons.search),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(14),
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                                onSubmitted: (_) => _searchPlaces(),
                                textInputAction: TextInputAction.search,
                              ),

                              SizedBox(height: 12),
                            ],
                          ]),
                    ),
                  ),

                  // Action buttons at bottom
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                          top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      )),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(14),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        if (!_isGettingLocation && _locationError == null)
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : _searchPlaces,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5856D4),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isSearching
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _searchController.text.trim().isEmpty
                                          ? 'Find ${_categories[_selectedCategory]}'
                                          : 'Search',
                                      style: TextStyle(
                                          fontSize:
                                              settings.getScaledFontSize(14)),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get brighter colors for dark mode
  Color _getBrighterColorForDarkMode(Color originalColor) {
    if (originalColor == Colors.orange) return Colors.orange.shade100;
    if (originalColor == Colors.green) return Colors.green.shade100;
    if (originalColor == Colors.blue) return Colors.blue.shade100;
    if (originalColor == Colors.purple) return Colors.purple.shade100;
    return originalColor.withOpacity(1.0);
  }

  Widget _buildCategoryGrid(SettingsProvider settings) {
    // Group categories with icons and colors
    final categoryGroups = [
      {
        'title': 'Food & Drink',
        'color': Colors.orange,
        'categories': [
          {
            'key': 'restaurant',
            'name': 'Restaurants',
            'icon': Icons.restaurant
          },
          {'key': 'cafe', 'name': 'Coffee', 'icon': Icons.local_cafe},
          {'key': 'bakery', 'name': 'Bakery', 'icon': Icons.cake},
          {
            'key': 'convenience_store',
            'name': 'Desserts',
            'icon': Icons.icecream
          },
          {'key': 'night_club', 'name': 'Bars', 'icon': Icons.nightlife},
        ]
      },
      {
        'title': 'Places & Travel',
        'color': Colors.green,
        'categories': [
          {'key': 'lodging', 'name': 'Hotels', 'icon': Icons.hotel},
          {
            'key': 'tourist_attraction',
            'name': 'Attractions',
            'icon': Icons.attractions
          },
          {
            'key': 'shopping_mall',
            'name': 'Shopping',
            'icon': Icons.shopping_bag
          },
          {'key': 'park', 'name': 'Parks', 'icon': Icons.park},
          {'key': 'subway_station', 'name': 'Transit', 'icon': Icons.train},
          {'key': 'restroom', 'name': 'Restroom', 'icon': Icons.wc},
        ]
      },
      {
        'title': 'Services',
        'color': Colors.blue,
        'categories': [
          {
            'key': 'gas_station',
            'name': 'Gas',
            'icon': Icons.local_gas_station
          },
          {'key': 'parking', 'name': 'Parking', 'icon': Icons.local_parking},
          {'key': 'atm', 'name': 'ATM', 'icon': Icons.atm},
          {'key': 'bank', 'name': 'Bank', 'icon': Icons.account_balance},
          {'key': 'pharmacy', 'name': 'Pharmacy', 'icon': Icons.medication},
          {
            'key': 'laundry',
            'name': 'Laundry',
            'icon': Icons.local_laundry_service
          },
        ]
      },
      {
        'title': 'Health & Beauty',
        'color': Colors.purple,
        'categories': [
          {
            'key': 'hospital',
            'name': 'Healthcare',
            'icon': Icons.local_hospital
          },
          {'key': 'gym', 'name': 'Fitness', 'icon': Icons.fitness_center},
          {
            'key': 'beauty_salon',
            'name': 'Beauty',
            'icon': Icons.face_retouching_natural
          },
        ]
      },
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryGroups.map((group) {
            final categories =
                group['categories'] as List<Map<String, dynamic>>;
            final color = group['color'] as Color;

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group header
                  Text(
                    group['title'] as String,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(10),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? _getBrighterColorForDarkMode(color)
                          : color,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Category grid
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category['key'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['key'] as String;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? color : color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? _getBrighterColorForDarkMode(color)
                                        : color),
                              ),
                              SizedBox(width: 3),
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(10),
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? _getBrighterColorForDarkMode(color)
                                          : color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
