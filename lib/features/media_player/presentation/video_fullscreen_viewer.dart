import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../application/video_notifier.dart';

class VideoFullscreenViewer extends ConsumerStatefulWidget {
  final OmniNode videoNode;
  const VideoFullscreenViewer({super.key, required this.videoNode});

  static void show(BuildContext context, OmniNode node) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => VideoFullscreenViewer(videoNode: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  ConsumerState<VideoFullscreenViewer> createState() => _VideoFullscreenViewerState();
}

class _VideoFullscreenViewerState extends ConsumerState<VideoFullscreenViewer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(videoProvider).currentVideo?.path != widget.videoNode.path) {
        ref.read(videoProvider.notifier).playFile(widget.videoNode);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final ctrl = videoState.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(children: [
          Center(
            child: ctrl != null && ctrl.value.isInitialized
                ? AspectRatio(aspectRatio: ctrl.value.aspectRatio, child: VideoPlayer(ctrl))
                : const CircularProgressIndicator(color: Colors.white),
          ),
          if (_showControls) ...[
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 8, right: 8),
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent])),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
                  Expanded(child: Text(widget.videoNode.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 12, top: 16, left: 8, right: 8),
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.transparent])),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (ctrl != null)
                    VideoProgressIndicator(
                      ctrl,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(playedColor: Colors.white, bufferedColor: Colors.white38, backgroundColor: Colors.white12),
                    ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      icon: Icon(videoState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                      onPressed: () => ref.read(videoProvider.notifier).togglePlayPause(),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
