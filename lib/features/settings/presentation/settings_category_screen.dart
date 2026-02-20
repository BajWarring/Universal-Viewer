import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/settings_notifier.dart';
import '../domain/settings_schema.dart';

class SettingsCategoryScreen extends ConsumerWidget {
  final SettingsCategory category;

  const SettingsCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView.builder(
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          final item = category.items[index];
          final currentValue = settings.get(item.id);

          switch (item.type) {
            case SettingType.header:
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(item.label.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              );

            case SettingType.toggle:
              return SwitchListTile(
                title: Text(item.label),
                value: currentValue ?? false,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).updateSetting(item.id, val);
                  // Special case: If dark mode toggled, update ThemeProvider (Phase 2)
                },
              );

            case SettingType.dropdown:
              return ListTile(
                title: Text(item.label),
                trailing: DropdownButton<String>(
                  value: currentValue ?? item.options!.first,
                  underline: const SizedBox(),
                  items: item.options!.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => ref.read(settingsProvider.notifier).updateSetting(item.id, val),
                ),
              );

            case SettingType.slider:
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.label}: ${currentValue ?? item.min}'),
                    Slider(
                      min: item.min ?? 0,
                      max: item.max ?? 100,
                      value: (currentValue ?? item.min)?.toDouble() ?? 0.0,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSetting(item.id, val.toInt()),
                    ),
                  ],
                ),
              );

            case SettingType.button:
              return ListTile(
                title: Text(item.label),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    // Execute button action (e.g., clear cache)
                  },
                  child: const Text('Open'),
                ),
              );
              
            case SettingType.themePicker:
              // For brevity, mapping this to a simple list of chips, 
              // but you would insert the horizontal carousel from Phase 2 here.
              return ListTile(
                title: Text(item.label),
                subtitle: Wrap(
                  spacing: 8,
                  children: item.options!.map((theme) => ChoiceChip(
                    label: Text(theme),
                    selected: currentValue == theme,
                    onSelected: (val) => ref.read(settingsProvider.notifier).updateSetting(item.id, theme),
                  )).toList(),
                ),
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
