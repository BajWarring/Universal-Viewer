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

  // PHASE 1 FIX: Added == and hashCode so Set<OmniNode> works correctly
  @override
  bool operator ==(Object other) => other is OmniNode && other.path == path;

  @override
  int get hashCode => path.hashCode;

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

class OmniFile extends OmniNode {
  const OmniFile({
    required String name,
    required String path,
    required int size,
    required DateTime modified,
    required String extension,
  }) : super(
          name: name,
          path: path,
          size: size,
          modified: modified,
          isFolder: false,
          extension: extension,
        );
}

class OmniFolder extends OmniNode {
  const OmniFolder({
    required String name,
    required String path,
    required DateTime modified,
    int size = 0,
  }) : super(
          name: name,
          path: path,
          size: size,
          modified: modified,
          isFolder: true,
          extension: '',
        );
}
