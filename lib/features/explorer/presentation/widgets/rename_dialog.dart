import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/directory_notifier.dart';

class RenameDialog extends ConsumerStatefulWidget {
  final OmniNode node;
  const RenameDialog({super.key, required this.node});
  @override
  ConsumerState<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends ConsumerState<RenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.name);
    if (!widget.node.isFolder && widget.node.name.contains('.')) {
      final extIndex = widget.node.name.lastIndexOf('.');
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: extIndex);
    } else {
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.node.name.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performRename() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.node.name) {
      if (mounted) Navigator.pop(context);
      return;
    }
    try {
      final oldFile = File(widget.node.path);
      final newPath = widget.node.path.replaceAll(widget.node.name, newName);
      await oldFile.rename(newPath);
      if (!mounted) return;
      ref.read(directoryProvider.notifier).loadDirectory(ref.read(directoryProvider).currentPath);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to rename: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Rename'),
      content: TextField(
        controller: _controller, autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), labelText: 'File name'),
        onSubmitted: (_) => _performRename(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _performRename, child: const Text('Rename')),
      ],
    );
  }
}
