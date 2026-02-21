import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/omni_node.dart';
import '../../domain/repositories/file_system_provider.dart';

class LocalFileSystemProvider implements FileSystemProvider {
  @override
  Future<List<OmniNode>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<FileSystemEntity> entities = await dir.list().toList();
    final List<OmniNode> nodes = [];

    for (var entity in entities) {
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      
      // Skip hidden files for now (files starting with a dot)
      if (name.startsWith('.')) continue;

      if (entity is Directory) {
        nodes.add(OmniFolder(
          name: name,
          path: entity.path,
          modified: stat.modified,
          size: 0,
        ));
      } else if (entity is File) {
        nodes.add(OmniFile(
          name: name,
          path: entity.path,
          size: stat.size,
          modified: stat.modified,
          extension: p.extension(entity.path).replaceAll('.', ''),
        ));
      }
    }
    
    // Sort: Folders first, then alphabetical
    nodes.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return nodes;
  }
}
