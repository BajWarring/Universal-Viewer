import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../application/file_operation_notifier.dart';
import 'widgets/explorer_header.dart';
import 'widgets/file_list_view.dart';
import 'widgets/file_grid_view.dart';
import 'widgets/dynamic_fab.dart';

class ExplorerScreen extends ConsumerWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirState = ref.watch(directoryProvider);
    final opState = ref.watch(fileOperationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // PHASE 1 FIX: ExplorerHeader goes in appBar, not inside Column
      appBar: const ExplorerHeader(),
      body: dirState.nodes.when(
        data: (nodes) {
          if (dirState.pathStack.isEmpty) {
            return _buildRootSelector(context, ref, theme);
          }
          // PHASE 3: toggle between list and grid
          if (opState.isGridView) {
            return FileGridView(nodes: nodes);
          }
          return FileListView(nodes: nodes);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading files:\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(directoryProvider.notifier).loadDirectory(dirState.currentPath),
                child: const Text('Retry'),
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: const DynamicFab(),
    );
  }

  Widget _buildRootSelector(BuildContext context, WidgetRef ref, ThemeData theme) {
    final drives = [
      (name: 'Internal Storage', icon: Icons.smartphone_rounded, path: '/storage/emulated/0', used: 0.25, usedStr: '10 GB / 128 GB'),
      (name: 'SD Card', icon: Icons.sd_card_rounded, path: '/storage/sdcard1', used: 0.60, usedStr: '42 GB / 64 GB'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: drives.map((drive) => _buildDriveCard(context, ref, theme, drive.name, drive.icon, drive.path, drive.used, drive.usedStr)).toList(),
    );
  }

  Widget _buildDriveCard(BuildContext context, WidgetRef ref, ThemeData theme, String name, IconData icon, String path, double used, String usedStr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(directoryProvider.notifier).jumpToPath(path),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            SizedBox(
              width: 60, height: 60,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: used,
                  backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  color: theme.colorScheme.primary,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                ),
                Icon(icon, color: theme.colorScheme.primary, size: 24),
              ]),
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(usedStr, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: used,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  color: theme.colorScheme.primary,
                ),
              ),
            ])),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outlineVariant),
          ]),
        ),
      ),
    );
  }
}
