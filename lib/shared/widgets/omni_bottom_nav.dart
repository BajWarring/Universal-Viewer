import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/media_player/presentation/floating_audio_player.dart';
import '../../../features/media_player/presentation/floating_video_player.dart';

class OmniBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const OmniBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // PHASE 4: FloatingAudioVideoPlayer lives here so it persists across all tabs
      

      body: Stack(children: [
        navigationShell,
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const FloatingVideoPlayer(), // <-- Added here
            const FloatingAudioPlayer(),
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 8),
          ]),
        ),
      ]),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
          // PHASE 2: frosted glass effect
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // PHASE 2: active pill indicator matching HTML prototype
          indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          onDestinationSelected: (index) => navigationShell.goBranch(index),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.home_rounded, color: theme.colorScheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
              label: 'Files',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.settings_rounded, color: theme.colorScheme.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
