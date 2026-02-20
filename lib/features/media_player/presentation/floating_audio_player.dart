import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/audio_notifier.dart';

class FloatingAudioPlayer extends ConsumerWidget {
  const FloatingAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);

    // If no track is playing, don't show the player
    if (audioState.currentTrack == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0 
        ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds 
        : 0.0;

    return Dismissible(
      key: const Key('mini_player'),
      direction: DismissDirection.down,
      onDismissed: (_) => ref.read(audioProvider.notifier).stopAndDismiss(),
      child: GestureDetector(
        onTap: () {
          // TODO: Expand to full screen waveform/lyrics player
        },
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Stack(
            children: [
              // Progress Bar Background
              Align(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  color: theme.colorScheme.primary,
                ),
              ),
              // Player Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.music_note),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        audioState.currentTrack!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(audioState.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => ref.read(audioProvider.notifier).stopAndDismiss(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
