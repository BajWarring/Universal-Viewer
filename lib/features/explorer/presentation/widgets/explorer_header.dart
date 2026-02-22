import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../../../filesystem/application/storage_service.dart';
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

    final rawFolderName = dirState.pathStack.isEmpty ? 'Storage' : dirState.pathStack.last.split('/').last;
    final currentFolderName = StorageService.getFriendlyFolderName(rawFolderName);
    final currentPath = dirState.currentPath == 'Root' ? 'Select a drive' : StorageService.getFriendlyPath(dirState.currentPath);

    return AppBar(
      title: InkWell(
        onTap: () => _showLocationDropdown(context, ref, dirState),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentFolderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, color: Colors.grey, size: 20),
                ],
              ),
              Text(currentPath, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        ),
        IconButton(
          icon: Icon(opState.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
          onPressed: () => ref.read(fileOperationProvider.notifier).toggleView(),
        ),
      ],
    );
  }

  void _showLocationDropdown(BuildContext context, WidgetRef ref, DirectoryState dirState) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final availableDrives = StorageService.getStorageRoots();

    showMenu<dynamic>(
      context: context,
      position: RelativeRect.fromLTRB(16, offset.dy + kToolbarHeight + 10, 100, 0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      items: <PopupMenuEntry<dynamic>>[
        const PopupMenuItem<String>(
          enabled: false,
          height: 30,
          child: Text('CURRENT PATH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        ),
        ...List.generate(dirState.pathStack.length, (index) {
          final segment = StorageService.getFriendlyFolderName(dirState.pathStack[index].split('/').last);
          final isLast = index == dirState.pathStack.length - 1;
          final icon = index == 0 ? (segment.contains('Internal') ? Icons.smartphone_rounded : Icons.sd_card_rounded) : Icons.folder_open_rounded;
          
          return PopupMenuItem<int>(
            value: index,
            height: 40,
            child: Row(
              children: [
                SizedBox(width: index * 12.0),
                Icon(icon, size: 20, color: isLast ? Theme.of(context).colorScheme.primary : Colors.grey),
                const SizedBox(width: 12),
                Text(segment, style: TextStyle(fontSize: 13, fontWeight: isLast ? FontWeight.bold : FontWeight.w500, color: isLast ? Theme.of(context).colorScheme.primary : null)),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          enabled: false,
          height: 30,
          child: Text('DRIVES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        ),
        ...availableDrives.map((drive) => PopupMenuItem<String>(
          value: drive['path'] as String,
          height: 40,
          child: Row(
            children: [
              Icon(drive['icon'] == 'smartphone' ? Icons.smartphone_rounded : Icons.sd_card_rounded, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Text(drive['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        )),
      ],
    ).then((value) {
      if (value is int) {
        ref.read(directoryProvider.notifier).jumpToIndex(value);
      } else if (value is String) {
        ref.read(directoryProvider.notifier).jumpToPath(value);
      }
    });
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount; 
  final VoidCallback onClose, onSelectAll, onDeselectAll, onInvert;
  const _SelectionAppBar({required this.selectedCount, required this.onClose, required this.onSelectAll, required this.onDeselectAll, required this.onInvert});
  
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
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
