abstract class OmniNode {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime modifiedAt;
  final bool isHidden;

  const OmniNode({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.modifiedAt,
    required this.isHidden,
  });

  bool get isFolder => this is OmniFolder;
  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';
}

class OmniFolder extends OmniNode {
  final int? itemCount; // Nullable because counting remote items can be expensive

  const OmniFolder({
    required super.id,
    required super.name,
    required super.path,
    required super.size,
    required super.modifiedAt,
    required super.isHidden,
    this.itemCount,
  });
}

class OmniFile extends OmniNode {
  const OmniFile({
    required super.id,
    required super.name,
    required super.path,
    required super.size,
    required super.modifiedAt,
    required super.isHidden,
  });
}
