import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles requesting all necessary permissions for the file manager.
class PermissionService {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    // Android 13+
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSdkVersion();

      if (sdkVersion >= 33) {
        // Android 13+ - request granular permissions
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        final allGranted = statuses.values.every((s) => s.isGranted);

        // Also try MANAGE_EXTERNAL_STORAGE for full access
        if (!await Permission.manageExternalStorage.isGranted) {
          await Permission.manageExternalStorage.request();
        }
        return allGranted || await Permission.manageExternalStorage.isGranted;
      } else if (sdkVersion >= 30) {
        // Android 11-12 - MANAGE_EXTERNAL_STORAGE
        if (!await Permission.manageExternalStorage.isGranted) {
          final status = await Permission.manageExternalStorage.request();
          return status.isGranted;
        }
        return true;
      } else {
        // Android 9-10 - legacy read/write
        final status = await [
          Permission.storage,
        ].request();
        return status.values.every((s) => s.isGranted);
      }
    }
    return true;
  }

  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final sdkVersion = await _getAndroidSdkVersion();

    if (sdkVersion >= 30) {
      return await Permission.manageExternalStorage.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  static Future<int> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 30;
    } catch (_) {
      return 30;
    }
  }
}

class PermissionScreen extends StatefulWidget {
  final VoidCallback onGranted;
  const PermissionScreen({super.key, required this.onGranted});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _requesting = true);
    final granted = await PermissionService.requestAllPermissions(context);
    setState(() => _requesting = false);
    if (granted && mounted) {
      widget.onGranted();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Storage permission is required to browse files.'),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome to Omni',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'To browse and manage your files, Omni needs access to your device storage.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _PermissionItem(
                icon: Icons.folder_rounded,
                title: 'Storage Access',
                desc: 'Read and manage files on your device',
              ),
              const SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.image_rounded,
                title: 'Media Access',
                desc: 'View photos, videos, and audio files',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requesting ? null : _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _requesting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Grant Permission', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: openAppSettings,
                child: Text(
                  'Open App Settings',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const _PermissionItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
