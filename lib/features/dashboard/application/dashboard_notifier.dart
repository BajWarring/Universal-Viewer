import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';
import '../../../../core/config/injection_container.dart';

class DashboardState {
  final bool isLoading;
  final bool hasPermission;
  final List<OmniNode> recentFiles;
  final List<OmniNode> pinnedFolders;
  final List<OmniNode> storageDrives;

  const DashboardState({
    this.isLoading = true,
    this.hasPermission = false,
    this.recentFiles = const [],
    this.pinnedFolders = const [],
    this.storageDrives = const [],
  });
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(() => initializeApp());
    return const DashboardState();
  }

  Future<void> initializeApp() async {
    // 1. Ask for Permission on First Launch
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      state = const DashboardState(isLoading: false, hasPermission: false);
      return;
    }

    // 2. Define Storage Drives
    final drives = [
      OmniNode(name: 'Internal Storage', path: '/storage/emulated/0', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
      // Android dynamically mounts SD cards, this is the standard fallback path. 
      // In a production app, you'd use external_path package to get the exact UUID.
      OmniNode(name: 'SD Card', path: '/storage/sdcard1', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
    ];

    // 3. Define Default Pinned Folders
    final pinned = [
      OmniNode(name: 'Downloads', path: '/storage/emulated/0/Download', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
      OmniNode(name: 'Documents', path: '/storage/emulated/0/Documents', size: 0, modified: DateTime.now(), isFolder: true, extension: ''),
    ];

    // 4. Fetch Actual Recent Files (Scans Downloads and Documents)
    final provider = sl<FileSystemProvider>(instanceName: 'local');
    List<OmniNode> realRecentFiles = [];
    
    for (var folder in pinned) {
      try {
        final nodes = await provider.listDirectory(folder.path);
        realRecentFiles.addAll(nodes.where((n) => !n.isFolder));
      } catch (_) {} // Ignore if folder is empty or locked
    }

    // Sort newest first and grab top 10
    realRecentFiles.sort((a, b) => b.modified.compareTo(a.modified));
    final topRecent = realRecentFiles.take(10).toList();

    state = DashboardState(
      isLoading: false,
      hasPermission: true,
      recentFiles: topRecent,
      pinnedFolders: pinned,
      storageDrives: drives,
    );
  }

  Future<void> requestPermissionRetry() async {
    state = const DashboardState(isLoading: true, hasPermission: false);
    await initializeApp();
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() => DashboardNotifier());
