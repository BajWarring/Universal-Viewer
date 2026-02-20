import 'package:flutter/material.dart';

class AppTheme {
  // Color tokens extracted directly from the HTML prototype
  static const Map<String, Color> themeColors = {
    "Simple Light": Color(0xFF135BEC),
    "Simple Dark": Color(0xFF135BEC),
    "Pure Black": Color(0xFF135BEC),
    "Material You Dynamic": Color(0xFF6750A4), // Fallback M3 Primary
    "Ocean Blue": Color(0xFF0EA5E9),
    "Forest Green": Color(0xFF22C55E),
    "Sunset Orange": Color(0xFFF97316),
    "Midnight Purple": Color(0xFFA855F7),
    "Minimal Gray": Color(0xFF64748B),
    "High Contrast": Color(0xFFD97706),
  };

  static ThemeData buildTheme({
    required String themeName,
    required Brightness brightness,
    ColorScheme? dynamicColorScheme,
  }) {
    ColorScheme colorScheme;
    
    // 1. Handle Material You Dynamic Color extraction
    if (themeName == "Material You Dynamic" && dynamicColorScheme != null) {
      colorScheme = dynamicColorScheme;
    } else {
      // 2. Generate scheme from seed color
      final seedColor = themeColors[themeName] ?? const Color(0xFF135BEC);
      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );
    }

    // 3. Apply custom Background and Surface overrides from the HTML CSS variables
    if (brightness == Brightness.dark) {
      if (themeName == "Pure Black") {
        colorScheme = colorScheme.copyWith(
          surface: const Color(0xFF000000), // 0 0 0
          surfaceContainer: const Color(0xFF0A0A0A), // 10 10 10
        );
      } else {
        colorScheme = colorScheme.copyWith(
          surface: const Color(0xFF101622), // 16 22 34
          surfaceContainer: const Color(0xFF1D2636), // 29 38 54
        );
      }
    } else {
      colorScheme = colorScheme.copyWith(
        surface: const Color(0xFFF6F6F8), // background-light
        surfaceContainer: const Color(0xFFFFFFFF),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter', // Applying the font family specified in your design
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
