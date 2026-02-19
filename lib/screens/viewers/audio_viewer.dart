import 'package:flutter/material.dart';

class AudioViewer extends StatelessWidget {
  final String filePath;
  final String fileName;
  const AudioViewer({super.key, required this.filePath, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note_rounded, size: 80, color: Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          const Text('Audio playback', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
