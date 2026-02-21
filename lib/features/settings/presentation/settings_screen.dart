import 'package:flutter/material.dart';
import '../domain/settings_schema.dart';
import 'settings_category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              children: List.generate(appSettingsSchema.length, (index) {
                final category = appSettingsSchema[index];
                final isLast = index == appSettingsSchema.length - 1;
                return Column(children: [
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLast ? 20 : 0)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                      child: Icon(category.icon, color: theme.colorScheme.onSurface, size: 20),
                    ),
                    title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(category.desc, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsCategoryScreen(category: category))),
                  ),
                  if (!isLast) Divider(height: 1, indent: 72, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ]);
              }),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('Omni File Manager v1.0.0', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant))),
          const SizedBox(height: 8),
          Center(child: Text('Built with Flutter & ❤️', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}
