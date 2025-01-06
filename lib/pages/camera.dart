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
      // Stop recording (stop capturing frames)
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
        // Get the current video track from the media stream
        final videoTrack = _mediaStream!.getVideoTracks().first;

        // Capture the current frame as bytes
        final imageBytes = await videoTrack.captureFrame();

        // Convert the ByteBuffer to a Uint8List
        final buffer = imageBytes.asUint8List();

        // Convert the captured frame to an Image
        img.Image? image = img.decodeImage(Uint8List.fromList(buffer));

        // Check if the image was decoded successfully
        if (image != null) {
          // Encode the image to Base64
          String base64String = base64Encode(img.encodeJpg(image));

          // You can print or save the Base64 string, e.g., upload it or store it
          print('Captured Frame (Base64): $base64String');
        }
      } catch (e) {
        print('Error capturing frame: $e');
      }
    }
  }

  Future<void> _captureImage() async {
    if (_mediaStream != null) {
      try {
        // Capture a single frame from the video
        final videoTrack = _mediaStream!.getVideoTracks().first;
        final imageBytes = await videoTrack.captureFrame();

        // Convert the ByteBuffer to a Uint8List
        final buffer = imageBytes.asUint8List();

        // Convert the captured frame to an Image
        img.Image? image = img.decodeImage(Uint8List.fromList(buffer));

        // Check if the image was decoded successfully
        if (image != null) {
          // Encode the image to Base64
          String base64String = base64Encode(img.encodeJpg(image));

          // Print the Base64 string (you can use it as needed)
          print('Captured Image (Base64): $base64String');
        }
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: _renderer.textureId != null
                ? Container(
                    width: 400, // Set a fixed width for the video view
                    height: 300, // Set a fixed height for the video view
                    child: RTCVideoView(_renderer),
                  )
                : CircularProgressIndicator(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _startStopRecording,
                child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture Image'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
