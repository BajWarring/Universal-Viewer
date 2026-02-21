import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';

class ArchiveFileSystemProvider implements FileSystemProvider {
  @override
  Future<List<OmniNode>> getRoots() async => [];

  @override
  Future<List<OmniNode>> listDirectory(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final List<OmniNode> nodes = [];
    final now = DateTime.now();
    for (var entry in archive) {
      final name = p.basename(entry.name);
      if (entry.isFile) {
        nodes.add(OmniFile(name: name, path: '$path/${entry.name}', size: entry.size, modified: now, extension: p.extension(entry.name).replaceAll('.', '')));
      } else {
        nodes.add(OmniFolder(name: name, path: '$path/${entry.name}', modified: now));
      }
    }
    return nodes;
  }

  @override
  Future<OmniNode> createFolder(String parentPath, String folderName) async {
    throw UnsupportedError('Cannot create folders inside an unextracted archive.');
  }

  @override
  Future<bool> delete(String path) async => false;

  @override
  Future<OmniNode> rename(String path, String newName) async {
    throw UnsupportedError('Cannot rename files inside an unextracted archive.');
  }
}
