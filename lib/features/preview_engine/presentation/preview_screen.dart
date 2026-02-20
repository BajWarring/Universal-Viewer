import 'package:flutter/material.dart';
import '../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';
// import 'renderers/pdf_previewer.dart';
// import 'renderers/media_previewer.dart';

class PreviewScreen extends StatelessWidget {
  final OmniNode node;

  const PreviewScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(node.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: _buildPreviewer(),
    );
  }

  Widget _buildPreviewer() {
    final ext = node.extension;
    
    // Text & Code
    if (['txt', 'md', 'json', 'xml', 'gradle', 'kts', 'java', 'kt', 'html', 'sql', 'csv'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    
    // Images
    if (['jpeg', 'jpg', 'png', 'svg', 'gif', 'webp'].contains(ext)) {
      return ImagePreviewer(path: node.path);
    }
    
    // Audio Routing (Triggers global player and pops back)
    if (['mp3', 'wav', 'flac', 'm4a'].contains(ext)) {
      // Start playing in background
      ref.read(audioProvider.notifier).playFile(node);
      // Optional: Return a widget that says "Playing in Background" or pop instantly
      return const Center(child: Text('Playing in Mini Player...')); 
    }

    // Video Routing
    if (['mp4', 'mkv', 'avi', 'webm'].contains(ext)) {
      // MediaKit handles the UI, so we push the dedicated video screen
      return VideoPlayerScreen(videoNode: node);
    }


    // Documents 
    if (['pdf'].contains(ext)) {
      return const Center(child: Text('PDF Renderer and Manipulation Tools here...'));
    }

    // Fallback View
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No built-in preview available for .$ext files'),
        ],
      ),
    );
  }
}
