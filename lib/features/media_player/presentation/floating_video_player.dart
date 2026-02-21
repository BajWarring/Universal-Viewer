import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../application/video_notifier.dart';
import 'video_fullscreen_viewer.dart';

class FloatingVideoPlayer extends ConsumerWidget {
  const FloatingVideoPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoProvider);
    if (videoState.currentVideo == null || videoState.controller == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final progress = videoState.duration.inMilliseconds > 0
        ? videoState.position.inMilliseconds / videoState.duration.inMilliseconds
        : 0.0;

    return Dismissible(
      key: const Key('mini_video_player'),
      direction: DismissDirection.down,
      onDismissed: (_) => ref.read(videoProvider.notifier).stopAndDismiss(),
      child: GestureDetector(
        onTap: () {
          VideoFullscreenViewer.show(context, videoState.currentVideo!);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              // Live Mini Video Feed (YouTube Style)
              Container(
                width: 90,
                height: 48,
                margin: const EdgeInsets.all(6),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: videoState.controller!.value.isInitialized 
                    ? FittedBox(
                        fit: BoxFit.cover, 
                        child: SizedBox(
                          width: videoState.controller!.value.size.width,
                          height: videoState.controller!.value.size.height,
                          child: VideoPlayer(videoState.controller!),
                        ),
                      )
                    : const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(
                videoState.currentVideo!.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              )),
              IconButton(
                icon: Icon(videoState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () => ref.read(videoProvider.notifier).togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => ref.read(videoProvider.notifier).stopAndDismiss(),
              ),
            ]),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: theme.colorScheme.primary,
            ),
          ]),
        ),
      ),
    );
  }
}
