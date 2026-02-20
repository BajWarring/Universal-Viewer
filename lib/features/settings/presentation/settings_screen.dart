import 'package:flutter/material.dart';
import '../domain/settings_schema.dart';
import 'settings_category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appSettingsSchema.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final category = appSettingsSchema[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(category.icon, color: Theme.of(context).colorScheme.onSurface),
            ),
            title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(category.desc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsCategoryScreen(category: category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
