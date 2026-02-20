import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/file_operation_notifier.dart';
import '../../../../filesystem/application/directory_notifier.dart';

class DynamicFab extends ConsumerWidget {
  const DynamicFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final currentPath = ref.watch(directoryProvider).currentPath;
    final theme = Theme.of(context);

    // STATE 1: Paste or Extract Mode
    if (opState.operation != FileOpType.none) {
      final isExtract = opState.operation == FileOpType.extract;
      return FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primaryContainer,
        onPressed: () {
          ref.read(fileOperationProvider.notifier).executePaste(currentPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isExtract ? 'Extracting...' : 'Pasting files...')),
          );
        },
        icon: Icon(isExtract ? Icons.download_rounded : Icons.content_paste), // Curved down arrow for extract
        label: Text(isExtract ? 'Extract Here' : 'Paste Here'),
      );
    }

    // STATE 2: Default Add Mode
    return FloatingActionButton(
      onPressed: () {
        // Show BottomSheet to create New Folder or New File
        _showAddBottomSheet(context, theme);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showAddBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('New Folder'),
              onTap: () { /* Handle folder creation */ Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('New File'),
              onTap: () { /* Handle file creation */ Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}
