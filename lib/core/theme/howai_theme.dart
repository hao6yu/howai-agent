import 'package:flutter/material.dart';

/// Semantic colors used by HowAI surfaces.
///
/// Widgets should prefer these tokens (or the matching [ColorScheme] role)
/// over checking brightness and choosing a hard-coded color themselves.
@immutable
class HowAIColors extends ThemeExtension<HowAIColors> {
  const HowAIColors({
    required this.canvas,
    required this.surface,
    required this.surfaceStrong,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const light = HowAIColors(
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F3F3),
    surfaceStrong: Color(0xFFE8E8E8),
    divider: Color(0xFFE8E8E8),
    textPrimary: Color(0xFF0D0D0D),
    textSecondary: Color(0xFF5D5D5D),
    textTertiary: Color(0xFF8F8F8F),
    accent: Color(0xFF0078D4),
    accentSoft: Color(0xFFE6F2FA),
    success: Color(0xFF008635),
    warning: Color(0xFFE25507),
    danger: Color(0xFFE02E2A),
  );

  static const dark = HowAIColors(
    canvas: Color(0xFF212121),
    surface: Color(0xFF303030),
    surfaceStrong: Color(0xFF414141),
    divider: Color(0xFF414141),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFCDCDCD),
    textTertiary: Color(0xFFAFAFAF),
    accent: Color(0xFF4AA8FF),
    accentSoft: Color(0xFF183B56),
    success: Color(0xFF40C977),
    warning: Color(0xFFFF9E6C),
    danger: Color(0xFFFF8583),
  );

  final Color canvas;
  final Color surface;
  final Color surfaceStrong;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warning;
  final Color danger;

  @override
  HowAIColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceStrong,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return HowAIColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  HowAIColors lerp(covariant HowAIColors? other, double t) {
    if (other == null) return this;
    return HowAIColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class HowAITheme {
  const HowAITheme._();

  static ThemeData light({double fontScale = 1}) =>
      _build(Brightness.light, fontScale);

  static ThemeData dark({double fontScale = 1}) =>
      _build(Brightness.dark, fontScale);

  static ThemeData _build(Brightness brightness, double fontScale) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? HowAIColors.dark : HowAIColors.light;
    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
      primary: colors.accent,
      onPrimary: Colors.white,
      primaryContainer: colors.accentSoft,
      onPrimaryContainer: colors.accent,
      secondary: colors.accent,
      onSecondary: Colors.white,
      secondaryContainer: colors.accentSoft,
      onSecondaryContainer: colors.textPrimary,
      error: colors.danger,
      onError: isDark ? colors.canvas : Colors.white,
      errorContainer: colors.danger.withValues(alpha: isDark ? 0.20 : 0.10),
      onErrorContainer: colors.danger,
      surface: colors.canvas,
      onSurface: colors.textPrimary,
      surfaceDim: colors.surfaceStrong,
      surfaceBright: colors.canvas,
      surfaceContainerLowest: colors.canvas,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surfaceStrong,
      surfaceContainerHighest: colors.surfaceStrong,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.textTertiary,
      outlineVariant: colors.divider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface:
          isDark ? HowAIColors.light.canvas : HowAIColors.dark.canvas,
      onInverseSurface:
          isDark ? HowAIColors.light.textPrimary : HowAIColors.dark.textPrimary,
      inversePrimary:
          isDark ? HowAIColors.light.accent : HowAIColors.dark.accent,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
    );
    final textTheme = _scaledTextTheme(base.textTheme, colors, fontScale);

    return base.copyWith(
      scaffoldBackgroundColor: colors.canvas,
      canvasColor: colors.canvas,
      cardColor: colors.surface,
      dividerColor: colors.divider,
      splashColor: colors.textPrimary.withValues(alpha: 0.06),
      highlightColor: colors.textPrimary.withValues(alpha: 0.04),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textSecondary, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 22),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.canvas,
        modalBackgroundColor: colors.canvas,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.textTertiary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textTertiary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        border: _inputBorder(colors.divider),
        enabledBorder: _inputBorder(colors.divider),
        focusedBorder: _inputBorder(colors.accent, width: 1.4),
        errorBorder: _inputBorder(colors.danger),
        focusedErrorBorder: _inputBorder(colors.danger, width: 1.4),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        selectedColor: colors.textPrimary,
        selectedTileColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.canvas,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? colors.surfaceStrong : HowAIColors.dark.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.canvas,
          disabledBackgroundColor: colors.surfaceStrong,
          disabledForegroundColor: colors.textTertiary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(48, 44),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.divider),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(48, 44),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textTertiary,
          highlightColor: colors.surfaceStrong,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? colors.surfaceStrong : colors.textPrimary,
        foregroundColor: isDark ? colors.textPrimary : colors.canvas,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.canvas
              : colors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.surfaceStrong,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : colors.divider,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.textPrimary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colors.canvas),
        side: BorderSide(color: colors.textTertiary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.textPrimary
              : colors.textTertiary,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: colors.textSecondary,
        collapsedIconColor: colors.textTertiary,
        textColor: colors.textPrimary,
        collapsedTextColor: colors.textPrimary,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surface,
        selectedColor: colors.surfaceStrong,
        side: BorderSide(color: colors.divider),
        labelStyle: textTheme.labelMedium?.copyWith(color: colors.textPrimary),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.surfaceStrong,
        circularTrackColor: colors.surfaceStrong,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceStrong : HowAIColors.dark.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _scaledTextTheme(
    TextTheme base,
    HowAIColors colors,
    double fontScale,
  ) {
    final scale = fontScale.clamp(0.8, 1.6);
    TextStyle? style(
      TextStyle? source,
      double size, {
      Color? color,
      FontWeight? weight,
      double? height,
    }) {
      return source?.copyWith(
        fontSize: size * scale,
        color: color ?? colors.textPrimary,
        fontWeight: weight,
        height: height,
      );
    }

    return base.copyWith(
      displayLarge: style(base.displayLarge, 44, weight: FontWeight.w600),
      displayMedium: style(base.displayMedium, 40, weight: FontWeight.w600),
      displaySmall: style(base.displaySmall, 36, weight: FontWeight.w600),
      headlineLarge: style(base.headlineLarge, 32, weight: FontWeight.w600),
      headlineMedium: style(base.headlineMedium, 28, weight: FontWeight.w600),
      headlineSmall: style(base.headlineSmall, 24, weight: FontWeight.w600),
      titleLarge: style(base.titleLarge, 22, weight: FontWeight.w600),
      titleMedium: style(base.titleMedium, 16, weight: FontWeight.w600),
      titleSmall: style(base.titleSmall, 14, weight: FontWeight.w600),
      bodyLarge: style(base.bodyLarge, 16, height: 1.45),
      bodyMedium: style(base.bodyMedium, 14, height: 1.45),
      bodySmall: style(
        base.bodySmall,
        12,
        color: colors.textSecondary,
        height: 1.4,
      ),
      labelLarge: style(base.labelLarge, 14, weight: FontWeight.w600),
      labelMedium: style(
        base.labelMedium,
        12,
        color: colors.textSecondary,
        weight: FontWeight.w500,
      ),
      labelSmall: style(
        base.labelSmall,
        11,
        color: colors.textTertiary,
        weight: FontWeight.w500,
      ),
    );
  }
}

extension HowAIThemeContext on BuildContext {
  HowAIColors get howaiColors {
    return Theme.of(this).extension<HowAIColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? HowAIColors.dark
            : HowAIColors.light);
  }
}
