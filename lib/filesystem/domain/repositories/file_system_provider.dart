import '../entities/omni_node.dart';

abstract class FileSystemProvider {
  Future<List<OmniNode>> listDirectory(String path);

  /// File Operations
  Future<void> createFolder(String path, String folderName);
  Future<void> rename(String path, String newName);
  Future<void> delete(String path);
  
  /// Resolves the root paths (e.g., Internal Storage, SD Card)
  Future<List<OmniFolder>> getRoots();
}
