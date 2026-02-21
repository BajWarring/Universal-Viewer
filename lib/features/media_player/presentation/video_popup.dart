import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import 'video_player_screen.dart';

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
                            Navigator.pop(context); 
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
