import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final String themeName;
  final ThemeMode themeMode;
  
  const ThemeState({
    this.themeName = 'Simple Light',
    this.themeMode = ThemeMode.system,
  });

  ThemeState copyWith({String? themeName, ThemeMode? themeMode}) {
    return ThemeState(
      themeName: themeName ?? this.themeName,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // In Phase 5, we will load the saved settings from shared_preferences/Drift here.
    return const ThemeState();
  }

  void setThemeName(String name) {
    state = state.copyWith(themeName: name);
    
    // Automatically adjust the ThemeMode based on the specific Pure Black and Light overrides
    if (name == 'Simple Light') {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else if (name == 'Simple Dark' || name == 'Pure Black') {
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
}

// Global provider for the UI to listen to
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});
