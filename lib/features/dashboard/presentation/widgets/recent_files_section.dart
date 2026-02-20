import 'package:flutter/material.dart';

class RecentFilesSection extends StatelessWidget {
  const RecentFilesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock Data
    final recentFiles = [
      {'name': 'Production_Final_v2.mp4', 'size': '2.4 GB', 'date': 'Oct 24, 2023', 'icon': Icons.video_library, 'path': '/Internal/Movies/Work'},
      {'name': 'Invoice_Q3_Project_X.pdf', 'size': '1.2 MB', 'date': 'Oct 23, 2023', 'icon': Icons.description, 'path': '/Internal/Documents'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT FILES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
              TextButton(
                onPressed: () {},
                child: Text('View all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              )
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: recentFiles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final file = recentFiles[index];
            return Container(
              height: 88,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    child: Icon(file['icon'] as IconData, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(file['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${file['date']} • ${file['size']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.folder, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(file['path'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
