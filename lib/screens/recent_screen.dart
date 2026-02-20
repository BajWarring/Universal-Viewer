import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/file_system_service.dart';
import '../widgets/file_item_tile.dart';
import '../widgets/bottom_sheet_menu.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});
  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<FileItem> _allFiles = [];
  List<FileItem> _filteredFiles = [];
  bool _loading = true;
  String _currentFilter = 'All';
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  final List<String> _filters = ['All', 'Documents', 'Images', 'Videos', 'Audio', 'Archives', 'APKs'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final files = await FileSystemService.getRecentFiles('/storage/emulated/0', limit: 100);
    if (mounted) setState(() { _allFiles = files; _applyFilter(); _loading = false; });
  }

  void _applyFilter() {
    if (_currentFilter == 'All') { _filteredFiles = _allFiles; } 
    else {
      _filteredFiles = _allFiles.where((f) {
        if (_currentFilter == 'Documents') return f.isPdf || f.isText || f.ext.contains('doc') || f.ext.contains('xls');
        if (_currentFilter == 'Images') return f.isImage;
        if (_currentFilter == 'Videos') return f.isVideo;
        if (_currentFilter == 'Audio') return f.isAudio;
        if (_currentFilter == 'Archives') return f.isArchive;
        if (_currentFilter == 'APKs') return f.isApk;
        return false;
      }).toList();
    }
  }

  void _showSelectionBottomSheet(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.content_copy), title: const Text('Copy'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.content_cut), title: const Text('Cut'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.folder_zip_outlined), title: const Text('Compress'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); setState(() { _isSelectionMode = false; _selectedItems.clear(); }); }),
          ],
        ),
      ),
    );
  }

  void _showFileOptions(BuildContext context, FileItem item, Color primaryColor) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => FileBottomSheet(
        item: item, primaryColor: primaryColor, currentPath: '/storage/emulated/0',
        onOpen: () { Navigator.pop(context); OpenFile.open(item.path); },
        onCompress: () { Navigator.pop(context); }, onRename: () { Navigator.pop(context); },
        onDelete: () { Navigator.pop(context); }, onDetails: () { Navigator.pop(context); },
        onShare: () { Navigator.pop(context); }, onCopy: () { Navigator.pop(context); }, onCut: () { Navigator.pop(context); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectionMode = false; _selectedItems.clear(); })),
              title: Text('${_selectedItems.length} selected', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(icon: const Icon(Icons.checklist), onPressed: () => setState(() { _selectedItems.addAll(_filteredFiles.map((f) => f.path)); })),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showSelectionBottomSheet(context, primaryColor)),
              ],
            )
          : AppBar(
              title: Text('Recent Files', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () => setState(() => _isSelectionMode = true)),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filters.length,
                    itemBuilder: (ctx, i) {
                      final filter = _filters[i];
                      final isSelected = _currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected, selectedColor: primaryColor.withOpacity(0.2), checkmarkColor: primaryColor,
                          onSelected: (v) { setState(() { _currentFilter = filter; _applyFilter(); }); },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFiles.isEmpty
              ? Center(child: Text('No $_currentFilter found', style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: _filteredFiles.length,
                  itemBuilder: (ctx, i) => FileItemTile(
                    item: _filteredFiles[i], isSelected: _selectedItems.contains(_filteredFiles[i].path), isSelectionMode: _isSelectionMode, primaryColor: primaryColor, isDark: isDark, showSize: settings.showFileSize, showDate: settings.showDateModified,
                    onTap: () { if (_isSelectionMode) { setState(() { _selectedItems.contains(_filteredFiles[i].path) ? _selectedItems.remove(_filteredFiles[i].path) : _selectedItems.add(_filteredFiles[i].path); }); } else { OpenFile.open(_filteredFiles[i].path); } },
                    onLongPress: () { setState(() { _isSelectionMode = true; _selectedItems.add(_filteredFiles[i].path); }); },
                    onMoreTap: () => _showFileOptions(context, _filteredFiles[i], primaryColor),
                  ),
                ),
    );
  }
}
