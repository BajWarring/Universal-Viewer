import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
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

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final isSelected = opState.selectedNodes.contains(node);

        return ListTile(
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          leading: CircleAvatar(
            backgroundColor: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.transparent,
            child: isSelected 
                ? const Icon(Icons.check, color: Colors.white)
                : Icon(node.isFolder ? Icons.folder : Icons.insert_drive_file),
          ),
          title: Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(node.isFolder ? 'Folder' : '${node.size} bytes'),
          trailing: isSelectionMode 
              ? null // Hide the 3-dots when selecting
              : IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => ActionBottomSheet.show(context, node),
                ),
          onLongPress: () {
            ref.read(fileOperationProvider.notifier).toggleSelection(node);
          },
          onTap: () {
            if (isSelectionMode) {
              // If we are already selecting, tap just selects/deselects
              ref.read(fileOperationProvider.notifier).toggleSelection(node);
            } else {
              // Normal Tap behavior
              if (node.isFolder) {
                // Navigate into folder (call directoryProvider here)
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
}
