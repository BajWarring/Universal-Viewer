import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../application/audio_notifier.dart';
import 'audio_fullscreen_viewer.dart';

class AudioPopup extends ConsumerStatefulWidget {
  final OmniNode node;
  const AudioPopup({super.key, required this.node});

  @override
  ConsumerState<AudioPopup> createState() => _AudioPopupState();
}

class _AudioPopupState extends ConsumerState<AudioPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(audioProvider).currentTrack?.path != widget.node.path) {
        ref.read(audioProvider.notifier).playFile(widget.node);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0 ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surfaceContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Text('Unknown Artist', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_formatTime(audioState.position), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.outlineVariant,
                      thumbColor: theme.colorScheme.primary,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) => ref.read(audioProvider.notifier).seek(Duration(milliseconds: (v * audioState.duration.inMilliseconds).round())),
                    ),
                  ),
                ),
                Text(_formatTime(audioState.duration), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous_rounded), color: Colors.grey, onPressed: () {}),
                const SizedBox(width: 8),
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
                  child: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: theme.colorScheme.onPrimary, size: 32),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.skip_next_rounded), color: Colors.grey, onPressed: () {}),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.pop(context); 
                    AudioFullscreenViewer.show(context, widget.node);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
