import 'package:flutter/material.dart';

class Pal {
  // Winter Arc — базовая палитра
  static const bg = Color(0xFF090C11);
  static const surface = Color(0xFF121720);
  static const surface2 = Color(0xFF1A2230);
  static const line = Color(0xFF293444);

  static const text = Color(0xFFEAF1F8);
  static const dim = Color(0xFF8998AA);

  // Основной ледяной акцент
  static const ice = Color(0xFF9BD4FF);
  static const ember = Color(0xFF80BEF5);
  static const cold = Color(0xFF426D9F);

  // Предупреждения и высокие значения на карте мышц
  static const hot = Color(0xFFE56B75);
}

Color heatColor(double s) {
  s = s.clamp(0.0, 1.0);

  if (s < 0.5) {
    return Color.lerp(Pal.cold, Pal.ice, s / 0.5)!;
  }

  return Color.lerp(Pal.ice, Pal.hot, (s - 0.5) / 0.5)!;
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: Pal.ember,
    onPrimary: Color(0xFF07111C),
    secondary: Pal.ice,
    onSecondary: Color(0xFF07111C),
    surface: Pal.surface,
    onSurface: Pal.text,
    surfaceContainerHighest: Pal.surface2,
    outline: Pal.line,
    error: Pal.hot,
    onError: Color(0xFF20090C),
  );

  final radius = BorderRadius.circular(16);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Pal.text,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        color: Pal.text,
        fontSize: 25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: Pal.text,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: Pal.text,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: Pal.text, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: Pal.text, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: Pal.dim, fontSize: 12, height: 1.35),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Pal.bg,
      foregroundColor: Pal.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Pal.text,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: Pal.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Pal.line, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Pal.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.ice, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.hot),
      ),
      labelStyle: const TextStyle(color: Pal.dim),
      hintStyle: const TextStyle(color: Pal.dim),
      prefixIconColor: Pal.dim,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Pal.ice,
      foregroundColor: const Color(0xFF07111C),
      elevation: 2,
      highlightElevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pal.ice,
        foregroundColor: const Color(0xFF07111C),
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Pal.ice,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: Pal.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Pal.ice,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Pal.ice),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Pal.surface2,
      selectedColor: Pal.ice.withValues(alpha: 0.16),
      side: const BorderSide(color: Pal.line),
      labelStyle: const TextStyle(
        color: Pal.text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),

    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Pal.surface2,
        foregroundColor: Pal.dim,
        selectedBackgroundColor: Pal.ice,
        selectedForegroundColor: const Color(0xFF07111C),
        side: const BorderSide(color: Pal.line),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Pal.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Pal.line),
      ),
      titleTextStyle: const TextStyle(
        color: Pal.text,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: const TextStyle(
        color: Pal.dim,
        fontSize: 14,
        height: 1.45,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: Pal.surface2,
      contentTextStyle: const TextStyle(color: Pal.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Pal.line),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Pal.ice,
      linearTrackColor: Pal.line,
    ),

    dividerTheme: const DividerThemeData(
      color: Pal.line,
      thickness: 1,
      space: 1,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: Pal.ice,
      textColor: Pal.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}
