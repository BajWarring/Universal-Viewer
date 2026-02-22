import 'dart:async';
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
  
  // Advanced State
  final bool isLocked;
  final double playbackSpeed;
  final DateTime? sleepTimerEnd;

  const VideoState({
    this.currentVideo,
    this.controller,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLocked = false,
    this.playbackSpeed = 1.0,
    this.sleepTimerEnd,
  });

  VideoState copyWith({
    OmniNode? currentVideo,
    VideoPlayerController? controller,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLocked,
    double? playbackSpeed,
    DateTime? sleepTimerEnd,
  }) {
    return VideoState(
      currentVideo: currentVideo ?? this.currentVideo,
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLocked: isLocked ?? this.isLocked,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      // If we pass a specific null intentionally to clear it, we'd need a different pattern. 
      // For simplicity, we manage sleep timer nulling via explicit methods.
      sleepTimerEnd: sleepTimerEnd ?? this.sleepTimerEnd,
    );
  }
  
  // Helper to clear sleep timer
  VideoState clearSleepTimer() {
    return VideoState(
      currentVideo: currentVideo,
      controller: controller,
      isPlaying: isPlaying,
      position: position,
      duration: duration,
      isLocked: isLocked,
      playbackSpeed: playbackSpeed,
      sleepTimerEnd: null,
    );
  }
}

class VideoNotifier extends Notifier<VideoState> {
  Timer? _sleepTimer;

  @override
  VideoState build() {
    ref.onDispose(() {
      state.controller?.dispose();
      _sleepTimer?.cancel();
    });
    return const VideoState();
  }

  Future<void> playFile(OmniNode node) async {
    if (state.currentVideo?.path == node.path && state.controller != null) {
      state.controller!.play();
      return;
    }

    final oldController = state.controller;
    final newController = VideoPlayerController.file(File(node.path));

    state = state.copyWith(currentVideo: node, controller: newController, isLocked: false, playbackSpeed: 1.0);
    
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

  void seekRelative(Duration delta) {
    final ctrl = state.controller;
    if (ctrl == null) return;
    final newPos = ctrl.value.position + delta;
    ctrl.seekTo(newPos);
  }

  void setPlaybackSpeed(double speed) {
    state.controller?.setPlaybackSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes <= 0) {
      state = state.clearSleepTimer();
      return;
    }
    
    final end = DateTime.now().add(Duration(minutes: minutes));
    state = state.copyWith(sleepTimerEnd: end);
    
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      state.controller?.pause();
      state = state.clearSleepTimer();
    });
  }

  void stopAndDismiss() {
    state.controller?.pause();
    state.controller?.removeListener(_onVideoEvent);
    state.controller?.dispose();
    _sleepTimer?.cancel();
    state = const VideoState(); 
  }
}

final videoProvider = NotifierProvider<VideoNotifier, VideoState>(() => VideoNotifier());
