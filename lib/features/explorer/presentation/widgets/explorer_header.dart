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
        onSelectAll: () {
          dirState.nodes.whenData((nodes) => ref.read(fileOperationProvider.notifier).selectAll(nodes));
        },
        onDeselectAll: () => ref.read(fileOperationProvider.notifier).deselectAll(),
        onInvert: () {
          dirState.nodes.whenData((nodes) => ref.read(fileOperationProvider.notifier).invertSelection(nodes));
        },
      );
    }

    final currentFolderName = dirState.pathStack.isEmpty ? 'Storage' : dirState.pathStack.last.split('/').last;

    return AppBar(
      title: GestureDetector(
        onTap: () => _showBreadcrumbPopup(context, ref, dirState),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(currentFolderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (dirState.pathStack.isNotEmpty)
                const Icon(Icons.expand_more_rounded, color: Colors.grey, size: 20),
            ]),
            if (dirState.currentPath != 'Root')
              Text(dirState.currentPath, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
          ]),
        ]),
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
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _showMoreMenu(context, ref, opState),
        ),
      ],
    );
  }

  void _showBreadcrumbPopup(BuildContext context, WidgetRef ref, DirectoryState dirState) {
    if (dirState.pathStack.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Navigate to', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Root item
              ListTile(
                leading: const Icon(Icons.storage_rounded),
                title: const Text('Storage Root'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(directoryProvider.notifier).loadDirectory('Root');
                },
              ),
              const Divider(height: 1),
              ...List.generate(dirState.pathStack.length, (index) {
                final segment = dirState.pathStack[index].split('/').last;
                final isLast = index == dirState.pathStack.length - 1;
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 16.0 + index * 8, right: 16),
                  leading: Icon(
                    index == 0 ? Icons.smartphone_rounded : Icons.folder_rounded,
                    color: isLast ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(segment, style: TextStyle(
                    fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                    color: isLast ? Theme.of(context).colorScheme.primary : null,
                  )),
                  trailing: isLast ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 18) : null,
                  onTap: isLast ? null : () {
                    Navigator.pop(ctx);
                    ref.read(directoryProvider.notifier).jumpToIndex(index);
                  },
                );
              }),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Switch Drive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              ListTile(
                leading: const Icon(Icons.smartphone_rounded),
                title: const Text('Internal Storage'),
                onTap: () { Navigator.pop(ctx); ref.read(directoryProvider.notifier).jumpToPath('/storage/emulated/0'); },
              ),
              ListTile(
                leading: const Icon(Icons.sd_card_rounded),
                title: const Text('SD Card'),
                onTap: () { Navigator.pop(ctx); ref.read(directoryProvider.notifier).jumpToPath('/storage/sdcard1'); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref, FileOperationState opState) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.checklist_rounded),
            title: const Text('Select items'),
            onTap: () { Navigator.pop(ctx); /* trigger via long press */ },
          ),
          ListTile(
            leading: const Icon(Icons.sort_rounded),
            title: const Text('Sort by'),
            onTap: () { Navigator.pop(ctx); _showSortSheet(context, ref, opState); },
          ),
        ]),
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref, FileOperationState opState) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SortSheet(opState: opState, ref: ref),
    );
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose, onSelectAll, onDeselectAll, onInvert;
  const _SelectionAppBar({
    required this.selectedCount, required this.onClose,
    required this.onSelectAll, required this.onDeselectAll, required this.onInvert,
  });

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
            PopupMenuItem(value: 'invert', child: Text('Invert Selection')),
          ],
        ),
      ],
    );
  }
}

class _SortSheet extends ConsumerWidget {
  final FileOperationState opState;
  final WidgetRef ref;
  const _SortSheet({required this.opState, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final theme = Theme.of(context);
    final currentState = watchRef.watch(fileOperationProvider);

    final sortOptions = [
      (SortBy.name, 'Name', Icons.sort_by_alpha_rounded),
      (SortBy.size, 'Size', Icons.format_size_rounded),
      (SortBy.date, 'Date Modified', Icons.calendar_today_rounded),
      (SortBy.type, 'File Type', Icons.category_rounded),
    ];

    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              icon: Icon(currentState.sortOrder == SortOrder.asc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 16),
              label: Text(currentState.sortOrder == SortOrder.asc ? 'Ascending' : 'Descending'),
              onPressed: () => watchRef.read(fileOperationProvider.notifier).toggleSortOrder(),
            ),
          ]),
        ),
        const Divider(height: 1),
        ...sortOptions.map((opt) {
          final isActive = currentState.sortBy == opt.$1;
          return ListTile(
            leading: Icon(opt.$3, color: isActive ? theme.colorScheme.primary : null),
            title: Text(opt.$2),
            trailing: isActive ? Icon(Icons.radio_button_checked, color: theme.colorScheme.primary) : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            onTap: () => watchRef.read(fileOperationProvider.notifier).setSortBy(opt.$1),
          );
        }),
        const SizedBox(height: 8),
      ]),
    );
  }
}
