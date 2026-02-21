import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/dashboard_notifier.dart';
import '../../../filesystem/application/directory_notifier.dart';
import '../../../filesystem/domain/entities/omni_node.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    if (dashState.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)));
    }
    if (!dashState.hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.folder_off_rounded, size: 72, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            const Text('Storage Access Required', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Omni needs permission to view and manage your files.', textAlign: TextAlign.center),
            ),
            FilledButton(
              onPressed: () => ref.read(dashboardProvider.notifier).requestPermissionRetry(),
              child: const Text('Grant Permission'),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Omni', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          Text('File Manager', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, 'PINNED FOLDERS', trailing: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), onPressed: () {})),
          _buildPinnedFolders(context, ref, dashState.pinnedFolders, theme),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'STORAGE DEVICES'),
          const SizedBox(height: 8),
          _buildStorageDrives(context, ref, dashState.storageDrives, theme),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'RECENT FILES', trailing: TextButton(
            onPressed: () {},
            child: Text('View all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          )),
          _buildRecentFiles(context, dashState.recentFiles, theme),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {Widget? trailing}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.4, color: theme.colorScheme.primary)),
        if (trailing != null) trailing,
      ]),
    );
  }

  Widget _buildPinnedFolders(BuildContext context, WidgetRef ref, List<OmniNode> folders, ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: folders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final folder = folders[index];
          return InkWell(
            onTap: () {
              ref.read(directoryProvider.notifier).jumpToPath(folder.path);
              // PHASE 1 FIX: correct route is /files
              context.go('/files');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 110,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(Icons.folder_special_rounded, color: theme.colorScheme.primary, size: 28),
                Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStorageDrives(BuildContext context, WidgetRef ref, List<OmniNode> drives, ThemeData theme) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: drives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final drive = drives[index];
          final isInternal = drive.name.contains('Internal');
          return InkWell(
            onTap: () {
              ref.read(directoryProvider.notifier).jumpToPath(drive.path);
              // PHASE 1 FIX: correct route is /files
              context.go('/files');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(children: [
                // PHASE 2: Storage ring visualization
                SizedBox(
                  width: 52, height: 52,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                      value: isInternal ? 0.25 : 0.60,
                      backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      color: theme.colorScheme.primary,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                    ),
                    Icon(isInternal ? Icons.smartphone_rounded : Icons.sd_card_rounded, color: theme.colorScheme.primary, size: 22),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(drive.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(isInternal ? '10 GB / 128 GB' : '42 GB / 64 GB', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentFiles(BuildContext context, List<OmniNode> files, ThemeData theme) {
    if (files.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Text('No recent files found.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = files[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
              child: Icon(Icons.insert_drive_file_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_formatBytes(file.size), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ])),
          ]),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
