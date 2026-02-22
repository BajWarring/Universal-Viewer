import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class VideoState {
  final OmniNode? currentVideo;
  final Player? player;
  final VideoController? controller;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;
  
  // Advanced State
  final bool isLocked;
  final double playbackSpeed;
  final bool isSpeedBoosted; 
  
  // Tracks (Correctly strongly typed for media_kit)
  final AudioTrack? selectedAudioTrack;
  final SubtitleTrack? selectedSubtitleTrack;
  final List<AudioTrack> audioTracks;
  final List<SubtitleTrack> subtitleTracks;

  const VideoState({
    this.currentVideo,
    this.player,
    this.controller,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
    this.isLocked = false,
    this.playbackSpeed = 1.0,
    this.isSpeedBoosted = false,
    this.selectedAudioTrack,
    this.selectedSubtitleTrack,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
  });

  VideoState copyWith({
    OmniNode? currentVideo,
    Player? player,
    VideoController? controller,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
    bool? isLocked,
    double? playbackSpeed,
    bool? isSpeedBoosted,
    AudioTrack? selectedAudioTrack,
    SubtitleTrack? selectedSubtitleTrack,
    List<AudioTrack>? audioTracks,
    List<SubtitleTrack>? subtitleTracks,
  }) {
    return VideoState(
      currentVideo: currentVideo ?? this.currentVideo,
      player: player ?? this.player,
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
      isLocked: isLocked ?? this.isLocked,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isSpeedBoosted: isSpeedBoosted ?? this.isSpeedBoosted,
      selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
      selectedSubtitleTrack: selectedSubtitleTrack ?? this.selectedSubtitleTrack,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
    );
  }
}

class VideoNotifier extends Notifier<VideoState> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  VideoState build() {
    ref.onDispose(() {
      _disposePlayer();
    });
    return const VideoState();
  }

  void _disposePlayer() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    state.player?.dispose();
  }

  Future<void> playFile(OmniNode node) async {
    if (state.currentVideo?.path == node.path && state.player != null) {
      state.player!.play();
      return;
    }

    _disposePlayer();

    final player = Player(configuration: const PlayerConfiguration(
      pitch: false, 
      title: 'Omni Media Engine',
      bufferSize: 32 * 1024 * 1024,
    ));
    final controller = VideoController(player);

    state = state.copyWith(
      currentVideo: node, 
      player: player, 
      controller: controller,
      isLocked: false, 
      playbackSpeed: 1.0,
      isSpeedBoosted: false,
    );
    
    _subscriptions.addAll([
      player.stream.playing.listen((playing) => state = state.copyWith(isPlaying: playing)),
      player.stream.position.listen((pos) => state = state.copyWith(position: pos)),
      player.stream.duration.listen((dur) => state = state.copyWith(duration: dur)),
      player.stream.buffering.listen((buf) => state = state.copyWith(isBuffering: buf)),
      player.stream.tracks.listen((tracks) {
        state = state.copyWith(
          audioTracks: tracks.audio,
          subtitleTracks: tracks.subtitle,
        );
      }),
      player.stream.track.listen((track) {
        state = state.copyWith(
          selectedAudioTrack: track.audio,
          selectedSubtitleTrack: track.subtitle,
        );
      }),
    ]);

    await player.open(Media(node.path));
    player.play();
  }

  void togglePlayPause() => state.player?.playOrPause();
  void seek(Duration position) => state.player?.seek(position);
  void seekRelative(Duration delta) {
    final current = state.player?.state.position ?? Duration.zero;
    state.player?.seek(current + delta);
  }

  void setPlaybackSpeed(double speed) {
    state.player?.setRate(speed);
    state = state.copyWith(playbackSpeed: speed, isSpeedBoosted: false);
  }

  void setSpeedBoost(bool active) {
    if (active) {
      state.player?.setRate(2.0);
      state = state.copyWith(isSpeedBoosted: true);
    } else {
      state.player?.setRate(state.playbackSpeed);
      state = state.copyWith(isSpeedBoosted: false);
    }
  }

  void toggleLock() => state = state.copyWith(isLocked: !state.isLocked);
  void setVolume(double volume) => state.player?.setVolume(volume * 100);
  
  void setAudioTrack(AudioTrack track) => state.player?.setAudioTrack(track);
  void setSubtitleTrack(SubtitleTrack track) => state.player?.setSubtitleTrack(track);

  void stopAndDismiss() {
    _disposePlayer();
    state = const VideoState(); 
  }
}

final videoProvider = NotifierProvider<VideoNotifier, VideoState>(() => VideoNotifier());
