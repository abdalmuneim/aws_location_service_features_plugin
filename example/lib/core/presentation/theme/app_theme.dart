import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// AWS "squid ink" navy and smile orange.
  static const Color seed = Color(0xFF232F3E);
  static const Color accent = Color(0xFFFF9900);

  /// Bundled font for Arabic; the default fonts have no Arabic glyphs.
  static const String arabicFontFamily = 'Cairo';

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  /// [theme] adjusted for the UI language: Arabic text uses
  /// [arabicFontFamily], every other language keeps the platform font.
  static ThemeData forLocale(ThemeData theme, Locale locale) {
    if (locale.languageCode != 'ar') return theme;
    return theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: arabicFontFamily),
      primaryTextTheme: theme.primaryTextTheme.apply(
        fontFamily: arabicFontFamily,
      ),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      secondary: accent,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
      chipTheme: const ChipThemeData(showCheckmark: false),
    );
  }
}

/// Fixed palette for drawing on the map (readable on light and dark styles).
abstract final class MapColors {
  static const Color primary = Color(0xFF1A73E8);
  static const Color alternative = Color(0xFF8E9AAF);
  static const Color origin = Color(0xFF0F9D58);
  static const Color destination = Color(0xFFDB4437);
  static const Color waypoint = Color(0xFFF4B400);
  static const Color result = Color(0xFFE8710A);
  static const Color device = Color(0xFF4285F4);
  static const Color trace = Color(0xFFD93025);

  /// Graded colors for nested isolines, inner to outer.
  static const List<Color> ramp = [
    Color(0xFF1B9E77),
    Color(0xFF66A61E),
    Color(0xFFE6AB02),
    Color(0xFFD95F02),
    Color(0xFFE7298A),
  ];

  static const List<Color> geofences = [
    Color(0xFF7B1FA2),
    Color(0xFF00897B),
    Color(0xFFC62828),
    Color(0xFF1565C0),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
  ];
}
