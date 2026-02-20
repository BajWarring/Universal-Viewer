import 'package:flutter/material.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class FileGridView extends StatelessWidget {
  final List<OmniNode> nodes;
  const FileGridView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grid View Coming Soon'));
  }
}
