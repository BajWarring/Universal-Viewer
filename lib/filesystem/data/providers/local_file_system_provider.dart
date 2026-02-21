import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/omni_node.dart';
import '../../domain/repositories/file_system_provider.dart';

class LocalFileSystemProvider implements FileSystemProvider {
  
  @override
  Future<List<OmniNode>> getRoots() async {
    // Return standard Android storage roots
    return [
      OmniFolder(name: 'Internal Storage', path: '/storage/emulated/0', modified: DateTime.now()),
      OmniFolder(name: 'SD Card', path: '/storage/sdcard1', modified: DateTime.now()),
    ];
  }

  @override
  Future<List<OmniNode>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<FileSystemEntity> entities = await dir.list().toList();
    final List<OmniNode> nodes = [];

    for (var entity in entities) {
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      
      // Skip hidden files for now
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

  @override
  Future<OmniNode> createFolder(String parentPath, String folderName) async {
    final newDir = Directory(p.join(parentPath, folderName));
    await newDir.create();
    final stat = await newDir.stat();
    return OmniFolder(name: folderName, path: newDir.path, modified: stat.modified);
  }

  @override
  Future<bool> delete(String path) async {
    final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory 
        ? Directory(path) 
        : File(path);
    if (await entity.exists()) {
      await entity.delete(recursive: true);
      return true;
    }
    return false;
  }

  @override
  Future<OmniNode> rename(String path, String newName) async {
    final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory 
        ? Directory(path) 
        : File(path);
        
    final newPath = p.join(p.dirname(path), newName);
    final renamedEntity = await entity.rename(newPath);
    final stat = await renamedEntity.stat();

    if (renamedEntity is Directory) {
      return OmniFolder(name: newName, path: newPath, modified: stat.modified);
    } else {
      return OmniFile(
        name: newName, 
        path: newPath, 
        size: stat.size, 
        modified: stat.modified, 
        extension: p.extension(newPath).replaceAll('.', '')
      );
    }
  }
}
