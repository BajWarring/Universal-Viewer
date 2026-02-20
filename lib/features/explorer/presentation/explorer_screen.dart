import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../filesystem/application/directory_notifier.dart';
import 'widgets/explorer_header.dart';
import 'widgets/file_list_view.dart';
import 'widgets/file_grid_view.dart';

class ExplorerScreen extends ConsumerWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirState = ref.watch(directoryProvider);
    // In a full implementation, layout preference (List vs Grid) 
    // and selection state would be stored in their own Riverpod providers.
    final bool isGridView = false; 

    return Scaffold(
      appBar: const ExplorerHeader(),
      body: dirState.nodes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (nodes) {
          if (nodes.isEmpty) {
            return const Center(child: Text('Folder is empty'));
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.read(directoryProvider.notifier).loadDirectory(dirState.currentPath),
            child: isGridView 
                ? FileGridView(nodes: nodes) 
                : FileListView(nodes: nodes),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hook up the "Add" action from your HTML FAB
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
