import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class EpubViewer extends StatefulWidget {
  final String filePath;
  const EpubViewer({super.key, required this.filePath});

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  late EpubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openFile(widget.filePath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chapter title bar
        EpubViewActualChapter(
          controller: _controller,
          builder: (chapterValue) => Container(
            color: const Color(0xFF14141F),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined, color: Color(0xFF6C63FF), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chapterValue?.chapter?.Title?.trim() ?? 'Reading...',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: EpubView(
            controller: _controller,
            builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(
                textStyle: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.white,
                ),
              ),
              chapterDividerBuilder: (_) => const Divider(
                color: Color(0xFF6C63FF),
                height: 40,
                thickness: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
