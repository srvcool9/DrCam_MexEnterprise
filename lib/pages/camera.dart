import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

class Camera extends StatefulWidget {
  @override
  _WebcamPageState createState() => _WebcamPageState();
}

class _WebcamPageState extends State<Camera> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  MediaStream? _mediaStream;
  bool isRecording = false;
  Timer? _recordingTimer;
  List<Uint8List> capturedImages = []; // List to store captured images

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _renderer.initialize();

    // Ensure the getUserMedia call is made on the main thread
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final mediaStream = await navigator.mediaDevices.getUserMedia({
          'video': true,
          'audio': false,
        });
        _renderer.srcObject = mediaStream;
        setState(() {
          _mediaStream = mediaStream;
        });
      } catch (e) {
        print('Error initializing camera: $e');
      }
    });
  }

  Future<void> _startStopRecording() async {
    if (isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
    } else {
      // Start recording (capture frames every second)
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _captureFrameAndSave();
      });
    }
    setState(() {
      isRecording = !isRecording;
    });
  }

  Future<void> _captureFrameAndSave() async {
    if (_mediaStream != null) {
      try {
        final videoTrack = _mediaStream!.getVideoTracks().first;
        final imageBytes = await videoTrack.captureFrame();
        final buffer = imageBytes.asUint8List();
        img.Image? image = img.decodeImage(buffer);

        if (image != null) {
          setState(() {
            // Store the image data in the list
            capturedImages.add(Uint8List.fromList(buffer));
            if (capturedImages.length > 3) {
              // Limit to the latest 3 images
              capturedImages.removeAt(0);
            }
          });
        }
      } catch (e) {
        print('Error capturing frame: $e');
      }
    }
  }

  Future<void> _captureImage() async {
    _captureFrameAndSave();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('USB Camera Feed'),
      ),
      body: Row(
        children: [
          // Video feed on the left
          Expanded(
            flex: 2,
            child: _renderer.textureId != null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: RTCVideoView(_renderer),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          // Image tiles on the right
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    'Captured Images',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 50),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: capturedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                          child: capturedImages.isNotEmpty
                              ? Image.memory(
                                  capturedImages[index],
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    'No Images',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _startStopRecording,
            label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
          ),
          SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: _captureImage,
            label: Text('Capture Image'),
          ),
        ],
      ),
    );
  }
}
