import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';
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
  
  // Gesture UI Feedback State
  String? _overlayIcon;
  String? _overlayText;
  Timer? _overlayTimer;
  
  // Drag State
  double _dragVolume = 1.0; 
  double _dragBrightness = 1.0;
  Duration? _scrubTarget;
  bool _isScrubbing = false;

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
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
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

  void _showFeedback(String text, String iconPath) {
    setState(() {
      _overlayText = text;
      _overlayIcon = iconPath;
    });
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() { _overlayText = null; _overlayIcon = null; });
    });
  }

  // --- MX/VLC Style Gestures ---
  void _onDoubleTapDown(TapDownDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width * 0.33) {
      ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: -10));
      _showFeedback("-10s", "rewind");
    } else if (details.globalPosition.dx > width * 0.66) {
      ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: 10));
      _showFeedback("+10s", "forward");
    } else {
      ref.read(videoProvider.notifier).togglePlayPause();
    }
    _startHideTimer();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragVolume = (ref.read(videoProvider).player?.state.volume ?? 100) / 100.0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    final width = MediaQuery.of(context).size.width;
    final delta = -details.primaryDelta! / 200.0; 
    
    if (details.globalPosition.dx > width / 2) {
      // Right side: Volume
      _dragVolume = (_dragVolume + delta).clamp(0.0, 1.0);
      ref.read(videoProvider.notifier).setVolume(_dragVolume);
      _showFeedback("${(_dragVolume * 100).toInt()}%", "volume");
    } else {
      // Left side: Brightness (Requires screen_brightness package for real hardware brightness)
      // Mocked for UI parity
      _dragBrightness = (_dragBrightness + delta).clamp(0.0, 1.0);
      _showFeedback("${(_dragBrightness * 100).toInt()}%", "brightness");
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (ref.read(videoProvider).isLocked) return;
    _isScrubbing = true;
    _scrubTarget = ref.read(videoProvider).position;
    setState(() => _showControls = true);
    _hideControlsTimer?.cancel();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isScrubbing) return;
    final state = ref.read(videoProvider);
    final delta = details.primaryDelta! * 2000; // ms per pixel sweep
    _scrubTarget = Duration(milliseconds: (_scrubTarget!.inMilliseconds + delta.toInt()).clamp(0, state.duration.inMilliseconds));
    _showFeedback(_formatTime(_scrubTarget!), "seek");
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isScrubbing && _scrubTarget != null) {
      ref.read(videoProvider.notifier).seek(_scrubTarget!);
      _isScrubbing = false;
      _startHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final ctrl = videoState.controller;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. MPV Video Surface
          Center(
            child: ctrl != null 
              ? Video(controller: ctrl, controls: NoVideoControls) // Disable default media_kit controls
              : const CircularProgressIndicator(color: Colors.white),
          ),
          
          // 2. Gesture Layer
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: _onDoubleTapDown,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onLongPressStart: (_) {
              if (!videoState.isLocked) {
                ref.read(videoProvider.notifier).setSpeedBoost(true);
                _showFeedback("2x Speed", "speed");
              }
            },
            onLongPressEnd: (_) {
              if (!videoState.isLocked) ref.read(videoProvider.notifier).setSpeedBoost(false);
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),

          // 3. Gesture Feedback Overlay
          if (_overlayText != null)
            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_overlayIcon == "volume") const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                      if (_overlayIcon == "brightness") const Icon(Icons.brightness_6_rounded, color: Colors.white, size: 28),
                      if (_overlayIcon == "speed") const Icon(Icons.speed_rounded, color: Colors.white, size: 28),
                      if (_overlayIcon != null) const SizedBox(width: 12),
                      Text(_overlayText!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                        Text('Locked - Tap lock icon below to unlock', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 5. Controls Overlay
          if (_showControls || _isScrubbing)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: (_showControls || _isScrubbing) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: Column(
                  children: [
                    // Top Bar
                    if (!videoState.isLocked)
                      Container(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 32, left: 16, right: 16),
                        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
                            const SizedBox(width: 16),
                            Expanded(child: Text(widget.videoNode.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            IconButton(icon: const Icon(Icons.audiotrack_rounded, color: Colors.white), onPressed: () => _showAudioTracks(context, videoState)),
                            IconButton(icon: const Icon(Icons.subtitles_rounded, color: Colors.white), onPressed: () => _showSubtitleTracks(context, videoState)),
                            _buildMoreMenu(context, ref, videoState),
                          ],
                        ),
                      ),
                    
                    const Spacer(),

                    // Center Controls
                    if (!videoState.isLocked && !_isScrubbing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 56,
                            icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: -10)); _startHideTimer(); },
                          ),
                          const SizedBox(width: 48),
                          IconButton(
                            iconSize: 84,
                            icon: Icon(videoState.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).togglePlayPause(); _startHideTimer(); },
                          ),
                          const SizedBox(width: 48),
                          IconButton(
                            iconSize: 56,
                            icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                            onPressed: () { ref.read(videoProvider.notifier).seekRelative(const Duration(seconds: 10)); _startHideTimer(); },
                          ),
                        ],
                      ),

                    const Spacer(),

                    // Bottom Bar
                    Container(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16, top: 32, left: 24, right: 24),
                      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Slider
                          if (!videoState.isLocked)
                            Row(
                              children: [
                                Text(_formatTime(_isScrubbing ? _scrubTarget! : videoState.position), style: const TextStyle(color: Colors.white, fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      activeTrackColor: theme.colorScheme.primary,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: theme.colorScheme.primary,
                                    ),
                                    child: Slider(
                                      value: (_isScrubbing ? _scrubTarget!.inMilliseconds : videoState.position.inMilliseconds).toDouble().clamp(0, videoState.duration.inMilliseconds.toDouble()),
                                      max: videoState.duration.inMilliseconds.toDouble() > 0 ? videoState.duration.inMilliseconds.toDouble() : 1.0,
                                      onChanged: (v) {
                                        _startHideTimer();
                                        ref.read(videoProvider.notifier).seek(Duration(milliseconds: v.toInt()));
                                      },
                                    ),
                                  ),
                                ),
                                Text(_formatTime(videoState.duration), style: const TextStyle(color: Colors.white, fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
                              ],
                            ),
                          const SizedBox(height: 8),
                          // Utility Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(videoState.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded, color: Colors.white),
                                onPressed: () {
                                  ref.read(videoProvider.notifier).toggleLock();
                                  if (!videoState.isLocked) setState(() => _showControls = false); // Hides if newly locked
                                  _showFeedback(videoState.isLocked ? "Unlocked" : "Locked", null);
                                },
                              ),
                              if (!videoState.isLocked)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white),
                                      onPressed: () { /* Future PIP implementation */ },
                                    ),
                                    TextButton(
                                      onPressed: () => _showSpeedOptions(context, ref),
                                      child: Text('${videoState.playbackSpeed}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  // --- Menus ---

  void _showAudioTracks(BuildContext context, VideoState state) {
    _startHideTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text("Audio Tracks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ...state.audioTracks.map((t) => ListTile(
              leading: Icon(state.selectedAudioTrack == t ? Icons.radio_button_checked : Icons.radio_button_off, color: state.selectedAudioTrack == t ? Theme.of(context).colorScheme.primary : Colors.grey),
              title: Text(t.title ?? t.language ?? 'Track ${t.id}'),
              onTap: () { ref.read(videoProvider.notifier).setAudioTrack(t); Navigator.pop(context); },
            ))
          ],
        ),
      ),
    );
  }

  void _showSubtitleTracks(BuildContext context, VideoState state) {
    _startHideTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text("Subtitles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ...state.subtitleTracks.map((t) => ListTile(
              leading: Icon(state.selectedSubtitleTrack == t ? Icons.radio_button_checked : Icons.radio_button_off, color: state.selectedSubtitleTrack == t ? Theme.of(context).colorScheme.primary : Colors.grey),
              title: Text(t.title ?? t.language ?? 'Track ${t.id}'),
              onTap: () { ref.read(videoProvider.notifier).setSubtitleTrack(t); Navigator.pop(context); },
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context, WidgetRef ref, VideoState state) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      onSelected: (value) {
        _startHideTimer();
        // Decode logic/filters to be expanded
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'hw', child: ListTile(leading: Icon(Icons.memory_rounded), title: Text('HW Decoder: Auto'), contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'sleep', child: ListTile(leading: Icon(Icons.timer_rounded), title: Text('Sleep Timer'), contentPadding: EdgeInsets.zero, dense: true)),
        const PopupMenuItem(value: 'stats', child: ListTile(leading: Icon(Icons.query_stats_rounded), title: Text('Player Stats'), contentPadding: EdgeInsets.zero, dense: true)),
      ],
    );
  }

  void _showSpeedOptions(BuildContext context, WidgetRef ref) {
    _startHideTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
            return ListTile(
              title: Text('${speed}x', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              onTap: () {
                ref.read(videoProvider.notifier).setPlaybackSpeed(speed);
                Navigator.pop(context);
                _showFeedback("Speed: ${speed}x", "speed");
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
