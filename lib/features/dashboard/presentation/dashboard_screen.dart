import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/pinned_folders_section.dart';
import 'widgets/storage_devices_section.dart';
import 'widgets/recent_files_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Omni', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('File Manager', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 16),
            PinnedFoldersSection(),
            SizedBox(height: 24),
            StorageDevicesSection(),
            SizedBox(height: 24),
            RecentFilesSection(),
            SizedBox(height: 100), // Padding for Bottom Nav
          ],
        ),
      ),
    );
  }
}
