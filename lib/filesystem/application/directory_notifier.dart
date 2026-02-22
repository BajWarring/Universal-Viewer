import 'dart:io';
import 'dart:isolate';
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

  DirectoryState copyWith({AsyncValue<List<OmniNode>>? nodes, String? currentPath, List<String>? pathStack}) {
    return DirectoryState(nodes: nodes ?? this.nodes, currentPath: currentPath ?? this.currentPath, pathStack: pathStack ?? this.pathStack);
  }
}

class DirectoryNotifier extends Notifier<DirectoryState> {
  @override
  DirectoryState build() => const DirectoryState();

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

      // Run folder parsing & item counting in background Isolate for 60fps performance
      final nodes = await Isolate.run(() => _loadDirectoryIsolate(path));

      final newStack = path == StorageService.internalStoragePath || path == StorageService.fallbackSdCardPath 
          ? [path] 
          : _buildStack(path);

      state = state.copyWith(nodes: AsyncValue.data(nodes), pathStack: newStack);
    } catch (e, st) {
      state = state.copyWith(nodes: AsyncValue.error(e, st));
    }
  }

  static Future<List<OmniNode>> _loadDirectoryIsolate(String path) async {
    final dir = Directory(path);
    final List<OmniNode> nodes = [];
    final entities = dir.listSync(followLinks: false);
    
    for (final entity in entities) {
      final stat = entity.statSync();
      final name = p.basename(entity.path);
      final isFolder = entity is Directory;
      
      int? itemCount;
      if (isFolder) {
        try {
          itemCount = (entity as Directory).listSync(followLinks: false).length;
        } catch (_) { itemCount = 0; }
      }
      
      nodes.add(OmniNode(
        name: name,
        path: entity.path,
        size: stat.size,
        modified: stat.modified,
        isFolder: isFolder,
        extension: isFolder ? '' : p.extension(name).replaceAll('.', ''),
        itemCount: itemCount,
      ));
    }

    nodes.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    
    return nodes;
  }

  List<String> _buildStack(String path) {
    if (!path.startsWith(StorageService.internalStoragePath) && !path.startsWith(StorageService.fallbackSdCardPath)) return [path];
    final String root = path.startsWith(StorageService.internalStoragePath) ? StorageService.internalStoragePath : StorageService.fallbackSdCardPath;
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

  void navigateTo(String folderName) => loadDirectory(p.join(state.currentPath, folderName));
  void jumpToPath(String path) => loadDirectory(path);
  void jumpToIndex(int index) {
    if (index >= 0 && index < state.pathStack.length) loadDirectory(state.pathStack[index]);
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() => DirectoryNotifier());
