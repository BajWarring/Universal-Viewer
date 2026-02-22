import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import '../domain/entities/omni_node.dart';
import '../../features/explorer/application/file_operation_notifier.dart'; // For FileOpType

class FileOperationMessage {
  final int currentItem;
  final int totalItems;
  final String currentItemName;
  final double percentage;
  final UndoAction? undoAction; // Passed back when operation finishes

  FileOperationMessage(this.currentItem, this.totalItems, this.currentItemName, this.percentage, {this.undoAction});
}

class UndoAction {
  final FileOpType type;
  final List<String> originalPaths;
  final List<String> newPaths;

  UndoAction({required this.type, required this.originalPaths, required this.newPaths});
}

class FileService {
  static Future<void> copyNodes(List<OmniNode> nodes, String targetPath, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) { if (message is FileOperationMessage) onProgress(message); });
    await Isolate.run(() => _copyTask([nodes, targetPath, receivePort.sendPort]));
    receivePort.close();
  }

  static Future<void> moveNodes(List<OmniNode> nodes, String targetPath, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) { if (message is FileOperationMessage) onProgress(message); });
    await Isolate.run(() => _moveTask([nodes, targetPath, receivePort.sendPort]));
    receivePort.close();
  }

  static Future<void> deleteNodes(List<OmniNode> nodes, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) { if (message is FileOperationMessage) onProgress(message); });
    await Isolate.run(() => _deleteTask([nodes, receivePort.sendPort]));
    receivePort.close();
  }

  static Future<void> undoTask(UndoAction action, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) { if (message is FileOperationMessage) onProgress(message); });
    await Isolate.run(() => _undoTaskRunner([action, receivePort.sendPort]));
    receivePort.close();
  }

  // --- ISOLATE ENTRY POINTS --- //

  static Future<void> _copyTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final targetPath = args[1] as String;
    final sendPort = args[2] as SendPort;

    List<String> originalPaths = [];
    List<String> newPaths = [];
    int total = nodes.length;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      final newPath = p.join(targetPath, node.name);
      
      originalPaths.add(node.path);
      newPaths.add(newPath);

      if (node.isFolder) {
        Directory(newPath).createSync(recursive: true);
      } else {
        File(node.path).copySync(newPath);
      }
    }
    
    final undo = UndoAction(type: FileOpType.copy, originalPaths: originalPaths, newPaths: newPaths);
    sendPort.send(FileOperationMessage(total, total, 'Finishing...', 1.0, undoAction: undo));
  }

  static Future<void> _moveTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final targetPath = args[1] as String;
    final sendPort = args[2] as SendPort;

    List<String> originalPaths = [];
    List<String> newPaths = [];
    int total = nodes.length;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      final newPath = p.join(targetPath, node.name);
      
      originalPaths.add(node.path);
      newPaths.add(newPath);

      if (node.isFolder) {
        Directory(node.path).renameSync(newPath);
      } else {
        File(node.path).renameSync(newPath);
      }
    }
    
    final undo = UndoAction(type: FileOpType.cut, originalPaths: originalPaths, newPaths: newPaths);
    sendPort.send(FileOperationMessage(total, total, 'Finishing...', 1.0, undoAction: undo));
  }

  static Future<void> _deleteTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final sendPort = args[1] as SendPort;

    // Soft delete: Move to a temp trash cache for undo capability
    final trashDir = Directory(p.join(Directory.systemTemp.path, '.omni_trash'));
    if (!trashDir.existsSync()) trashDir.createSync(recursive: true);

    List<String> originalPaths = [];
    List<String> newPaths = [];
    int total = nodes.length;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      
      final safeName = '${DateTime.now().millisecondsSinceEpoch}_${node.name}';
      final newPath = p.join(trashDir.path, safeName);
      
      originalPaths.add(node.path);
      newPaths.add(newPath);

      if (node.isFolder) {
        Directory(node.path).renameSync(newPath);
      } else {
        File(node.path).renameSync(newPath);
      }
    }
    
    final undo = UndoAction(type: FileOpType.delete, originalPaths: originalPaths, newPaths: newPaths);
    sendPort.send(FileOperationMessage(total, total, 'Cleaning up...', 1.0, undoAction: undo));
  }

  static Future<void> _undoTaskRunner(List<dynamic> args) async {
    final action = args[0] as UndoAction;
    final sendPort = args[1] as SendPort;
    
    int total = action.newPaths.length;
    for (int i = 0; i < total; i++) {
      sendPort.send(FileOperationMessage(i + 1, total, 'Undoing...', (i / total)));
      
      if (action.type == FileOpType.copy) {
        // Undo Copy -> Delete the pasted files
        final f = File(action.newPaths[i]);
        final d = Directory(action.newPaths[i]);
        if (f.existsSync()) f.deleteSync();
        else if (d.existsSync()) d.deleteSync(recursive: true);
      } else if (action.type == FileOpType.cut || action.type == FileOpType.delete) {
        // Undo Move/Delete -> Move files back from target/trash to original location
        final f = File(action.newPaths[i]);
        final d = Directory(action.newPaths[i]);
        if (f.existsSync()) f.renameSync(action.originalPaths[i]);
        else if (d.existsSync()) d.renameSync(action.originalPaths[i]);
      }
    }
    sendPort.send(FileOperationMessage(total, total, 'Restored!', 1.0));
  }
}
