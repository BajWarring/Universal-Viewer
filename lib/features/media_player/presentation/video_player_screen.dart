import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class VideoPlayerScreen extends StatefulWidget {
  final OmniNode videoNode;
  const VideoPlayerScreen({super.key, required this.videoNode});
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
    _controller = VideoPlayerController.file(File(widget.videoNode.path))
      ..initialize().then((_) { setState(() {}); _controller.play(); });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
                : const CircularProgressIndicator(color: Colors.white),
          ),
          if (_showControls) ...[
            // Top bar
            Positioned(top: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 8, right: 8),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent])),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  Expanded(child: Text(widget.videoNode.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ]),
              )),
            // Bottom controls
            Positioned(bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 12, top: 16, left: 8, right: 8),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.transparent])),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: Colors.white, bufferedColor: Colors.white38, backgroundColor: Colors.white12)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      icon: Icon(_controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                      onPressed: () => setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }),
                    ),
                  ]),
                ]),
              )),
          ],
        ]),
      ),
    );
  }
}
