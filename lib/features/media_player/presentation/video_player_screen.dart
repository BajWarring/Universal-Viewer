import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';

class VideoPlayerScreen extends StatefulWidget {
  final OmniNode videoNode;

  const VideoPlayerScreen({super.key, required this.videoNode});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    // Force Landscape for Video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize MediaKit Player
    player = Player();
    controller = VideoController(player);
    
    // Play the file
    player.open(Media(widget.videoNode.path));
  }

  @override
  void dispose() {
    // Restore orientations and UI overlay when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Gesture Interceptors for Brightness/Volume/Seek
        onVerticalDragUpdate: (details) {
          final isLeftSide = details.globalPosition.dx < MediaQuery.of(context).size.width / 2;
          if (isLeftSide) {
            // Adjust Brightness logic here
          } else {
            // Adjust Volume logic here
            // player.setVolume(newVolume);
          }
        },
        onDoubleTapDown: (details) {
          final isLeftSide = details.globalPosition.dx < MediaQuery.of(context).size.width / 2;
          final currentPosition = player.state.position;
          if (isLeftSide) {
            player.seek(currentPosition - const Duration(seconds: 10)); // Rewind
          } else {
            player.seek(currentPosition + const Duration(seconds: 10)); // Forward
          }
        },
        child: Stack(
          children: [
            Center(
              child: Video(
                controller: controller,
                // Advanced Controls: Allows Audio track switching, speed, and subs
                controls: MaterialVideoControls, 
              ),
            ),
            // Custom Top Bar (Back button + PiP Button)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
                    onPressed: () {
                      // Trigger native PiP mode (requires specific Android manifest setup)
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
