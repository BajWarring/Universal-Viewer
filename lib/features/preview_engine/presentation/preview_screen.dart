import 'package:flutter/material.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';

class UnifiedViewer extends StatelessWidget {
  final OmniNode node;
  const UnifiedViewer({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => UnifiedViewer(node: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation), child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
    
    if (['jpeg', 'jpg', 'png', 'gif', 'webp'].contains(ext)) {
      return ImagePreviewer(path: node.path);
    }
    
    if (['txt', 'md', 'json', 'xml', 'java', 'kt', 'gradle', 'kts', 'html', 'sql', 'csv', 'py', 'dart', 'db'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    
    // Fallback View
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
