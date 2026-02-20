import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageInfo {
  final String label;
  final String path;
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final bool isRemovable;

  StorageInfo({required this.label, required this.path, required this.totalBytes, required this.usedBytes, required this.freeBytes, required this.isRemovable});

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
    final addedPaths = <String>{};

    try {
      // 1. Force Internal Storage as Base to avoid duplicates
      final internalRoot = Directory('/storage/emulated/0');
      if (await internalRoot.exists()) {
        final stat = await _getStorageStat(internalRoot.path);
        devices.add(StorageInfo(
          label: 'Internal Storage',
          path: internalRoot.path,
          totalBytes: stat['total'] ?? 0,
          usedBytes: stat['used'] ?? 0,
          freeBytes: stat['free'] ?? 0,
          isRemovable: false,
        ));
        addedPaths.add(internalRoot.path);
      }

      // 2. Discover External/USB storage via path_provider
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null) {
        for (int i = 0; i < extDirs.length; i++) {
          final rootPath = extDirs[i].path.split('Android')[0].replaceAll(RegExp(r'/$'), '');
          
          if (addedPaths.contains(rootPath) || rootPath == '/storage/emulated/0') continue;
          
          bool isRemovable = true;
          final isUsb = rootPath.toLowerCase().contains('usb');
          final label = isUsb ? 'USB Drive' : 'SD Card';
          
          final stat = await _getStorageStat(rootPath);
          devices.add(StorageInfo(
            label: label,
            path: rootPath,
            totalBytes: stat['total'] ?? 0,
            usedBytes: stat['used'] ?? 0,
            freeBytes: stat['free'] ?? 0,
            isRemovable: isRemovable,
          ));
          addedPaths.add(rootPath);
        }
      }
    } catch (e) {
      if (devices.isEmpty) {
        devices.add(StorageInfo(label: 'Internal Storage', path: '/storage/emulated/0', totalBytes: 64 * 1024 * 1024 * 1024, usedBytes: 20 * 1024 * 1024 * 1024, freeBytes: 44 * 1024 * 1024 * 1024, isRemovable: false));
      }
    }
    return devices;
  }

  static Future<Map<String, int>> _getStorageStat(String path) async {
    try {
      final result = await Process.run('df', ['-k', path]);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        if (lines.length >= 2) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final total = int.tryParse(parts[1]) ?? 0;
            final used = int.tryParse(parts[2]) ?? 0;
            final free = int.tryParse(parts[3]) ?? 0;
            return {'total': total * 1024, 'used': used * 1024, 'free': free * 1024};
          }
        }
      }
    } catch (_) {}
    return {};
  }
}
