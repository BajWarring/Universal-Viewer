import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/file_system_service.dart';
import '../utils/storage_service.dart';
import '../widgets/file_item_tile.dart';
import '../widgets/file_item_grid_card.dart';
import '../widgets/bottom_sheet_menu.dart';
import '../widgets/compress_modal.dart';
import '../widgets/rename_modal.dart';
import '../widgets/details_modal.dart';
import '../widgets/create_folder_dialog.dart';

class FilesScreen extends StatefulWidget {
  final String? initialPath;
  final String? initialTitle;
  const FilesScreen({super.key, this.initialPath, this.initialTitle});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<StorageInfo> _storageDevices = [];
  bool _atRoot = true;
  List<FileItem> _files = [];
  List<String> _pathStack = [];
  String? _currentRootPath;
  bool _loading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  @override
  void initState() {
    super.initState();
    _loadStorage();
    if (widget.initialPath != null) {
      _atRoot = false;
      _currentRootPath = '/storage/emulated/0';
      _pathStack = ['Internal Storage', ...widget.initialPath!.replaceFirst('/storage/emulated/0/', '').split('/')];
      _loadDirectory(widget.initialPath!);
    }
  }

  Future<void> _loadStorage() async {
    final devices = await StorageService.getStorageDevices();
    if (mounted) setState(() => _storageDevices = devices);
  }

  Future<void> _navigateToRoot(StorageInfo device) async {
    setState(() {
      _currentRootPath = device.path;
      _pathStack = [device.label];
      _atRoot = false;
      _isSelectionMode = false;
      _selectedItems.clear();
    });
    await _loadDirectory(device.path);
  }

  Future<void> _loadDirectory(String path) async {
    setState(() => _loading = true);
    final settings = context.read<AppSettings>();
    final items = await FileSystemService.listDirectory(path, showHidden: settings.showHiddenFiles, sortBy: _sortBy, sortOrder: _sortOrder);
    if (mounted) setState(() { _files = items; _loading = false; });
  }

  void _enterFolder(FileItem folder) {
    setState(() {
      _pathStack.add(folder.name);
      _isSelectionMode = false;
      _selectedItems.clear();
    });
    _loadDirectory(folder.path);
  }

  void _navigateUp() {
    if (_pathStack.length <= 1) {
      if (widget.initialPath != null) { Navigator.pop(context); } else {
        setState(() { _atRoot = true; _pathStack = []; _currentRootPath = null; _files = []; });
      }
      return;
    }
    _pathStack.removeLast();
    final path = _buildCurrentPath();
    setState(() { _isSelectionMode = false; _selectedItems.clear(); });
    _loadDirectory(path);
  }

  void _navigateToIndex(int index) {
    _pathStack = _pathStack.sublist(0, index + 1);
    final path = _buildCurrentPath();
    setState(() {});
    _loadDirectory(path);
  }

  String _buildCurrentPath() {
    if (_pathStack.isEmpty || _currentRootPath == null) return '';
    if (_pathStack.length == 1) return _currentRootPath!;
    final subPath = _pathStack.sublist(1).join('/');
    return '$_currentRootPath/$subPath';
  }

  void _toggleSelectionMode() {
    setState(() { _isSelectionMode = !_isSelectionMode; _selectedItems.clear(); });
  }

  void _toggleItemSelection(FileItem item) {
    setState(() { _selectedItems.contains(item.path) ? _selectedItems.remove(item.path) : _selectedItems.add(item.path); });
  }

