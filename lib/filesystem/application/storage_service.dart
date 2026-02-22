import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  static const String internalStoragePath = '/storage/emulated/0';
  static const String fallbackSdCardPath = '/storage/sdcard1';

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) return true;
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) return true;
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true; 
  }

  static String getFriendlyPath(String path) {
    if (path == internalStoragePath) return 'Internal Storage';
    if (path.startsWith('$internalStoragePath/')) return path.replaceFirst('$internalStoragePath/', 'Internal Storage / ').replaceAll('/', ' / ');
    if (path == fallbackSdCardPath) return 'SD Card';
    if (path.startsWith('$fallbackSdCardPath/')) return path.replaceFirst('$fallbackSdCardPath/', 'SD Card / ').replaceAll('/', ' / ');
    return path.replaceAll('/', ' / ');
  }

  static String getFriendlyFolderName(String folderName) {
    if (folderName == '0') return 'Internal Storage';
    if (folderName == 'sdcard1') return 'SD Card';
    if (folderName == 'emulated') return 'Storage';
    return folderName;
  }

  static List<Map<String, dynamic>> getStorageRoots() {
    final drives = [{'name': 'Internal Storage', 'path': internalStoragePath, 'icon': 'smartphone'}];
    if (Directory(fallbackSdCardPath).existsSync()) drives.add({'name': 'SD Card', 'path': fallbackSdCardPath, 'icon': 'sd_card'});
    return drives;
  }

  /// Fetches REAL device storage via standard Unix 'df' command
  static Future<Map<String, dynamic>> getStorageInfo(String path) async {
    try {
      if (Platform.isAndroid || Platform.isLinux) {
        final result = await Process.run('df', ['-k', path]);
        final lines = result.stdout.toString().split('\n');
        if (lines.length > 1) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final total = int.tryParse(parts[1]) ?? 0;
            final used = int.tryParse(parts[2]) ?? 0;
            final available = int.tryParse(parts[3]) ?? 0;
            
            if (total > 0) {
              return {
                'total': total * 1024,
                'used': used * 1024,
                'free': available * 1024,
                'usedFraction': used / total,
              };
            }
          }
        }
      }
    } catch (_) {}
    return {'total': 1, 'used': 0, 'free': 1, 'usedFraction': 0.0};
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
