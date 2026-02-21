import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/settings_notifier.dart';
import '../domain/settings_schema.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsCategoryScreen extends ConsumerWidget {
  final SettingsCategory category;
  const SettingsCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Icon(category.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(category.desc, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ]),
            );
          }
          final item = category.items[index - 1];
          final currentValue = settings.get(item.id);

          switch (item.type) {
            case SettingType.header:
              return Padding(padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text(item.label.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)));

            case SettingType.toggle:
              return SwitchListTile(
                title: Text(item.label),
                value: currentValue ?? false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).updateSetting(item.id, val);
                  if (item.id == 'darkMode') ref.read(themeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              );

            case SettingType.dropdown:
              return ListTile(
                title: Text(item.label),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                trailing: DropdownButton<String>(
                  value: currentValue ?? item.options!.first,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(12),
                  items: item.options!.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (val) => ref.read(settingsProvider.notifier).updateSetting(item.id, val),
                ),
              );

            case SettingType.slider:
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${item.label}: ${currentValue ?? item.min?.toInt()} MB'),
                  Slider(
                    min: item.min ?? 0, max: item.max ?? 100,
                    value: (currentValue ?? item.min)?.toDouble() ?? 0,
                    onChanged: (val) => ref.read(settingsProvider.notifier).updateSetting(item.id, val.toInt()),
                  ),
                ]));

            case SettingType.button:
              return ListTile(
                title: Text(item.label),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Open')),
              );

            case SettingType.themePicker:
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: item.options!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final name = item.options![i];
                        final isActive = currentValue == name;
                        final color = AppTheme.themeColors[name] ?? const Color(0xFF135BEC);
                        return GestureDetector(
                          onTap: () {
                            ref.read(settingsProvider.notifier).updateSetting(item.id, name);
                            ref.read(themeProvider.notifier).setThemeName(name);
                          },
                          child: Column(children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isActive ? color : theme.colorScheme.outlineVariant, width: isActive ? 2.5 : 1),
                              ),
                              child: Center(child: Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(width: 60, child: Text(name.split(' ').first, style: TextStyle(fontSize: 9, color: isActive ? color : theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                        );
                      },
                    ),
                  ),
                ]),
              );

            case SettingType.text:
              return ListTile(
                title: Text(item.label),
                trailing: Text(item.id == 'version' ? 'v1.0.0' : (currentValue?.toString() ?? ''), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              );
          }
        },
      ),
    );
  }
}
