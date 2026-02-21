import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';
import '../../media_player/presentation/video_player_screen.dart';
import 'package:pdfx/pdfx.dart';

class PreviewScreen extends StatelessWidget {
  final OmniNode node;
  const PreviewScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(node.name, style: const TextStyle(fontSize: 15)), actions: [
        IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
      ]),
      body: _buildPreviewer(context),
    );
  }

  Widget _buildPreviewer(BuildContext context) {
    final ext = node.extension.toLowerCase();
    if (['txt', 'md', 'json', 'xml', 'gradle', 'kts', 'java', 'kt', 'html', 'sql', 'csv', 'py', 'dart', 'db'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    if (ext == 'svg') return Center(child: SvgPicture.file(File(node.path)));
    if (['jpeg', 'jpg', 'png', 'gif', 'webp'].contains(ext)) return ImagePreviewer(path: node.path);
    if (['mp4', 'mkv', 'avi', 'webm'].contains(ext)) return VideoPlayerScreen(videoNode: node);
    // add import 'package:pdfx/pdfx.dart';

if (ext == 'pdf') {
  return PdfView(pinchingEnabled: true, controller: PdfController(document: PdfDocument.openFile(node.path)));
}
if (['zip', 'rar', '7z', 'tar', 'apk'].contains(ext)) {
  return Center(child: ElevatedButton.icon(
    onPressed: () { /* switch to archive provider */ },
    icon: const Icon(Icons.folder_zip_rounded),
    label: Text('View inside .$ext'),
  ));
}
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.insert_drive_file_rounded, size: 64, color: Colors.grey),
      const SizedBox(height: 16),
      Text('No preview available for .${node.extension}', style: const TextStyle(color: Colors.grey)),
    ]));
  }
}
