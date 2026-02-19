import 'dart:io';
import 'package:flutter/material.dart';

class TextViewer extends StatefulWidget {
  final String filePath;
  const TextViewer({super.key, required this.filePath});

  @override
  State<TextViewer> createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> {
  String? _content;
  bool _loading = true;
  double _fontSize = 15;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final content = await File(widget.filePath).readAsString();
      if (mounted) setState(() { _content = content; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _content = 'Cannot read this file format as text.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));

    return Column(
      children: [
        Container(
          color: const Color(0xFF14141F),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Font size: ${_fontSize.toInt()}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
              const Spacer(),
              IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() => _fontSize = (_fontSize - 1).clamp(10, 30))),
              IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => _fontSize = (_fontSize + 1).clamp(10, 30))),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              _content ?? '',
              style: TextStyle(fontSize: _fontSize, height: 1.7, color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ),
      ],
    );
  }
}
