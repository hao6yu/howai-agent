import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/profile_name_service.dart';

void main() {
  group('ProfileNameService.normalizeDisplayName', () {
    test('rejects blank and fallback names regardless of casing', () {
      expect(ProfileNameService.normalizeDisplayName(null), isNull);
      expect(ProfileNameService.normalizeDisplayName('   '), isNull);
      expect(ProfileNameService.normalizeDisplayName('User'), isNull);
      expect(ProfileNameService.normalizeDisplayName('  uSeR  '), isNull);
    });

    test('normalizes an explicitly supplied preferred name', () {
      expect(
        ProfileNameService.normalizeDisplayName('  Hao \n Yu  '),
        'Hao Yu',
      );
      expect(ProfileNameService.normalizeDisplayName('小雨'), '小雨');
    });

    test('rejects oversized and control-character values', () {
      expect(
        ProfileNameService.normalizeDisplayName(List.filled(81, 'a').join()),
        isNull,
      );
      expect(ProfileNameService.normalizeDisplayName('Hao\u0000Yu'), isNull);
    });
  });

  test('profile tool requires an explicit set or decline action', () {
    final tool = ProfileNameService.toolDefinition();
    final parameters = tool['parameters']! as Map<String, dynamic>;
    final properties =
        parameters['properties']! as Map<String, dynamic>;
    final action = properties['action']! as Map<String, dynamic>;

    expect(tool['strict'], isTrue);
    expect(action['enum'], ['set', 'decline']);
    expect(parameters['required'], ['action', 'display_name']);
    expect(parameters['additionalProperties'], isFalse);
  });
}
