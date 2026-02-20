import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';

class FileListView extends ConsumerWidget {
  final List<OmniNode> nodes;

  const FileListView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: nodes.length + 1, // +1 for the "Go Back" row
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        
        // Handle "Go Back" item
        if (index == 0) {
          final isAtRoot = ref.read(directoryProvider).pathStack.length <= 1;
          if (isAtRoot) return const SizedBox.shrink();

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => ref.read(directoryProvider.notifier).navigateUp(),
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.turn_left, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Text('Go Back', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        final item = nodes[index - 1];
        final isSelected = false; // Bind to a selection Riverpod state in production

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (item.isFolder) {
              ref.read(directoryProvider.notifier).navigateTo(item.name);
            } else {
              // Trigger preview or open action
            }
          },
          onLongPress: () {
            // Trigger bottom sheet for item actions (Copy, Move, Compress)
          },
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: item.isFolder 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    item.isFolder ? Icons.folder : Icons.description,
                    color: item.isFolder ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.isFolder ? 'Folder' : '${(item.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    // Open Bottom Sheet just like your HTML prototype
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
