import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class TextPreviewer extends StatelessWidget {
  final String path;
  final String extension;
  const TextPreviewer({super.key, required this.path, required this.extension});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: File(path).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Cannot read file.\n${snapshot.error}', textAlign: TextAlign.center));
        final content = snapshot.data ?? '';
        final lineCount = content.split('\n').length;
        const textStyle = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(lineCount, (i) => Text('${i + 1}', style: textStyle.copyWith(color: Colors.grey.withOpacity(0.7))))),
              ),
              HighlightView(content, language: extension, theme: atomOneDarkTheme, padding: const EdgeInsets.all(16), textStyle: textStyle),
            ]),
          ),
        );
      },
    );
  }
}
