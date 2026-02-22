class OmniNode {
  final String name;
  final String path;
  final int size;
  final DateTime modified;
  final bool isFolder;
  final String extension;
  final int? itemCount; // Added to match HTML's '124 items' badge

  const OmniNode({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.isFolder,
    required this.extension,
    this.itemCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OmniNode && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
