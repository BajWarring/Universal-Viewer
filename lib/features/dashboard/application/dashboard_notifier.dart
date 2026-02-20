import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';
import '../../../../core/config/injection_container.dart';

class DashboardState {
  final List<OmniNode> recentFiles;
  final bool isLoading;

  const DashboardState({this.recentFiles = const [], this.isLoading = true});
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(() => loadRealData());
    return const DashboardState();
  }

  Future<void> loadRealData() async {
    final provider = sl<FileSystemProvider>(instanceName: 'local');
    List<OmniNode> allFoundFiles = [];

    // Scan the most common folders for recent files
    final targets = ['/storage/emulated/0/Download', '/storage/emulated/0/Documents'];
    
    for (String path in targets) {
      try {
        final nodes = await provider.listDirectory(path);
        allFoundFiles.addAll(nodes.where((n) => !n.isFolder));
      } catch (_) {} // Ignore if folder doesn't exist
    }

    // Sort by modified date (newest first)
    allFoundFiles.sort((a, b) {
      final statA = File(a.path).statSync();
      final statB = File(b.path).statSync();
      return statB.modified.compareTo(statA.modified);
    });

    // Take the top 10
    final recent = allFoundFiles.take(10).toList();
    state = DashboardState(recentFiles: recent, isLoading: false);
  }
}
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() => DashboardNotifier());
