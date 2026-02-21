class OmniNode {
  final String name;
  final String path;
  final int size;
  final DateTime modified;
  final bool isFolder;
  final String extension;

  const OmniNode({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.isFolder,
    required this.extension,
  });

  // Helper method to copy with changes (useful for renaming)
  OmniNode copyWith({
    String? name,
    String? path,
    int? size,
    DateTime? modified,
    bool? isFolder,
    String? extension,
  }) {
    return OmniNode(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      modified: modified ?? this.modified,
      isFolder: isFolder ?? this.isFolder,
      extension: extension ?? this.extension,
    );
  }
}
