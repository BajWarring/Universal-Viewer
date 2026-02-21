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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Storage Access Required', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Omni File Manager needs permission to view and manage your files.', textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: () => ref.read(dashboardProvider.notifier).requestPermissionRetry(),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Omni', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('File Manager', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}), // TODO: Route to Search
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPinnedFolders(context, ref, dashState.pinnedFolders, theme),
            const SizedBox(height: 24),
            _buildStorageDrives(context, ref, dashState.storageDrives, theme),
            const SizedBox(height: 24),
            _buildRecentFiles(context, dashState.recentFiles, theme),
            const SizedBox(height: 100), // Bottom nav padding
          ],
        ),
      ),
    );
  }

  // --- UI SECTIONS ---

  Widget _buildPinnedFolders(BuildContext context, WidgetRef ref, List<OmniNode> folders, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PINNED FOLDERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.colorScheme.primary)),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {}, // TODO: Open full pinned folders edit page
              )
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: folders.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final folder = folders[index];
              return InkWell(
                onTap: () {
                  ref.read(directoryProvider.notifier).jumpToPath(folder.path);
                  context.go('/explorer'); // Navigate to Files tab
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.folder_special, color: theme.colorScheme.primary, size: 28),
                      Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageDrives(BuildContext context, WidgetRef ref, List<OmniNode> drives, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('STORAGE DEVICES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.colorScheme.primary)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: drives.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final drive = drives[index];
              final isInternal = drive.name.contains('Internal');
              return InkWell(
                onTap: () {
                  ref.read(directoryProvider.notifier).jumpToPath(drive.path);
                  context.go('/explorer'); // Navigate to Files tab
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isInternal ? Icons.smartphone : Icons.sd_card, color: theme.colorScheme.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(drive.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFiles(BuildContext context, List<OmniNode> files, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECENT FILES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.colorScheme.primary)),
              TextButton(
                onPressed: () {}, // TODO: Open full recent files page
                child: Text('View all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              )
            ],
          ),
        ),
        if (files.isEmpty)
          const Padding(padding: EdgeInsets.all(16.0), child: Text('No recent files found.'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = files[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      child: Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${file.size} bytes', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
