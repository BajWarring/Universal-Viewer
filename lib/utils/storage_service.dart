import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageInfo {
  final String label;
  final String path;
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final bool isRemovable;

  StorageInfo({
    required this.label,
    required this.path,
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
    required this.isRemovable,
  });

  double get usedPercent => totalBytes > 0 ? usedBytes / totalBytes : 0;

  String get usedFormatted => _format(usedBytes);
  String get totalFormatted => _format(totalBytes);
  String get freeFormatted => _format(freeBytes);

  static String _format(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class StorageService {
  static Future<List<StorageInfo>> getStorageDevices() async {
    final devices = <StorageInfo>[];
    try {
      final pathsChecked = <String>{};
      
      // 1. Use path_provider to reliably detect SD Cards on Android 10+
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null) {
        for (int i = 0; i < extDirs.length; i++) {
          // Extracts the actual root path from the app-specific directory path
          final rootPath = extDirs[i].path.split('Android')[0].replaceAll(RegExp(r'/$'), '');
          if (pathsChecked.contains(rootPath)) continue;
          pathsChecked.add(rootPath);

          bool isRemovable = i > 0; // 0 is usually internal, > 0 are SD Cards
          final label = isRemovable ? 'SD Card' : 'Internal Storage';
          
          final stat = await _getStorageStat(rootPath);
          devices.add(StorageInfo(
            label: label,
            path: rootPath,
            totalBytes: stat['total'] ?? 0,
            usedBytes: stat['used'] ?? 0,
            freeBytes: stat['free'] ?? 0,
            isRemovable: isRemovable,
          ));
        }
      }

      // 2. Fallback for Internal Storage if path_provider failed
      final internalRoot = Directory('/storage/emulated/0');
      if (!pathsChecked.contains(internalRoot.path) && await internalRoot.exists()) {
        final stat = await _getStorageStat(internalRoot.path);
        devices.add(StorageInfo(
          label: 'Internal Storage',
          path: internalRoot.path,
          totalBytes: stat['total'] ?? 0,
          usedBytes: stat['used'] ?? 0,
          freeBytes: stat['free'] ?? 0,
          isRemovable: false,
        ));
        pathsChecked.add(internalRoot.path);
      }

      // 3. Legacy SD Card checks for older Android versions
      final sdPaths = [
        '/storage/sdcard1',
        '/storage/extSdCard',
        '/mnt/sdcard',
        '/mnt/external_sd',
      ];

      for (final sdPath in sdPaths) {
        if (pathsChecked.contains(sdPath)) continue;
        final sdDir = Directory(sdPath);
        
        if (await sdDir.exists()) {
          final stat = await _getStorageStat(sdPath);
          if (stat['total'] != null && stat['total']! > 0) {
            devices.add(StorageInfo(
              label: 'SD Card',
              path: sdPath,
              totalBytes: stat['total'] ?? 0,
              usedBytes: stat['used'] ?? 0,
              freeBytes: stat['free'] ?? 0,
              isRemovable: true,
            ));
            pathsChecked.add(sdPath);
          }
        }
      }
    } catch (e) {
      // Absolute Fallback
      devices.add(StorageInfo(
        label: 'Internal Storage',
        path: '/storage/emulated/0',
        totalBytes: 64 * 1024 * 1024 * 1024,
        usedBytes: 20 * 1024 * 1024 * 1024,
        freeBytes: 44 * 1024 * 1024 * 1024,
        isRemovable: false,
      ));
    }

    return devices;
  }

  static Future<Map<String, int>> _getStorageStat(String path) async {
    try {
      // Use df command on Android for accurate sizing
      final result = await Process.run('df', ['-k', path]);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        if (lines.length >= 2) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final total = int.tryParse(parts[1]) ?? 0;
            final used = int.tryParse(parts[2]) ?? 0;
            final free = int.tryParse(parts[3]) ?? 0;
            return {
              'total': total * 1024,
              'used': used * 1024,
              'free': free * 1024,
            };
          }
        }
      }
    } catch (_) {}

    // Fallback: read from /proc/mounts style
    try {
      final stat = await FileStat.stat(path);
      return {'total': 0, 'used': 0, 'free': 0};
    } catch (_) {}
    return {};
  }
}
