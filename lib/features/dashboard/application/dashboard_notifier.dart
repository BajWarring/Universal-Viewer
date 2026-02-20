import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class DashboardState {
  final List<OmniFolder> pinnedFolders;
  final List<OmniFile> recentFiles;
  final Map<String, double> storageUsage; // e.g., {'Internal': 0.8, 'SD Card': 0.4}

  const DashboardState({
    this.pinnedFolders = const [],
    this.recentFiles = const [],
    this.storageUsage = const {},
  });
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    // In a real implementation, you would fetch this from your local DB and FileSystemProvider
    return DashboardState(
      storageUsage: {'Internal': 0.65, 'SD Card': 0.30},
    );
  }

  // Methods to pin folders, refresh recent files, etc., would go here.
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
