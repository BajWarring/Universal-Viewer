import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/file_system_service.dart';
import '../widgets/file_item_tile.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<FileItem> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final files = await FileSystemService.getRecentFiles('/storage/emulated/0', limit: 50);
    if (mounted) setState(() { _files = files; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);
    final isDark = settings.darkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Recent', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_files.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_rounded, size: 72, color: primaryColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No recent files', style: GoogleFonts.inter(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => FileItemTile(
                    item: _files[i],
                    isSelected: false,
                    isSelectionMode: false,
                    primaryColor: primaryColor,
                    isDark: isDark,
                    showSize: settings.showFileSize,
                    showDate: settings.showDateModified,
                    onTap: () => OpenFile.open(_files[i].path),
                    onLongPress: () {},
                  ),
                  childCount: _files.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
