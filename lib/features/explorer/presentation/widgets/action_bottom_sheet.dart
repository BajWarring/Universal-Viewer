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
                Text(node.isFolder ? 'Folder' : '${_formatBytes(node.size)} • .${node.extension}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
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
    final isArchive = ['zip','rar','7z','tar','apk'].contains(node.extension.toLowerCase());
    if (node.isFolder || isArchive) {
      return [
        _SheetAction('Open', Icons.folder_open_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        if (isArchive) ...[
          _SheetAction('Extract Here', Icons.unarchive_rounded, () { Navigator.pop(context); _extractHere(context); }),
          _SheetAction('Extract To...', Icons.drive_file_move_rounded, () { Navigator.pop(context); _extractTo(context); }),
        ],
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cut'))); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRename(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context); }),
        if (!node.isFolder) _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); Share.shareXFiles([XFile(node.path)]); }),
      ];
    } else {
      return [
        _SheetAction('Open', Icons.open_in_new_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        _SheetAction('Open with', Icons.apps_rounded, () { Navigator.pop(context); _openWith(context); }),
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cut'))); }),
        _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); Share.shareXFiles([XFile(node.path)]); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRename(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context); }),
      ];
    }
  }

  void _openNode(BuildContext context, WidgetRef ref) {
    if (node.isFolder) {
      ref.read(directoryProvider.notifier).navigateTo(node.name);
    } else {
      UnifiedViewer.show(context, node);
    }
  }

  void _openWith(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening with system apps...')));
  void _extractHere(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extracting here...')));
  void _extractTo(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose destination...')));
  
  void _showRename(BuildContext context) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: RenameDialog(node: node)));
  
  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, builder: (_) => Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Delete ${node.name}?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton(onPressed: () async {
          await ref.read(directoryProvider.notifier).deleteNode(node);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${node.name} deleted')));
          }
        }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete'))),
      ]),
    ])));
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _detailRow('Name', node.name),
      _detailRow('Type', node.isFolder ? 'Folder' : '.${node.extension.toUpperCase()} File'),
      _detailRow('Size', _formatBytes(node.size)),
      _detailRow('Location', node.path),
      _detailRow('Modified', node.modified.toString().split('.').first),
      const SizedBox(height: 16),
      OutlinedButton.icon(icon: const Icon(Icons.copy), label: const Text('Copy path'), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Path copied')))),
    ])));
  }

  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(value, style: const TextStyle(fontSize: 14))]));

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'mp4': case 'mkv': return Icons.video_library_rounded;
      case 'mp3': return Icons.music_note_rounded;
      case 'jpg': case 'png': return Icons.image_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'zip': case 'rar': case '7z': return Icons.folder_zip_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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


  
  List<_SheetAction> _buildActions(BuildContext context, WidgetRef ref) {
    final isArchive = ['zip','rar','7z','tar','apk'].contains(node.extension.toLowerCase());
    if (node.isFolder || isArchive) {
      return [
        _SheetAction('Open', Icons.folder_open_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        if (isArchive) ...[
          // Extracts in the current folder immediately
          _SheetAction('Extract Here', Icons.unarchive_rounded, () { 
            Navigator.pop(context); 
            ref.read(fileOperationProvider.notifier).setOperation(FileOpType.extract, explicitNodes: [node]);
            ref.read(fileOperationProvider.notifier).executePaste(ref.read(directoryProvider).currentPath);
            TaskProgressDialog.show(context);
          }),
          // Pops up the OperationBar allowing user to navigate to another folder and hit Paste/Extract
          _SheetAction('Extract To...', Icons.drive_file_move_rounded, () { 
            ref.read(fileOperationProvider.notifier).setOperation(FileOpType.extract, explicitNodes: [node]);
            Navigator.pop(context); 
          }),
        ],
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        
        // Explicitly pass [node] so single items trigger the bottom Operation Bar
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy, explicitNodes: [node]); Navigator.pop(context); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut, explicitNodes: [node]); Navigator.pop(context); }),
        
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRename(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context); }),
        if (!node.isFolder) _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); Share.shareXFiles([XFile(node.path)]); }),
      ];
    } else {
      return [
        _SheetAction('Open', Icons.open_in_new_rounded, () { Navigator.pop(context); _openNode(context, ref); }),
        _SheetAction('Open with', Icons.apps_rounded, () { Navigator.pop(context); _openWith(context); }),
        _SheetAction('Compress', Icons.folder_zip_rounded, () { Navigator.pop(context); CompressDialog.show(context, node); }),
        
        _SheetAction('Copy', Icons.copy_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.copy, explicitNodes: [node]); Navigator.pop(context); }),
        _SheetAction('Cut', Icons.content_cut_rounded, () { ref.read(fileOperationProvider.notifier).setOperation(FileOpType.cut, explicitNodes: [node]); Navigator.pop(context); }),
        
        _SheetAction('Share', Icons.share_rounded, () { Navigator.pop(context); Share.shareXFiles([XFile(node.path)]); }),
        _SheetAction('Rename', Icons.drive_file_rename_outline_rounded, () { Navigator.pop(context); _showRename(context); }),
        _SheetAction('Delete', Icons.delete_outline_rounded, () { Navigator.pop(context); _showDeleteConfirm(context, ref); }, isDestructive: true),
        _SheetAction('Details', Icons.info_outline_rounded, () { Navigator.pop(context); _showDetails(context); }),
      ];
    }
  }



  
  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final bg = action.isDestructive ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
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
