import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);

    final sorted = ref.read(fileOperationProvider.notifier).sortedNodes(nodes);

    if (sorted.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.folder_open_rounded, size: 64, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Text('This folder is empty', style: TextStyle(color: theme.colorScheme.outline)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
      itemBuilder: (context, index) {
        final node = sorted[index];
        final isSelected = opState.selectedNodes.contains(node);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.25),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, color: theme.colorScheme.onPrimary)
                : Icon(
                    node.isFolder ? Icons.folder_rounded : _fileIcon(node.extension),
                    color: node.isFolder ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          title: Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(children: [
              Text(
                node.isFolder ? 'Folder' : _formatBytes(node.size),
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              // PHASE 1 FIX: proper Unicode bullet char (•)
              Text(' • ${_formatDate(node.modified)}',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ),
          trailing: opState.isSelectionMode
              ? null
              : IconButton(icon: const Icon(Icons.more_vert_rounded, size: 20), onPressed: () => ActionBottomSheet.show(context, node)),
          onLongPress: () {
            HapticFeedback.mediumImpact();
            ref.read(fileOperationProvider.notifier).toggleSelection(node);
          },
          onTap: () {
            if (opState.isSelectionMode) {
              ref.read(fileOperationProvider.notifier).toggleSelection(node);
            } else {
              if (node.isFolder) {
                ref.read(directoryProvider.notifier).navigateTo(node.name);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewScreen(node: node)));
              }
            }
          },
        );
      },
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': case 'mkv': case 'avi': return Icons.video_library_rounded;
      case 'mp3': case 'wav': case 'flac': return Icons.music_note_rounded;
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'webp': return Icons.image_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'zip': case 'rar': case '7z': case 'tar': return Icons.folder_zip_rounded;
      case 'apk': return Icons.android_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
