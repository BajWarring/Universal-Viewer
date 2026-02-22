import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../settings/application/settings_notifier.dart'; // Fixed Import Path
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';
import '../../media_player/presentation/audio_popup.dart';
import '../../media_player/presentation/video_popup.dart';
import '../../media_player/application/audio_notifier.dart';
import '../../media_player/application/video_notifier.dart';

class UnifiedViewer extends ConsumerWidget {
  final OmniNode node;
  const UnifiedViewer({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    final ext = node.extension.toLowerCase();
    final isAudio = ['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(ext);
    final isVideo = ['mp4', 'mkv', 'avi', 'webm', 'mov'].contains(ext);

    // Read Settings to determine UI behavior from the map
    final container = ProviderScope.containerOf(context);
    final mode = container.read(settingsProvider).get('mediaUiMode');

    if (isAudio) {
      if (mode == 'popup_mode') {
        showDialog(context: context, barrierColor: Colors.black54, builder: (_) => AudioPopup(node: node));
      } else {
        container.read(audioProvider.notifier).playFile(node);
      }
      return;
    }
    
    if (isVideo) {
      if (mode == 'popup_mode') {
        showDialog(context: context, barrierColor: Colors.black87, builder: (_) => VideoPopup(node: node));
      } else {
        container.read(videoProvider.notifier).playFile(node);
      }
      return;
    }

    // Default Fullscreen Viewer (Images, Text, etc)
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => UnifiedViewer(node: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, 
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation), 
            child: child
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)))),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
                ],
              ),
            ),
            Expanded(
              child: _buildPreviewer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewer(BuildContext context) {
    final ext = node.extension.toLowerCase();
    
    if (['txt', 'md', 'json', 'xml', 'gradle', 'kts', 'java', 'kt', 'html', 'sql', 'csv', 'py', 'dart', 'db'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    if (ext == 'svg') return Center(child: SvgPicture.file(File(node.path)));
    if (['jpeg', 'jpg', 'png', 'gif', 'webp'].contains(ext)) return ImagePreviewer(path: node.path);
    if (ext == 'pdf') {
      return PdfView(
        controller: PdfController(
          document: PdfDocument.openFile(node.path),
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No preview available for .${node.extension}'),
        ],
      ),
    );
  }
}
