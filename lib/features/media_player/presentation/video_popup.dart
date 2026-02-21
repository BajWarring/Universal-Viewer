import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../application/video_notifier.dart';
import 'video_fullscreen_viewer.dart';

class VideoPopup extends ConsumerStatefulWidget {
  final OmniNode node;
  const VideoPopup({super.key, required this.node});

  @override
  ConsumerState<VideoPopup> createState() => _VideoPopupState();
}

class _VideoPopupState extends ConsumerState<VideoPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(videoProvider).currentVideo?.path != widget.node.path) {
        ref.read(videoProvider.notifier).playFile(widget.node);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final ctrl = videoState.controller;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: AspectRatio(
          aspectRatio: ctrl != null && ctrl.value.isInitialized ? ctrl.value.aspectRatio : 16 / 9,
          child: Stack(
            children: [
              if (ctrl != null && ctrl.value.isInitialized)
                VideoPlayer(ctrl)
              else
                const Center(child: CircularProgressIndicator(color: Colors.white)),
              
              GestureDetector(
                onTap: () {
                  ref.read(videoProvider.notifier).togglePlayPause();
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedOpacity(
                          opacity: videoState.isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 64),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.pop(context); 
                            VideoFullscreenViewer.show(context, widget.node);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
