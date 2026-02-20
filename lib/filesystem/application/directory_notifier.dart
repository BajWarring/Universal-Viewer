import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/injection_container.dart';
import '../domain/entities/omni_node.dart';
import '../domain/repositories/file_system_provider.dart';

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
    _localProvider = sl<FileSystemProvider>(instanceName: 'local');
    
    // Trigger the permission request and file load immediately on startup
    Future.microtask(() => _init());
    
    return DirectoryState(pathStack: ['/storage/emulated/0'], nodes: const AsyncValue.loading());
  }

  Future<void> _init() async {
    // Request Android Storage Permissions
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      loadDirectory('/storage/emulated/0');
    } else {
      state = DirectoryState(
        pathStack: state.pathStack, 
        nodes: AsyncValue.error('Storage Permission Denied. Please enable in settings.', StackTrace.current)
      );
    }
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
    state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
    loadDirectory(state.currentPath);
  }

  void navigateUp() {
    if (state.pathStack.length > 1) {
      final newStack = List<String>.from(state.pathStack)..removeLast();
      state = DirectoryState(pathStack: newStack, nodes: const AsyncValue.loading());
      loadDirectory(state.currentPath);
    }
  }
}

final directoryProvider = NotifierProvider<DirectoryNotifier, DirectoryState>(() {
  return DirectoryNotifier();
});
