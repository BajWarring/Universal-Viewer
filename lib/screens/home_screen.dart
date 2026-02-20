import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/file_system_service.dart';
import '../utils/storage_service.dart';
import '../widgets/bottom_sheet_menu.dart';
import 'files_screen.dart';
import 'pinned_folders_screen.dart';
import 'recent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StorageInfo> _storageDevices = [];
  List<FileItem> _recentFiles = [];
  bool _loadingStorage = true;
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadStorage();
    await _loadRecent();
  }

  Future<void> _loadStorage() async {
    final devices = await StorageService.getStorageDevices();
    if (mounted) setState(() { _storageDevices = devices; _loadingStorage = false; });
  }

  Future<void> _loadRecent() async {
    try {
      final files = await FileSystemService.getRecentFiles('/storage/emulated/0', limit: 10);
      if (mounted) setState(() { _recentFiles = files; _loadingRecent = false; });
    } catch (_) {
      if (mounted) setState(() { _loadingRecent = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, primaryColor),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildPinnedFolders(context, settings, primaryColor, isDark),
                const SizedBox(height: 8),
                _buildStorageSection(context, primaryColor, isDark),
                const SizedBox(height: 8),
                _buildRecentFiles(context, primaryColor, isDark),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color primaryColor) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 110,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Omni', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('File Manager', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildPinnedFolders(BuildContext context, AppSettings settings, Color primaryColor, bool isDark) {
    final pinned = settings.pinnedFolders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
          child: Row(
            children: [
              Text('PINNED FOLDERS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PinnedFoldersScreen())),
                child: Text('Edit', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pinned.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final folder = pinned[i];
              return _PinnedFolderCard(
                name: folder['name']!,
                path: folder['path']!,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _navigateToFolder(context, folder['path']!, folder['name']!),
              ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  void _navigateToFolder(BuildContext context, String path, String name) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FilesScreen(initialPath: path, initialTitle: name)));
  }

  Widget _buildStorageSection(BuildContext context, Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Text('STORAGE DEVICES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ),
        if (_loadingStorage) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
        else SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _storageDevices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final device = _storageDevices[i];
              return _StorageCard(
                device: device,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _navigateToFolder(context, device.path, device.label),
              ).animate(delay: Duration(milliseconds: i * 80)).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFiles(BuildContext context, Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
          child: Row(
            children: [
              Text('RECENT FILES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentScreen())),
                child: Text('View all', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        if (_loadingRecent) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
        else if (_recentFiles.isEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Center(child: Text('No recent files', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)))))
        else Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _recentFiles.take(5).toList().asMap().entries.map((e) {
              return _RecentFileCard(
                item: e.value,
                primaryColor: primaryColor,
                isDark: isDark,
                onMoreTap: () => _showFileOptions(context, e.value, primaryColor),
              ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showFileOptions(BuildContext context, FileItem item, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FileBottomSheet(
        item: item,
        primaryColor: primaryColor,
        currentPath: '/storage/emulated/0',
        onOpen: () { Navigator.pop(context); OpenFile.open(item.path); },
        onCompress: () { Navigator.pop(context); },
        onRename: () { Navigator.pop(context); },
        onDelete: () { Navigator.pop(context); },
        onDetails: () { Navigator.pop(context); },
        onShare: () { Navigator.pop(context); },
        onCopy: () { Navigator.pop(context); },
        onCut: () { Navigator.pop(context); },
      ),
    );
  }
}

class _PinnedFolderCard extends StatelessWidget {
  final String name, path;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _PinnedFolderCard({required this.name, required this.path, required this.primaryColor, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110, height: 100,
        decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.04) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0)), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.folder_rounded, color: primaryColor, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis, maxLines: 1)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  final StorageInfo device;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _StorageCard({required this.device, required this.primaryColor, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 52, height: 52, child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(value: device.usedPercent, backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0), color: primaryColor, strokeWidth: 3),
                Icon(device.isRemovable ? (device.label.contains('USB') ? Icons.usb : Icons.sd_card_rounded) : Icons.smartphone_rounded, color: primaryColor, size: 20),
              ])),
              const SizedBox(height: 8),
              Text(device.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${device.usedFormatted} / ${device.totalFormatted}', style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentFileCard extends StatelessWidget {
  final FileItem item;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onMoreTap;

  const _RecentFileCard({required this.item, required this.primaryColor, required this.isDark, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.04) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () { OpenFile.open(item.path); },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: item.getColor(primaryColor).withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(item.icon, color: item.getColor(primaryColor), size: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1),
                      const SizedBox(height: 2),
                      Text('${FileSystemService.formatDate(item.modified)} • ${FileSystemService.formatSize(item.size)}', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      const SizedBox(height: 1),
                      Row(children: [Icon(Icons.folder_outlined, size: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)), const SizedBox(width: 3), Expanded(child: Text(item.path.replaceFirst('/storage/emulated/0', '/Internal'), style: GoogleFonts.inter(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)), overflow: TextOverflow.ellipsis, maxLines: 1))]),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), color: Colors.grey, onPressed: onMoreTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
