import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FontViewer extends StatefulWidget {
  final String filePath;
  final String fileName;
  const FontViewer({super.key, required this.filePath, required this.fileName});

  @override
  State<FontViewer> createState() => _FontViewerState();
}

class _FontViewerState extends State<FontViewer> {
  String? _fontFamily;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    try {
      final fontData = await File(widget.filePath).readAsBytes();
      final fontLoader = FontLoader('PreviewFont_${DateTime.now().millisecondsSinceEpoch}');
      fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
      await fontLoader.load();
      if (mounted) setState(() { _fontFamily = fontLoader.family; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFA29BFE)));

    final sampleText = 'The quick brown fox jumps over the lazy dog';
    final pangram = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789!@#\$%^&*()';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFA29BFE).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA29BFE).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aa', style: TextStyle(fontSize: 72, fontFamily: _fontFamily, color: const Color(0xFFA29BFE), height: 1)),
                const SizedBox(height: 16),
                Text(sampleText, style: TextStyle(fontSize: 22, fontFamily: _fontFamily, color: Colors.white, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SampleBlock(title: 'Regular 16px', text: sampleText, size: 16, family: _fontFamily),
          _SampleBlock(title: 'Large 24px', text: sampleText, size: 24, family: _fontFamily),
          _SampleBlock(title: 'Small 12px', text: sampleText, size: 12, family: _fontFamily),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14141F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E30)),
            ),
            child: Text(
              pangram,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 15, height: 2, color: Colors.white.withOpacity(0.8)),
            ),
          ),
          const SizedBox(height: 20),
          _InfoTile(label: 'File', value: widget.fileName),
          _InfoTile(label: 'Format', value: widget.fileName.split('.').last.toUpperCase()),
        ],
      ),
    );
  }
}

class _SampleBlock extends StatelessWidget {
  final String title, text;
  final double size;
  final String? family;
  const _SampleBlock({required this.title, required this.text, required this.size, this.family});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(fontFamily: family, fontSize: size, color: Colors.white, height: 1.4)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14141F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1E30)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
