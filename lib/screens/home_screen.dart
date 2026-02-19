import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/file_system_service.dart';
import '../utils/storage_service.dart';
import 'files_screen.dart';

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

  final List<_PinnedFolder> _pinnedFolders = [
    _PinnedFolder('Camera', Icons.camera_alt_rounded, '/storage/emulated/0/DCIM/Camera'),
    _PinnedFolder('Downloads', Icons.download_rounded, '/storage/emulated/0/Download'),
    _PinnedFolder('WhatsApp', Icons.chat_rounded, '/storage/emulated/0/WhatsApp'),
    _PinnedFolder('Documents', Icons.description_rounded, '/storage/emulated/0/Documents'),
    _PinnedFolder('Music', Icons.music_note_rounded, '/storage/emulated/0/Music'),
    _PinnedFolder('Screenshots', Icons.screenshot_rounded, '/storage/emulated/0/Pictures/Screenshots'),
  ];

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
                _buildPinnedFolders(context, primaryColor, isDark),
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
            Text(
              'Omni',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'File Manager',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => _showSearch(context, primaryColor),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showSearch(BuildContext context, Color primaryColor) {
    showSearch(
      context: context,
      delegate: _FileSearchDelegate(primaryColor: primaryColor),
    );
  }

  Widget _buildPinnedFolders(BuildContext context, Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
          child: Row(
            children: [
              Text(
                'PINNED FOLDERS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.tune_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _pinnedFolders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final folder = _pinnedFolders[i];
              return _PinnedFolderCard(
                folder: folder,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _navigateToFolder(context, folder.path, folder.name),
              ).animate(delay: Duration(milliseconds: i * 60))
               .fadeIn(duration: 300.ms)
               .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  void _navigateToFolder(BuildContext context, String path, String name) {
    // Navigate to files tab with this path
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FolderViewScreen(path: path, title: name),
    ));
  }

  Widget _buildStorageSection(BuildContext context, Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Text(
            'STORAGE DEVICES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        if (_loadingStorage)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SizedBox(
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
                ).animate(delay: Duration(milliseconds: i * 80))
                 .fadeIn(duration: 400.ms)
                 .slideY(begin: 0.2, end: 0);
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
              Text(
                'RECENT FILES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('View all', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        if (_loadingRecent)
          const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
        else if (_recentFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: Text(
                'No recent files',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _recentFiles.take(5).toList().asMap().entries.map((e) {
                return _RecentFileCard(
                  item: e.value,
                  primaryColor: primaryColor,
                  isDark: isDark,
                ).animate(delay: Duration(milliseconds: e.key * 50))
                 .fadeIn(duration: 300.ms)
                 .slideY(begin: 0.1, end: 0);
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _PinnedFolder {
  final String name;
  final IconData icon;
  final String path;
  _PinnedFolder(this.name, this.icon, this.path);
}

class _PinnedFolderCard extends StatelessWidget {
  final _PinnedFolder folder;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _PinnedFolderCard({
    required this.folder,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 100,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(folder.icon, color: primaryColor, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
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

  const _StorageCard({
    required this.device,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular progress
              SizedBox(
                width: 52,
                height: 52,
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
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                device.label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${device.usedFormatted} / ${device.totalFormatted}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
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

  const _RecentFileCard({
    required this.item,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.getColor(primaryColor).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.getColor(primaryColor), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${FileSystemService.formatDate(item.modified)} • ${FileSystemService.formatSize(item.size)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(Icons.folder_outlined, size: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.path.replaceFirst('/storage/emulated/0', '/Internal'),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Search Delegate
class _FileSearchDelegate extends SearchDelegate<FileItem?> {
  final Color primaryColor;
  List<FileItem> _results = [];
  bool _searching = false;

  _FileSearchDelegate({required this.primaryColor});

  @override
  String get searchFieldLabel => 'Search files...';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildResultsList(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length >= 2) return _buildResultsList(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('Type to search files', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    if (query.length < 2) return const SizedBox();
    return FutureBuilder<List<FileItem>>(
      future: FileSystemService.searchFiles('/storage/emulated/0', query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Text('No results for "$query"', style: const TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) {
            final item = results[i];
            return ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: item.getColor(primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.getColor(primaryColor), size: 20),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(item.path, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
              trailing: Text(
                FileSystemService.formatSize(item.size),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              onTap: () => close(context, item),
            );
          },
        );
      },
    );
  }
}
