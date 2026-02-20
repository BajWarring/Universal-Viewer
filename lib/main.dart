import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routing/app_router.dart';

class OmniFileManagerApp extends ConsumerWidget {
  const OmniFileManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'Omni File Manager',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          
          // Generate Light Theme
          theme: AppTheme.buildTheme(
            themeName: themeState.themeName,
            brightness: Brightness.light,
            dynamicColorScheme: lightDynamic,
          ),
          
          // Generate Dark Theme
          darkTheme: AppTheme.buildTheme(
            themeName: themeState.themeName,
            brightness: Brightness.dark,
            dynamicColorScheme: darkDynamic,
          ),
          
          // Apply User's Mode Preference
          themeMode: themeState.themeMode, 
        );
      },
    );
  }
}
