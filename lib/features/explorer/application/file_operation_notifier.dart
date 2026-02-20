import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_utils; // Requires the 'path' package
import '../../../filesystem/application/directory_notifier.dart';

class FileOpState {
  final bool isProcessing;
  final String? errorMessage;
  
  const FileOpState({this.isProcessing = false, this.errorMessage});
}

class FileOperationNotifier extends Notifier<FileOpState> {
  @override
  FileOpState build() => const FileOpState();

  Future<void> renameItem(String oldPath, String newName) async {
    state = const FileOpState(isProcessing: true);
    try {
      final parentDir = File(oldPath).parent.path;
      final newPath = path_utils.join(parentDir, newName);
      
      final type = await FileSystemEntity.type(oldPath);
      if (type == FileSystemEntityType.file) {
        await File(oldPath).rename(newPath);
      } else if (type == FileSystemEntityType.directory) {
        await Directory(oldPath).rename(newPath);
      }
      
      _refreshCurrentDirectory();
      state = const FileOpState(isProcessing: false);
    } catch (e) {
      state = FileOpState(errorMessage: 'Failed to rename: $e');
    }
  }

  Future<void> moveItem(String sourcePath, String destDirPath) async {
    state = const FileOpState(isProcessing: true);
    final fileName = path_utils.basename(sourcePath);
    final destPath = path_utils.join(destDirPath, fileName);

    try {
      // Attempt standard rename first
      await File(sourcePath).rename(destPath);
    } on FileSystemException {
      // Fallback for cross-partition moves: Copy then Delete
      try {
        await File(sourcePath).copy(destPath);
        await File(sourcePath).delete();
      } catch (e) {
        state = FileOpState(errorMessage: 'Failed to move: $e');
        return;
      }
    }
    _refreshCurrentDirectory();
    state = const FileOpState(isProcessing: false);
  }

  Future<void> deleteItem(String path) async {
    state = const FileOpState(isProcessing: true);
    try {
      final type = await FileSystemEntity.type(path);
      if (type == FileSystemEntityType.file) {
        await File(path).delete();
      } else {
        await Directory(path).delete(recursive: true);
      }
      _refreshCurrentDirectory();
      state = const FileOpState(isProcessing: false);
    } catch (e) {
      state = FileOpState(errorMessage: 'Failed to delete: $e');
    }
  }

  void _refreshCurrentDirectory() {
    final currentPath = ref.read(directoryProvider).currentPath;
    ref.read(directoryProvider.notifier).loadDirectory(currentPath);
  }
}

final fileOpProvider = NotifierProvider<FileOperationNotifier, FileOpState>(() {
  return FileOperationNotifier();
});
