import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final String themeName;
  final ThemeMode themeMode;

  const ThemeState({
    this.themeName = 'Simple Dark',
    this.themeMode = ThemeMode.dark,
  });

  ThemeState copyWith({String? themeName, ThemeMode? themeMode}) {
    return ThemeState(themeName: themeName ?? this.themeName, themeMode: themeMode ?? this.themeMode);
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  static const List<String> allThemes = [
    "Simple Light", "Simple Dark", "Pure Black", "Material You Dynamic",
    "Ocean Blue", "Forest Green", "Sunset Orange", "Midnight Purple", "Minimal Gray", "High Contrast",
  ];

  @override
  ThemeState build() => const ThemeState();

  void setThemeName(String name) {
    ThemeMode mode = state.themeMode;
    if (name == 'Simple Light') {
      mode = ThemeMode.light;
    } else if (name == 'Simple Dark' || name == 'Pure Black') {
      mode = ThemeMode.dark;
    }
    state = ThemeState(themeName: name, themeMode: mode);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() => ThemeNotifier());
