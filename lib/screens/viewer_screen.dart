import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/format_registry.dart';
import 'viewers/image_viewer.dart';
import 'viewers/svg_viewer.dart';
import 'viewers/text_viewer.dart';
import 'viewers/code_viewer.dart';
import 'viewers/pdf_viewer.dart';
import 'viewers/video_viewer.dart';
import 'viewers/audio_viewer.dart';
import 'viewers/archive_viewer.dart';
import 'viewers/spreadsheet_viewer.dart';
import 'viewers/epub_viewer.dart';
import 'viewers/font_viewer.dart';
import 'viewers/hex_viewer.dart';

class ViewerScreen extends StatelessWidget {
  final String filePath;
  final String fileName;
  final int fileSize;
  final FileFormat? format;

  const ViewerScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.format,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = format;
    final color = fmt?.color ?? const Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            Text(_formatSize(fileSize), style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.shareXFiles([XFile(filePath)], text: fileName),
          ),
        ],
      ),
      body: _buildViewer(context, fmt, color),
    );
  }

  Widget _buildViewer(BuildContext context, FileFormat? fmt, Color color) {
    if (fmt == null) {
      // Unknown format — try hex viewer
      return HexViewer(filePath: filePath);
    }

    switch (fmt.viewer) {
      case ViewerType.image:
        return ImageViewer(filePath: filePath);
      case ViewerType.svg:
        return SvgViewer(filePath: filePath);
      case ViewerType.text:
        return TextViewer(filePath: filePath);
      case ViewerType.code:
        return CodeViewer(filePath: filePath, language: fmt.ext);
      case ViewerType.pdf:
        return PdfViewer(filePath: filePath);
      case ViewerType.video:
        return VideoViewer(filePath: filePath);
      case ViewerType.audio:
        return AudioViewer(filePath: filePath, fileName: fileName);
      case ViewerType.archive:
        return ArchiveViewer(filePath: filePath);
      case ViewerType.spreadsheet:
        return SpreadsheetViewer(filePath: filePath, ext: fmt.ext);
      case ViewerType.epub:
        return EpubViewer(filePath: filePath);
      case ViewerType.font:
        return FontViewer(filePath: filePath, fileName: fileName);
      case ViewerType.hex:
        return HexViewer(filePath: filePath);
    }
  }
}
