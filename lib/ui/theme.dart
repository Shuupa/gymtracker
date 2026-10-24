import 'package:flutter/material.dart';

class Pal {
  static const bg = Color(0xFF0B0F14);
  static const surface = Color(0xFF121821);
  static const surface2 = Color(0xFF1A2230);
  static const line = Color(0xFF263244);
  static const text = Color(0xFFE8EEF5);
  static const dim = Color(0xFF8A97A8);
  static const ice = Color(0xFF7FD3FF);
  static const ember = Color(0xFFFF6A2B);
  static const hot = Color(0xFFFFC857);
  static const cold = Color(0xFF3A6EA5);
}

/// 0..1 -> холодный сталь -> угли -> раскалённый
Color heatColor(double s) {
  s = s.clamp(0.0, 1.0);
  return s < 0.5
      ? Color.lerp(Pal.cold, Pal.ember, s / 0.5)!
      : Color.lerp(Pal.ember, Pal.hot, (s - 0.5) / 0.5)!;
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: Pal.ember,
    onPrimary: Color(0xFF1A0A02),
    secondary: Pal.ice,
    surface: Pal.surface,
    onSurface: Pal.text,
    surfaceContainerHighest: Pal.surface2,
    outline: Pal.line,
  );
  final radius = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Pal.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Pal.text,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: Pal.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Pal.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Pal.surface2,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.ember, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Pal.dim),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Pal.ember,
      foregroundColor: const Color(0xFF1A0A02),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pal.ember,
        foregroundColor: const Color(0xFF1A0A02),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Pal.ice),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Pal.ember),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Pal.surface2,
      selectedColor: Pal.ember.withValues(alpha: 0.25),
      side: const BorderSide(color: Pal.line),
      labelStyle: const TextStyle(color: Pal.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Pal.surface2,
        foregroundColor: Pal.dim,
        selectedBackgroundColor: Pal.ember.withValues(alpha: 0.25),
        selectedForegroundColor: Pal.hot,
        side: const BorderSide(color: Pal.line),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Pal.line),
    listTileTheme: const ListTileThemeData(iconColor: Pal.ice),
  );
}
