import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../../filesystem/application/storage_service.dart';
import '../../application/file_operation_notifier.dart';
import '../../../preview_engine/presentation/preview_screen.dart';
import 'action_bottom_sheet.dart';

class FileGridView extends ConsumerWidget {
  final List<OmniNode> nodes;
  const FileGridView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final theme = Theme.of(context);
    final sorted = ref.read(fileOperationProvider.notifier).sortedNodes(nodes);

    if (sorted.isEmpty) return _buildEmptyState(theme);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final node = sorted[index];
        final isSelected = opState.selectedNodes.contains(node);

        return GestureDetector(
          onLongPress: () { 
            HapticFeedback.mediumImpact(); 
            ref.read(fileOperationProvider.notifier).toggleSelection(node); 
          },
          onTap: () {
            if (opState.isSelectionMode) ref.read(fileOperationProvider.notifier).toggleSelection(node);
            else if (node.isFolder) ref.read(directoryProvider.notifier).navigateTo(node.name);
            else UnifiedViewer.show(context, node);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: isSelected ? 2 : 0)
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Container(
                        width: 56, height: 56, 
                        decoration: BoxDecoration(color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), 
                        child: isSelected ? Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 28) : Icon(node.isFolder ? Icons.folder_rounded : _fileIcon(node.extension), color: theme.colorScheme.primary, size: 32)
                      ),
                      const SizedBox(height: 12),
                      Text(node.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(node.isFolder ? '${node.itemCount} items' : StorageService.formatBytes(node.size), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                    ]
                  )
                ),
                if (!opState.isSelectionMode) 
                  Positioned(top: 0, right: 0, child: IconButton(iconSize: 18, icon: const Icon(Icons.more_vert_rounded), onPressed: () => ActionBottomSheet.show(context, node))),
              ],
            ),
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
        Text('This folder is empty', style: TextStyle(color: theme.colorScheme.outline))
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
