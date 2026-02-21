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
    Future.microtask(() => loadDirectory('Root'));
    return DirectoryState(pathStack: [], nodes: const AsyncValue.loading());
  }

  Future<void> loadDirectory(String path) async {
    state = DirectoryState(pathStack: state.pathStack, nodes: const AsyncValue.loading());
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

  void navigateTo(String folderName) {
    if (state.pathStack.isEmpty) {
      String newPath = folderName == 'Internal Storage' ? '/storage/emulated/0' : '/storage/sdcard1';
      jumpToPath(newPath);
      return;
    }
    final newStack = List<String>.from(state.pathStack)..add(folderName);
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  void jumpToPath(String absolutePath) {
    final cleanPath = absolutePath.endsWith('/') ? absolutePath.substring(0, absolutePath.length - 1) : absolutePath;
    final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
    final newStack = <String>[];
    if (segments.isNotEmpty) {
      newStack.add('/${segments[0]}');
      newStack.addAll(segments.sublist(1));
    }
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  void navigateUp() {
    if (state.pathStack.isEmpty) return;
    final newStack = List<String>.from(state.pathStack)..removeLast();
    if (newStack.isEmpty) {
      state = DirectoryState(pathStack: [], nodes: const AsyncValue.loading());
      loadDirectory('Root');
    } else {
      state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
      loadDirectory(state.currentPath);
    }
  }

  void jumpToIndex(int index) {
    final newStack = state.pathStack.sublist(0, index + 1);
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  Future<void> deleteNode(OmniNode node) async {
    await _localProvider.delete(node.path);
    loadDirectory(state.currentPath);
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() => DirectoryNotifier());
