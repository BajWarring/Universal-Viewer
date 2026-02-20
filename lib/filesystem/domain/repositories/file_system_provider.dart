import 'package:omni_file_manager/filesystem/domain/entities/omni_node.dart';

abstract class FileSystemProvider {
  String get providerId;
  String get displayName;
  
  /// Fetches the contents of a specific directory path
  Future<List<OmniNode>> listDirectory(String path);
  
  /// File Operations
  Future<void> createFolder(String path, String folderName);
  Future<void> rename(String path, String newName);
  Future<void> delete(String path);
  
  /// Resolves the root paths (e.g., Internal Storage, SD Card)
  Future<List<OmniFolder>> getRoots();
}
