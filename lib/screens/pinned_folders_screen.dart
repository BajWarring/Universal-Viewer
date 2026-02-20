import 'package:flutter/material.dart';

class PinnedFoldersScreen extends StatefulWidget {
  const PinnedFoldersScreen({super.key});

  @override
  State<PinnedFoldersScreen> createState() => _PinnedFoldersScreenState();
}

class _PinnedFoldersScreenState extends State<PinnedFoldersScreen> {
  final List<String> _folders = ['Documents', 'Downloads', 'Camera', 'WhatsApp'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pinned Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigate to a folder and tap "Pin to Home" from the 3-dots menu.')));
            },
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _folders.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final item = _folders.removeAt(oldIndex);
            _folders.insert(newIndex, item);
          });
        },
        itemBuilder: (context, i) {
          return ListTile(
            key: ValueKey(_folders[i]),
            leading: const Icon(Icons.folder, color: Colors.blue),
            title: Text(_folders[i]),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => _folders.removeAt(i)),
            ),
          );
        },
      ),
    );
  }
}
