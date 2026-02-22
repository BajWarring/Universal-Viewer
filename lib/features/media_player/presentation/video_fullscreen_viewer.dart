import 'dart:async';
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
  Timer? _hideControlsTimer;
  
  // Gesture tracking
  String? _toastMessage;
  Timer? _toastTimer;
  double _dragVolume = 1.0; 
  Duration? _scrubTarget;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(videoProvider).currentVideo?.path != widget.videoNode.path) {
        ref.read(videoProvider.notifier).playFile(widget.videoNode);
      }
      _startHideTimer();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _hideControlsTimer?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls && !ref.read(videoProvider).isLocked) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (ref.read(videoProvider).isLocked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _showToast(String message) {
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  // --- Gestures ---
  void _onDoubleTapDown(TapDownDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 2) {
      ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: -10));
      _showToast("⏪ 10s");
    } else {
      ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: 10));
      _showToast("10s ⏩");
    }
    _startHideTimer();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    final width = MediaQuery.of(context).size.width;
    final delta = -details.primaryDelta! / 200.0; 
    
    if (details.globalPosition.dx > width / 2) {
      // Right side: Volume
      final ctrl = ref.read(videoProvider).controller;
      if (ctrl != null) {
        _dragVolume = (_dragVolume + delta).clamp(0.0, 1.0);
        ctrl.setVolume(_dragVolume);
        _showToast("Volume: ${(_dragVolume * 100).toInt()}%");
      }
    } else {
      // Left side: Brightness (Mocked for now as we lack screen_brightness package)
      _showToast("Brightness Adjusted");
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    final state = ref.read(videoProvider);
    if (state.controller == null) return;
    
    final delta = details.primaryDelta! * 1000; // ms per pixel
    final currentTarget = _scrubTarget ?? state.position;
    _scrubTarget = Duration(milliseconds: (currentTarget.inMilliseconds + delta.toInt()).clamp(0, state.duration.inMilliseconds));
    
    _showToast(_formatTime(_scrubTarget!));
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_scrubTarget != null && !ref.read(videoProvider).isLocked) {
      ref.read(videoProvider.notifier).seek(_scrubTarget!);
      _scrubTarget = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final ctrl = videoState.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Surface
          Center(
            child: RepaintBoundary(
              child: ctrl != null && ctrl.value.isInitialized
                  ? AspectRatio(aspectRatio: ctrl.value.aspectRatio, child: VideoPlayer(ctrl))
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
          
          // 2. Gesture Layer
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: _onDoubleTapDown,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onHorizontalDragStart: (_) => _startHideTimer(),
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onLongPress: () {
              if (videoState.isLocked) {
                ref.read(videoProvider.notifier).toggleLock();
                _showToast("Controls Unlocked");
                setState(() => _showControls = true);
                _startHideTimer();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),

          // 3. Toast Overlay
          if (_toastMessage != null)
            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30)),
                  child: Text(_toastMessage!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // 4. Locked Indicator
          if (videoState.isLocked)
            Positioned(
              top: 32, left: 0, right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Locked - Long press to unlock', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 5. Controls Overlay
          if (_showControls && !videoState.isLocked)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Column(
                  children: [
                    // Top Bar
                    Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 24, left: 16, right: 16),
                      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
                          const SizedBox(width: 16),
                          Expanded(child: Text(widget.videoNode.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          _buildMoreMenu(context, ref, videoState),
                        ],
                      ),
                    ),
                    
                    // Center Controls
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: -10)); _startHideTimer(); },
                          ),
                          const SizedBox(width: 48),
                          IconButton(
                            iconSize: 72,
                            icon: Icon(videoState.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).togglePlayPause(); _startHideTimer(); },
                          ),
                          const SizedBox(width: 48),
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: 10)); _startHideTimer(); },
                          ),
                        ],
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 24, left: 24, right: 24),
                      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ctrl != null)
                            Row(
                              children: [
                                Text(_formatTime(videoState.position), style: const TextStyle(color: Colors.white, fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: VideoProgressIndicator(
                                      ctrl,
                                      allowScrubbing: true,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      colors: const VideoProgressColors(playedColor: Colors.red, bufferedColor: Colors.white38, backgroundColor: Colors.white24),
                                    ),
                                  ),
                                ),
                                Text(_formatTime(videoState.duration), style: const TextStyle(color: Colors.white, fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
                                tooltip: 'Lock Controls',
                                onPressed: () {
                                  ref.read(videoProvider.notifier).toggleLock();
                                  setState(() => _showControls = false);
                                  _showToast("Controls Locked");
                                },
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('CC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text('${videoState.playbackSpeed}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context, WidgetRef ref, VideoState state) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      onSelected: (value) {
        _startHideTimer();
        if (value == 'speed') _showSpeedOptions(context, ref);
        if (value == 'sleep') _showSleepTimerOptions(context, ref);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'speed', child: ListTile(leading: Icon(Icons.speed_rounded), title: Text('Playback Speed'), contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'audio', child: ListTile(leading: Icon(Icons.audiotrack_rounded), title: Text('Audio Tracks'), contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'sub', child: ListTile(leading: Icon(Icons.subtitles_rounded), title: Text('Subtitles'), contentPadding: EdgeInsets.zero, dense: true)),
        PopupMenuItem(value: 'sleep', child: ListTile(leading: const Icon(Icons.timer_rounded), title: Text(state.sleepTimerEnd != null ? 'Timer Active' : 'Sleep Timer'), contentPadding: EdgeInsets.zero, dense: true)),
      ],
    );
  }

  void _showSpeedOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
            return ListTile(
              title: Text('${speed}x'),
              onTap: () {
                ref.read(videoProvider.notifier).setPlaybackSpeed(speed);
                Navigator.pop(context);
                _showToast("Speed: ${speed}x");
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSleepTimerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0, 5, 10, 15, 30, 60].map((mins) {
            return ListTile(
              title: Text(mins == 0 ? 'Off' : '$mins minutes'),
              onTap: () {
                ref.read(videoProvider.notifier).setSleepTimer(mins);
                Navigator.pop(context);
                _showToast(mins == 0 ? "Sleep Timer Off" : "Sleep Timer: $mins min");
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}
