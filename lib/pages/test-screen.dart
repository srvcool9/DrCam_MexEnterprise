import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';


class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key); // Removed dynamic path

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  // 🔹 Set a fixed video path here
  static const String _fixedVideoPath = "C:/Users/HP/Documents/final_video.mp4";
   // Change this pathr

  @override
  void initState() {
    
    super.initState();
    _initializeVideo();

    
  }


  void _initializeVideo() async {
    if (File(_fixedVideoPath).existsSync()) {
      _controller = VideoPlayerController.file(File(_fixedVideoPath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller!.play(); // Auto-play
          }
        }).catchError((error) {
          debugPrint("Error initializing video: $error");
        });
    } else {
      debugPrint("Video file not found at: $_fixedVideoPath");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fixed Path Video Player")),
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading video..."),
                ],
              ),
      ),
    );
  }
}
