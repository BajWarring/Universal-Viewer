import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../../filesystem/application/storage_service.dart';
import '../../application/file_operation_notifier.dart';
import '../../../preview_engine/presentation/preview_screen.dart';
import 'action_bottom_sheet.dart';

class FileListView extends ConsumerWidget {
  final List<OmniNode> nodes;
  const FileListView({super.key, required this.nodes});

  String _formatHtmlDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final theme = Theme.of(context);
    final sorted = ref.read(fileOperationProvider.notifier).sortedNodes(nodes);

    if (sorted.isEmpty) return _buildEmptyState(theme);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final node = sorted[index];
        final isSelected = opState.selectedNodes.contains(node);

        final subtitleText = node.isFolder ? '${node.itemCount} items' : StorageService.formatBytes(node.size);

        return Dismissible(
          key: ValueKey(node.path),
          background: Container(color: theme.colorScheme.primary, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 24), child: const Icon(Icons.info_outline_rounded, color: Colors.white)),
          secondaryBackground: Container(color: theme.colorScheme.error, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 24), child: const Icon(Icons.delete_outline_rounded, color: Colors.white)),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) ActionBottomSheet.showDeleteConfirm(context, ref, node);
            else ActionBottomSheet.showDetails(context, node);
            return false; 
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            selected: isSelected,
            selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40, height: 40,
              decoration: BoxDecoration(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: isSelected ? Icon(Icons.check_rounded, color: theme.colorScheme.onPrimary) : Icon(node.isFolder ? Icons.folder_rounded : _fileIcon(node.extension), color: theme.colorScheme.primary, size: 24),
            ),
            title: Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                children: [
                  Text(subtitleText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 6),
                  Text('•', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                  const SizedBox(width: 6),
                  Text(_formatHtmlDate(node.modified), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            trailing: !opState.isSelectionMode ? IconButton(icon: const Icon(Icons.more_vert_rounded, size: 20), onPressed: () => ActionBottomSheet.show(context, node)) : null,
            onLongPress: () {
              HapticFeedback.mediumImpact();
              ref.read(fileOperationProvider.notifier).toggleSelection(node);
            },
            onTap: () {
              if (opState.isSelectionMode) ref.read(fileOperationProvider.notifier).toggleSelection(node);
              else if (node.isFolder) ref.read(directoryProvider.notifier).navigateTo(node.name);
              else UnifiedViewer.show(context, node);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.folder_open_rounded, size: 64, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Text('This folder is empty', style: TextStyle(color: theme.colorScheme.outline)),
      ])
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': case 'mkv': return Icons.video_library_rounded;
      case 'mp3': return Icons.music_note_rounded;
      case 'jpg': case 'png': return Icons.image_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'zip': case 'rar': case '7z': return Icons.folder_zip_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }
}
