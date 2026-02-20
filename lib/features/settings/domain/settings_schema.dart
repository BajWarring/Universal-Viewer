import 'package:flutter/material.dart';

enum SettingType { toggle, dropdown, slider, button, themePicker, header, text }

class SettingItem {
  final SettingType type;
  final String id;
  final String label;
  final List<String>? options;
  final double? min;
  final double? max;

  const SettingItem({
    required this.type,
    required this.id,
    required this.label,
    this.options,
    this.min,
    this.max,
  });
}

class SettingsCategory {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final List<SettingItem> items;

  const SettingsCategory({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.items,
  });
}

// Replicating your HTML Schema structure
final List<SettingsCategory> appSettingsSchema = [
  SettingsCategory(
    id: 'appearance',
    title: 'Appearance & Themes',
    desc: 'Visual identity and feel',
    icon: Icons.palette_outlined,
    items: [
      const SettingItem(type: SettingType.themePicker, id: 'theme', label: 'Theme picker', options: ["Simple Light", "Pure Black", "Material You Dynamic", "Ocean Blue"]),
      const SettingItem(type: SettingType.toggle, id: 'darkMode', label: 'Dark mode'),
      const SettingItem(type: SettingType.dropdown, id: 'animationIntensity', label: 'Animation intensity', options: ["Full", "Reduced"]),
    ],
  ),
  SettingsCategory(
    id: 'layout',
    title: 'Layout & Display',
    desc: 'Lists, grids, and file info',
    icon: Icons.grid_view_outlined,
    items: [
      const SettingItem(type: SettingType.dropdown, id: 'defaultLayout', label: 'Default layout', options: ["List", "Grid", "Compact list"]),
      const SettingItem(type: SettingType.toggle, id: 'showHiddenFiles', label: 'Show hidden files'),
    ],
  ),
  // Add Safety, Search, Archives, Performance, etc. from your HTML...
];
