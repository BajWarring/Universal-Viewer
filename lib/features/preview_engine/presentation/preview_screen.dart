import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import 'renderers/text_previewer.dart';
import 'renderers/image_previewer.dart';
import '../../media_player/presentation/video_player_screen.dart';
import '../../media_player/application/audio_notifier.dart';

class UnifiedViewer extends StatelessWidget {
  final OmniNode node;
  const UnifiedViewer({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    final ext = node.extension.toLowerCase();
    final isAudio = ['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(ext);
    final isVideo = ['mp4', 'mkv', 'avi', 'webm', 'mov'].contains(ext);

    // 1. Show Mini Media Popups
    if (isAudio) {
      showDialog(context: context, barrierColor: Colors.black54, builder: (_) => AudioPopup(node: node));
      return;
    }
    if (isVideo) {
      showDialog(context: context, barrierColor: Colors.black87, builder: (_) => VideoPopup(node: node));
      return;
    }

    // 2. Show Default Fullscreen Viewer (Images, Text, etc)
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => UnifiedViewer(node: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation), child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)))),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
                ],
              ),
            ),
            Expanded(
              child: _buildPreviewer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewer(BuildContext context) {
    final ext = node.extension.toLowerCase();
    
    if (['jpeg', 'jpg', 'png', 'gif', 'webp'].contains(ext)) {
      return ImagePreviewer(path: node.path);
    }
    
    if (['txt', 'md', 'json', 'xml', 'java', 'kt', 'gradle', 'kts', 'html', 'sql', 'csv', 'py', 'dart', 'db'].contains(ext)) {
      return TextPreviewer(path: node.path, extension: ext);
    }
    
    // Fallback View
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No preview available for .${node.extension}'),
        ],
      ),
    );
  }
}

// ==========================================
// 🎵 AUDIO POPUP (Mini View)
// ==========================================
class AudioPopup extends ConsumerStatefulWidget {
  final OmniNode node;
  const AudioPopup({super.key, required this.node});

  @override
  ConsumerState<AudioPopup> createState() => _AudioPopupState();
}

class _AudioPopupState extends ConsumerState<AudioPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Play the file if it's not already playing
      if (ref.read(audioProvider).currentTrack?.path != widget.node.path) {
        ref.read(audioProvider.notifier).playFile(widget.node);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0 ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surfaceContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Text('Unknown Artist', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_formatTime(audioState.position), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.outlineVariant,
                      thumbColor: theme.colorScheme.primary,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) => ref.read(audioProvider.notifier).seek(Duration(milliseconds: (v * audioState.duration.inMilliseconds).round())),
                    ),
                  ),
                ),
                Text(_formatTime(audioState.duration), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous_rounded), color: Colors.grey, onPressed: () {}),
                const SizedBox(width: 8),
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
                  child: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: theme.colorScheme.onPrimary, size: 32),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.skip_next_rounded), color: Colors.grey, onPressed: () {}),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.pop(context); 
                    AudioFullscreenViewer.show(context, widget.node);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ==========================================
// 🎵 AUDIO FULLSCREEN
// ==========================================
class AudioFullscreenViewer extends ConsumerWidget {
  final OmniNode node;
  const AudioFullscreenViewer({super.key, required this.node});

  static void show(BuildContext context, OmniNode node) {
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => AudioFullscreenViewer(node: node),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    final progress = audioState.duration.inMilliseconds > 0 ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary.withValues(alpha: 0.3), theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32), onPressed: () => Navigator.pop(context)),
                    const Text('NOW PLAYING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12))],
                ),
                child: Icon(Icons.music_note_rounded, size: 100, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(node.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('Unknown Artist', style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        thumbColor: theme.colorScheme.primary,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (v) => ref.read(audioProvider.notifier).seek(Duration(milliseconds: (v * audioState.duration.inMilliseconds).round())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTime(audioState.position), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(_formatTime(audioState.duration), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.shuffle_rounded), color: theme.colorScheme.onSurfaceVariant, onPressed: () {}),
                    IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 40), onPressed: () {}),
                    FloatingActionButton.large(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.primary,
                      onPressed: () => ref.read(audioProvider.notifier).togglePlayPause(),
                      child: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: theme.colorScheme.onPrimary, size: 48),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next_rounded, size: 40), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.repeat_rounded), color: theme.colorScheme.onSurfaceVariant, onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ==========================================
// 🎬 VIDEO POPUP (Mini View)
// ==========================================
class VideoPopup extends StatefulWidget {
  final OmniNode node;
  const VideoPopup({super.key, required this.node});

  @override
  State<VideoPopup> createState() => _VideoPopupState();
}

class _VideoPopupState extends State<VideoPopup> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.node.path))
      ..initialize().then((_) {
        setState(() { _isInitialized = true; });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          aspectRatio: _isInitialized ? _controller.value.aspectRatio : 16 / 9,
          child: Stack(
            children: [
              if (_isInitialized)
                VideoPlayer(_controller)
              else
                const Center(child: CircularProgressIndicator(color: Colors.white)),
              
              // Hover / Click Overlay
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedOpacity(
                          opacity: _controller.value.isPlaying ? 0.0 : 1.0,
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
                            _controller.pause();
                            Navigator.pop(context); // close popup
                            // Navigate to the existing VideoPlayerScreen for Fullscreen
                            Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoNode: widget.node)));
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
