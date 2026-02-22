import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/file_operation_notifier.dart';

class TaskProgressDialog extends ConsumerWidget {
  const TaskProgressDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const TaskProgressDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: const Cubic(0.16, 1.0, 0.3, 1.0));
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1.0).animate(curve), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final theme = Theme.of(context);

    ref.listen<FileOperationState>(fileOperationProvider, (previous, next) {
      if (previous?.taskStatus == TaskStatus.running && next.taskStatus == TaskStatus.success) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) Navigator.pop(context);
        });
      }
    });

    String title = "Processing...";
    Color barColor = theme.colorScheme.primary;

    if (opState.operation == FileOpType.copy) title = "Copying...";
    if (opState.operation == FileOpType.cut) title = "Moving...";
    if (opState.operation == FileOpType.delete) {
      title = "Deleting...";
      barColor = Colors.red;
    }
    if (opState.operation == FileOpType.compress) title = "Compressing...";
    if (opState.operation == FileOpType.extract) title = "Extracting...";
    if (opState.operation == FileOpType.undo) title = "Undoing Operation...";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              opState.currentTaskItem.isEmpty ? "Preparing..." : opState.currentTaskItem,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: barColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Processing...',
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${(opState.taskProgress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: opState.taskProgress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: barColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context), 
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Hide'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(fileOperationProvider.notifier).cancelTask();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
