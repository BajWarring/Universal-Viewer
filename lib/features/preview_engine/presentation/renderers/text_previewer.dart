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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Cannot read text file.\n${snapshot.error}', textAlign: TextAlign.center),
          );
        }

        return SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: HighlightView(
              snapshot.data ?? '',
              // It is recommended to explicitly pass the language value for performance
              language: extension, 
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}
