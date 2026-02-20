import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetIt Dependency Injection
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

    return MaterialApp.router(
      title: 'Omni File Manager',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // We will hook up the dynamic theme provider in Phase 2
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, 
    );
  }
}

