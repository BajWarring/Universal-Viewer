import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart'; // <--- Added this import
import 'core/config/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MediaKit for video playback
  MediaKit.ensureInitialized(); 
  
  await initializeDependencies();

  runApp(
    const ProviderScope(
      child: OmniFileManagerApp(),
    ),
  );
}

class OmniFileManagerApp extends ConsumerWidget {
  const OmniFileManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Omni File Manager',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.buildTheme(
        themeName: themeState.themeName,
        brightness: Brightness.light,
        dynamicColorScheme: null,
      ),
      darkTheme: AppTheme.buildTheme(
        themeName: themeState.themeName,
        brightness: Brightness.dark,
        dynamicColorScheme: null,
      ),
      themeMode: themeState.themeMode,
    );
  }
}
