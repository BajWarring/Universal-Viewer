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
    if (widget.initialPath != null) {
      _atRoot = false;
      _currentRootPath = '/storage/emulated/0';
      _pathStack = ['Internal Storage', ...widget.initialPath!.replaceFirst('/storage/emulated/0/', '').split('/')];
      _loadDirectory(widget.initialPath!);
    } else {
      _loadStorage();
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
    final items = await FileSystemService.listDirectory(
      path,
      showHidden: settings.showHiddenFiles,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
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
      if (widget.initialPath != null) {
        Navigator.pop(context); // Pop if pushed as a shortcut
      } else {
        setState(() {
          _atRoot = true;
          _pathStack = [];
          _currentRootPath = null;
          _files = [];
        });
      }
      return;
    }
    _pathStack.removeLast();
    final path = _buildCurrentPath();
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
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
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }

  void _toggleItemSelection(FileItem item) {
    setState(() {
      if (_selectedItems.contains(item.path)) {
        _selectedItems.remove(item.path);
      } else {
        _selectedItems.add(item.path);
      }
    });
  }

  void _performSelectionAction(String action) {
    setState(() {
      if (action == 'selectAll') {
        _selectedItems.addAll(_files.map((f) => f.path));
      } else if (action == 'deselectAll') {
        _selectedItems.clear();
      } else if (action == 'invert') {
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
      onPopInvoked: (didPop) {
        if (!didPop && !_atRoot) {
          if (_isSelectionMode) {
            _toggleSelectionMode();
          } else {
            _navigateUp();
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context, primaryColor, isDark),
            Expanded(
              child: _atRoot
                  ? _buildStorageList(context, primaryColor, isDark)
                  : _buildFileList(context, settings, primaryColor, isDark),
            ),
          ],
        ),
        floatingActionButton: !_atRoot && !_isSelectionMode
            ? _buildFAB(context, primaryColor)
            : null,
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
          child: _isSelectionMode
              ? _buildSelectionHeader(context, primaryColor)
              : _buildNormalHeader(context, primaryColor),
        ),
      ),
    );
  }

  void _showHeaderDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(20, 100, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        const PopupMenuItem(enabled: false, child: Text('Current Path', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700))),
        ..._pathStack.asMap().entries.map((e) {
          final isLast = e.key == _pathStack.length - 1;
          return PopupMenuItem(
            value: e.key,
            child: Row(
              children: [
                SizedBox(width: e.key * 12.0),
                Icon(isLast ? Icons.folder_open : Icons.folder, size: 20, color: isLast ? Theme.of(context).colorScheme.primary : Colors.grey),
                const SizedBox(width: 12),
                Text(e.value, style: GoogleFonts.inter(fontSize: 14, fontWeight: isLast ? FontWeight.bold : FontWeight.w500)),
              ],
            ),
          );
        }),
      ],
    ).then((index) {
      if (index != null) _navigateToIndex(index as int);
    });
  }

  Widget _buildNormalHeader(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          if (!_atRoot || widget.initialPath != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _navigateUp,
            ),
          Expanded(
            child: _atRoot
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Files', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                  )
                : GestureDetector(
                    onTap: () => _showHeaderDropdown(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _pathStack.last,
                                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.expand_more_rounded, color: primaryColor.withOpacity(0.7), size: 20),
                            ],
                          ),
                          Text(
                            '/${_pathStack.join("/")}',
                            style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'select') _toggleSelectionMode();
              if (v == 'sort') _showSortDialog(context, primaryColor);
            },
            itemBuilder: (_) => [
              if (!_atRoot) const PopupMenuItem(value: 'select', child: Text('Selection mode')),
              const PopupMenuItem(value: 'sort', child: Text('Sort by')),
            ],
          ),
        ],
      ),
    );
  }

  void _showSelectionBottomSheet(BuildContext context, Color primaryColor) {
    final selectedItems = _files.where((f) => _selectedItems.contains(f.path)).toList();
    final isSingle = selectedItems.length == 1;
    final allApks = selectedItems.every((f) => f.isApk);

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
              ListTile(
                leading: Icon(selectedItems.first.isApk ? Icons.system_update : Icons.open_in_new),
                title: Text(selectedItems.first.isApk ? 'Install APK' : 'Open'),
                onTap: () { Navigator.pop(context); _openFile(selectedItems.first, context); },
              ),
              if (selectedItems.first.isApk)
                 ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('View APK contents'),
                  onTap: () { Navigator.pop(context); },
                ),
              if (selectedItems.first.isArchive)
                ListTile(
                  leading: const Icon(Icons.unarchive_outlined),
                  title: const Text('Extract Here'),
                  onTap: () { Navigator.pop(context); },
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () { Navigator.pop(context); _showRenameModal(context, selectedItems.first, primaryColor); },
              ),
            ],
            if (allApks && !isSingle)
              ListTile(
                leading: const Icon(Icons.system_update),
                title: const Text('Install Split APKs'),
                onTap: () { Navigator.pop(context); },
              ),
            ListTile(leading: const Icon(Icons.content_copy), title: const Text('Copy'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.content_cut), title: const Text('Cut'), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.folder_zip_outlined), title: const Text('Compress'), onTap: () { Navigator.pop(context); _showCompressModal(context, selectedItems.first, primaryColor); }),
            ListTile(leading: const Icon(Icons.info_outline), title: Text(isSingle ? 'Details' : 'Group Details'), onTap: () { Navigator.pop(context); if(isSingle) _showDetails(context, selectedItems.first, primaryColor); }),
            ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Share'), onTap: () { Navigator.pop(context); }),
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
          Expanded(
            child: Text('${_selectedItems.length} selected', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.checklist_rounded),
            iconColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: _performSelectionAction,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'selectAll', child: Text('Select All')),
              const PopupMenuItem(value: 'deselectAll', child: Text('Deselect All')),
              const PopupMenuItem(value: 'invert', child: Text('Invert Selection')),
            ],
          ),
          if (_selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showSelectionBottomSheet(context, primaryColor),
            ),
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final path in _selectedItems) {
        await FileSystemService.deleteItem(path);
      }
      _toggleSelectionMode();
      _loadDirectory(_buildCurrentPath());
    }
  }

  Widget _buildStorageList(BuildContext context, Color primaryColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: _storageDevices.map((device) {
        return _StorageDeviceCard(
          device: device,
          primaryColor: primaryColor,
          isDark: isDark,
          onTap: () => _navigateToRoot(device),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85
              ),
              itemCount: itemCount,
              itemBuilder: (ctx, i) {
                if (hasGoBack && i == 0) return _buildGoBackGrid();
                final fileIndex = hasGoBack ? i - 1 : i;
                return FileItemGridCard(
                  item: _files[fileIndex],
                  isSelected: _selectedItems.contains(_files[fileIndex].path),
                  isSelectionMode: _isSelectionMode, primaryColor: primaryColor, isDark: isDark,
                  onTap: () => _handleItemTap(_files[fileIndex], context),
                  onLongPress: () => _handleItemLongPress(_files[fileIndex], context),
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
                  item: _files[fileIndex],
                  isSelected: _selectedItems.contains(_files[fileIndex].path),
                  isSelectionMode: _isSelectionMode, primaryColor: primaryColor, isDark: isDark,
                  showSize: settings.showFileSize, showDate: settings.showDateModified,
                  onTap: () => _handleItemTap(_files[fileIndex], context),
                  onLongPress: () => _handleItemLongPress(_files[fileIndex], context),
                  onMoreTap: () => _showBottomSheet(context, _files[fileIndex], primaryColor),
                ).animate(delay: Duration(milliseconds: i * 20)).fadeIn(duration: 200.ms);
              },
            ),
    );
  }

  Widget _buildGoBackTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.turn_left_rounded, color: Colors.grey),
      ),
      title: Text('Go Back', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
      onTap: _navigateUp,
    );
  }

  Widget _buildGoBackGrid() {
    return GestureDetector(
      onTap: _navigateUp,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.turn_left_rounded, size: 32, color: Colors.grey),
            SizedBox(height: 8),
            Text('Go Back', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
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
    if (item.isArchive) {
      _showBottomSheet(context, item, AppTheme.getPrimaryColor(context.read<AppSettings>().theme));
      return;
    }
    OpenFile.open(item.path);
  }

  void _showBottomSheet(BuildContext context, FileItem item, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
          _loadDirectory(_buildCurrentPath());
        },
      ),
    );
  }

  void _showRenameModal(BuildContext context, FileItem item, Color primaryColor) {
    showDialog(
      context: context,
      builder: (_) => RenameModal(
        currentName: item.name, primaryColor: primaryColor,
        onRename: (newName) async {
          Navigator.pop(context);
          final success = await FileSystemService.renameItem(item.path, newName);
          if (mounted && success) _loadDirectory(_buildCurrentPath());
        },
      ),
    );
  }

  void _showDetails(BuildContext context, FileItem item, Color primaryColor) {
    showDialog(context: context, builder: (_) => DetailsModal(item: item, primaryColor: primaryColor, currentPath: _buildCurrentPath()));
  }

  void _shareItem(FileItem item) { Share.shareXFiles([XFile(item.path)], text: item.name); }

  void _showSortDialog(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        currentSortBy: _sortBy, currentOrder: _sortOrder, primaryColor: primaryColor,
        onSortChanged: (by, order) { setState(() { _sortBy = by; _sortOrder = order; }); _loadDirectory(_buildCurrentPath()); },
      ),
    );
  }

  Widget _buildFAB(BuildContext context, Color primaryColor) {
    return FloatingActionButton(
      onPressed: () => _showCreateOptions(context, primaryColor),
      backgroundColor: primaryColor, foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _showCreateOptions(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _CreateOptionsSheet(
        primaryColor: primaryColor,
        onCreateFolder: () { Navigator.pop(context); _showCreateFolderDialog(context, primaryColor); },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (_) => CreateFolderDialog(
        primaryColor: primaryColor,
        onCreate: (name) async {
          Navigator.pop(context);
          final success = await FileSystemService.createFolder(_buildCurrentPath(), name);
          if (mounted && success) _loadDirectory(_buildCurrentPath());
        },
      ),
    );
  }
}

// ---- Sub-widgets (Fully Restored) ----

class _StorageDeviceCard extends StatelessWidget {
  final StorageInfo device;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _StorageDeviceCard({
    required this.device,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? primaryColor.withOpacity(0.1) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: device.usedPercent,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0),
                        color: primaryColor,
                        strokeWidth: 3,
                      ),
                      Icon(
                        device.isRemovable ? Icons.sd_card_rounded : Icons.smartphone_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${device.usedFormatted} Used / ${device.totalFormatted} Total',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: device.usedPercent,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0),
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
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

class _SortSheet extends StatefulWidget {
  final SortBy currentSortBy;
  final SortOrder currentOrder;
  final Color primaryColor;
  final Function(SortBy, SortOrder) onSortChanged;

  const _SortSheet({
    required this.currentSortBy,
    required this.currentOrder,
    required this.primaryColor,
    required this.onSortChanged,
  });

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late SortBy _sortBy;
  late SortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSortBy;
    _sortOrder = widget.currentOrder;
  }

  @override
  Widget build(BuildContext context) {
    final opts = [
      (SortBy.name, 'Name', Icons.sort_by_alpha_rounded),
      (SortBy.size, 'Size', Icons.format_size_rounded),
      (SortBy.date, 'Date', Icons.calendar_today_rounded),
      (SortBy.type, 'Type', Icons.category_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Sort By', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...opts.map((o) => RadioListTile<SortBy>(
            value: o.$1, groupValue: _sortBy,
            title: Row(children: [Icon(o.$3, size: 18, color: widget.primaryColor), const SizedBox(width: 10), Text(o.$2, style: GoogleFonts.inter(fontWeight: FontWeight.w600))]),
            activeColor: widget.primaryColor,
            onChanged: (v) => setState(() => _sortBy = v!),
          )),
          const Divider(height: 16),
          RadioListTile<SortOrder>(
            value: SortOrder.asc, groupValue: _sortOrder,
            title: Row(children: const [Icon(Icons.arrow_upward_rounded, size: 18), SizedBox(width: 10), Text('Ascending')]),
            activeColor: widget.primaryColor,
            onChanged: (v) => setState(() => _sortOrder = v!),
          ),
          RadioListTile<SortOrder>(
            value: SortOrder.desc, groupValue: _sortOrder,
            title: Row(children: const [Icon(Icons.arrow_downward_rounded, size: 18), SizedBox(width: 10), Text('Descending')]),
            activeColor: widget.primaryColor,
            onChanged: (v) => setState(() => _sortOrder = v!),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () { Navigator.pop(context); widget.onSortChanged(_sortBy, _sortOrder); },
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _CreateOptionsSheet extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onCreateFolder;

  const _CreateOptionsSheet({required this.primaryColor, required this.onCreateFolder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.create_new_folder_rounded, color: primaryColor),
            ),
            title: Text('New Folder', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            subtitle: const Text('Create a new folder'),
            onTap: onCreateFolder,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

// Folder View Screen (navigated to from home screen shortcuts)
class FolderViewScreen extends StatefulWidget {
  final String path;
  final String title;

  const FolderViewScreen({super.key, required this.path, required this.title});

  @override
  State<FolderViewScreen> createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends State<FolderViewScreen> {
  List<FileItem> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = context.read<AppSettings>();
    final items = await FileSystemService.listDirectory(widget.path, showHidden: settings.showHiddenFiles);
    if (mounted) setState(() { _files = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: _files.length,
              itemBuilder: (ctx, i) => FileItemTile(
                item: _files[i],
                isSelected: false,
                isSelectionMode: false,
                primaryColor: primaryColor,
                isDark: isDark,
                showSize: settings.showFileSize,
                showDate: settings.showDateModified,
                onTap: () {
                  if (_files[i].isFolder) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FolderViewScreen(path: _files[i].path, title: _files[i].name),
                    ));
                  } else {
                    OpenFile.open(_files[i].path);
                  }
                },
                onLongPress: () {},
              ),
            ),
    );
  }
}
