import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/file_operation_notifier.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../../shared/widgets/task_progress_dialog.dart';

class OperationBar extends ConsumerWidget {
  const OperationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    if (opState.operation == FileOpType.none) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isExtract = opState.operation == FileOpType.extract;
    final isCut = opState.operation == FileOpType.cut;
    
    String title = isExtract ? 'Extracting' : (isCut ? 'Moving' : 'Copying');
    IconData icon = isExtract ? Icons.unarchive_rounded : (isCut ? Icons.content_cut_rounded : Icons.content_copy_rounded);
    String actionLabel = isExtract ? 'Extract Here' : (isCut ? 'Move Here' : 'Paste');

    return Positioned(
      bottom: 90, left: 16, right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: theme.colorScheme.surface, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.colorScheme.surface.withValues(alpha: 0.7))),
                  Text('${opState.clipboard.length} item(s)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.surface)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => ref.read(fileOperationProvider.notifier).clearClipboard(),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.surface.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              onPressed: () {
                final destPath = ref.read(directoryProvider).currentPath;
                
                // 1. Show the global progress modal immediately
                TaskProgressDialog.show(context);
                
                // 2. Trigger the isolate-backed Riverpod action
                ref.read(fileOperationProvider.notifier).executePaste(destPath);
              },
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
