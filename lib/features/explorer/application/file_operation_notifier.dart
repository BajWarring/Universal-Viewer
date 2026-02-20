import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

enum FileOpType { none, copy, cut, extract }

class FileOperationState {
  final Set<OmniNode> selectedNodes;
  final List<OmniNode> clipboard;
  final FileOpType operation;

  const FileOperationState({
    this.selectedNodes = const {},
    this.clipboard = const [],
    this.operation = FileOpType.none,
  });

  FileOperationState copyWith({
    Set<OmniNode>? selectedNodes,
    List<OmniNode>? clipboard,
    FileOpType? operation,
  }) {
    return FileOperationState(
      selectedNodes: selectedNodes ?? this.selectedNodes,
      clipboard: clipboard ?? this.clipboard,
      operation: operation ?? this.operation,
    );
  }
}

class FileOperationNotifier extends Notifier<FileOperationState> {
  @override
  FileOperationState build() => const FileOperationState();

  // --- SELECTION LOGIC ---
  void toggleSelection(OmniNode node) {
    final newSelection = Set<OmniNode>.from(state.selectedNodes);
    if (newSelection.contains(node)) {
      newSelection.remove(node);
    } else {
      newSelection.add(node);
    }
    state = state.copyWith(selectedNodes: newSelection);
  }

  void clearSelection() => state = state.copyWith(selectedNodes: {});

  // --- CLIPBOARD LOGIC ---
  void setOperation(FileOpType type) {
    if (state.selectedNodes.isEmpty && type != FileOpType.none) return;
    state = state.copyWith(
      clipboard: state.selectedNodes.toList(),
      operation: type,
      selectedNodes: {}, // Clear selection after cutting/copying
    );
  }

  void clearClipboard() => state = state.copyWith(clipboard: [], operation: FileOpType.none);

  // Execute the paste/extract
  Future<void> executePaste(String destinationPath) async {
    if (state.operation == FileOpType.none || state.clipboard.isEmpty) return;

    // TODO: Call your FileSystemProvider to actually copy/move the files here
    // print('Executing ${state.operation} to $destinationPath');

    // Clear after pasting
    clearClipboard();
  }
}

final fileOperationProvider = NotifierProvider<FileOperationNotifier, FileOperationState>(() {
  return FileOperationNotifier();
});
