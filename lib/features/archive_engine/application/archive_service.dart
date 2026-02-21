import 'dart:io';
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
  // PHASE 1 FIX: These are instance methods, not static
  Future<void> compressDirectory(CompressParams params) async {
    var encoder = ZipFileEncoder();
    encoder.create(params.destinationPath);
    encoder.addDirectory(Directory(params.sourcePath));
    encoder.close();
  }

  Future<void> compress(List<String> filePaths, String destinationZip) async {
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
  }

  Future<void> extract(String zipPath, String destinationDir) async {
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
  }
}