  void _performSelectionAction(String action) {
    setState(() {
      if (action == 'selectAll') { _selectedItems.addAll(_files.map((f) => f.path)); }
      else if (action == 'deselectAll') { _selectedItems.clear(); }
      else if (action == 'invert') {
        final all = _files.map((f) => f.path).toSet();
        final newSelected = all.difference(_selectedItems);
        _selectedItems.clear();
        _selectedItems.addAll(newSelected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return PopScope(
      canPop: _atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_atRoot) { _isSelectionMode ? _toggleSelectionMode() : _navigateUp(); }
      },
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context, primaryColor, isDark),
            Expanded(child: _atRoot ? _buildStorageList(context, primaryColor, isDark) : _buildFileList(context, settings, primaryColor, isDark)),
          ],
        ),
        floatingActionButton: !_atRoot && !_isSelectionMode ? _buildFAB(context, primaryColor) : null,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor, bool isDark) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isSelectionMode ? _buildSelectionHeader(context, primaryColor) : _buildNormalHeader(context, primaryColor),
        ),
      ),
    );
  }

  void _showHeaderDropdown(BuildContext context) {
    showMenu<dynamic>(
      context: context,
      position: const RelativeRect.fromLTRB(20, 100, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        const PopupMenuItem(enabled: false, child: Text('Current Path', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700))),
        ..._pathStack.asMap().entries.map((e) {
          final isLast = e.key == _pathStack.length - 1;
          return PopupMenuItem<dynamic>(
            value: e.key,
            child: Row(children: [ SizedBox(width: e.key * 12.0), Icon(isLast ? Icons.folder_open : Icons.folder, size: 20, color: isLast ? Theme.of(context).colorScheme.primary : Colors.grey), const SizedBox(width: 12), Text(e.value, style: GoogleFonts.inter(fontSize: 14, fontWeight: isLast ? FontWeight.bold : FontWeight.w500)) ]),
          );
        }),
        const PopupMenuDivider(),
        const PopupMenuItem(enabled: false, child: Text('Drives Sections', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700))),
        ..._storageDevices.map((d) => PopupMenuItem<dynamic>(
          value: d,
          child: Row(children: [ Icon(d.isRemovable ? Icons.sd_card : Icons.smartphone, size: 20, color: Colors.grey), const SizedBox(width: 12), Text(d.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))]),
        )),
      ],
    ).then((result) {
      if (result is int) { _navigateToIndex(result); }
      else if (result is StorageInfo) { _navigateToRoot(result); }
    });
  }

  Widget _buildNormalHeader(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          if (!_atRoot || widget.initialPath != null) IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _navigateUp),
          Expanded(
            child: _atRoot
                ? Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Files', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)))
                : GestureDetector(
                    onTap: () => _showHeaderDropdown(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [ Flexible(child: Text(_pathStack.last, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)), Icon(Icons.expand_more_rounded, color: primaryColor.withOpacity(0.7), size: 20) ]),
                          Text('/${_pathStack.join("/")}', style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45)), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
          ),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) { if (v == 'select') _toggleSelectionMode(); if (v == 'sort') {} },
            itemBuilder: (_) => [ if (!_atRoot) const PopupMenuItem(value: 'select', child: Text('Selection mode')), const PopupMenuItem(value: 'sort', child: Text('Sort by')) ],
          ),
        ],
      ),
    );
  }

  void _showSelectionBottomSheet(BuildContext context, Color primaryColor) {
    final selectedItems = _files.where((f) => _selectedItems.contains(f.path)).toList();
    final isSingle = selectedItems.length == 1;
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
            if (isSingle) ...[
              ListTile(leading: const Icon(Icons.open_in_new), title: const Text('Open'), onTap: () { Navigator.pop(context); _openFile(selectedItems.first, context); }),
              if (selectedItems.first.isArchive) ListTile(leading: const Icon(Icons.unarchive_outlined), title: const Text('Extract Here'), onTap: () { Navigator.pop(context); _extractArchive(selectedItems.first.path); }),
              ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Rename'), onTap: () { Navigator.pop(context); _showRenameModal(context, selectedItems.first, primaryColor); }),
            ],
            ListTile(leading: const Icon(Icons.content_copy), title: const Text('Copy'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.content_cut), title: const Text('Cut'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.folder_zip_outlined), title: const Text('Compress'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); _confirmBulkDelete(context); }),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: _toggleSelectionMode),
          Expanded(child: Text('${_selectedItems.length} selected', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.checklist_rounded), iconColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: _performSelectionAction,
            itemBuilder: (_) => [ const PopupMenuItem(value: 'selectAll', child: Text('Select All')), const PopupMenuItem(value: 'deselectAll', child: Text('Deselect All')), const PopupMenuItem(value: 'invert', child: Text('Invert Selection')) ],
          ),
          if (_selectedItems.isNotEmpty) IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () => _showSelectionBottomSheet(context, primaryColor)),
        ],
      ),
    );
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete selected'),
        content: Text('Delete ${_selectedItems.length} items? This cannot be undone.'),
        actions: [ TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')) ],
      ),
    );
    if (confirm == true) {
      for (final path in _selectedItems) { await FileSystemService.deleteItem(path); }
      _toggleSelectionMode();
      _loadDirectory(_buildCurrentPath());
    }
  }

  Widget _buildStorageList(BuildContext context, Color primaryColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: _storageDevices.map((device) {
        return _StorageDeviceCard(device: device, primaryColor: primaryColor, isDark: isDark, onTap: () => _navigateToRoot(device)).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildFileList(BuildContext context, AppSettings settings, Color primaryColor, bool isDark) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final isGrid = settings.defaultLayout == 'Grid';
    final hasGoBack = !_atRoot;
    final itemCount = _files.length + (hasGoBack ? 1 : 0);
    return RefreshIndicator(
      onRefresh: () => _loadDirectory(_buildCurrentPath()),
      child: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
              itemCount: itemCount,
              itemBuilder: (ctx, i) {
                if (hasGoBack && i == 0) return _buildGoBackGrid();
                final fileIndex = hasGoBack ? i - 1 : i;
                return FileItemGridCard(
                  item: _files[fileIndex], isSelected: _selectedItems.contains(_files[fileIndex].path), isSelectionMode: _isSelectionMode, primaryColor: primaryColor, isDark: isDark,
                  onTap: () => _handleItemTap(_files[fileIndex], context), onLongPress: () => _handleItemLongPress(_files[fileIndex], context),
                ).animate(delay: Duration(milliseconds: i * 20)).fadeIn(duration: 200.ms);
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
              itemCount: itemCount,
              itemBuilder: (ctx, i) {
                if (hasGoBack && i == 0) return _buildGoBackTile();
                final fileIndex = hasGoBack ? i - 1 : i;
                return FileItemTile(
                  item: _files[fileIndex], isSelected: _selectedItems.contains(_files[fileIndex].path), isSelectionMode: _isSelectionMode, primaryColor: primaryColor, isDark: isDark, showSize: settings.showFileSize, showDate: settings.showDateModified,
                  onTap: () => _handleItemTap(_files[fileIndex], context), onLongPress: () => _handleItemLongPress(_files[fileIndex], context), onMoreTap: () => _showBottomSheet(context, _files[fileIndex], primaryColor),
                ).animate(delay: Duration(milliseconds: i * 20)).fadeIn(duration: 200.ms);
              },
            ),
    );
  }

  Widget _buildGoBackTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.turn_left_rounded, color: Colors.grey)),
      title: Text('Go Back', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
      onTap: _navigateUp,
    );
  }

  Widget _buildGoBackGrid() {
    return GestureDetector(
      onTap: _navigateUp,
      child: Container(decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.turn_left_rounded, size: 32, color: Colors.grey), SizedBox(height: 8), Text('Go Back', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)) ])),
    );
  }

  void _handleItemTap(FileItem item, BuildContext context) {
    if (_isSelectionMode) { _toggleItemSelection(item); return; }
    if (item.isFolder) { _enterFolder(item); } else { _openFile(item, context); }
  }

  void _handleItemLongPress(FileItem item, BuildContext context) {
    HapticFeedback.mediumImpact();
    if (!_isSelectionMode) _toggleSelectionMode();
    _toggleItemSelection(item);
  }

  void _openFile(FileItem item, BuildContext context) {
    if (item.isArchive) { _showBottomSheet(context, item, AppTheme.getPrimaryColor(context.read<AppSettings>().theme)); return; }
    OpenFile.open(item.path);
  }

  void _showBottomSheet(BuildContext context, FileItem item, Color primaryColor) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => FileBottomSheet(
        item: item, primaryColor: primaryColor,
        onOpen: () { Navigator.pop(context); _openFile(item, context); },
        onCompress: () { Navigator.pop(context); _showCompressModal(context, item, primaryColor); },
        onRename: () { Navigator.pop(context); _showRenameModal(context, item, primaryColor); },
        onDelete: () { Navigator.pop(context); _deleteItem(context, item); },
        onDetails: () { Navigator.pop(context); _showDetails(context, item, primaryColor); },
        onShare: () { Navigator.pop(context); _shareItem(item); },
        onCopy: () { Navigator.pop(context); }, onCut: () { Navigator.pop(context); },
        currentPath: _buildCurrentPath(),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, FileItem item) async {
    final success = await FileSystemService.deleteItem(item.path);
    if (mounted && success) _loadDirectory(_buildCurrentPath());
  }

  void _showCompressModal(BuildContext context, FileItem item, Color primaryColor) {
    showDialog(
      context: context,
      builder: (_) => CompressModal(
        itemName: item.name, primaryColor: primaryColor,
        onCompress: (archiveName, format, password) async {
          Navigator.pop(context);
          await FileSystemService.compressItems([item.path], '$_buildCurrentPath()/$archiveName');
          _loadDirectory(_buildCurrentPath());
        },
      ),
    );
  }

  void _extractArchive(String path) async {
    await FileSystemService.extractArchive(path, _buildCurrentPath());
    _loadDirectory(_buildCurrentPath());
  }

  void _showRenameModal(BuildContext context, FileItem item, Color primaryColor) {
    showDialog(context: context, builder: (_) => RenameModal(currentName: item.name, primaryColor: primaryColor, onRename: (newName) async { Navigator.pop(context); final success = await FileSystemService.renameItem(item.path, newName); if (mounted && success) _loadDirectory(_buildCurrentPath()); }));
  }

  void _showDetails(BuildContext context, FileItem item, Color primaryColor) {
    showDialog(context: context, builder: (_) => DetailsModal(item: item, primaryColor: primaryColor, currentPath: _buildCurrentPath()));
  }

  void _shareItem(FileItem item) { Share.shareXFiles([XFile(item.path)], text: item.name); }
  
  Widget _buildFAB(BuildContext context, Color primaryColor) {
    return FloatingActionButton(
      onPressed: () {}, backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

class _StorageDeviceCard extends StatelessWidget {
  final StorageInfo device; final Color primaryColor; final bool isDark; final VoidCallback onTap;
  const _StorageDeviceCard({required this.device, required this.primaryColor, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? primaryColor.withOpacity(0.1) : const Color(0xFFE2E8F0)), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20), onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(width: 60, height: 60, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: device.usedPercent, backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0), color: primaryColor, strokeWidth: 3), Icon(device.isRemovable ? Icons.sd_card_rounded : Icons.smartphone_rounded, color: primaryColor, size: 22)])),
                const SizedBox(width: 18),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(device.label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('${device.usedFormatted} Used / ${device.totalFormatted} Total', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))), const SizedBox(height: 6), LinearProgressIndicator(value: device.usedPercent, backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0), color: primaryColor, borderRadius: BorderRadius.circular(4), minHeight: 4)])),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
