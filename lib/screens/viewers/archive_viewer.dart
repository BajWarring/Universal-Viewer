import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class ArchiveViewer extends StatefulWidget {
  final String filePath;
  const ArchiveViewer({super.key, required this.filePath});

  @override
  State<ArchiveViewer> createState() => _ArchiveViewerState();
}

class _ArchiveViewerState extends State<ArchiveViewer> {
  List<ArchiveFile>? _files;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await File(widget.filePath).readAsBytes();
      final Archive archive = ZipDecoder().decodeBytes(bytes);
      if (mounted) setState(() { _files = archive.files.toList(); _loading = false; });
    } catch (e) {
      // Try other formats
      try {
        final bytes = await File(widget.filePath).readAsBytes();
        final Archive archive = TarDecoder().decodeBytes(bytes);
        if (mounted) setState(() { _files = archive.files.toList(); _loading = false; });
      } catch (e2) {
        if (mounted) setState(() { _error = 'Cannot read this archive format.\nRAR and 7Z require native codecs.'; _loading = false; });
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _iconForFile(String name) {
    final ext = p.extension(name).toLowerCase().replaceAll('.', '');
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) return Icons.image_outlined;
    if (['mp4','mkv','avi','mov'].contains(ext)) return Icons.videocam_outlined;
    if (['py','js','ts','java','c','cpp'].contains(ext)) return Icons.code;
    if (['pdf'].contains(ext)) return Icons.picture_as_pdf_outlined;
    if (name.endsWith('/')) return Icons.folder_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFF7B731)));

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_zip_outlined, size: 64, color: Color(0xFFF7B731)),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ),
      );
    }

    final files = _files!;
    final totalSize = files.fold<int>(0, (sum, f) => sum + f.size);

    return Column(
      children: [
        Container(
          color: const Color(0xFF14141F),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.folder_zip_outlined, color: Color(0xFFF7B731), size: 20),
              const SizedBox(width: 10),
              Text('${files.length} files · ${_formatSize(totalSize)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (_, i) {
              final f = files[i];
              final isDir = f.name.endsWith('/');
              return ListTile(
                leading: Icon(
                  _iconForFile(f.name),
                  color: isDir ? const Color(0xFFF7B731) : Colors.white54,
                  size: 20,
                ),
                title: Text(
                  f.name,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isDir ? null : Text(
                  _formatSize(f.size),
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
