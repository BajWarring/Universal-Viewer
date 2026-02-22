import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  static const String internalStoragePath = '/storage/emulated/0';
  static const String fallbackSdCardPath = '/storage/sdcard1';

  /// Requests comprehensive storage permissions required for Android 11+
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
        return true;
      }
      
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) return true;

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true; // Auto-grant for non-Android platforms in this scope
  }

  /// Maps a raw path to a friendly UI label
  static String getFriendlyPath(String path) {
    if (path == internalStoragePath) return 'Internal Storage';
    if (path.startsWith('$internalStoragePath/')) {
      return path.replaceFirst('$internalStoragePath/', 'Internal Storage / ').replaceAll('/', ' / ');
    }
    if (path == fallbackSdCardPath) return 'SD Card';
    if (path.startsWith('$fallbackSdCardPath/')) {
      return path.replaceFirst('$fallbackSdCardPath/', 'SD Card / ').replaceAll('/', ' / ');
    }
    return path.replaceAll('/', ' / ');
  }

  /// Maps a raw folder name to a friendly UI label (e.g., for the Dropdown)
  static String getFriendlyFolderName(String folderName) {
    if (folderName == '0') return 'Internal Storage';
    if (folderName == 'sdcard1') return 'SD Card';
    if (folderName == 'emulated') return 'Storage';
    return folderName;
  }

  /// Returns available root storage drives
  static List<Map<String, dynamic>> getStorageRoots() {
    final drives = [
      {'name': 'Internal Storage', 'path': internalStoragePath, 'icon': 'smartphone'},
    ];
    
    // Add SD Card if it exists
    if (Directory(fallbackSdCardPath).existsSync()) {
      drives.add({'name': 'SD Card', 'path': fallbackSdCardPath, 'icon': 'sd_card'});
    }
    
    return drives;
  }
}
