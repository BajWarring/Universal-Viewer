import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import '../domain/entities/omni_node.dart';

class FileOperationMessage {
  final int currentItem;
  final int totalItems;
  final String currentItemName;
  final double percentage;

  FileOperationMessage(this.currentItem, this.totalItems, this.currentItemName, this.percentage);
}

class FileService {
  /// Executes a copy operation in a background isolate and streams progress
  static Future<void> copyNodes(List<OmniNode> nodes, String targetPath, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    
    receivePort.listen((message) {
      if (message is FileOperationMessage) onProgress(message);
    });

    await Isolate.run(() => _copyTask([nodes, targetPath, receivePort.sendPort]));
    receivePort.close();
  }

  /// Executes a move/cut operation in a background isolate
  static Future<void> moveNodes(List<OmniNode> nodes, String targetPath, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is FileOperationMessage) onProgress(message);
    });

    await Isolate.run(() => _moveTask([nodes, targetPath, receivePort.sendPort]));
    receivePort.close();
  }

  /// Executes a delete operation in a background isolate
  static Future<void> deleteNodes(List<OmniNode> nodes, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is FileOperationMessage) onProgress(message);
    });

    await Isolate.run(() => _deleteTask([nodes, receivePort.sendPort]));
    receivePort.close();
  }

  // --- ISOLATE ENTRY POINTS --- //

  static Future<void> _copyTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final targetPath = args[1] as String;
    final sendPort = args[2] as SendPort;

    int total = nodes.length; // Simplified: in reality, you'd recursively count folder contents
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      
      final newPath = p.join(targetPath, node.name);
      if (node.isFolder) {
        // Simple recursive copy logic would go here
        Directory(newPath).createSync(recursive: true);
      } else {
        File(node.path).copySync(newPath);
      }
    }
    sendPort.send(FileOperationMessage(total, total, 'Finishing...', 1.0));
  }

  static Future<void> _moveTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final targetPath = args[1] as String;
    final sendPort = args[2] as SendPort;

    int total = nodes.length;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      
      final newPath = p.join(targetPath, node.name);
      if (node.isFolder) {
        Directory(node.path).renameSync(newPath);
      } else {
        File(node.path).renameSync(newPath);
      }
    }
    sendPort.send(FileOperationMessage(total, total, 'Finishing...', 1.0));
  }

  static Future<void> _deleteTask(List<dynamic> args) async {
    final nodes = args[0] as List<OmniNode>;
    final sendPort = args[1] as SendPort;

    int total = nodes.length;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      sendPort.send(FileOperationMessage(i + 1, total, node.name, (i / total)));
      
      if (node.isFolder) {
        Directory(node.path).deleteSync(recursive: true);
      } else {
        File(node.path).deleteSync();
      }
    }
    sendPort.send(FileOperationMessage(total, total, 'Cleaning up...', 1.0));
  }
}
