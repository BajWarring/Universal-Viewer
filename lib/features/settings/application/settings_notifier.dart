import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final Map<String, dynamic> values;
  const SettingsState({required this.values});

  SettingsState copyWith(String key, dynamic value) {
    final n = Map<String, dynamic>.from(values); 
    n[key] = value; 
    return SettingsState(values: n);
  }
  
  dynamic get(String key) => values[key];
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState(values: {
    'theme': 'Simple Dark', 'darkMode': true, 'animationIntensity': 'Full',
    'layoutDensity': 'Comfortable', 'iconSize': 'Medium', 'enableThumbnails': true,
    'showHiddenFiles': false, 'confirmDelete': true, 'largeFileThreshold': 500,
    'defaultLayout': 'List', 'showFileSize': true, 'showDateModified': true,
    'searchSubfolders': true, 'hapticFeedback': true,
    // NEW: Add the default mode here
    'mediaUiMode': 'popup_mode', 
  });

  void updateSetting(String key, dynamic value) { 
    state = state.copyWith(key, value); 
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() => SettingsNotifier());
