import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';

class ArchiveFileSystemProvider implements FileSystemProvider {
  
  @override
  Future<List<OmniNode>> getRoots() async {
    return []; // Archives don't have systemic roots
  }

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
          path: '$path/${file.name}', // Virtual path inside the zip
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

  // Archive contents are read-only while zipped, so these return safe fallbacks
  @override
  Future<OmniNode> createFolder(String parentPath, String folderName) async {
    throw UnsupportedError('Cannot create folders inside an unextracted archive.');
  }

  @override
  Future<bool> delete(String path) async {
    return false; // Cannot delete directly from zip without rewriting the entire archive
  }

  @override
  Future<OmniNode> rename(String path, String newName) async {
    throw UnsupportedError('Cannot rename files inside an unextracted archive.');
  }
}
