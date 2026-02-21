import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/audio_notifier.dart';

class FloatingAudioPlayer extends ConsumerWidget {
  const FloatingAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    if (audioState.currentTrack == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0
        ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds
        : 0.0;

    return Dismissible(
      key: const Key('mini_player'),
      direction: DismissDirection.down,
      onDismissed: (_) => ref.read(audioProvider.notifier).stopAndDismiss(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                audioState.currentTrack!.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              IconButton(
                icon: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => ref.read(audioProvider.notifier).stopAndDismiss(),
              ),
            ]),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.outlineVariant,
              thumbColor: theme.colorScheme.primary,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) => ref.read(audioProvider.notifier).seek(Duration(milliseconds: (v * audioState.duration.inMilliseconds).round())),
            ),
          ),
        ]),
      ),
    );
  }
}
