import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';

class ArchiveFileSystemProvider implements FileSystemProvider {
  @override
  Future<List<OmniNode>> listDirectory(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    
    final List<OmniNode> nodes = [];
    final now = DateTime.now();

    for (var file in archive) {
      final name = p.basename(file.name);
      
      if (file.isFile) {
        nodes.add(OmniFile(
          name: name,
          path: '$path/${file.name}', // Virtual path
          size: file.size,
          modified: now, 
          extension: p.extension(file.name).replaceAll('.', ''),
        ));
      } else {
        nodes.add(OmniFolder(
          name: name,
          path: '$path/${file.name}',
          modified: now,
        ));
      }
    }
    return nodes;
  }
}
