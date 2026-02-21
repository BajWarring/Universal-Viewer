import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../application/file_operation_notifier.dart';
import '../../../search/presentation/search_screen.dart';

class ExplorerHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ExplorerHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(fileOperationProvider);
    final dirState = ref.watch(directoryProvider);

    if (opState.isSelectionMode) {
      return _SelectionAppBar(
        selectedCount: opState.selectedNodes.length,
        onClose: () => ref.read(fileOperationProvider.notifier).clearSelection(),
        onSelectAll: () => dirState.nodes.whenData((nodes) => ref.read(fileOperationProvider.notifier).selectAll(nodes)),
        onDeselectAll: () => ref.read(fileOperationProvider.notifier).deselectAll(),
        onInvert: () => dirState.nodes.whenData((nodes) => ref.read(fileOperationProvider.notifier).invertSelection(nodes)),
      );
    }

    final currentFolderName = dirState.pathStack.isEmpty ? 'Storage' : dirState.pathStack.last.split('/').last;
    
    return AppBar(
      title: GestureDetector(
        onTap: () => _showBreadcrumbDropdown(context, ref, dirState),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(currentFolderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (dirState.pathStack.isNotEmpty) const Icon(Icons.expand_more_rounded, color: Colors.grey, size: 20),
            ]),
            if (dirState.currentPath != 'Root') Text(dirState.currentPath, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
          ]),
        ]),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
        IconButton(icon: Icon(opState.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded), onPressed: () 
=> ref.read(fileOperationProvider.notifier).toggleView()),
        IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () => _showMoreMenu(context, ref, opState)),
      ],
    );
  }

  void _showBreadcrumbDropdown(BuildContext context, WidgetRef ref, DirectoryState dirState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(28)),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, 
margin: const EdgeInsets.only(top: 12, bottom: 8), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Current Path', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            ...List.generate(dirState.pathStack.length, (index) {
              final segment = dirState.pathStack[index].split('/').last;
              final isLast = index == dirState.pathStack.length - 1;
              return ListTile(
                leading: Icon(index == 0 ? Icons.smartphone_rounded : Icons.folder_rounded, color: isLast ? Theme.of(context).colorScheme.primary : null),
                title: Text(segment, style: TextStyle(fontWeight: isLast ? FontWeight.bold : FontWeight.normal, color: isLast ? Theme.of(context).colorScheme.primary : null)),
                onTap: isLast ? null : () { Navigator.pop(context); ref.read(directoryProvider.notifier).jumpToIndex(index); },
              );
            }),
            const Divider(height: 1),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Storage Drives', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            ListTile(leading: const Icon(Icons.smartphone_rounded), title: const Text('Internal Storage'), onTap: () { Navigator.pop(context); ref.read(directoryProvider.notifier).jumpToPath('/storage/emulated/0'); }),
            ListTile(leading: const Icon(Icons.sd_card_rounded), title: const Text('SD Card'), onTap: () { Navigator.pop(context); ref.read(directoryProvider.notifier).jumpToPath('/storage/sdcard1'); }),
          ]),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref, FileOperationState opState) {
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.checklist_rounded), title: const Text('Select items'), onTap: () { Navigator.pop(ctx); }),
      ListTile(leading: const Icon(Icons.sort_rounded), title: const Text('Sort by'), onTap: () { Navigator.pop(ctx); }),
    ])));
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount; 
  final VoidCallback onClose, onSelectAll, onDeselectAll, onInvert;

  const _SelectionAppBar({required this.selectedCount, required this.onClose, required this.onSelectAll, required this.onDeselectAll, required this.onInvert});
  
  @override 
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override 
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), 
      leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose), 
      title: Text('$selectedCount selected', style: const TextStyle(fontWeight: FontWeight.bold)), 
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.checklist_rounded), 
          onSelected: (v) { 
            if (v == 'all') {
              onSelectAll(); 
            } else if (v == 'none') {
              onDeselectAll(); 
            } else {
              onInvert(); 
            }
          }, 
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('Select All')), 
            PopupMenuItem(value: 'none', child: Text('Deselect All')), 
            PopupMenuItem(value: 'invert', child: Text('Invert Selection'))
          ]
        )
      ]
    );
  }
}
