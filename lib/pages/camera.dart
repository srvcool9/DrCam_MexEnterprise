import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:doctorcam/models/patient_history.dart';
import 'package:doctorcam/models/patient_master.dart';
import 'package:doctorcam/repository/PatientHistoryRepository.dart';
import 'package:doctorcam/repository/PatientRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Required for file handling
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
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
  late FlutterFFmpeg _flutterFFmpeg; // FlutterFFmpeg instance
  String? videoFilePath; // Path to save the video

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

  @override
  void initState() {
    super.initState();
    patientrepository = Patientrepository();
    patientHistoryRepository = Patienthistoryrepository();
    _flutterFFmpeg = FlutterFFmpeg();
    _tabController = TabController(length: 2, vsync: this);

    _requestPermissions().then((_) {
      _listCameras();
      _initializeCamera();
    });
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
          print("Camera Found: ${device.label} (ID: ${device.deviceId})");
        }
      }
    } catch (e) {
      print("Error listing cameras: $e");
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
          },
          'audio': true,
        });

        _renderer.srcObject = mediaStream;
        setState(() {
          _mediaStream = mediaStream;
        });
        print("Camera initialized with device ID: $selectedDeviceId");
      } else {
        print("No camera found.");
      }
    } catch (e) {
      print('Error initializing camera: $e');
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
      setState(() {
        _existPatientIdController.text = patientExists.patientId.toString();
        _existPatientNameController.text = patientExists.patientName;
        _existGenderController.text = patientExists.gender;
        _existPhoneController.text = patientExists.phone;
        _existAddressController.text = patientExists.address;
        _existDobController.text = patientExists.dateOfBirth;
      });
    } else if (patientPersist != null) {
      setState(() {
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

      int patientId = await patientrepository.updatePatient(patient);
      if (patientId != null) {
        final newApointment = PatientHistory(
          id: null,
          patientId: patientId,
          appointmentDate: _existAppointmentDateController.text,
          createdOn: DateTime.now().toString(),
        );
        patientHistoryRepository.insertPatientHistory(newApointment);
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
    return await patientHistoryRepository.insertPatientHistory(patientHistory);
  }

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary =
          _videoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
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
      videoFilePath = join(
          videoDir.path, 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');

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
    await Future.delayed(
        Duration(seconds: 1)); // Simulate delay in stopping the recording

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

    if (_videoPlayerController != null &&
        _videoPlayerController.value.isInitialized) {
      _videoPlayerController.dispose();
    }

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
                      Tab(text: 'New Patient'),
                      Tab(text: 'Existing Patient'),
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
                            TextFormField(
                              controller: _patientIdController,
                              decoration: InputDecoration(
                                  labelText: 'Patient Id',
                                  border: OutlineInputBorder()),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter patient ID'
                                  : null,
                            ),
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
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller:
                                  _dobController, // Ensure this controller is declared
                              decoration: InputDecoration(
                                labelText: 'Date Of Birth',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true, // Prevent manual text input
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Check if a date was selected
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate); // Format date
                                  _dobController.text =
                                      formattedDate; // Update the controller
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
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller:
                                  _appointmentDateController, // Ensure this controller is declared
                              decoration: InputDecoration(
                                labelText: 'Apointment Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true, // Prevent manual text input
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Check if a date was selected
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate); // Format date
                                  _appointmentDateController.text =
                                      formattedDate; // Update the controller
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                savePatient(context);
                              },
                              child: Text('Save'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _existPatientIdController,
                              decoration: InputDecoration(
                                labelText: 'Serach By PaitentId or Phone',
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
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller:
                                  _existDobController, // Ensure this controller is declared
                              decoration: InputDecoration(
                                labelText: 'Date Of Birth',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true, // Prevent manual text input
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Check if a date was selected
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate); // Format date
                                  _existDobController.text =
                                      formattedDate; // Update the controller
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _existPhoneController,
                              decoration: InputDecoration(
                                  labelText: 'Phone No.',
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _existAddressController,
                              decoration: InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller:
                                  _existAppointmentDateController, // Ensure this controller is declared
                              decoration: InputDecoration(
                                labelText: 'Apointment Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true, // Prevent manual text input
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Check if a date was selected
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate); // Format date
                                  _existAppointmentDateController.text =
                                      formattedDate; // Update the controller
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                updateExistingPatient(context);
                              },
                              child: Text('Update'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: Icon(isRecording ? Icons.stop : Icons.videocam),
                        label: Text(isRecording ? 'Stop' : 'Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 205, // Adjust height as needed
                    padding: EdgeInsets.only(top: 16),
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
                                  ? VideoPlayerWidget(
                                      videoPath: item[
                                          'data']) // Display video using video_player
                                  : item['type'] == 'loading'
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : Center(child: Icon(Icons.videocam)),
                        );
                      },
                    ),
                  )
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
  VideoPlayerController? _controller; // ✅ Use nullable controller

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    if (widget.videoPath.isNotEmpty && File(widget.videoPath).existsSync()) {
      _controller = VideoPlayerController.file(File(widget.videoPath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller!.play(); // Auto-play
          }
        }).catchError((error) {
          debugPrint("Error initializing video: $error");
        });
    } else {
      debugPrint("Invalid video path: ${widget.videoPath}");
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // ✅ Null check before disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null && _controller!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        : Center(child: CircularProgressIndicator());
  }
}
