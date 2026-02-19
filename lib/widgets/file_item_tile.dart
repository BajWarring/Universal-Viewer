import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/file_system_service.dart';

class FileItemTile extends StatelessWidget {
  final FileItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final Color primaryColor;
  final bool isDark;
  final bool showSize;
  final bool showDate;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onMoreTap;

  const FileItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.primaryColor,
    required this.isDark,
    this.showSize = true,
    this.showDate = true,
    required this.onTap,
    required this.onLongPress,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.getColor(primaryColor);
    final isHidden = item.isHidden && !isSelected;

    return Opacity(
      opacity: isHidden ? 0.5 : 1.0,
      child: Container(
        height: 76,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.07)
              : isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor.withOpacity(0.4)
                : isDark
                    ? Colors.white.withOpacity(0.07)
                    : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Leading: checkbox or icon
                  if (isSelectionMode)
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    )
                  else
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildIcon(color),
                    ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        _buildSubtitle(context),
                      ],
                    ),
                  ),

                  // Trailing
                  if (!isSelectionMode && onMoreTap != null)
                    _MoreButton(onTap: onMoreTap!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    // Try to show a thumbnail for images
    if (item.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(item.path),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(item.icon, color: color, size: 22),
        ),
      );
    }
    return Icon(item.icon, color: color, size: 22);
  }

  Widget _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    if (showDate) parts.add(FileSystemService.formatDate(item.modified));
    if (showSize) {
      if (item.isFolder) {
        parts.add('${item.itemCount} items');
      } else {
        parts.add(FileSystemService.formatSize(item.size));
      }
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' • '),
      style: GoogleFonts.inter(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.more_vert_rounded,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
          size: 18,
        ),
      ),
    );
  }
}
