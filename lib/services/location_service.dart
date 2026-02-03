import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;
  bool _locationPermissionGranted = false;

  // Google Places API key from .env
  String? get _googleApiKey => dotenv.env['GOOGLE_PLACES_API_KEY'];

  // Check and request location permissions
  Future<bool> checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // print('[LocationService] Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // print('[LocationService] Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // print('[LocationService] Location permissions are permanently denied');
      return false;
    }

    _locationPermissionGranted = true;
    // print('[LocationService] Location permission granted');
    return true;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _currentPosition = position;
      // print('[LocationService] Current location: ${position.latitude}, ${position.longitude}');

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      return position;
    } catch (e) {
      // print('[LocationService] Error getting location: $e');
      return null;
    }
  }

  // Convert coordinates to address
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = '${place.locality}, ${place.administrativeArea}, ${place.country}';
        // print('[LocationService] Current address: $_currentAddress');
      }
    } catch (e) {
      // print('[LocationService] Error getting address: $e');
    }
  }

  // Convert address/city name to coordinates using Geocoding API
  Future<Position?> getLocationFromAddress(String address) async {
    try {
      // print('[LocationService] Geocoding address: $address');
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        Position position = Position(
          longitude: location.longitude,
          latitude: location.latitude,
          timestamp: DateTime.now(),
          accuracy: 100.0, // Estimated accuracy for geocoded locations
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        // print('[LocationService] Geocoded successfully: ${position.latitude}, ${position.longitude}');
        return position;
      }
    } catch (e) {
      // print('[LocationService] Geocoding error: $e');
    }

    return null;
  }

  // Search for nearby places using Google Places API (New)
  Future<List<PlaceResult>> searchNearbyPlaces({
    required String query,
    String type = 'restaurant', // restaurant, lodging, tourist_attraction, etc.
    int radius = 5000, // 5km default
    bool openNow = false, // Filter for places that are currently open
    String? customLocation, // Optional: search in different location (city name or address)
  }) async {
    Position? searchPosition;

    if (customLocation != null && customLocation.isNotEmpty) {
      // Search in custom location
      searchPosition = await getLocationFromAddress(customLocation);
      if (searchPosition == null) {
        // print('[LocationService] Failed to geocode custom location: $customLocation');
        return [];
      }
      // print('[LocationService] Using custom location: $customLocation (${searchPosition.latitude}, ${searchPosition.longitude})');
    } else {
      // Use current location (existing behavior)
      if (_currentPosition == null) {
        await getCurrentLocation();
        if (_currentPosition == null) return [];
      }
      searchPosition = _currentPosition;
      // print('[LocationService] Using current location: (${searchPosition!.latitude}, ${searchPosition.longitude})');
    }

    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      // print('[LocationService] Google Places API key not found');
      // print('[LocationService] Available env keys: ${dotenv.env.keys.where((k) => k.contains('GOOGLE')).join(', ')}');
      return [];
    }

    print('[LocationService] API key found: ${_googleApiKey!.substring(0, 10)}...');

    try {
      // Use Google Places API (New) - Text Search
      final String url = 'https://places.googleapis.com/v1/places:searchText';

      // Prepare request body for new Google Places API
      final requestBody = {
        'textQuery': customLocation != null ? '$query in $customLocation' : '$query near me',
        'locationBias': {
          'circle': {
            'center': {
              'latitude': searchPosition!.latitude,
              'longitude': searchPosition.longitude,
            },
            'radius': radius.toDouble(),
          },
        },
        'maxResultCount': 20,
        'languageCode': 'en',
        'rankPreference': 'DISTANCE',
      };

      // Add openNow filter if requested
      if (openNow) {
        requestBody['openNow'] = true;
      }

      print('[LocationService] Searching places (NEW API): $query (type: $type, openNow: $openNow)');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey!,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.photos,places.location,places.regularOpeningHours,places.priceLevel,places.types,places.currentOpeningHours,places.websiteUri,places.nationalPhoneNumber,places.internationalPhoneNumber,places.generativeSummary,places.reviews,places.reservable,places.restroom,places.evChargeOptions,places.parkingOptions,places.allowsDogs,places.goodForChildren,places.accessibilityOptions,places.takeout,places.delivery,places.dineIn,places.curbsidePickup',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['places'] != null) {
          List<PlaceResult> places = [];
          for (var result in data['places']) {
            places.add(PlaceResult.fromNewApiJson(result, searchPosition!));
          }

          // Sort by rating and distance
          places.sort((a, b) {
            // Prioritize rating, then distance
            int ratingCompare = b.rating.compareTo(a.rating);
            if (ratingCompare != 0) return ratingCompare;
            return a.distance.compareTo(b.distance);
          });

          print('[LocationService] Found ${places.length} places');
          return places;
        } else {
          print('[LocationService] No places found in response');
        }
      } else {
        print('[LocationService] HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[LocationService] Error searching places: $e');
    }

    return [];
  }

  // Get place details including MORE photos
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (_googleApiKey == null || _googleApiKey!.isEmpty) return null;

    try {
      final String url = 'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=name,rating,formatted_phone_number,website,opening_hours,reviews,photos'
          '&key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      // print('[LocationService] Error getting place details: $e');
    }

    return null;
  }

  // Get MAXIMUM photos using multiple API strategies
  Future<List<String>> getPlacePhotos(String placeId) async {
    // print('🖼️ [DEBUG] ===== AGGRESSIVE PHOTO COLLECTION for $placeId =====');

    List<String> allPhotos = [];

    // Strategy 1: Legacy Place Details API (best photo source - 5-10 photos)
    final details = await getPlaceDetails(placeId);
    if (details != null && details.photoReferences.isNotEmpty) {
      allPhotos.addAll(details.photoReferences);
      // print('🖼️ [SUCCESS] Legacy Place Details returned ${details.photoReferences.length} photos');
    } else {
      // print('🖼️ [WARNING] Legacy Place Details returned NO photos');
    }

    // Strategy 2: New Place Details API for additional photos
    final newApiPhotos = await getPlaceDetailsNewAPI(placeId);
    if (newApiPhotos.isNotEmpty) {
      // Merge and deduplicate
      Set<String> photoSet = Set<String>.from(allPhotos);
      photoSet.addAll(newApiPhotos);
      allPhotos = photoSet.toList();
      // print('🖼️ [SUCCESS] New Place Details added ${newApiPhotos.length} more photos');
    } else {
      // print('🖼️ [WARNING] New Place Details returned NO additional photos');
    }

    // If still no photos, log critical issue
    if (allPhotos.isEmpty) {
      // print('🖼️ [CRITICAL] NO PHOTOS FOUND for place $placeId - Google may have limited photos for this location');
    } else {
      // print('🖼️ [SUCCESS] ===== TOTAL PHOTOS COLLECTED: ${allPhotos.length} =====');
      // Log first few photo references for debugging
      for (int i = 0; i < allPhotos.length && i < 3; i++) {
        // print('🖼️ [DEBUG] Photo ${i + 1}: ${allPhotos[i]}');
      }
    }

    return allPhotos;
  }

  // New Place Details API call for more photos
  Future<List<String>> getPlaceDetailsNewAPI(String placeId) async {
    if (_googleApiKey == null || _googleApiKey!.isEmpty) return [];

    try {
      final String url = 'https://places.googleapis.com/v1/places/$placeId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey!,
          'X-Goog-FieldMask': 'photos',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['photos'] != null) {
          List<String> photoRefs = (data['photos'] as List).map((p) => p['name'] as String).toList();
          // print('🖼️ [DEBUG] New API Place Details found ${photoRefs.length} photos');
          return photoRefs;
        }
      } else {
        // print('🖼️ [DEBUG] New API Place Details failed: ${response.statusCode}');
      }
    } catch (e) {
      // print('🖼️ [DEBUG] New API Place Details error: $e');
    }

    return [];
  }

  // Generate photo URL from photo reference (supports both old and new API)
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (_googleApiKey == null) return '';

    // Check if this is a new API photo reference (starts with places/)
    if (photoReference.startsWith('places/')) {
      // New API format: use Places Photo API
      return 'https://places.googleapis.com/v1/$photoReference/media'
          '?maxWidthPx=$maxWidth'
          '&key=$_googleApiKey';
    } else {
      // Legacy API format
      return 'https://maps.googleapis.com/maps/api/place/photo'
          '?maxwidth=$maxWidth'
          '&photo_reference=$photoReference'
          '&key=$_googleApiKey';
    }
  }

  // Search for places at a specific location (for map tap functionality)
  Future<List<PlaceResult>> searchNearbyPlacesAtLocation({
    required double latitude,
    required double longitude,
    int radius = 15, // Very small radius for precise location
    String query = 'establishment',
  }) async {
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      // print('[LocationService] Google Places API key not found');
      return [];
    }

    try {
      // First try: Use Google Places Nearby Search API (Legacy) for more accurate location-based results
      final String nearbyUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

      final nearbyParams = {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'key': _googleApiKey!,
        'rankby': 'distance', // This overrides radius but gives better precision
      };

      // Remove radius when using rankby=distance for maximum precision
      nearbyParams.remove('radius');

      final nearbyUriParams = nearbyParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final nearbyResponse = await http.get(Uri.parse('$nearbyUrl?$nearbyUriParams'));

      // print('[LocationService] Searching for places at location: $latitude, $longitude (using legacy nearby search for precision)');

      if (nearbyResponse.statusCode == 200) {
        final nearbyData = json.decode(nearbyResponse.body);

        if (nearbyData['results'] != null && nearbyData['results'].isNotEmpty) {
          List<PlaceResult> places = [];

          // Create a temporary position for parsing
          final searchPosition = Position(
            longitude: longitude,
            latitude: latitude,
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );

          // Take only the closest 3 results for precision
          final limitedResults = nearbyData['results'].take(3).toList();

          for (var result in limitedResults) {
            final place = PlaceResult.fromJson(result, searchPosition);

            // Determine distance threshold based on place type
            double distanceThreshold = 25.0; // Default for small businesses

            // Larger threshold for big venues/landmarks
            final types = place.types;
            if (types.contains('tourist_attraction') ||
                types.contains('stadium') ||
                types.contains('convention_center') ||
                types.contains('shopping_mall') ||
                types.contains('university') ||
                types.contains('hospital') ||
                types.contains('airport') ||
                types.contains('park') ||
                types.contains('museum') ||
                types.contains('establishment')) {
              distanceThreshold = 100.0; // More forgiving for large venues
            }

            if (place.distance <= distanceThreshold) {
              places.add(place);
              // print('[LocationService] Found match: ${place.name} at ${place.distance.toStringAsFixed(1)}m (threshold: ${distanceThreshold}m)');
            } else {
              // print('[LocationService] Rejected: ${place.name} at ${place.distance.toStringAsFixed(1)}m (exceeds ${distanceThreshold}m threshold)');
            }
          }

          // Sort by distance (closest first)
          places.sort((a, b) => a.distance.compareTo(b.distance));

          if (places.isNotEmpty) {
            // print('[LocationService] Found ${places.length} precise places at tapped location');
            return places;
          } else {
            // print('[LocationService] No places found within 25m precision threshold');
          }
        }
      }

      // Fallback: Use New Places API if legacy didn't work
      // print('[LocationService] Fallback to new Places API for tapped location');
      final String url = 'https://places.googleapis.com/v1/places:searchText';

      final requestBody = {
        'textQuery': 'business OR establishment OR tourist_attraction OR convention_center OR museum OR park',
        'locationBias': {
          'circle': {
            'center': {
              'latitude': latitude,
              'longitude': longitude,
            },
            'radius': 50.0, // Larger radius for fallback to catch big venues
          },
        },
        'maxResultCount': 5, // Get more results to find the right one
        'languageCode': 'en',
        'rankPreference': 'DISTANCE',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey!,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.photos,places.location,places.regularOpeningHours,places.priceLevel,places.types,places.currentOpeningHours,places.websiteUri,places.nationalPhoneNumber,places.internationalPhoneNumber,places.generativeSummary,places.reviews',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['places'] != null) {
          List<PlaceResult> places = [];

          final searchPosition = Position(
            longitude: longitude,
            latitude: latitude,
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );

          for (var result in data['places']) {
            final place = PlaceResult.fromNewApiJson(result, searchPosition);

            // Determine distance threshold based on place type
            double distanceThreshold = 20.0; // Default for small businesses

            // Larger threshold for big venues/landmarks
            final types = place.types;
            if (types.contains('tourist_attraction') ||
                types.contains('stadium') ||
                types.contains('convention_center') ||
                types.contains('shopping_mall') ||
                types.contains('university') ||
                types.contains('hospital') ||
                types.contains('airport') ||
                types.contains('park') ||
                types.contains('museum') ||
                types.contains('establishment')) {
              distanceThreshold = 80.0; // More forgiving for large venues
            }

            if (place.distance <= distanceThreshold) {
              places.add(place);
              // print('[LocationService] Fallback found: ${place.name} at ${place.distance.toStringAsFixed(1)}m (threshold: ${distanceThreshold}m)');
            } else {
              // print('[LocationService] Fallback rejected: ${place.name} at ${place.distance.toStringAsFixed(1)}m (exceeds ${distanceThreshold}m threshold)');
            }
          }

          places.sort((a, b) => a.distance.compareTo(b.distance));

          // print('[LocationService] Fallback found ${places.length} places at tapped location');
          return places;
        }
      }
    } catch (e) {
      // print('[LocationService] Error searching places at tapped location: $e');
    }

    return [];
  }

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get hasLocationPermission => _locationPermissionGranted;
}

