import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import 'widgets/explorer_header.dart';
import 'widgets/file_list_view.dart';
import 'widgets/dynamic_fab.dart';

class ExplorerScreen extends ConsumerWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirState = ref.watch(directoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // The Header we built in Phase 4 (Path breadcrumbs, search icon, etc.)
            const ExplorerHeader(),
            
            // The File List
            Expanded(
              child: dirState.nodes.when(
                data: (nodes) => FileListView(nodes: nodes),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading files:\n$err', textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const DynamicFab(),
    );
  }
}
