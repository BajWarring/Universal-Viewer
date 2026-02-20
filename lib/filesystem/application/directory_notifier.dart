import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_file_manager/core/config/injection_container.dart';
import 'package:omni_file_manager/filesystem/domain/entities/omni_node.dart';
import 'package:omni_file_manager/filesystem/domain/repositories/file_system_provider.dart';

// State class to hold the path stack and the current directory contents
class DirectoryState {
  final List<String> pathStack;
  final AsyncValue<List<OmniNode>> nodes;

  DirectoryState({required this.pathStack, required this.nodes});
  
  String get currentPath => pathStack.isEmpty ? '' : pathStack.join('/');
}

class DirectoryNotifier extends Notifier<DirectoryState> {
  late final FileSystemProvider _localProvider;

  @override
  DirectoryState build() {
    // We fetch our LocalFileSystemProvider from GetIt (set up in Phase 1)
    _localProvider = sl<FileSystemProvider>(instanceName: 'local');
    return DirectoryState(pathStack: ['/storage/emulated/0'], nodes: const AsyncValue.loading());
  }

  Future<void> loadDirectory(String path) async {
    state = DirectoryState(pathStack: state.pathStack, nodes: const AsyncValue.loading());
    try {
      final nodes = await _localProvider.listDirectory(path);
      state = DirectoryState(pathStack: state.pathStack, nodes: AsyncValue.data(nodes));
    } catch (e, st) {
      state = DirectoryState(pathStack: state.pathStack, nodes: AsyncValue.error(e, st));
    }
  }

  void navigateTo(String folderName) {
    final newStack = List<String>.from(state.pathStack)..add(folderName);
    state = DirectoryState(pathStack: newStack, nodes: state.nodes);
    loadDirectory(state.currentPath);
  }

  void navigateUp() {
    if (state.pathStack.length > 1) {
      final newStack = List<String>.from(state.pathStack)..removeLast();
      state = DirectoryState(pathStack: newStack, nodes: state.nodes);
      loadDirectory(state.currentPath);
    }
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() {
  return DirectoryNotifier();
});
