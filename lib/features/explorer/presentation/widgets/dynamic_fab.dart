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

    if (opState.operation != FileOpType.none) {
      final isExtract = opState.operation == FileOpType.extract;
      return FloatingActionButton.extended(
        onPressed: () {
          ref.read(fileOperationProvider.notifier).executePaste(currentPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isExtract ? 'Extracting...' : 'Pasting ${opState.clipboard.length} item(s)...')),
          );
        },
        icon: Icon(isExtract ? Icons.unarchive_rounded : Icons.content_paste_rounded),
        label: Text(isExtract ? 'Extract Here' : 'Paste Here (${opState.clipboard.length})'),
      );
    }

    return FloatingActionButton(
      onPressed: () => _showAddBottomSheet(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Icon(Icons.add_rounded),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.create_new_folder_rounded), title: const Text('New Folder'), onTap: () { Navigator.pop(ctx); _showNewFolderDialog(context); }),
          ListTile(leading: const Icon(Icons.note_add_rounded), title: const Text('New File'), onTap: () { Navigator.pop(ctx); }),
        ]),
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Folder name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); /* TODO: create folder */ }, child: const Text('Create')),
        ],
      ),
    );
  }
}
