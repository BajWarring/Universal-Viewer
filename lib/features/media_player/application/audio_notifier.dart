import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class AudioState {
  final OmniNode? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({OmniNode? track, bool? isPlaying, Duration? pos, Duration? dur}) {
    return AudioState(
      currentTrack: track ?? currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: pos ?? position,
      duration: dur ?? duration,
    );
  }
}

class AudioNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;

  @override
  AudioState build() {
    _player = AudioPlayer();
    
    // Listen to player streams to update UI state
    _player.positionStream.listen((p) => state = state.copyWith(pos: p));
    _player.durationStream.listen((d) => state = state.copyWith(dur: d ?? Duration.zero));
    _player.playingStream.listen((p) => state = state.copyWith(isPlaying: p));
    
    return const AudioState();
  }

  Future<void> playFile(OmniNode node) async {
    state = state.copyWith(track: node);
    await _player.setFilePath(node.path);
    _player.play();
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void seek(Duration position) => _player.seek(position);

  void stopAndDismiss() {
    _player.stop();
    state = const AudioState(); // Clears current track, hiding the mini-player
  }
}

final audioProvider = NotifierProvider<AudioNotifier, AudioState>(() => AudioNotifier());
