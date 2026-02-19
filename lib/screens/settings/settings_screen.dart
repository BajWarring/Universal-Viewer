import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_settings.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsCategory? _currentCategory;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final primaryColor = AppTheme.getPrimaryColor(settings.theme);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _currentCategory == null
            ? _buildMainMenu(context, primaryColor)
            : _buildCategoryPage(context, _currentCategory!, settings, primaryColor),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, Color primaryColor) {
    return CustomScrollView(
      key: const ValueKey('main'),
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: _categories.asMap().entries.map((e) {
                    final isLast = e.key == _categories.length - 1;
                    final cat = e.value;
                    return _SettingsMenuRow(
                      category: cat,
                      primaryColor: primaryColor,
                      showDivider: !isLast,
                      onTap: () => setState(() => _currentCategory = cat),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPage(BuildContext context, _SettingsCategory cat, AppSettings settings, Color primaryColor) {
    return CustomScrollView(
      key: ValueKey(cat.id),
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => setState(() => _currentCategory = null),
          ),
          title: Text(cat.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildItems(cat, settings, primaryColor, context),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItems(_SettingsCategory cat, AppSettings settings, Color primaryColor, BuildContext context) {
    if (cat.id == 'appearance') {
      return [
        _ThemeCarousel(settings: settings, primaryColor: primaryColor),
        const Divider(height: 1, indent: 16, endIndent: 16),
        ..._standardItems(cat, settings, primaryColor, context),
      ];
    }
    return _standardItems(cat, settings, primaryColor, context);
  }

  List<Widget> _standardItems(_SettingsCategory cat, AppSettings settings, Color primaryColor, BuildContext context) {
    final items = cat.id == 'appearance' ? cat.items.skip(1).toList() : cat.items;
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.type == 'section_header') {
        result.add(_SectionHeader(label: item.label!, primaryColor: primaryColor));
        continue;
      }
      result.add(_SettingsItemRow(
        item: item,
        settings: settings,
        primaryColor: primaryColor,
        showDivider: i < items.length - 1 && items[i + 1].type != 'section_header',
        onChanged: (v) => settings.setSetting(item.id!, v),
        onButtonTap: () {
          if (item.id == 'resetPrefs') {
            settings.resetToDefaults();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences reset to defaults'), behavior: SnackBarBehavior.floating),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.label} triggered'), behavior: SnackBarBehavior.floating),
            );
          }
        },
      ));
    }
    return result;
  }
}

// ─── Settings Item Row ────────────────────────────────────────────────────────

class _SettingsItemRow extends StatelessWidget {
  final _SettingsItem item;
  final AppSettings settings;
  final Color primaryColor;
  final bool showDivider;
  final ValueChanged<dynamic> onChanged;
  final VoidCallback? onButtonTap;

  const _SettingsItemRow({
    required this.item,
    required this.settings,
    required this.primaryColor,
    required this.showDivider,
    required this.onChanged,
    this.onButtonTap,
  });

  dynamic _getValue() {
    switch (item.id) {
      case 'darkMode': return settings.darkMode;
      case 'followSystemTheme': return settings.followSystemTheme;
      case 'animationIntensity': return settings.animationIntensity;
      case 'layoutDensity': return settings.layoutDensity;
      case 'iconSize': return settings.iconSize;
      case 'enableThumbnails': return settings.enableThumbnails;
      case 'imgThumbs': return settings.imgThumbs;
      case 'vidThumb': return settings.vidThumb;
      case 'pdfThumbs': return settings.pdfThumbs;
      case 'albumCovers': return settings.albumCovers;
      case 'apkIcons': return settings.apkIcons;
      case 'archiveThumbs': return settings.archiveThumbs;
      case 'thumbnailQuality': return settings.thumbnailQuality;
      case 'wifiOnlyThumbs': return settings.wifiOnlyThumbs;
      case 'chargeOnlyThumbs': return settings.chargeOnlyThumbs;
      case 'defaultLayout': return settings.defaultLayout;
      case 'rememberLayout': return settings.rememberLayout;
      case 'showStorageBars': return settings.showStorageBars;
      case 'showItemCount': return settings.showItemCount;
      case 'showExtensions': return settings.showExtensions;
      case 'showFileSize': return settings.showFileSize;
      case 'showDateModified': return settings.showDateModified;
      case 'showTimeModified': return settings.showTimeModified;
      case 'showTypeLabel': return settings.showTypeLabel;
      case 'showFullPath': return settings.showFullPath;
      case 'sizeFormat': return settings.sizeFormat;
      case 'dateFormat': return settings.dateFormat;
      case 'startupLocation': return settings.startupLocation;
      case 'openLastSession': return settings.openLastSession;
      case 'defaultOpenAction': return settings.defaultOpenAction;
      case 'singleTapOpen': return settings.singleTapOpen;
      case 'showHiddenFiles': return settings.showHiddenFiles;
      case 'dimHiddenFiles': return settings.dimHiddenFiles;
      case 'autoRefresh': return settings.autoRefresh;
      case 'confirmDelete': return settings.confirmDelete;
      case 'confirmOverwrite': return settings.confirmOverwrite;
      case 'confirmLargeMove': return settings.confirmLargeMove;
      case 'largeFileThreshold': return settings.largeFileThreshold;
      case 'showProgressDialog': return settings.showProgressDialog;
      case 'searchSubfolders': return settings.searchSubfolders;
      case 'searchHidden': return settings.searchHidden;
      case 'rememberSearches': return settings.rememberSearches;
      case 'defaultArchiveFormat': return settings.defaultArchiveFormat;
      case 'archiveCompressionLevel': return settings.archiveCompressionLevel;
      case 'defaultEncryption': return settings.defaultEncryption;
      case 'autoExtractDownloads': return settings.autoExtractDownloads;
      case 'deleteSourceAfterCompress': return settings.deleteSourceAfterCompress;
      case 'bgIndexing': return settings.bgIndexing;
      case 'autoScanMedia': return settings.autoScanMedia;
      case 'parallelOps': return settings.parallelOps;
      case 'lowMemoryMode': return settings.lowMemoryMode;
      case 'longPressDuration': return settings.longPressDuration;
      case 'enableSwipe': return settings.enableSwipe;
      case 'swipeLeft': return settings.swipeLeft;
      case 'swipeRight': return settings.swipeRight;
      case 'hapticFeedback': return settings.hapticFeedback;
      case 'debugLogs': return settings.debugLogs;
      case 'experimentalFeatures': return settings.experimentalFeatures;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _getValue();
    Widget trailing;

    if (item.type == 'toggle') {
      trailing = Switch(
        value: value as bool? ?? false,
        onChanged: onChanged,
        activeColor: primaryColor,
      );
    } else if (item.type == 'dropdown') {
      trailing = _CompactDropdown(
        options: item.options!,
        value: value as String? ?? item.options!.first,
        primaryColor: primaryColor,
        onChanged: (v) => onChanged(v),
      );
    } else if (item.type == 'slider') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${value ?? item.min} MB', style: GoogleFonts.inter(fontSize: 13, color: primaryColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Slider(
            value: (value as int? ?? item.min!).toDouble(),
            min: item.min!.toDouble(),
            max: item.max!.toDouble(),
            divisions: ((item.max! - item.min!) / item.step!).round(),
            activeColor: primaryColor,
            onChanged: (v) => onChanged(v.round()),
          ),
          if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      );
    } else if (item.type == 'text') {
      trailing = Text(item.staticValue ?? '', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500));
    } else if (item.type == 'button') {
      trailing = TextButton(
        onPressed: onButtonTap,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('Open', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
      );
    } else {
      trailing = const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(item.label!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _CompactDropdown extends StatelessWidget {
  final List<String> options;
  final String value;
  final Color primaryColor;
  final ValueChanged<String?> onChanged;

  const _CompactDropdown({
    required this.options,
    required this.value,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options.map((o) => DropdownMenuItem(
            value: o,
            child: Text(o, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          )).toList(),
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
          isDense: true,
          iconSize: 18,
          dropdownColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color primaryColor;
  const _SectionHeader({required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: primaryColor),
      ),
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  final _SettingsCategory category;
  final Color primaryColor;
  final bool showDivider;
  final VoidCallback onTap;

  const _SettingsMenuRow({
    required this.category,
    required this.primaryColor,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          title: Text(category.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          subtitle: Text(category.desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}

// ─── Theme Carousel ───────────────────────────────────────────────────────────

class _ThemeCarousel extends StatelessWidget {
  final AppSettings settings;
  final Color primaryColor;

  const _ThemeCarousel({required this.settings, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: AppTheme.themeNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final name = AppTheme.themeNames[i];
          final isActive = settings.theme == name;
          final color = AppTheme.getPrimaryColor(name);
          return GestureDetector(
            onTap: () {
              if (name == 'Simple Light') settings.setSetting('darkMode', false);
              if (name == 'Simple Dark' || name == 'Pure Black') settings.setSetting('darkMode', true);
              settings.setSetting('theme', name);
            },
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 126,
                  decoration: BoxDecoration(
                    color: name == 'Simple Light' ? Colors.white : name == 'Pure Black' ? Colors.black : const Color(0xFF1D2636),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive ? color : Colors.grey.withOpacity(0.25),
                      width: isActive ? 2.5 : 1.5,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          width: 26, height: 5,
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              Positioned(left: 6, top: 6, child: Container(width: 14, height: 20, decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: BorderRadius.circular(3)))),
                              Positioned(left: 14, top: 6, child: Container(width: 14, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)))),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            Container(width: 28, height: 14, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(7))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Data Schema ──────────────────────────────────────────────────────────────

class _SettingsCategory {
  final String id, title, desc;
  final IconData icon;
  final List<_SettingsItem> items;
  _SettingsCategory(this.id, this.title, this.desc, this.icon, this.items);
}

class _SettingsItem {
  final String type;
  final String? id, label, staticValue;
  final List<String>? options;
  final int? min, max, step;
  _SettingsItem({required this.type, this.id, this.label, this.staticValue, this.options, this.min, this.max, this.step});
}

final _categories = [
  _SettingsCategory('appearance', 'Appearance & Themes', 'Visual identity and feel', Icons.palette_outlined, [
    _SettingsItem(type: 'carousel_theme_picker', id: 'theme', label: 'Theme'),
    _SettingsItem(type: 'toggle', id: 'darkMode', label: 'Dark mode'),
    _SettingsItem(type: 'toggle', id: 'followSystemTheme', label: 'Follow system theme'),
    _SettingsItem(type: 'dropdown', id: 'animationIntensity', label: 'Animation intensity', options: ['Full', 'Reduced']),
    _SettingsItem(type: 'dropdown', id: 'layoutDensity', label: 'Layout density', options: ['Comfortable', 'Compact']),
    _SettingsItem(type: 'dropdown', id: 'iconSize', label: 'Icon size', options: ['Small', 'Medium', 'Large']),
  ]),
  _SettingsCategory('previews', 'Previews & Thumbnails', 'Manage file media previews', Icons.image_outlined, [
    _SettingsItem(type: 'toggle', id: 'enableThumbnails', label: 'Enable thumbnails'),
    _SettingsItem(type: 'toggle', id: 'imgThumbs', label: 'Image thumbnails'),
    _SettingsItem(type: 'toggle', id: 'vidThumb', label: 'Video thumbnails'),
    _SettingsItem(type: 'toggle', id: 'pdfThumbs', label: 'PDF thumbnails'),
    _SettingsItem(type: 'toggle', id: 'albumCovers', label: 'Album covers'),
    _SettingsItem(type: 'toggle', id: 'apkIcons', label: 'APK icons'),
    _SettingsItem(type: 'toggle', id: 'archiveThumbs', label: 'Archive thumbnails'),
    _SettingsItem(type: 'dropdown', id: 'thumbnailQuality', label: 'Thumbnail quality', options: ['Low', 'Balanced', 'High']),
    _SettingsItem(type: 'toggle', id: 'wifiOnlyThumbs', label: 'Generate thumbnails only on Wi-Fi'),
    _SettingsItem(type: 'toggle', id: 'chargeOnlyThumbs', label: 'Generate thumbnails only while charging'),
    _SettingsItem(type: 'button', id: 'clearThumbs', label: 'Clear thumbnail cache'),
  ]),
  _SettingsCategory('layout', 'Layout & Display', 'Lists, grids, and file info', Icons.grid_view_rounded, [
    _SettingsItem(type: 'section_header', label: 'General Display'),
    _SettingsItem(type: 'dropdown', id: 'defaultLayout', label: 'Default layout', options: ['List', 'Grid', 'Compact list']),
    _SettingsItem(type: 'toggle', id: 'rememberLayout', label: 'Remember layout per folder'),
    _SettingsItem(type: 'toggle', id: 'showStorageBars', label: 'Show storage usage bars'),
    _SettingsItem(type: 'toggle', id: 'showItemCount', label: 'Show folder item count'),
    _SettingsItem(type: 'toggle', id: 'showExtensions', label: 'Show file extensions'),
    _SettingsItem(type: 'section_header', label: 'File Info Display'),
    _SettingsItem(type: 'toggle', id: 'showFileSize', label: 'Show file size'),
    _SettingsItem(type: 'toggle', id: 'showDateModified', label: 'Show date modified'),
    _SettingsItem(type: 'toggle', id: 'showTimeModified', label: 'Show time modified'),
    _SettingsItem(type: 'toggle', id: 'showTypeLabel', label: 'Show file type label'),
    _SettingsItem(type: 'toggle', id: 'showFullPath', label: 'Show full path preview'),
    _SettingsItem(type: 'dropdown', id: 'sizeFormat', label: 'Size format', options: ['Human readable', 'Exact bytes']),
    _SettingsItem(type: 'dropdown', id: 'dateFormat', label: 'Date format', options: ['Relative', 'Full date']),
  ]),
  _SettingsCategory('general', 'General Behavior', 'Startup and default actions', Icons.tune_rounded, [
    _SettingsItem(type: 'dropdown', id: 'startupLocation', label: 'Startup location', options: ['Last opened', 'Internal storage', 'Custom folder']),
    _SettingsItem(type: 'toggle', id: 'openLastSession', label: 'Open last session on launch'),
    _SettingsItem(type: 'dropdown', id: 'defaultOpenAction', label: 'Default open action', options: ['Open file', 'Preview']),
    _SettingsItem(type: 'toggle', id: 'singleTapOpen', label: 'Single tap to open'),
    _SettingsItem(type: 'toggle', id: 'showHiddenFiles', label: 'Show hidden files'),
    _SettingsItem(type: 'toggle', id: 'dimHiddenFiles', label: 'Dim hidden files'),
    _SettingsItem(type: 'toggle', id: 'autoRefresh', label: 'Auto refresh folders'),
  ]),
  _SettingsCategory('safety', 'Safety & Confirmations', 'Deletion and warnings', Icons.security_outlined, [
    _SettingsItem(type: 'toggle', id: 'confirmDelete', label: 'Confirm before delete'),
    _SettingsItem(type: 'toggle', id: 'confirmOverwrite', label: 'Confirm before overwrite'),
    _SettingsItem(type: 'toggle', id: 'confirmLargeMove', label: 'Confirm before moving large files'),
    _SettingsItem(type: 'slider', id: 'largeFileThreshold', label: 'Large file threshold (MB)', min: 10, max: 2000, step: 10),
    _SettingsItem(type: 'toggle', id: 'showProgressDialog', label: 'Show operation progress dialog'),
  ]),
  _SettingsCategory('search', 'Search', 'Search filters and history', Icons.search_rounded, [
    _SettingsItem(type: 'toggle', id: 'searchSubfolders', label: 'Search subfolders by default'),
    _SettingsItem(type: 'toggle', id: 'searchHidden', label: 'Include hidden files'),
    _SettingsItem(type: 'toggle', id: 'rememberSearches', label: 'Remember recent searches'),
    _SettingsItem(type: 'button', id: 'clearSearchHistory', label: 'Clear search history'),
  ]),
  _SettingsCategory('archives', 'Archives', 'Compression formats', Icons.folder_zip_outlined, [
    _SettingsItem(type: 'dropdown', id: 'defaultArchiveFormat', label: 'Default compression format', options: ['ZIP', '7z', 'TAR']),
    _SettingsItem(type: 'dropdown', id: 'archiveCompressionLevel', label: 'Compression level', options: ['Fast', 'Balanced', 'Maximum']),
    _SettingsItem(type: 'dropdown', id: 'defaultEncryption', label: 'Default encryption', options: ['None', 'ZipCrypto', 'AES-256']),
    _SettingsItem(type: 'toggle', id: 'autoExtractDownloads', label: 'Auto extract after download'),
    _SettingsItem(type: 'toggle', id: 'deleteSourceAfterCompress', label: 'Delete source after compression'),
  ]),
  _SettingsCategory('performance', 'Performance & Storage', 'Caching and indexing', Icons.speed_rounded, [
    _SettingsItem(type: 'toggle', id: 'bgIndexing', label: 'Enable background indexing'),
    _SettingsItem(type: 'toggle', id: 'autoScanMedia', label: 'Scan media automatically'),
    _SettingsItem(type: 'dropdown', id: 'parallelOps', label: 'Limit parallel operations', options: ['1', '2', '4']),
    _SettingsItem(type: 'toggle', id: 'lowMemoryMode', label: 'Low memory mode'),
    _SettingsItem(type: 'button', id: 'clearCache', label: 'Clear all caches'),
  ]),
  _SettingsCategory('permissions', 'Permissions', 'App access control', Icons.lock_outlined, [
    _SettingsItem(type: 'text', id: 'permStatus', label: 'Storage permission status', staticValue: 'Granted'),
    _SettingsItem(type: 'button', id: 'managePerms', label: 'Manage permissions'),
    _SettingsItem(type: 'button', id: 'restrictedFolders', label: 'Show restricted folders'),
  ]),
  _SettingsCategory('gestures', 'Gestures & Interaction', 'Swipes and haptics', Icons.swipe_rounded, [
    _SettingsItem(type: 'dropdown', id: 'longPressDuration', label: 'Long press duration', options: ['Short', 'Default', 'Long']),
    _SettingsItem(type: 'toggle', id: 'enableSwipe', label: 'Enable swipe actions'),
    _SettingsItem(type: 'dropdown', id: 'swipeLeft', label: 'Swipe left action', options: ['Delete', 'Rename', 'None']),
    _SettingsItem(type: 'dropdown', id: 'swipeRight', label: 'Swipe right action', options: ['Share', 'Details', 'None']),
    _SettingsItem(type: 'toggle', id: 'hapticFeedback', label: 'Haptic feedback'),
  ]),
  _SettingsCategory('advanced', 'Advanced', 'Developer options', Icons.build_outlined, [
    _SettingsItem(type: 'toggle', id: 'debugLogs', label: 'Enable debug logs'),
    _SettingsItem(type: 'button', id: 'viewLogs', label: 'File operation log viewer'),
    _SettingsItem(type: 'toggle', id: 'experimentalFeatures', label: 'Experimental features'),
    _SettingsItem(type: 'button', id: 'forceRescan', label: 'Force media rescan'),
    _SettingsItem(type: 'button', id: 'resetPrefs', label: 'Reset app preferences'),
  ]),
  _SettingsCategory('about', 'About', 'Version and licenses', Icons.info_outlined, [
    _SettingsItem(type: 'text', id: 'version', label: 'App version', staticValue: 'v1.0.0 (Build 1)'),
    _SettingsItem(type: 'button', id: 'pathsInfo', label: 'Storage paths info'),
    _SettingsItem(type: 'button', id: 'licenses', label: 'Open source licenses'),
    _SettingsItem(type: 'button', id: 'privacy', label: 'Privacy policy'),
    _SettingsItem(type: 'button', id: 'feedback', label: 'Send feedback'),
  ]),
];
