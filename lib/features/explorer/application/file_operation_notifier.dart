import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

enum FileOpType { none, copy, cut, extract }
enum SortBy { name, size, date, type }
enum SortOrder { asc, desc }

class FileOperationState {
  final Set<OmniNode> selectedNodes;
  final List<OmniNode> clipboard;
  final FileOpType operation;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isGridView;

  const FileOperationState({
    this.selectedNodes = const {},
    this.clipboard = const [],
    this.operation = FileOpType.none,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.asc,
    this.isGridView = false,
  });

  bool get isSelectionMode => selectedNodes.isNotEmpty;

  FileOperationState copyWith({
    Set<OmniNode>? selectedNodes,
    List<OmniNode>? clipboard,
    FileOpType? operation,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? isGridView,
  }) {
    return FileOperationState(
      selectedNodes: selectedNodes ?? this.selectedNodes,
      clipboard: clipboard ?? this.clipboard,
      operation: operation ?? this.operation,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}

class FileOperationNotifier extends Notifier<FileOperationState> {
  @override
  FileOperationState build() => const FileOperationState();

  void toggleSelection(OmniNode node) {
    final newSel = Set<OmniNode>.from(state.selectedNodes);
    if (newSel.contains(node)) {
      newSel.remove(node);
    } else {
      newSel.add(node);
    }
    state = state.copyWith(selectedNodes: newSel);
  }

  void selectAll(List<OmniNode> nodes) => state = state.copyWith(selectedNodes: Set.from(nodes));
  void deselectAll() => state = state.copyWith(selectedNodes: {});
  void invertSelection(List<OmniNode> nodes) {
    final newSel = nodes.where((n) => !state.selectedNodes.contains(n)).toSet();
    state = state.copyWith(selectedNodes: newSel);
  }

  void clearSelection() => state = state.copyWith(selectedNodes: {});

  void setOperation(FileOpType type) {
    if (state.selectedNodes.isEmpty && type != FileOpType.none) return;
    state = state.copyWith(clipboard: state.selectedNodes.toList(), operation: type, selectedNodes: {});
  }

  void clearClipboard() => state = state.copyWith(clipboard: [], operation: FileOpType.none);

  void setSortBy(SortBy by) => state = state.copyWith(sortBy: by);
  void toggleSortOrder() => state = state.copyWith(sortOrder: state.sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc);
  void toggleView() => state = state.copyWith(isGridView: !state.isGridView);

  Future<void> executePaste(String destinationPath) async {
    if (state.operation == FileOpType.none || state.clipboard.isEmpty) return;
    clearClipboard();
  }

  List<OmniNode> sortedNodes(List<OmniNode> nodes) {
    final sorted = List<OmniNode>.from(nodes);
    sorted.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      int cmp;
      switch (state.sortBy) {
        case SortBy.name: cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase()); break;
        case SortBy.size: cmp = a.size.compareTo(b.size); break;
        case SortBy.date: cmp = a.modified.compareTo(b.modified); break;
        case SortBy.type: cmp = a.extension.compareTo(b.extension); break;
      }
      return state.sortOrder == SortOrder.asc ? cmp : -cmp;
    });
    return sorted;
  }
}

final fileOperationProvider = NotifierProvider<FileOperationNotifier, FileOperationState>(() => FileOperationNotifier());



  Future<void> executePaste(String destinationPath) async {
    if (state.operation == FileOpType.none || state.clipboard.isEmpty) return;

    final provider = sl<FileSystemProvider>(instanceName: 'local');
    for (final item in state.clipboard) {
      if (state.operation == FileOpType.copy) {
        // copy logic (for folders it's recursive)
        await _copyItem(item, destinationPath, provider);
      } else if (state.operation == FileOpType.cut) {
        await _moveItem(item, destinationPath, provider);
      }
    }
    clearClipboard();
  }

  Future<void> _copyItem(OmniNode item, String dest, FileSystemProvider provider) async {
    // simple implementation - you can make it more robust
    final newPath = '\( dest/ \){item.name}';
    // actual file copy code would go here (use File.copy / Directory copy recursive)
    // for now placeholder
  }

  Future<void> _moveItem(OmniNode item, String dest, FileSystemProvider provider) async {
    await provider.rename(item.path, '\( dest/ \){item.name}'); // reuse rename for move
  }
