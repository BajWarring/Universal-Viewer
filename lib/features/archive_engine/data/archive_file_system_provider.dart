import 'dart:io';
import 'package:archive/archive_io.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';

class ArchiveFileSystemProvider implements FileSystemProvider {
  final String archiveFilePath;
  late Archive _archive;
  bool _isLoaded = false;

  ArchiveFileSystemProvider(this.archiveFilePath);

  @override
  String get providerId => 'archive_provider';

  @override
  String get displayName => archiveFilePath.split('/').last;

  Future<void> _loadArchiveHeaders() async {
    if (_isLoaded) return;
    // We only read the headers to save RAM, not the full file contents
    final inputStream = InputFileStream(archiveFilePath);
    _archive = ZipDecoder().decodeBuffer(inputStream, verify: false);
    _isLoaded = true;
  }

  @override
  Future<List<OmniNode>> listDirectory(String virtualPath) async {
    await _loadArchiveHeaders();
    final List<OmniNode> nodes = [];
    
    // Logic to filter the _archive files based on the requested virtualPath
    // so we only return the files inside the current "folder" of the ZIP.
    for (final file in _archive) {
      if (file.name.startsWith(virtualPath)) {
         // Map to OmniNode (omitted string parsing for brevity)
         nodes.add(OmniFile(
           id: file.name,
           name: file.name.split('/').last,
           path: file.name, // The virtual path inside the zip
           size: file.size,
           modifiedAt: DateTime.now(),
           isHidden: false,
         ));
      }
    }
    return nodes;
  }

  // File operations inside a zip are generally not supported without full extraction/recompression
  @override Future<void> createFolder(String path, String folderName) async => throw UnimplementedError();
  @override Future<void> rename(String path, String newName) async => throw UnimplementedError();
  @override Future<void> delete(String path) async => throw UnimplementedError();
  @override Future<List<OmniFolder>> getRoots() async => [];
}
