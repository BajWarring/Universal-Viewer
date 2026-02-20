import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../application/file_operation_notifier.dart';
import '../../../preview_engine/presentation/preview_screen.dart';
import 'action_bottom_sheet.dart';

class FileListView extends ConsumerWidget {
  final List<OmniNode> nodes;

  const FileListView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final isSelectionMode = opState.selectedNodes.isNotEmpty;
    final theme = Theme.of(context);

    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('This folder is empty', style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88), // Extra padding so FAB doesn't hide the last file
      itemCount: nodes.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final node = nodes[index];
        final isSelected = opState.selectedNodes.contains(node);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
          leading: CircleAvatar(
            backgroundColor: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.surfaceContainerHighest,
            child: isSelected 
                ? Icon(Icons.check, color: theme.colorScheme.onPrimary)
                : Icon(
                    node.isFolder ? Icons.folder : Icons.insert_drive_file,
                    color: node.isFolder ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          title: Text(
            node.name, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  node.isFolder ? 'Folder' : _formatBytes(node.size),
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ${_formatDate(node.modified)}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          trailing: isSelectionMode 
              ? null // Hide the 3-dots when selecting files
              : IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => ActionBottomSheet.show(context, node),
                ),
          onLongPress: () {
            ref.read(fileOperationProvider.notifier).toggleSelection(node);
          },
          onTap: () {
            if (isSelectionMode) {
              // If we are already selecting, a standard tap selects/deselects
              ref.read(fileOperationProvider.notifier).toggleSelection(node);
            } else {
              // Normal Tap behavior
              if (node.isFolder) {
                ref.read(directoryProvider.notifier).navigateTo(node.name);
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PreviewScreen(node: node),
                ));
              }
            }
          },
        );
      },
    );
  }

  // Helper method to make file sizes readable
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
