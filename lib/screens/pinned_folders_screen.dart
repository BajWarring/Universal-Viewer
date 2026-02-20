import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';

class PinnedFoldersScreen extends StatefulWidget {
  const PinnedFoldersScreen({super.key});

  @override
  State<PinnedFoldersScreen> createState() => _PinnedFoldersScreenState();
}

class _PinnedFoldersScreenState extends State<PinnedFoldersScreen> {
  late List<Map<String, String>> _folders;

  @override
  void initState() {
    super.initState();
    _folders = List.from(context.read<AppSettings>().pinnedFolders);
  }

  void _save() {
    context.read<AppSettings>().updatePinnedFolders(_folders);
  }

  void _addFolder() {
    final nameCtrl = TextEditingController();
    final pathCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pin New Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
            TextField(controller: pathCtrl, decoration: const InputDecoration(labelText: 'Path (e.g. /storage/emulated/0/Music)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && pathCtrl.text.isNotEmpty) {
                setState(() => _folders.add({'name': nameCtrl.text, 'path': pathCtrl.text}));
                _save();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Pin Folder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pinned Folders', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addFolder),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ReorderableGridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1
          ),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _folders.removeAt(oldIndex);
              _folders.insert(newIndex, item);
            });
            _save();
          },
          itemCount: _folders.length,
          itemBuilder: (context, i) {
            final folder = _folders[i];
            return Card(
              key: ValueKey(folder['path']),
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), 
                // Fix: Using 'side' and 'BorderSide' instead of 'border' and 'Border.all'
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_rounded, color: primaryColor, size: 40),
                        const SizedBox(height: 8),
                        Text(folder['name']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -4, right: -4,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() => _folders.removeAt(i));
                        _save();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
