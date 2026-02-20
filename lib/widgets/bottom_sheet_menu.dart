import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/file_system_service.dart';

class FileBottomSheet extends StatelessWidget {
  final FileItem item;
  final Color primaryColor;
  final VoidCallback onOpen;
  final VoidCallback onCompress;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onCut;
  final String currentPath;

  const FileBottomSheet({
    super.key,
    required this.item,
    required this.primaryColor,
    required this.onOpen,
    required this.onCompress,
    required this.onRename,
    required this.onDelete,
    required this.onDetails,
    required this.onShare,
    required this.onCopy,
    required this.onCut,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = item.getColor(primaryColor);
    final options = _buildOptions();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2636) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 44, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // File info header
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.isFolder
                                ? '${item.itemCount} items'
                                : FileSystemService.formatSize(item.size),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Options grid
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: options.map((opt) => _OptionButton(
                    label: opt.label,
                    icon: opt.icon,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    isDestructive: opt.isDestructive,
                    onTap: opt.action,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_SheetOption> _buildOptions() {
    if (item.isFolder) {
      return [
        _SheetOption('Pin to Home', Icons.push_pin_rounded, () {}),
        _SheetOption('Open', Icons.folder_open_rounded, onOpen),
        _SheetOption('Compress', Icons.folder_zip_rounded, onCompress),
        _SheetOption('Copy', Icons.content_copy_rounded, onCopy),
        _SheetOption('Cut', Icons.content_cut_rounded, onCut),
        _SheetOption('Rename', Icons.drive_file_rename_outline_rounded, onRename),
        _SheetOption('Details', Icons.info_outline_rounded, onDetails),
        _SheetOption('Delete', Icons.delete_outline_rounded, onDelete, isDestructive: true),
      ];
    } else if (item.isArchive) {
      return [
        _SheetOption('View', Icons.visibility_rounded, onOpen),
        _SheetOption('Extract Here', Icons.unarchive_rounded, () {}),
        _SheetOption('Extract To...', Icons.drive_file_move_rounded, () {}),
        _SheetOption('Compress', Icons.folder_zip_rounded, onCompress),
        _SheetOption('Copy', Icons.content_copy_rounded, onCopy),
        _SheetOption('Cut', Icons.content_cut_rounded, onCut),
        _SheetOption('Rename', Icons.drive_file_rename_outline_rounded, onRename),
        _SheetOption('Details', Icons.info_outline_rounded, onDetails),
        _SheetOption('Share', Icons.share_rounded, onShare),
        _SheetOption('Delete', Icons.delete_outline_rounded, onDelete, isDestructive: true),
      ];
    } else if (item.isApk) {
       return [
        _SheetOption('Install', Icons.system_update_rounded, onOpen),
        _SheetOption('View Contents', Icons.visibility_rounded, onOpen),
        _SheetOption('Compress', Icons.folder_zip_rounded, onCompress),
        _SheetOption('Copy', Icons.content_copy_rounded, onCopy),
        _SheetOption('Cut', Icons.content_cut_rounded, onCut),
        _SheetOption('Rename', Icons.drive_file_rename_outline_rounded, onRename),
        _SheetOption('Details', Icons.info_outline_rounded, onDetails),
        _SheetOption('Share', Icons.share_rounded, onShare),
        _SheetOption('Delete', Icons.delete_outline_rounded, onDelete, isDestructive: true),
      ];
    } else {
      return [
        _SheetOption('Open', Icons.open_in_new_rounded, onOpen),
        _SheetOption('Open With', Icons.apps_rounded, () {}),
        _SheetOption('Compress', Icons.folder_zip_rounded, onCompress),
        _SheetOption('Copy', Icons.content_copy_rounded, onCopy),
        _SheetOption('Cut', Icons.content_cut_rounded, onCut),
        _SheetOption('Rename', Icons.drive_file_rename_outline_rounded, onRename),
        _SheetOption('Details', Icons.info_outline_rounded, onDetails),
        _SheetOption('Share', Icons.share_rounded, onShare),
        _SheetOption('Delete', Icons.delete_outline_rounded, onDelete, isDestructive: true),
      ];
    }
  }
}

class _SheetOption {
  final String label;
  final IconData icon;
  final VoidCallback action;
  final bool isDestructive;
  _SheetOption(this.label, this.icon, this.action, {this.isDestructive = false});
}

class _OptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final Color primaryColor;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.primaryColor,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : primaryColor;
    return Material(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
