import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../application/file_operation_notifier.dart';

class RenameDialog extends ConsumerStatefulWidget {
  final OmniNode node;
  const RenameDialog({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(node: node),
    );
  }

  @override
  ConsumerState<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends ConsumerState<RenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opState = ref.watch(fileOpProvider);

    return AlertDialog(
      title: const Text('Rename File'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'New Name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: opState.isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: opState.isProcessing 
              ? null 
              : () async {
                  await ref.read(fileOpProvider.notifier).renameItem(widget.node.path, _controller.text);
                  if (context.mounted) Navigator.pop(context);
                },
          child: opState.isProcessing 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text('Save'),
        ),
      ],
    );
  }
}
