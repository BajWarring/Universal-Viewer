import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../../../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import '../../media_player/presentation/video_player_screen.dart';

class PreviewScreen extends StatelessWidget {
  final OmniNode node;

  const PreviewScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(node.name, style: const TextStyle(fontSize: 16))),
      body: _buildPreviewer(context),
    );
  }

  Widget _buildPreviewer(BuildContext context) {
    final ext = node.extension.toLowerCase();
    
    // Code, Docs, & Databases
    if (['txt', 'md', 'json', 'xml', 'gradle', 'kts', 'java', 'kt', 'html', 'sql', 'csv', 'py', 'dart', 'db'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    
    // SVGs
    if (ext == 'svg') {
      return Center(child: SvgPicture.file(File(node.path)));
    }

    // Standard Images
    if (['jpeg', 'jpg', 'png', 'gif', 'webp'].contains(ext)) {
      return Center(child: Image.file(File(node.path)));
    }
    
    // Video Routing
    if (['mp4', 'mkv', 'avi', 'webm'].contains(ext)) {
      return VideoPlayerScreen(videoNode: node);
    }

    // PDF Routing (Requires flutter_pdfview package later)
    if (ext == 'pdf') {
      return const Center(child: Text('PDF Viewer integration pending...'));
    }

    // Archives & APKs (Requires extraction logic)
    if (['zip', 'rar', '7z', 'apk'].contains(ext)) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () {}, // TODO: Trigger Archive/APK Viewer
          icon: const Icon(Icons.folder_zip),
          label: Text('View inside .$ext'),
        ),
      );
    }

    return const Center(child: Text('Format not supported yet.'));
  }
}
