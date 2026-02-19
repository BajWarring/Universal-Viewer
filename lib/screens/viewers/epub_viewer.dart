import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class EpubViewer extends StatefulWidget {
  final String filePath;
  const EpubViewer({super.key, required this.filePath});

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  EpubController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openFile(widget.filePath),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EpubView(
      controller: _controller!,
      builders: EpubViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(
          textStyle: TextStyle(fontSize: 16, height: 1.8, color: Colors.white),
        ),
        chapterDividerBuilder: (_) => const Divider(color: Color(0xFF6C63FF), height: 40),
      ),
    );
  }
}
