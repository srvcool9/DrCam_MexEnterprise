import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Required for file handling
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart'; // Add flutter_ffmpeg

class Camera extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<Camera> with SingleTickerProviderStateMixin {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  MediaStream? _mediaStream;
  bool isRecording = false;
  late TabController _tabController;
  final GlobalKey _videoKey = GlobalKey();
  late VideoPlayerController _videoPlayerController;
  List<Map<String, dynamic>> capturedItems = [];
  late FlutterFFmpeg _flutterFFmpeg; // FlutterFFmpeg instance
  String? videoFilePath; // Path to save the video

  @override
  void initState() {
    super.initState();
    _flutterFFmpeg = FlutterFFmpeg();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _renderer.initialize();
    try {
      final mediaStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });
      _renderer.srcObject = mediaStream;
      setState(() {
        _mediaStream = mediaStream;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary =
          _videoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          capturedItems.insert(0, {
            'type': 'image',
            'data': byteData.buffer.asUint8List(),
            'datetime': DateTime.now(),
          });
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });
    if (isRecording) {
      // Start recording (just simulate it here)
      print('Recording started');
      _startRecording();
    } else {
      // Stop recording
      print('Recording stopped');
      _stopRecording();
    }
  }

  // Simulate video recording by saving the stream using flutter_ffmpeg
  Future<void> _startRecording() async {
    if (_mediaStream != null) {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(join(appDocumentsDir.path, 'videos'));

      // Create the directory if it doesn't exist
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      // Define the video path with timestamp to avoid name conflicts
      videoFilePath = join(videoDir.path, 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');

      setState(() {
        capturedItems.insert(0, {
          'type': 'loading', // Show loading indicator first
          'data': 'loading',
          'datetime': DateTime.now(),
        });
      });

      // Simulate video recording (this should be replaced with actual recording logic)
      await Future.delayed(Duration(seconds: 3)); // Simulate recording time

      // Once the video is "recorded", replace the loading state with the actual file path
      setState(() {
        capturedItems[0] = {
          'type': 'video',
          'data': videoFilePath,
          'datetime': DateTime.now(),
        };
      });

      print("Video saved to: $videoFilePath");
    }
  }

  Future<void> _stopRecording() async {
    // Stop the actual recording process here.
    // Simulate video recording stop
    await Future.delayed(Duration(seconds: 1)); // Simulate delay in stopping the recording

    // Save the video file using flutter_ffmpeg
    if (videoFilePath != null) {
      final String command =
          '-y -f lavfi -t 10 -i anullsrc=r=44100:cl=stereo -t 10 -c:v libx264 -r 30 $videoFilePath'; // Example command for FFmpeg
      await _flutterFFmpeg.execute(command);
    }

    setState(() {
      isRecording = false; // Stop recording
    });
  }

  @override
  void dispose() {
    _renderer.dispose();
    _tabController.dispose();
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _videoPlayerController.dispose(); // Dispose the video player controller
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 1.0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: 'New User'),
                      Tab(text: 'Existing User'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...[
                              'Patient ID',
                              'First Name',
                              'Last Name',
                              'Gender',
                              'Date of Birth',
                              'Phone No.',
                              'Address',
                            ].map(
                              (label) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: label,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Save action
                              },
                              child: Text('Save'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Center(child: Text("Existing User")),
                        Center(child: Text("Camera")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: RepaintBoundary(
                      key: _videoKey,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _renderer.textureId != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: RTCVideoView(_renderer),
                              )
                            : Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Capture'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,
                                foregroundColor: Colors.white),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: Icon(isRecording ? Icons.stop : Icons.videocam),
                        label: Text(isRecording ? 'Stop' : 'Record'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: capturedItems.length,
                      itemBuilder: (context, index) {
                        final item = capturedItems[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: item['type'] == 'image'
                              ? Image.memory(
                                  item['data'],
                                  fit: BoxFit.cover,
                                )
                              : item['type'] == 'video'
                                  ? VideoPlayerWidget(videoPath: item['data']) // Display video using video_player
                                  : item['type'] == 'loading'
                                      ? Center(child: CircularProgressIndicator())
                                      : Center(child: Icon(Icons.videocam)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}