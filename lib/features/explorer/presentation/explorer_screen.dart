import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../../filesystem/application/storage_service.dart';
import '../application/file_operation_notifier.dart';
import 'widgets/explorer_header.dart';
import 'widgets/file_list_view.dart';
import 'widgets/file_grid_view.dart';
import 'widgets/dynamic_fab.dart';
import 'widgets/operation_bar.dart';

class ExplorerScreen extends ConsumerWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirState = ref.watch(directoryProvider);
    final opState = ref.watch(fileOperationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const ExplorerHeader(),
      body: Stack(
        children: [
          dirState.nodes.when(
            data: (nodes) {
              if (dirState.pathStack.isEmpty) return _buildRootSelector(context, theme);
              if (opState.isGridView) return FileGridView(nodes: nodes);
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
                  FilledButton(onPressed: () => ref.read(directoryProvider.notifier).loadDirectory(dirState.currentPath), child: const Text('Retry')),
                ]),
              ),
            ),
          ),
          const OperationBar(),
        ],
      ),
      floatingActionButton: const DynamicFab(),
    );
  }

  Widget _buildRootSelector(BuildContext context, ThemeData theme) {
    final drives = StorageService.getStorageRoots();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: drives.map((drive) => _DriveCardAsync(
        drivePath: drive['path'] as String,
        driveName: drive['name'] as String,
        iconData: drive['icon'] == 'smartphone' ? Icons.smartphone_rounded : Icons.sd_card_rounded,
        theme: theme,
      )).toList(),
    );
  }
}

class _DriveCardAsync extends ConsumerWidget {
  final String drivePath;
  final String driveName;
  final IconData iconData;
  final ThemeData theme;

  const _DriveCardAsync({required this.drivePath, required this.driveName, required this.iconData, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: StorageService.getStorageInfo(drivePath),
      builder: (context, snapshot) {
        double usedFraction = 0.0;
        String freeText = "Calculating...";

        if (snapshot.hasData) {
          final data = snapshot.data!;
          usedFraction = data['usedFraction'] as double;
          freeText = '${StorageService.formatBytes(data['free'] as int)} free';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: theme.colorScheme.surfaceContainer,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => ref.read(directoryProvider.notifier).jumpToPath(drivePath),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                SizedBox(
                  width: 64, height: 64,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                      value: snapshot.hasData ? usedFraction : null,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      color: theme.colorScheme.primary,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                    Icon(iconData, color: theme.colorScheme.primary, size: 28),
                  ]),
                ),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(driveName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(freeText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: snapshot.hasData ? usedFraction : null,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ])),
              ]),
            ),
          ),
        );
      }
    );
  }
}
