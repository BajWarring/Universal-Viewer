import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class VideoState {
  final OmniNode? currentVideo;
  final VideoPlayerController? controller;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const VideoState({
    this.currentVideo,
    this.controller,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  VideoState copyWith({
    OmniNode? currentVideo,
    VideoPlayerController? controller,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return VideoState(
      currentVideo: currentVideo ?? this.currentVideo,
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class VideoNotifier extends Notifier<VideoState> {
  @override
  VideoState build() {
    ref.onDispose(() {
      state.controller?.dispose();
    });
    return const VideoState();
  }

  Future<void> playFile(OmniNode node) async {
    // If the same video is already playing, just resume it
    if (state.currentVideo?.path == node.path && state.controller != null) {
      state.controller!.play();
      return;
    }

    final oldController = state.controller;
    final newController = VideoPlayerController.file(File(node.path));

    state = state.copyWith(currentVideo: node, controller: newController);
    
    await newController.initialize();
    
    newController.addListener(_onVideoEvent);
    newController.play();
    
    oldController?.removeListener(_onVideoEvent);
    oldController?.dispose();
  }

  void _onVideoEvent() {
    final ctrl = state.controller;
    if (ctrl == null) return;
    state = state.copyWith(
      isPlaying: ctrl.value.isPlaying,
      position: ctrl.value.position,
      duration: ctrl.value.duration,
    );
  }

  void togglePlayPause() {
    final ctrl = state.controller;
    if (ctrl == null) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }
  }

  void seek(Duration position) {
    state.controller?.seekTo(position);
  }

  void stopAndDismiss() {
    state.controller?.pause();
    state.controller?.removeListener(_onVideoEvent);
    state.controller?.dispose();
    state = const VideoState(); // Reset state
  }
}

final videoProvider = NotifierProvider<VideoNotifier, VideoState>(() => VideoNotifier());
