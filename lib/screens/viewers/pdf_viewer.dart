import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final String filePath;
  const PdfViewer({super.key, required this.filePath});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Page controls
        Container(
          color: const Color(0xFF14141F),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE53935)),
                onPressed: _currentPage > 1 ? () => _controller.previousPage() : null,
              ),
              Expanded(
                child: Text(
                  _totalPages > 0 ? 'Page $_currentPage of $_totalPages' : 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFFE53935)),
                onPressed: (_currentPage < _totalPages) ? () => _controller.nextPage() : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: SfPdfViewer.file(
            File(widget.filePath),
            controller: _controller,
            onDocumentLoaded: (details) {
              setState(() => _totalPages = details.document.pages.count);
            },
            onPageChanged: (details) {
              setState(() => _currentPage = details.newPageNumber);
            },
          ),
        ),
      ],
    );
  }
}
