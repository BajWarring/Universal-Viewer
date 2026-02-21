import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/injection_container.dart';
import '../domain/entities/omni_node.dart';
import '../domain/repositories/file_system_provider.dart';

class DirectoryState {
  final List<String> pathStack;
  final AsyncValue<List<OmniNode>> nodes;

  DirectoryState({required this.pathStack, required this.nodes});
  
  String get currentPath => pathStack.isEmpty ? 'Root' : pathStack.join('/');
}

class DirectoryNotifier extends Notifier<DirectoryState> {
  late final FileSystemProvider _localProvider;

  @override
  DirectoryState build() {
    _localProvider = sl<FileSystemProvider>(instanceName: 'local');
    // Start at an artificial "Root" level that shows drives
    Future.microtask(() => loadDirectory('Root'));
    return DirectoryState(pathStack: [], nodes: const AsyncValue.loading());
  }

  Future<void> loadDirectory(String path) async {
    state = DirectoryState(pathStack: state.pathStack, nodes: const AsyncValue.loading());
    
    // If we are at the artificial root, show the Storage Drives
    if (path == 'Root' || path.isEmpty) {
       final drives = [
        OmniNode(name: 'Internal Storage', path: '/storage/emulated/0', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
        OmniNode(name: 'SD Card', path: '/storage/sdcard1', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
      ];
      state = DirectoryState(pathStack: [], nodes: AsyncValue.data(drives));
      return;
    }

    try {
      final nodes = await _localProvider.listDirectory(path);
      state = DirectoryState(pathStack: state.pathStack, nodes: AsyncValue.data(nodes));
    } catch (e, st) {
      state = DirectoryState(pathStack: state.pathStack, nodes: AsyncValue.error(e, st));
    }
  }

  // Called when tapping a folder in the File ListView
  void navigateTo(String folderName) {
    // If we are currently at Root, we need to set the stack to the absolute path of the drive
    if (state.pathStack.isEmpty) {
       String newPath = folderName == 'Internal Storage' ? '/storage/emulated/0' : '/storage/sdcard1';
       jumpToPath(newPath);
       return;
    }

    final newStack = List<String>.from(state.pathStack)..add(folderName);
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  // Called by Dashboard to jump directly into Documents/Downloads/Internal Storage
  void jumpToPath(String absolutePath) {
    // Remove trailing slash if present, split into segments
    final cleanPath = absolutePath.endsWith('/') ? absolutePath.substring(0, absolutePath.length - 1) : absolutePath;
    final newStack = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
    
    // Add the leading slash back to the first element for absolute paths on Android
    if (newStack.isNotEmpty) {
      newStack[0] = '/${newStack[0]}';
    }
    
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  void navigateUp() {
    if (state.pathStack.isEmpty) return; // Already at Root
    
    final newStack = List<String>.from(state.pathStack)..removeLast();
    
    // If we backed all the way out, go to the Drive Selection Root
    if (newStack.isEmpty) {
      state = DirectoryState(pathStack: [], nodes: const AsyncValue.loading());
      loadDirectory('Root');
    } else {
      state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
      loadDirectory(state.currentPath);
    }
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() {
  return DirectoryNotifier();
});
