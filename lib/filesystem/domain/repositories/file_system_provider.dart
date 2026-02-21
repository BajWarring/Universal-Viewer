import '../entities/omni_node.dart';

abstract class FileSystemProvider {
  Future<List<OmniNode>> getRoots();
  Future<List<OmniNode>> listDirectory(String path);
  Future<OmniNode> createFolder(String parentPath, String folderName);
  Future<bool> delete(String path);
  Future<OmniNode> rename(String path, String newName);
}
