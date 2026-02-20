import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../search/presentation/search_screen.dart';

class ExplorerHeader extends ConsumerWidget implements PreferredSizeWidget {
  final bool isSelectionMode;

  const ExplorerHeader({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirState = ref.watch(directoryProvider);
    final currentFolderName = dirState.pathStack.isEmpty 
        ? 'Storage' 
        : dirState.pathStack.last.split('/').last;

    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Cancel selection mode logic
          },
        ),
        title: const Text('Selection', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.blue),
            onPressed: () {}, // Select All
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, // Multi-selection context menu
          ),
        ],
      );
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(currentFolderName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.expand_more, color: Colors.grey, size: 20),
            ],
          ),
          Text(
            dirState.currentPath, 
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        IconButton(
         icon: const Icon(Icons.search), 
          onPressed: () {
           Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const SearchScreen()),
           );
         }
      ),

        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
