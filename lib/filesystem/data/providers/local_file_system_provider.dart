import 'dart:io';
import 'package:omni_file_manager/filesystem/domain/entities/omni_node.dart';
import 'package:omni_file_manager/filesystem/domain/repositories/file_system_provider.dart';

class LocalFileSystemProvider implements FileSystemProvider {
  @override
  String get providerId => 'local_storage';

  @override
  String get displayName => 'Internal Storage';

  @override
  Future<List<OmniNode>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<OmniNode> nodes = [];
    final entities = dir.list(followLinks: false);

    await for (final entity in entities) {
      final stat = await entity.stat();
      final name = entity.path.split(Platform.pathSeparator).last;
      final isHidden = name.startsWith('.');

      if (entity is Directory) {
        nodes.add(OmniFolder(
          id: entity.path,
          name: name,
          path: entity.path,
          size: stat.size,
          modifiedAt: stat.modified,
          isHidden: isHidden,
        ));
      } else if (entity is File) {
        nodes.add(OmniFile(
          id: entity.path,
          name: name,
          path: entity.path,
          size: stat.size,
          modifiedAt: stat.modified,
          isHidden: isHidden,
        ));
      }
    }
    
    // Sort: Folders first, then alphabetically
    nodes.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return nodes;
  }

  @override
  Future<List<OmniFolder>> getRoots() async {
    // For Android, the standard root of internal shared storage is generally:
    final internalStorage = Directory('/storage/emulated/0');
    final roots = <OmniFolder>[];

    if (await internalStorage.exists()) {
       final stat = await internalStorage.stat();
       roots.add(OmniFolder(
         id: 'internal_root',
         name: 'Internal Storage',
         path: internalStorage.path,
         size: stat.size,
         modifiedAt: stat.modified,
         isHidden: false,
       ));
    }
    
    // Note: SD Card detection requires platform channels or native path resolution
    // which we will add later.
    return roots;
  }

  // --- Boilerplate File Ops omitted for brevity ---
  @override Future<void> createFolder(String path, String folderName) async {}
  @override Future<void> rename(String path, String newName) async {}
  @override Future<void> delete(String path) async {}
}
