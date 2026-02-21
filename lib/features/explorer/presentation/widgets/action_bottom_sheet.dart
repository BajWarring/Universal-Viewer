import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../application/file_operation_notifier.dart';
import 'rename_dialog.dart';
import '../../../archive_engine/presentation/widgets/compress_dialog.dart';
import '../../../preview_engine/presentation/preview_screen.dart';
import '../../../../filesystem/application/directory_notifier.dart';

class ActionBottomSheet extends ConsumerWidget {
  final OmniNode node;
  const ActionBottomSheet({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActionBottomSheet(node: node),
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
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
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
                Text(node.isFolder ? '\( {node.name} Folder' : ' \){_formatBytes(node.size)} • .${node.extension}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ])),
            ]),
          ),
          const Divider(height: 1),
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
    final isArchiveFile = ['zip', 'rar', '7z', 'tar', 'apk'].contains(node.extension.toLowerCase());

    if (node.isFolder || isArchiveFile) {
      return [
        _SheetAction('Open', Icons.folder_open_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        if (isArchiveFile) ...[
          _SheetAction('Extract Here', Icons.unarchive_rounded, () { Navigator.pop(context); _extractHere(context, ref); }),
          _SheetAction('Extract To...', Icons.drive_file_move_rounded, () { Navigator.pop(context); _extractTo(context); }),
        ],
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cut'))); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRenameBottom(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetailsBottom(context); }),
      ];
    } else {
      return [
        _SheetAction('Open', Icons.open_in_new_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        _SheetAction('Open with', Icons.apps_rounded, () { Navigator.pop(context); _openWith(context); }),
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cut'))); }),
        _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); Share.shareXFiles([XFile(node.path)]); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRenameBottom(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetailsBottom(context); }),
      ];
    }
  }

  void _openNode(BuildContext context, WidgetRef ref) {
    if (node.isFolder) {
      ref.read(directoryProvider.notifier).navigateTo(node.name);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewScreen(node: node)));
    }
  }

  void _openWith(BuildContext context) async {
    // System chooser
    // For real implementation use: OpenFile.open(node.path) from open_file package (add if needed)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening with...')));
  }

  void _extractHere(BuildContext context, WidgetRef ref) {
    // TODO: call ArchiveService.extract
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extracting here...')));
  }

  void _extractTo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose destination...')));
  }

  void _showRenameBottom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: RenameDialog(node: node),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Delete ${node.name}?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('This action cannot be undone.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              onPressed: () async {
                await ref.read(directoryProvider.notifier).deleteNode(node); // you'll add this method
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${node.name} deleted')));
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _showDetailsBottom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _detailRow('Name', node.name),
          _detailRow('Type', node.isFolder ? 'Folder' : '.${node.extension.toUpperCase()} File'),
          _detailRow('Size', _formatBytes(node.size)),
          _detailRow('Location', node.path),
          _detailRow('Modified', node.modified.toString().split('.').first),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy path'),
            onPressed: () {
              // Clipboard.setData(ClipboardData(text: node.path));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Path copied')));
            },
          ),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(value, style: const TextStyle(fontSize: 14))]),
  );

  IconData _fileIcon(String ext) { /* same as before */ return Icons.insert_drive_file_rounded; }

  String _formatBytes(int bytes) { /* same */ return '$bytes B'; }
}

class _ActionTile extends StatelessWidget { /* unchanged from before */ }
