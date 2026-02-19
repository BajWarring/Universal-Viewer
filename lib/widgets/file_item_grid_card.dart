import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/file_system_service.dart';

class FileItemGridCard extends StatelessWidget {
  final FileItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileItemGridCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.getColor(primaryColor);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
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
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: _buildIcon(color)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isSelectionMode)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade400, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (item.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(item.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Icon(item.icon, color: color, size: 32),
        ),
      );
    }
    return Icon(item.icon, color: color, size: 32);
  }
}
