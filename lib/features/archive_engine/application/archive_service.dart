import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class ArchiveService {
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
