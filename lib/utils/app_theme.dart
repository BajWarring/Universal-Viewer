import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Map<String, Color> themeColors = {
    'Simple Light': Color(0xFF135BEC),
    'Simple Dark': Color(0xFF135BEC),
    'Pure Black': Color(0xFF135BEC),
    'Material You Dynamic': Color(0xFF6750A4),
    'Ocean Blue': Color(0xFF0EA5E9),
    'Forest Green': Color(0xFF22C55E),
    'Sunset Orange': Color(0xFFF97316),
    'Midnight Purple': Color(0xFFA855F7),
    'Minimal Gray': Color(0xFF64748B),
    'High Contrast': Color(0xFFD97706),
  };

  static const List<String> themeNames = [
    'Simple Light', 'Simple Dark', 'Pure Black', 'Material You Dynamic',
    'Ocean Blue', 'Forest Green', 'Sunset Orange', 'Midnight Purple',
    'Minimal Gray', 'High Contrast',
  ];

  static Color getPrimaryColor(String themeName) =>
      themeColors[themeName] ?? const Color(0xFF135BEC);

  static ThemeData lightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(primary: primaryColor),
      scaffoldBackgroundColor: const Color(0xFFF6F6F8),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF6F6F8),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF475569)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFF8FAFC).withOpacity(0.9),
        indicatorColor: primaryColor.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
    );
  }

  static ThemeData darkTheme(Color primaryColor, {bool isPureBlack = false}) {
    final bgColor = isPureBlack ? Colors.black : const Color(0xFF101622);
    final surfaceColor = isPureBlack ? const Color(0xFF0A0A0A) : const Color(0xFF1D2636);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryColor,
        surface: surfaceColor,
        background: bgColor,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgColor.withOpacity(0.9),
        indicatorColor: primaryColor.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
