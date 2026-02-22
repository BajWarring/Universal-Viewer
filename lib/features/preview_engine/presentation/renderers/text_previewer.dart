import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class TextPreviewer extends StatefulWidget {
  final String path;
  final String extension;
  const TextPreviewer({super.key, required this.path, required this.extension});

  @override
  State<TextPreviewer> createState() => _TextPreviewerState();
}

class _TextPreviewerState extends State<TextPreviewer> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String _content = '';
  bool _isLoading = true;
  String _error = '';

  List<int> _matchIndices = [];
  int _currentMatch = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.path);
      _content = await file.readAsString();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() { _matchIndices = []; _currentMatch = 0; });
      return;
    }
    
    final lines = _content.split('\n');
    final queryLower = query.toLowerCase();
    _matchIndices = [];
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().contains(queryLower)) {
        _matchIndices.add(i);
      }
    }
    
    _currentMatch = 0;
    setState(() {});
    if (_matchIndices.isNotEmpty) _scrollToMatch();
  }

  void _nextMatch() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatch = (_currentMatch + 1) % _matchIndices.length;
    });
    _scrollToMatch();
  }

  void _prevMatch() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatch = (_currentMatch - 1 + _matchIndices.length) % _matchIndices.length;
    });
    _scrollToMatch();
  }

  void _scrollToMatch() {
    if (_matchIndices.isEmpty) return;
    final lineIndex = _matchIndices[_currentMatch];
    
    // Approximate line height calculation: FontSize (13) * Height (1.5) + Padding
    final offset = lineIndex * 19.5; 
    
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text('Cannot read file.\n$_error', textAlign: TextAlign.center));

    final lineCount = _content.split('\n').length;
    const textStyle = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);

    return Column(
      children: [
        // --- Search Bar Header ---
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _matchIndices = [];
                    }
                  });
                },
              ),
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Find in file...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: _search,
                      )
                    : const Text('Code Viewer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              if (_matchIndices.isNotEmpty) ...[
                Text('${_currentMatch + 1} / ${_matchIndices.length}', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20), onPressed: _prevMatch),
                IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20), onPressed: _nextMatch),
              ]
            ],
          ),
        ),

        // --- Code Viewer ---
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: Border(right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        lineCount, 
                        (i) {
                          final isMatch = _matchIndices.contains(i);
                          final isCurrentMatch = _matchIndices.isNotEmpty && _matchIndices[_currentMatch] == i;
                          
                          return Container(
                            color: isCurrentMatch ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                            child: Text(
                              '${i + 1}', 
                              style: textStyle.copyWith(
                                color: isMatch ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.7),
                                fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
                              )
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                  HighlightView(
                    _content, 
                    language: widget.extension, 
                    theme: atomOneDarkTheme, 
                    padding: const EdgeInsets.all(16), 
                    textStyle: textStyle
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
