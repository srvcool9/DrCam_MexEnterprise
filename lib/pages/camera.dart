import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:doctorcam/models/patient_history.dart';
import 'package:doctorcam/models/patient_images.dart';
import 'package:doctorcam/models/patient_master.dart';
import 'package:doctorcam/repository/PatientHistoryRepository.dart';
import 'package:doctorcam/repository/PatientImagesRepository.dart';
import 'package:doctorcam/repository/PatientRepository.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Required for file handling
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

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
  List<String> imagesBase64List = []; // FlutterFFmpeg instance
  String? videoFilePath; // Path to save the video4
  MediaRecorder? _mediaRecorder; // Define MediaRecorder instance
  Uint8List? _recordedData;

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
    patientimagesrepository = Patientimagesrepository();

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
      setState(() async {
        loadPatientImages(patientExists.patientId!);
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
    List<String> images =
        await patientimagesrepository.getImagesByPatientId(patientId);

    if (images.isNotEmpty) {
      List<Map<String, dynamic>> newItems = images.map((img) {
        return {
          'type': 'image',
          'data': base64Decode(img),
          'datetime': DateFormat('dd-MM-yyyy').format(DateTime.now())
        };
      }).toList();

      setState(() {
        imagesBase64List.addAll(images);
        capturedItems = [...newItems];
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

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary =
          _videoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
            'datetime': DateTime.now(),
          });
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void toggleRecording() {
    if (isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  // Simulate video recording by saving the stream using flutter_ffmpeg

  Future<void> _startRecording() async {
    if (_mediaStream != null) {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory(join(appDocumentsDir.path, 'videos'));
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }
      videoFilePath = join(
          videoDir.path, 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');

      File videoFile = File(videoFilePath!);
      if (videoFile.existsSync()) {
        print("Warning: File already exists, overwriting...");
      }

      // FFmpeg command to record video from screen capture
      String command =
          '-y -f gdigrab -framerate 30 -i desktop -c:v libx264 -pix_fmt yuv420p $videoFilePath';

      await FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          print("Recording saved to $videoFilePath");
        } else {
          print("Recording failed!");
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    await FFmpegKit.cancel(); // Stops the FFmpeg process
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
              minHeight:
                  MediaQuery.of(context).size.height, // Ensures scrolling
            ),
            child: Column(
              children: [
                Container(
                    height: 550,
                    child: Row(children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Aligns form fields to left
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
                            SizedBox(height: 16),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(left: 20, top: 10),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Aligns form fields to left
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        readOnly:
                                            true, // Prevent manual text input
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (pickedDate != null) {
                                            // Check if a date was selected
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd').format(
                                                    pickedDate); // Format date
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
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        readOnly:
                                            true, // Prevent manual text input
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (pickedDate != null) {
                                            // Check if a date was selected
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd').format(
                                                    pickedDate); // Format date
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _existPatientIdController,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Serach By PaitentId or Phone',
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
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        readOnly:
                                            true, // Prevent manual text input
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (pickedDate != null) {
                                            // Check if a date was selected
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd').format(
                                                    pickedDate); // Format date
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
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        readOnly:
                                            true, // Prevent manual text input
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (pickedDate != null) {
                                            // Check if a date was selected
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd').format(
                                                    pickedDate); // Format date
                                            _existAppointmentDateController
                                                    .text =
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
                            )),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              'Camera',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: RepaintBoundary(
                                key: _videoKey,
                                child: Container(
                                  width: 900,
                                  height: 900,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _renderer.textureId != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: RTCVideoView(_renderer),
                                        )
                                      : Center(
                                          child: CircularProgressIndicator()),
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
                                  onPressed: toggleRecording,
                                  icon: Icon(isRecording
                                      ? Icons.stop
                                      : Icons.videocam),
                                  label: Text(isRecording ? 'Stop' : 'Record'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ])),
                // Flex 3 positioned below both Flex 1 and Flex 2
                SizedBox(height: 30),
                Container(
                  height: 300, // Adjust to make scroll effect more visible
                  child: Container(
                    height: 200, // Adjust height as needed
                    padding: EdgeInsets.only(top: 16, left: 30, right: 10),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            200, // Maximum width of each grid item
                        childAspectRatio:
                            1, // Adjust height-to-width ratio as needed
                        crossAxisSpacing:
                            30, // Spacing between items horizontally
                        mainAxisSpacing: 20, // Spacing between items vertically
                      ),
                      itemCount: capturedItems.length,
                      itemBuilder: (context, index) {
                        final item = capturedItems[index];
                        return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['datetime'] ??
                                    '', // Display title above the card
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  // border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: 0.1), // Light shadow for depth
                                      blurRadius: 5, // Blur effect
                                      offset: Offset(2, 4), // Shadow direction
                                    ),
                                  ],
                                ),
                                child: item['type'] == 'image'
                                    ? Image.memory(
                                        item['data'],
                                        fit: BoxFit.cover,
                                      )
                                    // : item['type'] == 'video'
                                    //     ? VideoPlayerWidget(
                                    //         videoPath: item[
                                    //             'data']) // Display video using video_player
                                    : item['type'] == 'loading'
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Center(child: Icon(Icons.videocam)),
                              )
                            ]);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: EdgeInsets.only(right: 40),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Generate Pdf'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoPath;

//   const VideoPlayerWidget({required this.videoPath});

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   VideoPlayerController? _controller; // ✅ Use nullable controller

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() async {
//     if (widget.videoPath.isNotEmpty && File(widget.videoPath).existsSync()) {
//       _controller = VideoPlayerController.file(File(widget.videoPath))
//         ..initialize().then((_) {
//           if (mounted) {
//             setState(() {});
//             _controller!.play(); // Auto-play
//           }
//         }).catchError((error) {
//           debugPrint("Error initializing video: $error");
//         });
//     } else {
//       debugPrint("Invalid video path: ${widget.videoPath}");
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose(); // ✅ Null check before disposal
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _controller != null && _controller!.value.isInitialized
//         ? AspectRatio(
//             aspectRatio: _controller!.value.aspectRatio,
//             child: VideoPlayer(_controller!),
//           )
//         : Center(child: CircularProgressIndicator());
//   }
// }
