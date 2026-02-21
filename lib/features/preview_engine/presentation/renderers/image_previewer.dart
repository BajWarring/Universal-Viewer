import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewer extends StatelessWidget {
  final String path;
  const ImagePreviewer({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5, maxScale: 6.0,
      child: Center(
        child: Image.file(File(path), fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey))),
      ),
    );
  }
}
