import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../application/file_operation_notifier.dart';
import 'rename_dialog.dart';
import '../../../archive_engine/presentation/widgets/compress_dialog.dart';

class ActionBottomSheet extends ConsumerWidget {
  final OmniNode node;
  const ActionBottomSheet({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionBottomSheet(node: node),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final actions = _buildActions(context, ref);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Drag handle
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(14)),
                child: Icon(node.isFolder ? Icons.folder_rounded : _fileIcon(node.extension), color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(node.isFolder ? 'Folder' : '${_formatBytes(node.size)} • .${node.extension}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ])),
            ]),
          ),
          const Divider(height: 1),
          // PHASE 2: 2-column action grid matching HTML prototype
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
              physics: const NeverScrollableScrollPhysics(),
              children: actions.map((a) => _ActionTile(action: a, theme: theme)).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  List<_SheetAction> _buildActions(BuildContext context, WidgetRef ref) {
    final actions = <_SheetAction>[];

    if (node.isFolder) {
      actions.addAll([
        _SheetAction('Open', Icons.folder_open_rounded, () { Navigator.pop(context); /* navigateTo handled by list */ }),
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).toggleSelection(node); ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).toggleSelection(node); ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); showDialog(context: context, builder: (_) => RenameDialog(node: node)); }),
        _SheetAction('Pin', Icons.push_pin_rounded, () { Navigator.pop(context); }),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context, node); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); }, isDestructive: true),
      ]);
    } else {
      actions.addAll([
        _SheetAction('Open', Icons.open_in_new_rounded, () { Navigator.pop(context); }),
        _SheetAction('Open with', Icons.apps_rounded, () { Navigator.pop(context); }),
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).toggleSelection(node); ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).toggleSelection(node); ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); showDialog(context: context, builder: (_) => RenameDialog(node: node)); }),
        _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); }),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context, node); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); }, isDestructive: true),
      ]);
    }
    return actions;
  }

  void _showDetails(BuildContext context, OmniNode node) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Icon(node.isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(node.name, style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _detailRow('Type', node.isFolder ? 'Folder' : '${node.extension.toUpperCase()} File'),
          _detailRow('Size', _formatBytes(node.size)),
          _detailRow('Location', node.path),
          _detailRow('Modified', '${node.modified.year}-${node.modified.month.toString().padLeft(2, '0')}-${node.modified.day.toString().padLeft(2, '0')}'),
        ]),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 72, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]),
  );

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': case 'mkv': case 'avi': return Icons.video_library_rounded;
      case 'mp3': case 'wav': case 'flac': return Icons.music_note_rounded;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'zip': case 'rar': case '7z': return Icons.folder_zip_rounded;
      case 'apk': return Icons.android_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _SheetAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SheetAction(this.label, this.icon, this.onTap, {this.isDestructive = false});
}

class _ActionTile extends StatelessWidget {
  final _SheetAction action;
  final ThemeData theme;
  const _ActionTile({required this.action, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final bg = action.isDestructive
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(action.icon, size: 18, color: action.isDestructive ? theme.colorScheme.error : theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text(action.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
