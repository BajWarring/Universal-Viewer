import 'dart:io';
import 'package:flutter/material.dart';

class HexViewer extends StatefulWidget {
  final String filePath;
  const HexViewer({super.key, required this.filePath});

  @override
  State<HexViewer> createState() => _HexViewerState();
}

class _HexViewerState extends State<HexViewer> {
  List<String> _lines = [];
  bool _loading = true;
  String _fileInfo = '';
  static const int _maxBytes = 4096;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = File(widget.filePath);
      final stat = await file.stat();
      final bytes = await file.openRead(0, _maxBytes).fold<List<int>>([], (a, b) => a..addAll(b));
      
      final lines = <String>[];
      for (var i = 0; i < bytes.length; i += 16) {
        final chunk = bytes.sublist(i, (i + 16).clamp(0, bytes.length));
        final offset = i.toRadixString(16).padLeft(8, '0').toUpperCase();
        final hex = chunk.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ').padRight(47);
        final ascii = chunk.map((b) => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.').join('');
        lines.add('$offset  $hex  $ascii');
      }

      final sizeMB = stat.size / 1024;
      final info = '${stat.size} bytes (${sizeMB.toStringAsFixed(1)} KB) · Showing first ${_maxBytes} bytes';

      if (mounted) setState(() { _lines = lines; _fileInfo = info; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));

    return Column(
      children: [
        Container(
          color: const Color(0xFF0D1117),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('HEX VIEW', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white38, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_fileInfo, style: const TextStyle(fontSize: 11, color: Colors.white38, fontFamily: 'monospace')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _lines.length,
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              color: i.isEven ? const Color(0xFF0D0D14) : const Color(0xFF0A0A10),
              child: Text(
                _lines[i],
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF9CDCFE),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
        Container(
          color: const Color(0xFF0D1117),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.white38),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Binary file displayed in hex. This format requires specialized software to open properly.',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
