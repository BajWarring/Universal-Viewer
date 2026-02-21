import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';
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

    if (sorted.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.folder_open_rounded, size: 64, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Text('This folder is empty', style: TextStyle(color: theme.colorScheme.outline)),
      ]));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
      ),
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
            if (opState.isSelectionMode) {
              ref.read(fileOperationProvider.notifier).toggleSelection(node);
            } else if (node.isFolder) {
              ref.read(directoryProvider.notifier).navigateTo(node.name);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewScreen(node: node)));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 24)
                        : Icon(
                            node.isFolder ? Icons.folder_rounded : _fileIcon(node.extension),
                            color: node.isFolder ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            size: 26,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(node.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text(
                    node.isFolder ? 'Folder' : _formatBytes(node.size),
                    style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ]),
              ),
              if (!opState.isSelectionMode)
                Positioned(
                  top: 2, right: 2,
                  child: IconButton(
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => ActionBottomSheet.show(context, node),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': case 'mkv': return Icons.video_library_rounded;
      case 'mp3': case 'wav': return Icons.music_note_rounded;
      case 'jpg': case 'jpeg': case 'png': return Icons.image_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'zip': case 'rar': case '7z': return Icons.folder_zip_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
