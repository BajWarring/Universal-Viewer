import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // HTML Prototype exact animation curves
  static const Curve emphasizedCurve = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Duration standardDuration = Duration(milliseconds: 200);
  static const Duration modalDuration = Duration(milliseconds: 300);

  static const Map<String, Color> themeColors = {
    "Simple Light": Color(0xFF135BEC),
    "Simple Dark": Color(0xFF135BEC),
    "Pure Black": Color(0xFF135BEC),
    "Material You Dynamic": Color(0xFF6750A4),
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

    if (themeName == "Material You Dynamic" && dynamicColorScheme != null) {
      colorScheme = dynamicColorScheme;
    } else {
      final seedColor = themeColors[themeName] ?? const Color(0xFF135BEC);
      colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    }

    // Exact color mapping from HTML Prototype CSS Variables
    if (brightness == Brightness.dark) {
      if (themeName == "Pure Black") {
        colorScheme = colorScheme.copyWith(
          surface: const Color(0xFF000000),
          surfaceContainer: const Color(0xFF0A0A0A),
          surfaceContainerHighest: const Color(0xFF141414),
        );
      } else {
        colorScheme = colorScheme.copyWith(
          surface: const Color(0xFF101622), // --color-bg-dark
          surfaceContainer: const Color(0xFF1D2636), // --color-surface-dark
          surfaceContainerHighest: const Color(0xFF243041),
        );
      }
    } else {
      colorScheme = colorScheme.copyWith(
        surface: const Color(0xFFF6F6F8), // background-light
        surfaceContainer: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFFEEEEF2),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // mapped to xl
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary);
          }
          return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
        }),
      ),
      cardTheme: CardTheme(
        elevation: 0, // soft elevation handled via shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // mapped to lg
        color: colorScheme.surfaceContainer,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // mapped to xl
        backgroundColor: colorScheme.surfaceContainer,
      ),
    );
  }
}
