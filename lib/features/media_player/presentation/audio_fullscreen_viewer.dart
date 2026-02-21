import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../application/audio_notifier.dart';

class AudioFullscreenViewer extends ConsumerWidget {
  final OmniNode node;
  const AudioFullscreenViewer({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => AudioFullscreenViewer(node: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0 ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary.withValues(alpha: 0.3), theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32), onPressed: () => Navigator.pop(context)),
                    const Text('NOW PLAYING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12))],
                ),
                child: Icon(Icons.music_note_rounded, size: 100, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(node.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('Unknown Artist', style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        thumbColor: theme.colorScheme.primary,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (v) => ref.read(audioProvider.notifier).seek(Duration(milliseconds: (v * audioState.duration.inMilliseconds).round())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTime(audioState.position), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(_formatTime(audioState.duration), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.shuffle_rounded), color: theme.colorScheme.onSurfaceVariant, onPressed: () {}),
                    IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 40), onPressed: () {}),
                    FloatingActionButton.large(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.primary,
                      onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
                      child: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: theme.colorScheme.onPrimary, size: 48),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next_rounded, size: 40), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.repeat_rounded), color: theme.colorScheme.onSurfaceVariant, onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
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