// Data models
class PlaceResult {
  final String placeId;
  final String name;
  final String address;
  final double rating;
  final int userRatingsTotal;
  final String? photoReference;
  final List<String> photoReferences;
  final double latitude;
  final double longitude;
  final double distance; // in meters
  final bool isOpen;
  final String priceLevel;
  final List<String> types;
  final String? website;
  final String? phoneNumber;
  final List<String> openingHours;
  final String? aiSummary;
  final String? reviewSummary;
  final bool? reservable;
  // New amenities fields
  final bool? hasRestroom;
  final bool? hasEvCharger;
  final bool? hasParking;
  final bool? allowsDogs;
  final bool? goodForChildren;
  // Additional accessibility and service info
  final bool? wheelchairAccessible;
  final bool? takeout;
  final bool? delivery;
  final bool? dineIn;
  final bool? curbsidePickup;

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.rating,
    required this.userRatingsTotal,
    this.photoReference,
    this.photoReferences = const [],
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.isOpen,
    required this.priceLevel,
    required this.types,
    this.website,
    this.phoneNumber,
    required this.openingHours,
    this.aiSummary,
    this.reviewSummary,
    this.reservable,
    // New amenities fields
    this.hasRestroom,
    this.hasEvCharger,
    this.hasParking,
    this.allowsDogs,
    this.goodForChildren,
    // Additional accessibility and service info
    this.wheelchairAccessible,
    this.takeout,
    this.delivery,
    this.dineIn,
    this.curbsidePickup,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json, Position userPosition) {
    double lat = json['geometry']['location']['lat'].toDouble();
    double lng = json['geometry']['location']['lng'].toDouble();

    // Calculate distance from user
    double distance = Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, lat, lng);

    // Get price level
    String priceLevel = 'Unknown';
    if (json['price_level'] != null) {
      int level = json['price_level'];
      switch (level) {
        case 0:
          priceLevel = 'Free';
          break;
        case 1:
          priceLevel = '\$';
          break;
        case 2:
          priceLevel = '\$\$';
          break;
        case 3:
          priceLevel = '\$\$\$';
          break;
        case 4:
          priceLevel = '\$\$\$\$';
          break;
      }
    }

    // Debug: Print photos data to see what's available
    if (json['photos'] != null) {
      // print('🖼️ [DEBUG] Legacy API Found ${json['photos'].length} photos for ${json['name']}');
      for (int i = 0; i < json['photos'].length; i++) {
        // print('🖼️ [DEBUG] Legacy Photo $i: ${json['photos'][i]}');
      }
    } else {
      // print('🖼️ [DEBUG] Legacy API No photos found for ${json['name']}');
    }

    return PlaceResult(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['vicinity'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? 0,
      photoReference: json['photos']?.isNotEmpty == true ? json['photos'][0]['photo_reference'] : null,
      photoReferences: json['photos'] != null ? (json['photos'] as List).map((p) => p['photo_reference'] as String).toList() : [],
      latitude: lat,
      longitude: lng,
      distance: distance,
      isOpen: json['opening_hours']?['open_now'] ?? false,
      priceLevel: priceLevel,
      types: List<String>.from(json['types'] ?? []),
      website: null,
      phoneNumber: null,
      openingHours: [],
      aiSummary: null,
      reviewSummary: null,
      reservable: null,
      // Legacy API doesn't have these fields
      hasRestroom: null,
      hasEvCharger: null,
      hasParking: null,
      allowsDogs: null,
      goodForChildren: null,
      wheelchairAccessible: null,
      takeout: null,
      delivery: null,
      dineIn: null,
      curbsidePickup: null,
    );
  }

  String get distanceText {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Get distance text with locale-aware unit conversion
  String getDistanceText({String? locale, String? countryCode}) {
    // Determine if user is in a country that uses imperial units
    bool useImperial = _shouldUseImperialUnits(locale: locale, countryCode: countryCode);

    if (useImperial) {
      // Convert meters to feet/miles
      double feet = distance * 3.28084;

      if (feet < 1000) {
        // Show in feet for distances under 1000 feet
        return '${feet.round()}ft';
      } else {
        // Convert to miles for longer distances
        double miles = distance * 0.000621371;
        if (miles < 0.1) {
          // For very short distances in miles, show one decimal
          return '${miles.toStringAsFixed(2)}mi';
        } else {
          return '${miles.toStringAsFixed(1)}mi';
        }
      }
    } else {
      // Use metric (default behavior)
      if (distance < 1000) {
        return '${distance.round()}m';
      } else {
        return '${(distance / 1000).toStringAsFixed(1)}km';
      }
    }
  }

  /// Determine if imperial units should be used based on locale/country
  static bool _shouldUseImperialUnits({String? locale, String? countryCode}) {
    // Countries that primarily use imperial units
    const imperialCountries = {
      'US', // United States
      'LR', // Liberia
      'MM', // Myanmar (partially)
    };

    // Check country code first (most reliable)
    if (countryCode != null) {
      final countryUpper = countryCode.toUpperCase();
      bool isImperial = imperialCountries.contains(countryUpper);
      return isImperial;
    }

    // Fallback to locale analysis
    if (locale != null) {
      final localeUpper = locale.toUpperCase();

      // Check for US English variants
      if (localeUpper.contains('US') || localeUpper == 'EN_US' || localeUpper == 'EN-US') {
        return true;
      }
      // Check for Liberia
      if (localeUpper.contains('LR') || localeUpper.contains('LIBERIA')) {
        return true;
      }
    }

    // Additional fallback: Check timezone (US timezones indicate US location)
    try {
      final timeZone = DateTime.now().timeZoneName;
      final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;

      // US timezone names and offsets
      const usTimeZones = {
        'PST', 'PDT', // Pacific
        'MST', 'MDT', // Mountain
        'CST', 'CDT', // Central
        'EST', 'EDT', // Eastern
        'AKST', 'AKDT', // Alaska
        'HST', 'HDT', // Hawaii
      };

      // Check timezone name
      if (usTimeZones.contains(timeZone)) {
        return true;
      }

      // Check timezone offset (US mainland is UTC-5 to UTC-8, Alaska UTC-9, Hawaii UTC-10)
      if (timeZoneOffset >= -10 && timeZoneOffset <= -5) {
        return true;
      }
    } catch (e) {
      // Silent fallback if timezone check fails
    }

    return false; // Default to metric
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'photoReference': photoReference,
      'photoReferences': photoReferences,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'isOpen': isOpen,
      'priceLevel': priceLevel,
      'types': types,
      'website': website,
      'phoneNumber': phoneNumber,
      'openingHours': openingHours,
      'aiSummary': aiSummary,
      'reviewSummary': reviewSummary,
      'reservable': reservable,
      'hasRestroom': hasRestroom,
      'hasEvCharger': hasEvCharger,
      'hasParking': hasParking,
      'allowsDogs': allowsDogs,
      'goodForChildren': goodForChildren,
      'wheelchairAccessible': wheelchairAccessible,
      'takeout': takeout,
      'delivery': delivery,
      'dineIn': dineIn,
      'curbsidePickup': curbsidePickup,
    };
  }

  factory PlaceResult.fromNewApiJson(Map<String, dynamic> json, Position userPosition) {
    double lat = json['location']?['latitude']?.toDouble() ?? 0.0;
    double lng = json['location']?['longitude']?.toDouble() ?? 0.0;

    // Calculate distance from user
    double distance = Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, lat, lng);

    // Get price level (new API format)
    String priceLevel = 'Unknown';
    if (json['priceLevel'] != null) {
      String level = json['priceLevel'];
      switch (level) {
        case 'PRICE_LEVEL_FREE':
          priceLevel = 'Free';
          break;
        case 'PRICE_LEVEL_INEXPENSIVE':
          priceLevel = '\$';
          break;
        case 'PRICE_LEVEL_MODERATE':
          priceLevel = '\$\$';
          break;
        case 'PRICE_LEVEL_EXPENSIVE':
          priceLevel = '\$\$\$';
          break;
        case 'PRICE_LEVEL_VERY_EXPENSIVE':
          priceLevel = '\$\$\$\$';
          break;
      }
    }

    // Check if open (new API format)
    bool isOpen = false;
    if (json['currentOpeningHours'] != null) {
      isOpen = json['currentOpeningHours']['openNow'] ?? false;
    } else if (json['regularOpeningHours'] != null) {
      isOpen = json['regularOpeningHours']['openNow'] ?? false;
    }

    // Parse opening hours
    List<String> openingHours = [];
    if (json['regularOpeningHours']?['weekdayDescriptions'] != null) {
      openingHours = List<String>.from(json['regularOpeningHours']['weekdayDescriptions']);
    }

    // Get website
    String? website = json['websiteUri'];

    // Get phone number
    String? phoneNumber = json['nationalPhoneNumber'] ?? json['internationalPhoneNumber'];

    // Get AI summary
    String? aiSummary = json['generativeSummary']?['overview']?['text'];

    // Get review summary (AI-generated)
    String? reviewSummary;
    if (json['reviews'] != null && json['reviews'].isNotEmpty) {
      // For now, create a simple summary from existing reviews
      // In future, Google might provide AI-generated review summaries
      List<dynamic> reviews = json['reviews'];
      if (reviews.length > 0) {
        reviewSummary = "Based on ${reviews.length} review${reviews.length > 1 ? 's' : ''}, visitors mention key themes and experiences.";
      }
    }

    // Get reservation capability
    bool? reservable = json['reservable'];

    // Parse amenities and accessibility
    bool? hasRestroom = json['restroom'];
    bool? hasEvCharger = json['evChargeOptions'] != null;
    bool? hasParking = json['parkingOptions'] != null;
    bool? allowsDogs = json['allowsDogs'];
    bool? goodForChildren = json['goodForChildren'];
    bool? wheelchairAccessible = json['accessibilityOptions']?['wheelchairAccessibleEntrance'];
    bool? takeout = json['takeout'];
    bool? delivery = json['delivery'];
    bool? dineIn = json['dineIn'];
    bool? curbsidePickup = json['curbsidePickup'];

    // Debug: Print photos data to see what's available
    if (json['photos'] != null) {
      // print('🖼️ [DEBUG] Found ${json['photos'].length} photos for ${json['displayName']?['text']}');
      for (int i = 0; i < json['photos'].length; i++) {
        // print('🖼️ [DEBUG] Photo $i: ${json['photos'][i]}');
      }
    } else {
      // print('🖼️ [DEBUG] No photos found for ${json['displayName']?['text']}');
    }

    return PlaceResult(
      placeId: json['id'] ?? '',
      name: json['displayName']?['text'] ?? 'Unknown',
      address: json['formattedAddress'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      userRatingsTotal: json['userRatingCount'] ?? 0,
      photoReference: json['photos']?.isNotEmpty == true ? json['photos'][0]['name'] : null,
      photoReferences: json['photos'] != null ? (json['photos'] as List).map((p) => p['name'] as String).toList() : [],
      latitude: lat,
      longitude: lng,
      distance: distance,
      isOpen: isOpen,
      priceLevel: priceLevel,
      types: json['types'] != null ? List<String>.from(json['types']) : [],
      website: website,
      phoneNumber: phoneNumber,
      openingHours: openingHours,
      aiSummary: aiSummary,
      reviewSummary: reviewSummary,
      reservable: reservable,
      // New amenities fields
      hasRestroom: hasRestroom,
      hasEvCharger: hasEvCharger,
      hasParking: hasParking,
      allowsDogs: allowsDogs,
      goodForChildren: goodForChildren,
      // Additional accessibility and service info
      wheelchairAccessible: wheelchairAccessible,
      takeout: takeout,
      delivery: delivery,
      dineIn: dineIn,
      curbsidePickup: curbsidePickup,
    );
  }

  factory PlaceResult.fromStoredJson(Map<String, dynamic> json) {
    return PlaceResult(
      placeId: json['placeId'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      userRatingsTotal: json['userRatingsTotal'] ?? 0,
      photoReference: json['photoReference'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      isOpen: json['isOpen'] ?? false,
      priceLevel: json['priceLevel'] ?? 'Unknown',
      types: List<String>.from(json['types'] ?? []),
      website: json['website'],
      phoneNumber: json['phoneNumber'],
      openingHours: json['openingHours'] != null ? List<String>.from(json['openingHours']) : [],
      aiSummary: json['aiSummary'],
      reviewSummary: json['reviewSummary'],
      reservable: json['reservable'],
      hasRestroom: json['hasRestroom'],
      hasEvCharger: json['hasEvCharger'],
      hasParking: json['hasParking'],
      allowsDogs: json['allowsDogs'],
      goodForChildren: json['goodForChildren'],
      wheelchairAccessible: json['wheelchairAccessible'],
      takeout: json['takeout'],
      delivery: json['delivery'],
      dineIn: json['dineIn'],
      curbsidePickup: json['curbsidePickup'],
    );
  }
}

class PlaceDetails {
  final String name;
  final double rating;
  final String? phoneNumber;
  final String? website;
  final List<String> openingHours;
  final List<PlaceReview> reviews;
  final List<String> photoReferences;

  PlaceDetails({
    required this.name,
    required this.rating,
    this.phoneNumber,
    this.website,
    required this.openingHours,
    required this.reviews,
    required this.photoReferences,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      openingHours: json['opening_hours']?['weekday_text'] != null ? List<String>.from(json['opening_hours']['weekday_text']) : [],
      reviews: json['reviews'] != null ? (json['reviews'] as List).map((r) => PlaceReview.fromJson(r)).toList() : [],
      photoReferences: json['photos'] != null ? (json['photos'] as List).map((p) => p['photo_reference'] as String).toList() : [],
    );
  }
}

class PlaceReview {
  final String authorName;
  final int rating;
  final String text;
  final String relativeTime;

  PlaceReview({
    required this.authorName,
    required this.rating,
    required this.text,
    required this.relativeTime,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      authorName: json['author_name'] ?? '',
      rating: json['rating'] ?? 0,
      text: json['text'] ?? '',
      relativeTime: json['relative_time_description'] ?? '',
    );
  }
}
