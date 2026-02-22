import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../domain/entities/omni_node.dart';
import 'storage_service.dart';

class DirectoryState {
  final AsyncValue<List<OmniNode>> nodes;
  final String currentPath;
  final List<String> pathStack;

  const DirectoryState({
    this.nodes = const AsyncValue.loading(),
    this.currentPath = 'Root',
    this.pathStack = const [],
  });

  DirectoryState copyWith({
    AsyncValue<List<OmniNode>>? nodes,
    String? currentPath,
    List<String>? pathStack,
  }) {
    return DirectoryState(
      nodes: nodes ?? this.nodes,
      currentPath: currentPath ?? this.currentPath,
      pathStack: pathStack ?? this.pathStack,
    );
  }
}

class DirectoryNotifier extends Notifier<DirectoryState> {
  @override
  DirectoryState build() {
    return const DirectoryState();
  }

  Future<void> loadDirectory(String path) async {
    state = state.copyWith(nodes: const AsyncValue.loading(), currentPath: path);
    try {
      final hasPermission = await StorageService.requestPermissions();
      if (!hasPermission) {
        state = state.copyWith(nodes: AsyncValue.error('Storage permission denied', StackTrace.current));
        return;
      }

      final dir = Directory(path);
      if (!dir.existsSync()) {
        state = state.copyWith(nodes: AsyncValue.error('Directory does not exist', StackTrace.current));
        return;
      }

      final List<OmniNode> nodes = [];
      await for (final entity in dir.list(followLinks: false)) {
        final stat = await entity.stat();
        final name = p.basename(entity.path);
        final isFolder = entity is Directory;
        
        nodes.add(OmniNode(
          name: name,
          path: entity.path,
          size: stat.size,
          modified: stat.modified,
          isFolder: isFolder,
          extension: isFolder ? '' : p.extension(name).replaceAll('.', ''),
        ));
      }

      // Sort: Folders first, then alphabetical
      nodes.sort((a, b) {
        if (a.isFolder && !b.isFolder) return -1;
        if (!a.isFolder && b.isFolder) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      final newStack = path == StorageService.internalStoragePath || path == StorageService.fallbackSdCardPath 
          ? [path] 
          : _buildStack(path);

      state = state.copyWith(nodes: AsyncValue.data(nodes), pathStack: newStack);
    } catch (e, st) {
      state = state.copyWith(nodes: AsyncValue.error(e, st));
    }
  }

  List<String> _buildStack(String path) {
    if (!path.startsWith(StorageService.internalStoragePath) && !path.startsWith(StorageService.fallbackSdCardPath)) {
      return [path];
    }
    
    final String root = path.startsWith(StorageService.internalStoragePath) 
        ? StorageService.internalStoragePath 
        : StorageService.fallbackSdCardPath;
        
    final relative = path.replaceFirst(root, '');
    final segments = relative.split('/').where((s) => s.isNotEmpty).toList();
    
    List<String> stack = [root];
    String current = root;
    for (var seg in segments) {
      current = p.join(current, seg);
      stack.add(current);
    }
    return stack;
  }

  void navigateTo(String folderName) {
    final newPath = p.join(state.currentPath, folderName);
    loadDirectory(newPath);
  }

  void jumpToPath(String path) {
    loadDirectory(path);
  }

  void jumpToIndex(int index) {
    if (index >= 0 && index < state.pathStack.length) {
      loadDirectory(state.pathStack[index]);
    }
  }

  void navigateUp() {
    if (state.pathStack.length > 1) {
      loadDirectory(state.pathStack[state.pathStack.length - 2]);
    } else {
      state = const DirectoryState(); // Go to root selector
    }
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() => DirectoryNotifier());
