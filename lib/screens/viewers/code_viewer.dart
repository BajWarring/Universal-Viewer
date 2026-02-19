import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CodeViewer extends StatefulWidget {
  final String filePath;
  final String language;
  const CodeViewer({super.key, required this.filePath, required this.language});

  @override
  State<CodeViewer> createState() => _CodeViewerState();
}

class _CodeViewerState extends State<CodeViewer> {
  String? _content;
  bool _loading = true;
  bool _error = false;
  bool _wrap = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final content = await File(widget.filePath).readAsString();
      if (mounted) setState(() { _content = content; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  String _normalizeLanguage(String ext) {
    const map = {
      'js': 'javascript', 'ts': 'typescript', 'py': 'python',
      'rb': 'ruby', 'cs': 'csharp', 'cpp': 'cpp', 'c': 'c',
      'h': 'c', 'java': 'java', 'go': 'go', 'rs': 'rust',
      'php': 'php', 'swift': 'swift', 'kt': 'kotlin',
      'html': 'xml', 'css': 'css', 'scss': 'scss',
      'json': 'json', 'xml': 'xml', 'yaml': 'yaml', 'yml': 'yaml',
      'sh': 'bash', 'bat': 'dos', 'ps1': 'powershell',
      'sql': 'sql', 'md': 'markdown', 'tex': 'latex',
    };
    return map[ext.toLowerCase()] ?? 'plaintext';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF26DE81)));
    if (_error || _content == null) {
      return const Center(child: Text('Cannot read file', style: TextStyle(color: Colors.white54)));
    }

    return Column(
      children: [
        // Toolbar
        Container(
          color: const Color(0xFF0D1117),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF26DE81).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26DE81).withOpacity(0.3)),
                ),
                child: Text(
                  _normalizeLanguage(widget.language).toUpperCase(),
                  style: const TextStyle(color: Color(0xFF26DE81), fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Text(
                '${_content!.split('\n').length} lines',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _wrap = !_wrap),
                child: Text(
                  _wrap ? 'Nowrap' : 'Wrap',
                  style: const TextStyle(color: Color(0xFF26DE81), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: _wrap ? Axis.vertical : Axis.horizontal,
              child: HighlightView(
                _content!,
                language: _normalizeLanguage(widget.language),
                theme: atomOneDarkTheme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
