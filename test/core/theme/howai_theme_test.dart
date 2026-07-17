import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';

void main() {
  group('HowAITheme', () {
    test('light theme exposes the neutral semantic palette', () {
      final theme = HowAITheme.light();
      final colors = theme.extension<HowAIColors>();

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(colors, isNotNull);
      expect(colors!.surface, const Color(0xFFF3F3F3));
      expect(colors.surfaceStrong, const Color(0xFFE8E8E8));
      expect(colors.textPrimary, const Color(0xFF0D0D0D));
      expect(colors.textSecondary, const Color(0xFF5D5D5D));
      expect(theme.colorScheme.primary, const Color(0xFF0078D4));
      expect(theme.appBarTheme.iconTheme?.color, colors.textPrimary);
    });

    test('dark theme exposes the neutral semantic palette', () {
      final theme = HowAITheme.dark();
      final colors = theme.extension<HowAIColors>();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF212121));
      expect(colors, isNotNull);
      expect(colors!.surface, const Color(0xFF303030));
      expect(colors.surfaceStrong, const Color(0xFF414141));
      expect(colors.textPrimary, const Color(0xFFFFFFFF));
      expect(colors.textSecondary, const Color(0xFFCDCDCD));
      expect(theme.colorScheme.primary, const Color(0xFF4AA8FF));
      expect(theme.appBarTheme.iconTheme?.color, colors.textPrimary);
    });

    test('keeps platform typography and applies the in-app font scale', () {
      final normal = HowAITheme.light();
      final enlarged = HowAITheme.light(fontScale: 1.25);
      final platformDefault = ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ).textTheme.bodyLarge?.fontFamily;

      expect(normal.textTheme.bodyLarge?.fontFamily, platformDefault);
      expect(normal.textTheme.bodyLarge?.fontSize, 16);
      expect(enlarged.textTheme.bodyLarge?.fontSize, 20);
      expect(enlarged.textTheme.titleMedium?.fontSize, 20);
    });

    test('clamps the in-app font scale to the supported range', () {
      expect(
          HowAITheme.light(fontScale: 0.1).textTheme.bodyLarge?.fontSize, 12.8);
      expect(
          HowAITheme.light(fontScale: 4).textTheme.bodyLarge?.fontSize, 25.6);
    });
  });
}
