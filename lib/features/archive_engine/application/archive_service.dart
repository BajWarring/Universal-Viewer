import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

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
  
  /// Runs compression in a background Isolate to prevent UI jank
  Future<void> compressDirectory(CompressParams params) async {
    await Isolate.run(() {
      var encoder = ZipFileEncoder();
      encoder.create(params.destinationPath);
      encoder.addDirectory(Directory(params.sourcePath));
      encoder.close();
    });
  }

  /// Runs multi-file compression in a background Isolate
  Future<void> compress(List<String> filePaths, String destinationZip) async {
    await Isolate.run(() async {
      var encoder = ZipFileEncoder();
      encoder.create(destinationZip);
      for (String path in filePaths) {
        final stat = await FileStat.stat(path);
        if (stat.type == FileSystemEntityType.directory) {
          encoder.addDirectory(Directory(path));
        } else {
          encoder.addFile(File(path));
        }
      }
      encoder.close();
    });
  }

  /// Runs extraction in a background Isolate
  Future<void> extract(String zipPath, String destinationDir) async {
    await Isolate.run(() async {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(p.join(destinationDir, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(p.join(destinationDir, filename)).createSync(recursive: true);
        }
      }
    });
  }
}
