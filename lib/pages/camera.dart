import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:doctorcam/models/patient_history.dart';
import 'package:doctorcam/models/patient_images.dart';
import 'package:doctorcam/models/patient_master.dart';
import 'package:doctorcam/models/patient_video.dart';
import 'package:doctorcam/pages/dashboard.dart';
import 'package:doctorcam/pages/test-screen.dart';
import 'package:doctorcam/repository/PatientHistoryRepository.dart';
import 'package:doctorcam/repository/PatientImagesRepository.dart';
import 'package:doctorcam/repository/PatientRepository.dart';
import 'package:doctorcam/repository/PatientVideoRepository.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Required for file handling
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:process_run/process_run.dart';
import 'package:permission_handler/permission_handler.dart';

// Add flutter_ffmpeg

class Camera extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<Camera>
    with SingleTickerProviderStateMixin {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  MediaStream? _mediaStream;
  bool isRecording = false;
  late TabController _tabController;
  final GlobalKey _videoKey = GlobalKey();
  late VideoPlayerController _videoPlayerController;
  List<Map<String, dynamic>> capturedItems = [];
  List<String> imagesBase64List = [];
  List<String> videoPaths = [];
  String? videoFilePath; // Path to save the video4
  MediaRecorder? _mediaRecorder; // Define MediaRecorder instance
  Uint8List? _recordedData;
  String? _outputPath;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _appointmentDateController =
      TextEditingController();
  late Patientrepository patientrepository;
  late Patienthistoryrepository patientHistoryRepository;
  late Patientimagesrepository patientimagesrepository;
  late PatientVideoRepository patientVideoRepository;

  final _updateFormKey = GlobalKey<FormState>();
  final TextEditingController _existPatientIdController =
      TextEditingController();
  final TextEditingController _existPatientNameController =
      TextEditingController();
  final TextEditingController _existGenderController = TextEditingController();
  final TextEditingController _existDobController = TextEditingController();
  final TextEditingController _existPhoneController = TextEditingController();
  final TextEditingController _existAddressController = TextEditingController();
  final TextEditingController _existAppointmentDateController =
      TextEditingController();

  String serverUrl = "http://127.0.0.1:5000";
  Timer? frameTimer;
  RTCPeerConnection? _peerConnection;
  String? outputMp4Path; // Path for final converted MP4 file
  Process? _ffmpegProcess;
  String? cameraName;
  double _brightness = 1.0;
  double _contrast = 2.0;
  double _exposure = 2.0;
  double _zoomLevel = 1.0;
  double _saturation = 1.0;

  @override
  void initState() {
    super.initState();
    patientrepository = Patientrepository();
    patientHistoryRepository = Patienthistoryrepository();
    patientimagesrepository = Patientimagesrepository();
    patientVideoRepository = PatientVideoRepository();

    _tabController = TabController(length: 2, vsync: this);

    _requestPermissions().then((_) {
      _listCameras();
      getFFmpegPath();
      _initializeCamera();
    });
  }

  Future<String> getFFmpegPath() async {
    final appDir = await getApplicationSupportDirectory();
    final ffmpegPath = '${appDir.path}\\ffmpeg.exe';

    final byteData =
        await rootBundle.load('assets/ffmpeg-plugin/bin/ffmpeg.exe');
    final buffer = byteData.buffer.asUint8List();
    final file = File(ffmpegPath);

    if (!file.existsSync()) {
      await file.writeAsBytes(buffer, flush: true);
    }

    return ffmpegPath;
  }

  void generatePdf(BuildContext context) {
    int? patientId = int.tryParse(_existPatientIdController.text);
    final dashboardState = context.findAncestorStateOfType<DashboardState>();
    if (dashboardState != null) {
      dashboardState.setState(() {
        dashboardState.selectedIndex = 5; // Index of PDFExampleScreen
        dashboardState.patientId = patientId!;
      });
    }
  }

  void resetNewPatientForm() {
    _patientIdController.clear();
    _patientNameController.clear();
    _genderController.clear();
    _dobController.clear();
    _phoneController.clear();
    _addressController.clear();
    _appointmentDateController.clear();
  }

  void _updateCameraSettings(String dd, double value) {}
  void resetExistingPatientForm() {
    _existPatientIdController.clear();
    _existPatientNameController.clear();
    _existGenderController.clear();
    _existDobController.clear();
    _existPhoneController.clear();
    _existAddressController.clear();
    _existAppointmentDateController.clear();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _listCameras() async {
    try {
      List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();
      for (var device in devices) {
        if (device.kind == 'videoinput') {
          setState(() {
            cameraName = device.label;
          });
          print("Camera Found: ${device.label} (ID: ${device.deviceId})");
          print("camera name:  $cameraName");
        }
      }
    } catch (e) {
      print("Error listing cameras: $e");
    }
  }

  void showErrorNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void showSuccessNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF005A96),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(66, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _loadPatientDate(BuildContext context) async {
    final patientPersist = await patientrepository.getPatientDetailByFeildName(
      'patients',
      'phone',
      _existPatientIdController.text.toString(),
    );

    final patientExists = await patientrepository.getPatientDetailByFeildName(
      'patients',
      'patientId',
      _existPatientIdController.text,
    );

    if (patientExists != null) {
      setState(() async {
        loadPatientImages(patientExists.patientId!);
        loadPatientVideos(patientExists.patientId!);
        _existPatientIdController.text = patientExists.patientId.toString();
        _existPatientNameController.text = patientExists.patientName;
        _existGenderController.text = patientExists.gender;
        _existPhoneController.text = patientExists.phone;
        _existAddressController.text = patientExists.address;
        _existDobController.text = patientExists.dateOfBirth;
      });
    } else if (patientPersist != null) {
      setState(() {
        loadPatientImages(patientPersist.patientId!);
        loadPatientVideos(patientPersist.patientId!);
        _existPatientIdController.text = patientPersist.patientId.toString();
        _existPatientNameController.text = patientPersist.patientName;
        _existGenderController.text = patientPersist.gender;
        _existPhoneController.text = patientPersist.phone;
        _existAddressController.text = patientPersist.address;
        _existDobController.text = patientPersist.dateOfBirth;
      });
    } else {
      showErrorNotification(context, "Patient not found.");
    }
  }

  void loadPatientImages(int patientId) async {
    List<PatientImages> images =
        await patientimagesrepository.getImagesByPatientId(patientId);

    if (images.isNotEmpty) {
      List<Map<String, dynamic>> newItems = images.map((img) {
        return {
          'type': 'image',
          'data': base64Decode(img.imageBase64),
          'datetime': img.createdOn
        };
      }).toList();

      setState(() {
        //imagesBase64List = images.map((i) => i.imageBase64).toList();
        capturedItems = [...capturedItems, ...newItems];
      });
    }
  }

  Future<void> loadPatientVideos(int patientId) async {
    List<PatientVideos> videos =
        await patientVideoRepository.getVideosByPatientId(patientId);

    if (videos.isNotEmpty) {
      List<Map<String, dynamic>> newItems = videos.map((video) {
        return {
          'type': 'video',
          'data': video.videoPath,
          'datetime': video.createdOn
        };
      }).toList();

      setState(() {
        //videoPaths = videos.map((v) => v.videoPath).toList();
        capturedItems = [...capturedItems, ...newItems];
      });
    }
  }

  Future<void> updateExistingPatient(BuildContext context) async {
    try {
      final patient = PatientMaster(
        patientId: int.tryParse(_existPatientIdController.text) ?? 0,
        patientName: _existPatientNameController.text,
        gender: _existGenderController.text,
        dateOfBirth: _existDobController.text,
        phone: _existPhoneController.text,
        address: _existAddressController.text,
      );

      await patientrepository.updatePatient(patient);
      int patientId = int.tryParse(_existPatientIdController.text) ?? 0;

      if (patientId != null) {
        final newApointment = PatientHistory(
          id: null,
          patientId: patientId,
          appointmentDate: _existAppointmentDateController.text,
          createdOn: DateTime.now().toString(),
        );
        int historyId =
            await patientHistoryRepository.insertPatientHistory(newApointment);
        patientimagesrepository
            .insertImageList(mapPatientImages(patientId, historyId));
        patientVideoRepository
            .insertVideoDataList(mapPatientVideos(patientId, historyId));
      }
      showSuccessNotification(context, "Patient updated successfully.");
    } catch (e, stackTrace) {
      debugPrint("Error updating patient: $e\nStackTrace: $stackTrace");
      if (context.mounted) {
        showErrorNotification(context, "Something went wrong.");
      }
    }
  }

  Future<void> savePatient(BuildContext context) async {
    try {
      final patientPersist =
          await patientrepository.getPatientDetailByFeildName(
        'patients',
        'phone',
        _phoneController.text,
      );

      final patient = PatientMaster(
        patientId:
            patientPersist?.patientId ?? null, // ✅ Use null-aware operator
        patientName: _patientNameController.text,
        gender: _genderController.text,
        dateOfBirth: _dobController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );

      if (patientPersist != null) {
        await patientrepository.updatePatient(patient);
        if (context.mounted) {
          showSuccessNotification(context, "Patient updated successfully.");
        }
      } else {
        int id = await patientrepository.insertPatient(patient);
        _savePatientHistory(id);
        if (context.mounted) {
          showSuccessNotification(
              context, "New patient inserted successfully.");
          resetNewPatientForm();
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error saving patient: $e\nStackTrace: $stackTrace");
      if (context.mounted) {
        showErrorNotification(context, "Something went wrong.");
      }
    }
  }

  Future<int> _savePatientHistory(int patientId) async {
    final patientHistory = PatientHistory(
        id: null,
        patientId: patientId,
        appointmentDate: _appointmentDateController.text,
        createdOn: DateTime.now().toString());
    int savedHistoryId =
        await patientHistoryRepository.insertPatientHistory(patientHistory);
    patientimagesrepository
        .insertImageList(mapPatientImages(patientId, savedHistoryId));
    patientVideoRepository
        .insertVideoDataList(mapPatientVideos(patientId, savedHistoryId));
    return savedHistoryId;
  }

  List<PatientImages> mapPatientImages(int patientId, int historyId) {
    List<PatientImages> imageList = [];
    if (imagesBase64List.isNotEmpty) {
      imagesBase64List.forEach((i) {
        imageList.add(PatientImages(
            id: null,
            patientId: patientId,
            historyId: historyId,
            imageBase64: i,
            createdOn: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())));
      });
      return imageList;
    } else {
      return [];
    }
  }

  List<PatientVideos> mapPatientVideos(int patientId, int historyId) {
    List<PatientVideos> videoList = [];
    if (videoPaths.isNotEmpty) {
      videoPaths.forEach((i) {
        videoList.add(PatientVideos(
            id: null,
            patientId: patientId,
            historyId: historyId,
            videoPath: i,
            createdOn: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())));
      });
      return videoList;
    } else {
      return [];
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    try {
      if (_patientNameController.text == "" &&
          _existPatientNameController.text == "") {
        showErrorNotification(
            context, "Please fill patient details to capture image");
      } else {
        RenderRepaintBoundary boundary = _videoKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage();
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          String base64String = base64Encode(byteData.buffer.asUint8List());
          setState(() {
            imagesBase64List.add(base64String);
          });

          setState(() {
            capturedItems.insert(0, {
              'type': 'image',
              'data': byteData.buffer.asUint8List(),
              'datetime': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
            });
          });
        }
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void toggleRecording(BuildContext context) {
    if (isRecording) {
      stopRecording();
    } else {
      startRecording(context);
    }
  }

  Future<void> _initializeCamera() async {
    await _renderer.initialize();
    try {
      List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();
      String? selectedDeviceId;

      for (var device in devices) {
        if (device.kind == 'videoinput') {
          print("Camera Found: ${device.label} (ID: ${device.deviceId})");
          selectedDeviceId ??= device.deviceId; // Select the first camera
        }
      }

      if (selectedDeviceId != null) {
        final mediaStream = await navigator.mediaDevices.getUserMedia({
          'video': {
            'deviceId': selectedDeviceId,
            'width': {'ideal': 3500}, // Set desired width
            'height': {'ideal': 1000}, // Set desired height
            'frameRate': 200,
          },
          'audio': true,
        });

        _renderer.srcObject = mediaStream;
        setState(() {
          _mediaStream = mediaStream;
        });
        print("Camera initialized with device ID: $selectedDeviceId");
        _applyConstraints();
      } else {
        print("No camera found.");
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _updateZoom(double zoom) {
    var _videoTrack = _mediaStream!.getVideoTracks().first;
    setState(() => _zoomLevel = zoom);
    if (_videoTrack != null) {
      _videoTrack!.applyConstraints({
        'advanced': [
          {'zoom': zoom}
        ]
      });
    }
  }

  Future<void> _applyConstraints() async {
    if (_mediaStream == null) return;

    var videoTrack = _mediaStream!.getVideoTracks().first;
    var supportedConstraints = navigator.mediaDevices.getSupportedConstraints();
    print("ddd");

    Map<String, dynamic> constraints = {
      'advanced': [
        {'brightness': _brightness},
        {'contrast': _contrast},
        {'exposureCompensation': _exposure},
      ]
    };

    await videoTrack.applyConstraints(constraints);
  }

  Future<void> stopCamera() async {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => track.stop());
      _renderer.srcObject = null;
      setState(() {
        _mediaStream = null;
      });
      print("Camera preview stopped.");
    }
  }

  Future<void> startRecording(BuildContext context) async {
    try {
      if (_patientNameController.text == "" &&
          _existPatientNameController.text == "") {
        showErrorNotification(
            context, "Please fill patient details to record videos");
      } else {
        String patientName;
        final dir = await getApplicationDocumentsDirectory();
        String randomString = Uuid().v4();

// Ensure patientName is assigned correctly
        if (_patientNameController.text.trim().isNotEmpty) {
          patientName = _patientNameController.text.trim();
        } else if (_existPatientNameController.text.trim().isNotEmpty) {
          patientName = _existPatientNameController.text.trim();
        } else {
          patientName = randomString;
        }

        String patientDir = '${dir.path}\\DrCam_Videos\\$patientName';
        Directory patientDirectory = Directory(patientDir);

        if (!patientDirectory.existsSync()) {
          patientDirectory.createSync(recursive: true);
        }

        if (_mediaStream != null) {
          print("Stopping camera preview before recording...");
          stopCamera();
        }

        this.setState(() {
          outputMp4Path = '${patientDirectory.path}\\$randomString.mp4';
        });

        String ffmpegPath = await getFFmpegPath();

        // String videoDeviceName = "HP TrueVision HD Camera";
        String? videoDeviceName = cameraName;

        //To record desktop
        //  List<String> command = [
        //   '-f', 'gdigrab', // Capture screen
        //   '-framerate', '30',
        //   '-i', 'desktop',
        //   '-c:v', 'libx264',
        //   '-preset', 'ultrafast',
        //   '-tune', 'zerolatency',
        //   videoFilePath!,
        // ];

        //Mkv format
        // List<String> command = [
        //   '-f',
        //   'dshow',
        //   '-rtbufsize',
        //   '100M',
        //   '-pixel_format',
        //   'yuyv422',
        //   '-i',
        //   'video=$videoDeviceName',
        //   '-c:v',
        //   'libx264',
        //   '-preset',
        //   'ultrafast',
        //   videoFilePath!,
        // ];

        //MP4 format
        List<String> command = [
          '-f',
          'dshow',
          '-i',
          'video=$videoDeviceName',
          '-c:v',
          'libx264',
          '-preset',
          'fast',
          '-crf',
          '23',
          '-pix_fmt',
          'yuv420p',
          '-movflags',
          '+faststart',
          '-y',
          outputMp4Path!,
        ];

        _ffmpegProcess =
            await Process.start(ffmpegPath, command, runInShell: true);

        setState(() {
          isRecording = true;
        });

        _ffmpegProcess!.stdout.transform(const Utf8Decoder()).listen((data) {
          print("FFmpeg Output: $data");
        });

        _ffmpegProcess!.stderr.transform(const Utf8Decoder()).listen((data) {
          print("FFmpeg Error: $data");
        });
      }
    } catch (e, stackTrace) {
      print("Exception while starting recording: $e");
      print("StackTrace: $stackTrace");
    }
  }

  void _playVideo(BuildContext context, String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: videoPath),
      ),
    );
  }

  Future<void> stopRecording() async {
    if (_ffmpegProcess == null) return;

    print("Stopping recording...");

    // Send 'q' to FFmpeg for a graceful shutdown
    _ffmpegProcess!.stdin.writeln('q');
    await _ffmpegProcess!.exitCode; // Wait for FFmpeg to fully exit

    setState(() {
      isRecording = false;
    });

    setState(() {
      capturedItems.add({
        'type': 'video',
        'data': outputMp4Path, // Store video file path
        'datetime': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      });
      videoPaths.add(outputMp4Path!);
    });

    _initializeCamera();
    print("Recording stopped. File saved at: $outputMp4Path");
  }

  @override
  void dispose() {
    _renderer.dispose();
    _tabController.dispose();
    _mediaStream?.getTracks().forEach((track) => track.stop());
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
    body: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height, // Ensures scrolling
        ),
        child: Column(
          children: [
            Container(
              height: 650,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            Tab(text: 'New Patient'),
                            Tab(text: 'Existing Patient'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20, top: 0, bottom: 100),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _patientNameController,
                                          decoration: InputDecoration(
                                              labelText: 'Patient Name',
                                              border: OutlineInputBorder()),
                                          validator: (value) => value!.isEmpty
                                              ? 'Please enter patient name'
                                              : null,
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _genderController,
                                          decoration: InputDecoration(
                                              labelText: 'Gender',
                                              border: OutlineInputBorder()),
                                          validator: (value) => value!.isEmpty
                                              ? 'Please enter gender'
                                              : null,
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _dobController,
                                          decoration: InputDecoration(
                                            labelText: 'Date Of Birth',
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.calendar_today),
                                          ),
                                          validator: (value) => value!.isEmpty
                                              ? 'Please select dob'
                                              : null,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1950),
                                              lastDate: DateTime(2100),
                                            );

                                            if (pickedDate != null) {
                                              String formattedDate = DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                              _dobController.text = formattedDate;
                                            }
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _phoneController,
                                          decoration: InputDecoration(
                                              labelText: 'Phone No.',
                                              border: OutlineInputBorder()),
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _addressController,
                                          decoration: InputDecoration(
                                              labelText: 'Address',
                                              border: OutlineInputBorder()),
                                          validator: (value) => value!.isEmpty
                                              ? 'Please select address'
                                              : null,
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller: _appointmentDateController,
                                          decoration: InputDecoration(
                                            labelText: 'Appointment Date',
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.calendar_today),
                                          ),
                                          validator: (value) => value!.isEmpty
                                              ? 'Please select appointment date'
                                              : null,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1950),
                                              lastDate: DateTime(2100),
                                            );

                                            if (pickedDate != null) {
                                              String formattedDate = DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                              _appointmentDateController.text = formattedDate;
                                            }
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              savePatient(context);
                                            }
                                          },
                                          child: Text('Save'),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                            backgroundColor: Colors.teal,
                                            foregroundColor: const ui.Color.fromARGB(255, 6, 4, 4),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Form(
                                    key: _updateFormKey,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),
                                          TextFormField(
                                            controller: _existPatientIdController,
                                            decoration: InputDecoration(
                                              labelText: 'Search By PatientId or Phone',
                                              border: OutlineInputBorder(),
                                              suffixIcon: IconButton(
                                                icon: Icon(Icons.search),
                                                onPressed: () {
                                                  _loadPatientDate(context);
                                                },
                                              ),
                                            ),
                                            validator: (value) => value!.isEmpty
                                                ? 'Please enter patient ID'
                                                : null,
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existPatientNameController,
                                            decoration: InputDecoration(
                                                labelText: 'Patient Name',
                                                border: OutlineInputBorder()),
                                            validator: (value) => value!.isEmpty
                                                ? 'Please enter patient name'
                                                : null,
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existGenderController,
                                            decoration: InputDecoration(
                                                labelText: 'Gender',
                                                border: OutlineInputBorder()),
                                            validator: (value) =>
                                                value!.isEmpty
                                                    ? 'Please enter gender'
                                                    : null,
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existDobController,
                                            decoration: InputDecoration(
                                              labelText: 'Date Of Birth',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            validator: (value) =>
                                                value!.isEmpty
                                                    ? 'Please enter dob'
                                                    : null,
                                            readOnly: true,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1950),
                                                lastDate: DateTime(2100),
                                              );

                                              if (pickedDate != null) {
                                                String formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(pickedDate);
                                                _existDobController.text =
                                                    formattedDate;
                                              }
                                            },
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existPhoneController,
                                            decoration: InputDecoration(
                                                labelText: 'Phone No.',
                                                border: OutlineInputBorder()),
                                            validator: (value) =>
                                                value!.isEmpty
                                                    ? 'Please enter phone no'
                                                    : null,
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existAddressController,
                                            decoration: InputDecoration(
                                                labelText: 'Address',
                                                border: OutlineInputBorder()),
                                            validator: (value) =>
                                                value!.isEmpty
                                                    ? 'Please enter address'
                                                    : null,
                                          ),
                                          SizedBox(height: 8),
                                          TextFormField(
                                            controller: _existAppointmentDateController,
                                            decoration: InputDecoration(
                                              labelText: 'Appointment Date',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            validator: (value) => value!.isEmpty
                                                ? 'Please enter appointment date'
                                                : null,
                                            readOnly: true,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1950),
                                                lastDate: DateTime(2100),
                                              );

                                              if (pickedDate != null) {
                                                String formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(pickedDate);
                                                _existAppointmentDateController.text =
                                                    formattedDate;
                                              }
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_updateFormKey.currentState!.validate()) {
                                                updateExistingPatient(context);
                                              }
                                            },
                                            child: Text('Update'),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                              backgroundColor: Colors.teal,
                                              foregroundColor: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Camera Preview & Controls
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Text(
                                'Camera',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Camera Preview
                                    RepaintBoundary(
                                      key: _videoKey,
                                      child: Container(
                                        width: 760,
                                        height: 430,
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
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),

                              // Capture & Record Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _captureImage(context),
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                    label: Text('Capture'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (isRecording) {
                                        stopRecording();
                                      } else {
                                        startRecording(context);
                                      }
                                    },
                                    icon: Icon(
                                        color: Colors.white,
                                        isRecording
                                            ? Icons.stop
                                            : Icons.videocam),
                                    label: Text(
                                        isRecording ? 'Stop' : 'Record'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isRecording
                                          ? Colors.red
                                          : Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ), // End of Buttons Row
                            ],
                          ),
                        ), // End of Camera Column

                        SizedBox(width: 10, height: 50),
                        // Spacing between video and mini box
                        Padding(
                          padding: EdgeInsets.only(top: 55, right: 5),
                          // Right Side: Mini Box with Sliders
                          child: Container(
                            width: 200,
                            height: 430, // Mini box width
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26, blurRadius: 5),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),

                                // Brightness Slider
                                Text("Brightness"),
                                Slider(
                                  value: _brightness,
                                  min: 0.0,
                                  max: 2.0,
                                  divisions: 10,
                                  activeColor: Colors.teal,
                                  label: _brightness.toStringAsFixed(1),
                                  onChanged: (double value) =>
                                      _updateCameraSettings("brightness", value),
                                ),

                                // Contrast Slider
                                Text("Contrast"),
                                Slider(
                                  value: _contrast,
                                  min: 0.5,
                                  max: 2.0,
                                  divisions: 10,
                                  label: _contrast.toStringAsFixed(1),
                                  activeColor: Colors.teal,
                                  onChanged: (double value) =>
                                      _updateCameraSettings("contrast", value),
                                ),

                                // Saturation Slider
                                Text("Saturation"),
                                Slider(
                                  value: _saturation,
                                  min: 0.5,
                                  max: 2.0,
                                  divisions: 10,
                                  label: _saturation.toStringAsFixed(1),
                                  activeColor: Colors.teal,
                                  onChanged: (double value) =>
                                      _updateCameraSettings("saturation", value),
                                ),
                                Text("Zoom"),
                                Slider(
                                  value: _zoomLevel,
                                  min: 1.0,
                                  max: 5.0, // Adjust max zoom as per camera capability
                                  divisions: 10,
                                  activeColor: Colors.teal,
                                  label: _zoomLevel.toStringAsFixed(1),
                                  onChanged: (double value) =>
                                      _updateZoom(value),
                                )
                              ],
                            ),
                          ), // End of Mini Box
                        )
                      ],
                    ),
                  ), // End of Expanded Row
                ],
              ),
            ),
            // Flex 3 positioned below both Flex 1 and Flex 2
            SizedBox(height: 30),
            Container(
              height: 300, // Adjust for scroll effect
              padding: EdgeInsets.only(top: 16, left: 30, right: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Grid item width
                  childAspectRatio: 1, // Aspect ratio
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                ),
                itemCount: capturedItems.length,
                itemBuilder: (context, index) {
                  final item = capturedItems[index];

                  return SizedBox(
                    // Prevent overflow
                    height: 180, // Consistent height
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display Date
                        Text(
                          "Date: ${item['datetime'] ?? ''}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5), // Reduce spacing
                        Expanded(
                          // Allow flexible space for content
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            child: item['type'] == 'image'
                                ? ClipRRect(
                                    // Rounded corners for images
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.memory(
                                      item['data'], // Image data from memory
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : item['type'] == 'video'
                                    ? GestureDetector(
                                        onTap: () {
                                          _playVideo(context, item['data']);
                                        },
                                        child: Stack(
                                          children: [
                                            // 📌 Top-left video icon
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Icon(Icons.videocam,
                                                  size: 24,
                                                  color: Colors.black54),
                                            ),
                                            // 📌 Center play button
                                            Center(
                                              child: Icon(
                                                  Icons.play_circle_fill,
                                                  size: 40,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Center(
                                        child: Icon(Icons.videocam)), // Default if type is unknown
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 1),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.only(right: 50, bottom: 80),
                    child: ElevatedButton(
                      onPressed: () {
                        generatePdf(context);
                      },
                      child: Text('Generate Pdf'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ) // Space between GridView and Button
                    ))
          ],
        ),
      ),
    ));
}
}

