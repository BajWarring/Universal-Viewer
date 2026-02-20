import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents the current user settings
class SettingsState {
  final Map<String, dynamic> values;

  const SettingsState({required this.values});

  SettingsState copyWith(String key, dynamic value) {
    final newValues = Map<String, dynamic>.from(values);
    newValues[key] = value;
    return SettingsState(values: newValues);
  }
  
  dynamic get(String key) => values[key];
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // These match the 'defaultSettings' from your HTML
    return const SettingsState(
      values: {
        'theme': 'Simple Light',
        'darkMode': false,
        'animationIntensity': 'Full',
        'layoutDensity': 'Comfortable',
        'iconSize': 'Medium',
        'enableThumbnails': true,
        'showHiddenFiles': false,
        'confirmDelete': true,
        'largeFileThreshold': 500,
        // Add the rest of your defaults here...
      },
    );
  }

  void updateSetting(String key, dynamic value) {
    state = state.copyWith(key, value);
    // TODO: Save to SharedPreferences/Drift here
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
