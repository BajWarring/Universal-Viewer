import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';

// Import these once Phase 8 is implemented. 
import '../../media_player/application/audio_notifier.dart';
import '../../media_player/presentation/video_player_screen.dart';

class PreviewScreen extends ConsumerWidget {
  final OmniNode node;

  const PreviewScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(node.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: _buildPreviewer(context, ref),
    );
  }

  Widget _buildPreviewer(BuildContext context, WidgetRef ref) {
    final ext = node.extension;
    
    // Text & Code
    if (['txt', 'md', 'json', 'xml', 'gradle', 'kts', 'java', 'kt', 'html', 'sql', 'csv'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    
    // Images
    if (['jpeg', 'jpg', 'png', 'svg', 'gif', 'webp'].contains(ext)) {
      return ImagePreviewer(path: node.path);
    }
    
    // Audio Routing (Uncomment when AudioNotifier is built)
    if (['mp3', 'wav', 'flac', 'm4a'].contains(ext)) {
      // ref.read(audioProvider.notifier).playFile(node);
      return const Center(child: Text('Playing in Mini Player...')); 
    }

    // Video Routing (Uncomment when VideoPlayerScreen is built)
    if (['mp4', 'mkv', 'avi', 'webm'].contains(ext)) {
      // return VideoPlayerScreen(videoNode: node);
      return const Center(child: Text('Video Player Coming Soon')); 
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
