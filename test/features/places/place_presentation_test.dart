import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/features/places/presentation/place_presentation.dart';

void main() {
  group('PlacePresentation', () {
    test('uses the established category priority order', () {
      final presentation = PlacePresentation.fromTypes(
        const ['park', 'restaurant', 'food'],
      );

      expect(presentation.description, '🍽️ Restaurant & Dining');
      expect(presentation.icon, Icons.restaurant);
      expect(presentation.accent, Colors.orange);
    });

    test('keeps related place types on the same user-facing category', () {
      expect(
        PlacePresentation.fromTypes(const ['meal_takeaway']).description,
        '🍽️ Restaurant & Dining',
      );
      expect(
        PlacePresentation.fromTypes(const ['hair_care']).description,
        '💅 Beauty & Personal Care',
      );
      expect(
        PlacePresentation.fromTypes(const ['place_of_worship']).description,
        '⛪ Places of Worship',
      );
    });

    test('provides neutral metadata for unknown and empty type lists', () {
      final unknown = PlacePresentation.fromTypes(const ['establishment']);
      final empty = PlacePresentation.fromTypes(const []);

      expect(unknown.description, '📍 Local Business');
      expect(unknown.icon, Icons.place);
      expect(unknown.accent, const Color(0xFF5856D6));
      expect(empty.description, unknown.description);
      expect(empty.icon, unknown.icon);
      expect(empty.accent, unknown.accent);
    });
  });
}
