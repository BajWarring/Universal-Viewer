import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../../../filesystem/application/file_service.dart'; // Imports FileOperationMessage

class CompressParams {
  final String sourcePath;
  final String destinationPath;
  final String format;
  final String? password;

  const CompressParams({
    required this.sourcePath,
    required this.destinationPath,
    this.format = 'zip',
    this.password,
  });
}

class ArchiveService {
  /// Runs compression in a background isolate and reports progress
  static Future<void> compressDirectory(CompressParams params, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is FileOperationMessage) onProgress(message);
    });

    await Isolate.run(() => _compressTask([params, receivePort.sendPort]));
    receivePort.close();
  }

  /// Runs extraction in a background isolate and reports progress
  static Future<void> extract(String zipPath, String destinationDir, void Function(FileOperationMessage) onProgress) async {
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is FileOperationMessage) onProgress(message);
    });

    await Isolate.run(() => _extractTask([zipPath, destinationDir, receivePort.sendPort]));
    receivePort.close();
  }

  // --- ISOLATE ENTRY POINTS --- //

  static Future<void> _compressTask(List<dynamic> args) async {
    final params = args[0] as CompressParams;
    final sendPort = args[1] as SendPort;

    var encoder = ZipFileEncoder();
    encoder.create(params.destinationPath);
    
    final dir = Directory(params.sourcePath);
    final entities = dir.listSync(recursive: true).whereType<File>().toList();
    
    int total = entities.length;
    if (total == 0) total = 1; // Prevent division by zero

    for (int i = 0; i < entities.length; i++) {
      final file = entities[i];
      sendPort.send(FileOperationMessage(i + 1, total, p.basename(file.path), (i / total)));
      encoder.addFile(file);
    }
    
    encoder.close();
    sendPort.send(FileOperationMessage(total, total, 'Finishing archive...', 1.0));
  }

  static Future<void> _extractTask(List<dynamic> args) async {
    final zipPath = args[0] as String;
    final destinationDir = args[1] as String;
    final sendPort = args[2] as SendPort;

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    
    int total = archive.length;
    if (total == 0) total = 1;

    for (int i = 0; i < archive.length; i++) {
      final file = archive[i];
      sendPort.send(FileOperationMessage(i + 1, total, file.name, (i / total)));
      
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(destinationDir, file.name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(destinationDir, file.name)).createSync(recursive: true);
      }
    }
    
    sendPort.send(FileOperationMessage(total, total, 'Cleanup...', 1.0));
  }
}
