import 'package:flutter/material.dart';

enum SettingType { toggle, dropdown, slider, button, themePicker, header, text }

class SettingItem {
  final SettingType type;
  final String id;
  final String label;
  final List<String>? options;
  final double? min;
  final double? max;
  const SettingItem({required this.type, required this.id, required this.label, this.options, this.min, this.max});
}

class SettingsCategory {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final List<SettingItem> items;
  const SettingsCategory({required this.id, required this.title, required this.desc, required this.icon, required this.items});
}

final List<SettingsCategory> appSettingsSchema = [
  const SettingsCategory(id: 'appearance', title: 'Appearance & Themes', desc: 'Visual identity and feel', icon: Icons.palette_outlined, items: [
    SettingItem(type: SettingType.themePicker, id: 'theme', label: 'Theme', options: ["Simple Light", "Simple Dark", "Pure Black", "Material You Dynamic", "Ocean Blue", "Forest Green", "Sunset Orange", "Midnight Purple", "Minimal Gray", "High Contrast"]),
    SettingItem(type: SettingType.toggle, id: 'darkMode', label: 'Dark mode'),
    SettingItem(type: SettingType.dropdown, id: 'animationIntensity', label: 'Animation intensity', options: ["Full", "Reduced"]),
    SettingItem(type: SettingType.dropdown, id: 'layoutDensity', label: 'Layout density', options: ["Comfortable", "Compact"]),
    SettingItem(type: SettingType.dropdown, id: 'iconSize', label: 'Icon size', options: ["Small", "Medium", "Large"]),
  ]),
  const SettingsCategory(id: 'layout', title: 'Layout & Display', desc: 'Lists, grids, and file info', icon: Icons.grid_view_outlined, items: [
    SettingItem(type: SettingType.dropdown, id: 'defaultLayout', label: 'Default layout', options: ["List", "Grid", "Compact list"]),
    SettingItem(type: SettingType.toggle, id: 'showHiddenFiles', label: 'Show hidden files'),
    SettingItem(type: SettingType.toggle, id: 'showFileSize', label: 'Show file size'),
    SettingItem(type: SettingType.toggle, id: 'showDateModified', label: 'Show date modified'),
  ]),
  const SettingsCategory(id: 'safety', title: 'Safety & Confirmations', desc: 'Deletion and warnings', icon: Icons.security_outlined, items: [
    SettingItem(type: SettingType.toggle, id: 'confirmDelete', label: 'Confirm before delete'),
    SettingItem(type: SettingType.slider, id: 'largeFileThreshold', label: 'Large file threshold (MB)', min: 10, max: 2000),
  ]),
  const SettingsCategory(id: 'search', title: 'Search', desc: 'Search filters and history', icon: Icons.search_outlined, items: [
    SettingItem(type: SettingType.toggle, id: 'searchSubfolders', label: 'Search subfolders by default'),
    SettingItem(type: SettingType.button, id: 'clearSearchHistory', label: 'Clear search history'),
  ]),
  const SettingsCategory(id: 'gestures', title: 'Gestures & Interaction', desc: 'Swipes and haptics', icon: Icons.swipe_outlined, items: [
    SettingItem(type: SettingType.toggle, id: 'hapticFeedback', label: 'Haptic feedback'),
  ]),
  const SettingsCategory(id: 'about', title: 'About', desc: 'Version and licenses', icon: Icons.info_outline, items: [
    SettingItem(type: SettingType.text, id: 'version', label: 'App version'),
  ]),
];
