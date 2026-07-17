import 'package:flutter/material.dart';

/// Presentation metadata derived from Google Places type identifiers.
///
/// Keeping this mapping outside the Places coordinator ensures cards, lists,
/// maps, and details use the same category label and fallback artwork.
@immutable
class PlacePresentation {
  const PlacePresentation({
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String description;
  final IconData icon;
  final Color accent;

  factory PlacePresentation.fromTypes(Iterable<String> placeTypes) {
    final types = placeTypes.toSet();

    return PlacePresentation(
      description: _descriptionFor(types),
      icon: _iconFor(types),
      accent: _accentFor(types),
    );
  }

  static String _descriptionFor(Set<String> types) {
    if (_containsAny(types, const {
      'restaurant',
      'food',
      'meal_takeaway',
    })) {
      return '🍽️ Restaurant & Dining';
    }
    if (types.contains('cafe')) return '☕ Coffee Shop & Café';
    if (_containsAny(types, const {'bakery', 'dessert'})) {
      return '🧁 Sweet Food & Bakery';
    }
    if (_containsAny(types, const {'convenience_store', 'ice_cream'})) {
      return '🍦 Ice Cream & Desserts';
    }
    if (_containsAny(types, const {'lodging', 'hotel'})) {
      return '🏨 Accommodation & Lodging';
    }
    if (_containsAny(types, const {'tourist_attraction', 'museum'})) {
      return '🎭 Tourist Attraction & Culture';
    }
    if (_containsAny(types, const {
      'shopping_mall',
      'store',
      'clothing_store',
    })) {
      return '🛍️ Shopping & Retail';
    }
    if (types.contains('parking')) return '🅿️ Parking Garage';
    if (_containsAny(types, const {'hospital', 'doctor'})) {
      return '🏥 Healthcare & Medical';
    }
    if (types.contains('pharmacy')) return '💊 Pharmacy & Medicine';
    if (_containsAny(types, const {'gas_station', 'car_repair'})) {
      return '⛽ Automotive Services';
    }
    if (types.contains('car_wash')) return '🚗 Car Wash & Service';
    if (types.contains('bank')) return '🏦 Banking Services';
    if (types.contains('atm')) return '🏧 ATM & Cash Machine';
    if (_containsAny(types, const {'gym', 'spa'})) {
      return '💪 Health & Fitness';
    }
    if (_containsAny(types, const {'beauty_salon', 'hair_care'})) {
      return '💅 Beauty & Personal Care';
    }
    if (types.contains('laundry')) {
      return '👕 Laundromat & Dry Cleaning';
    }
    if (_containsAny(types, const {'school', 'university'})) {
      return '🎓 Education & Learning';
    }
    if (_containsAny(types, const {'church', 'place_of_worship'})) {
      return '⛪ Places of Worship';
    }
    if (_containsAny(types, const {'park', 'zoo'})) {
      return '🌳 Parks & Recreation';
    }
    if (_containsAny(types, const {'movie_theater', 'night_club'})) {
      return '🎬 Entertainment & Nightlife';
    }
    if (_containsAny(types, const {'subway_station', 'restroom'})) {
      return '🚻 Public Restroom & Facilities';
    }
    return '📍 Local Business';
  }

  static IconData _iconFor(Set<String> types) {
    if (_containsAny(types, const {'restaurant', 'food'})) {
      return Icons.restaurant;
    }
    if (types.contains('cafe')) return Icons.local_cafe;
    if (types.contains('bakery')) return Icons.cake;
    if (types.contains('convenience_store')) return Icons.icecream;
    if (types.contains('lodging')) return Icons.hotel;
    if (types.contains('tourist_attraction')) return Icons.attractions;
    if (_containsAny(types, const {'shopping_mall', 'store'})) {
      return Icons.shopping_bag;
    }
    if (types.contains('parking')) return Icons.local_parking;
    if (types.contains('hospital')) return Icons.local_hospital;
    if (types.contains('pharmacy')) return Icons.medication;
    if (types.contains('gas_station')) return Icons.local_gas_station;
    if (types.contains('car_wash')) return Icons.car_repair;
    if (types.contains('bank')) return Icons.account_balance;
    if (types.contains('atm')) return Icons.atm;
    if (types.contains('gym')) return Icons.fitness_center;
    if (types.contains('beauty_salon')) return Icons.face_retouching_natural;
    if (types.contains('laundry')) return Icons.local_laundry_service;
    if (types.contains('night_club')) return Icons.nightlife;
    if (types.contains('park')) return Icons.park;
    if (types.contains('subway_station')) return Icons.wc;
    return Icons.place;
  }

  static Color _accentFor(Set<String> types) {
    if (_containsAny(types, const {'restaurant', 'food'})) {
      return Colors.orange;
    }
    if (types.contains('cafe')) return Colors.brown;
    if (types.contains('bakery')) return Colors.pink;
    if (types.contains('convenience_store')) return Colors.cyan;
    if (types.contains('lodging')) return Colors.blue;
    if (types.contains('tourist_attraction')) return Colors.purple;
    if (_containsAny(types, const {'shopping_mall', 'store'})) {
      return Colors.green;
    }
    if (types.contains('parking')) return Colors.indigo;
    if (types.contains('hospital')) return Colors.red;
    if (types.contains('pharmacy')) return Colors.red.shade300;
    if (types.contains('gas_station')) return Colors.yellow.shade700;
    if (types.contains('car_wash')) return Colors.teal;
    if (types.contains('bank')) return Colors.blue.shade700;
    if (types.contains('atm')) return Colors.green.shade700;
    if (types.contains('gym')) return Colors.orange.shade700;
    if (types.contains('beauty_salon')) return Colors.pink.shade400;
    if (types.contains('laundry')) return Colors.blue.shade400;
    if (types.contains('night_club')) return Colors.deepPurple;
    if (types.contains('park')) return Colors.green.shade600;
    if (types.contains('subway_station')) return Colors.grey.shade600;
    return const Color(0xFF5856D6);
  }

  static bool _containsAny(Set<String> types, Set<String> candidates) {
    return candidates.any(types.contains);
  }
}
