import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/application/file_service.dart';
import '../../../../filesystem/application/directory_notifier.dart';
import '../../archive_engine/application/archive_service.dart';

enum FileOpType { none, copy, cut, extract, compress, delete, undo }
enum SortBy { name, size, date, type }
enum SortOrder { asc, desc }
enum TaskStatus { idle, running, success, error }

class FileOperationState {
  final Set<OmniNode> selectedNodes;
  final List<OmniNode> clipboard;
  final FileOpType operation;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isGridView;
  
  final TaskStatus taskStatus;
  final double taskProgress;
  final String currentTaskItem;
  final String errorMessage;
  
  final UndoAction? lastUndoableAction;

  const FileOperationState({
    this.selectedNodes = const {},
    this.clipboard = const [],
    this.operation = FileOpType.none,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.asc,
    this.isGridView = false,
    this.taskStatus = TaskStatus.idle,
    this.taskProgress = 0.0,
    this.currentTaskItem = '',
    this.errorMessage = '',
    this.lastUndoableAction,
  });

  bool get isSelectionMode => selectedNodes.isNotEmpty;

  FileOperationState copyWith({
    Set<OmniNode>? selectedNodes,
    List<OmniNode>? clipboard,
    FileOpType? operation,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? isGridView,
    TaskStatus? taskStatus,
    double? taskProgress,
    String? currentTaskItem,
    String? errorMessage,
    UndoAction? lastUndoableAction,
  }) {
    return FileOperationState(
      selectedNodes: selectedNodes ?? this.selectedNodes,
      clipboard: clipboard ?? this.clipboard,
      operation: operation ?? this.operation,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isGridView: isGridView ?? this.isGridView,
      taskStatus: taskStatus ?? this.taskStatus,
      taskProgress: taskProgress ?? this.taskProgress,
      currentTaskItem: currentTaskItem ?? this.currentTaskItem,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUndoableAction: lastUndoableAction ?? this.lastUndoableAction,
    );
  }
}

class FileOperationNotifier extends Notifier<FileOperationState> {
  @override
  FileOperationState build() => const FileOperationState();

  void toggleSelection(OmniNode node) {
    final newSel = Set<OmniNode>.from(state.selectedNodes);
    newSel.contains(node) ? newSel.remove(node) : newSel.add(node);
    state = state.copyWith(selectedNodes: newSel);
  }

  void selectAll(List<OmniNode> nodes) => state = state.copyWith(selectedNodes: Set.from(nodes));
  void deselectAll() => state = state.copyWith(selectedNodes: {});
  void invertSelection(List<OmniNode> nodes) {
    final newSel = nodes.where((n) => !state.selectedNodes.contains(n)).toSet();
    state = state.copyWith(selectedNodes: newSel);
  }
  void clearSelection() => state = state.copyWith(selectedNodes: {});

  // Updated to accept explicit nodes so single-item taps in the bottom sheet trigger the Operation Bar
  void setOperation(FileOpType type, {List<OmniNode>? explicitNodes}) {
    final nodes = explicitNodes ?? state.selectedNodes.toList();
    if (nodes.isEmpty && type != FileOpType.none) return;
    state = state.copyWith(clipboard: nodes, operation: type, selectedNodes: {});
  }

  void clearClipboard() => state = state.copyWith(clipboard: [], operation: FileOpType.none);
  void toggleView() => state = state.copyWith(isGridView: !state.isGridView);

  void cancelTask() => state = state.copyWith(taskStatus: TaskStatus.idle, taskProgress: 0, currentTaskItem: '');

  Future<void> executePaste(String destinationPath) async {
    if (state.operation == FileOpType.none || state.clipboard.isEmpty) return;
    
    final nodesToProcess = List<OmniNode>.from(state.clipboard);
    final opType = state.operation;
    
    state = state.copyWith(taskStatus: TaskStatus.running, taskProgress: 0.0, lastUndoableAction: null);
    clearClipboard();

    try {
      if (opType == FileOpType.copy) {
        await FileService.copyNodes(nodesToProcess, destinationPath, _updateProgress);
      } else if (opType == FileOpType.cut) {
        await FileService.moveNodes(nodesToProcess, destinationPath, _updateProgress);
      } else if (opType == FileOpType.extract) {
        await ArchiveService.extract(nodesToProcess.first.path, destinationPath, _updateProgress);
      }
      
      ref.read(directoryProvider.notifier).loadDirectory(destinationPath);
    } catch (e) {
      state = state.copyWith(taskStatus: TaskStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> executeCompress(CompressParams params) async {
    state = state.copyWith(taskStatus: TaskStatus.running, operation: FileOpType.compress, taskProgress: 0.0, lastUndoableAction: null);
    try {
      await ArchiveService.compressDirectory(params, _updateProgress);
      ref.read(directoryProvider.notifier).loadDirectory(ref.read(directoryProvider).currentPath);
    } catch (e) {
      state = state.copyWith(taskStatus: TaskStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> executeDelete(List<OmniNode> nodes) async {
    state = state.copyWith(taskStatus: TaskStatus.running, operation: FileOpType.delete, taskProgress: 0.0, lastUndoableAction: null);
    try {
      await FileService.deleteNodes(nodes, _updateProgress);
      ref.read(directoryProvider.notifier).loadDirectory(ref.read(directoryProvider).currentPath);
      clearSelection();
    } catch (e) {
      state = state.copyWith(taskStatus: TaskStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> undoLastAction() async {
    final action = state.lastUndoableAction;
    if (action == null) return;

    state = state.copyWith(taskStatus: TaskStatus.running, operation: FileOpType.undo, taskProgress: 0.0, lastUndoableAction: null);
    try {
      await FileService.undoTask(action, _updateProgress);
      ref.read(directoryProvider.notifier).loadDirectory(ref.read(directoryProvider).currentPath);
    } catch (e) {
      state = state.copyWith(taskStatus: TaskStatus.error, errorMessage: e.toString());
    }
  }

  void _updateProgress(FileOperationMessage msg) {
    if (msg.percentage >= 1.0) {
      state = state.copyWith(taskStatus: TaskStatus.success, taskProgress: 1.0, currentTaskItem: msg.currentItemName, lastUndoableAction: msg.undoAction);
    } else {
      state = state.copyWith(taskProgress: msg.percentage, currentTaskItem: msg.currentItemName);
    }
  }

  List<OmniNode> sortedNodes(List<OmniNode> nodes) {
    final sorted = List<OmniNode>.from(nodes);
    sorted.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }
}

final fileOperationProvider = NotifierProvider<FileOperationNotifier, FileOperationState>(() => FileOperationNotifier());
