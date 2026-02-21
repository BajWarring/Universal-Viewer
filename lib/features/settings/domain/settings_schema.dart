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
  SettingsCategory(id: 'appearance', title: 'Appearance & Themes', desc: 'Visual identity and feel', icon: Icons.palette_outlined, items: [
    const SettingItem(type: SettingType.themePicker, id: 'theme', label: 'Theme', options: ["Simple Light", "Simple Dark", "Pure Black", "Material You Dynamic", "Ocean Blue", "Forest Green", "Sunset Orange", "Midnight Purple", "Minimal Gray", "High Contrast"]),
    const SettingItem(type: SettingType.toggle, id: 'darkMode', label: 'Dark mode'),
    const SettingItem(type: SettingType.dropdown, id: 'animationIntensity', label: 'Animation intensity', options: ["Full", "Reduced"]),
    const SettingItem(type: SettingType.dropdown, id: 'layoutDensity', label: 'Layout density', options: ["Comfortable", "Compact"]),
    const SettingItem(type: SettingType.dropdown, id: 'iconSize', label: 'Icon size', options: ["Small", "Medium", "Large"]),
  ]),
  SettingsCategory(id: 'layout', title: 'Layout & Display', desc: 'Lists, grids, and file info', icon: Icons.grid_view_outlined, items: [
    const SettingItem(type: SettingType.dropdown, id: 'defaultLayout', label: 'Default layout', options: ["List", "Grid", "Compact list"]),
    const SettingItem(type: SettingType.toggle, id: 'showHiddenFiles', label: 'Show hidden files'),
    const SettingItem(type: SettingType.toggle, id: 'showFileSize', label: 'Show file size'),
    const SettingItem(type: SettingType.toggle, id: 'showDateModified', label: 'Show date modified'),
  ]),
  SettingsCategory(id: 'safety', title: 'Safety & Confirmations', desc: 'Deletion and warnings', icon: Icons.security_outlined, items: [
    const SettingItem(type: SettingType.toggle, id: 'confirmDelete', label: 'Confirm before delete'),
    const SettingItem(type: SettingType.slider, id: 'largeFileThreshold', label: 'Large file threshold (MB)', min: 10, max: 2000),
  ]),
  SettingsCategory(id: 'search', title: 'Search', desc: 'Search filters and history', icon: Icons.search_outlined, items: [
    const SettingItem(type: SettingType.toggle, id: 'searchSubfolders', label: 'Search subfolders by default'),
    const SettingItem(type: SettingType.button, id: 'clearSearchHistory', label: 'Clear search history'),
  ]),
  SettingsCategory(id: 'gestures', title: 'Gestures & Interaction', desc: 'Swipes and haptics', icon: Icons.swipe_outlined, items: [
    const SettingItem(type: SettingType.toggle, id: 'hapticFeedback', label: 'Haptic feedback'),
  ]),
  SettingsCategory(id: 'about', title: 'About', desc: 'Version and licenses', icon: Icons.info_outline, items: [
    const SettingItem(type: SettingType.text, id: 'version', label: 'App version'),
  ]),
];
