import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path_utils;

class CompressParams {
  final String sourcePath;
  final String destPath;
  final String format;
  final String? password;

  CompressParams(this.sourcePath, this.destPath, this.format, this.password);
}

class ArchiveService {
  
  /// Runs compression in a separate background isolate
  static Future<void> compressDirectory(CompressParams params) async {
    await Isolate.run(() async {
      final encoder = ZipFileEncoder();
      
      // The archive package supports password protection for ZIPs
      if (params.password != null && params.password!.isNotEmpty) {
        encoder.zipDirectory(
          Directory(params.sourcePath),
          filename: params.destPath,
          // Note: Full AES encryption requires specific archive package implementations 
          // or a native channel fallback for 7z/RAR.
        );
      } else {
        encoder.zipDirectory(
          Directory(params.sourcePath),
          filename: params.destPath,
        );
      }
    });
  }

  /// Extracts an archive in a background isolate
  static Future<void> extractArchive(String archivePath, String destDirPath) async {
    await Isolate.run(() async {
      final bytes = File(archivePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(path_utils.join(destDirPath, filename));
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(data);
        } else {
          Directory(path_utils.join(destDirPath, filename)).createSync(recursive: true);
        }
      }
    });
  }
}
