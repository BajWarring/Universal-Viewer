import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class AudioState {
  final OmniNode? currentTrack;
  const AudioState({this.currentTrack});
}

class AudioNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;

  @override
  AudioState build() {
    _player = AudioPlayer();
    return const AudioState();
  }

  Future<void> playFile(OmniNode node) async {
    state = AudioState(currentTrack: node);
    await _player.setFilePath(node.path);
    _player.play();
  }
}

final audioProvider = NotifierProvider<AudioNotifier, AudioState>(() => AudioNotifier());
