import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:doctorcam/models/patient_images.dart';
import 'package:doctorcam/pages/dashboard.dart';
import 'package:doctorcam/repository/PatientImagesRepository.dart';
import 'package:doctorcam/repository/PatientRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart'; // For file picking

class PDFExampleScreen extends StatefulWidget {
  const PDFExampleScreen({super.key});

  @override
  State<PDFExampleScreen> createState() => _PDFExampleScreenState();
}

class _PDFExampleScreenState extends State<PDFExampleScreen> {
  int? patientId;
  String? agencyName;
  List<Map<String, dynamic>> capturedItems = [];
  final TextEditingController _imageCountController = TextEditingController();
  late Patientrepository patientrepository;
  late Patientimagesrepository patientImagesRepository;
  List<String> imagesBase64List = [];
  Set<int> selectedIndices = {};
    List<PatientImages> images =[];

  @override
  void initState() {
    super.initState();
    patientrepository = Patientrepository();
    patientImagesRepository = Patientimagesrepository();
    final dashboardState = context.findAncestorStateOfType<DashboardState>();
    setState(() {
      patientId = dashboardState?.patientId!;
      agencyName = dashboardState?.agencyName!;
    });
    loadPatientImages(patientId!);
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
      imagesBase64List= selectedIndices.map((i)=> images[i].imageBase64).toList();
      _imageCountController.text= imagesBase64List.length.toString();
    
    });
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

  void loadPatientImages(int patientId) async {
   images =
        await patientImagesRepository.getImagesByPatientId(patientId);

    if (images.isNotEmpty) {
      List<Map<String, dynamic>> newItems = images.map((img) {
        return {
          'type': 'image',
          'data': base64Decode(img.imageBase64),
          'datetime': img.createdOn
        };
      }).toList();

      setState(() {
        imagesBase64List= selectedIndices.map((i)=> images[i].imageBase64).toList();
       // imagesBase64List = images.map((i) => i.imageBase64).toList();
        capturedItems = [...newItems];
        _imageCountController.text= imagesBase64List.length.toString();
      });
    }
  }

  Future<void> _createAndSavePdf() async {
    List<Uint8List> images = [];
    // Create a PDF document
    final pdf = pw.Document();

    // Load an image from assets
    Uint8List? imageBytes;
    try {
      if (imagesBase64List.isNotEmpty) {
        imagesBase64List.forEach((i) {images.add(base64Decode(i));});
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
     // Fallback to null if image loading fails
    }

    // Add content to the PDF
     for (Uint8List imageBytes in images) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                agencyName!,
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal),
              ),
              pw.SizedBox(height: 20),
              pw.Text('This is an example of adding text to a PDF.'),
              pw.SizedBox(height: 20),
              pw.Text('Below is an image loaded from assets:'),
              pw.SizedBox(height: 10),
              if (imageBytes != null)
                pw.Image(
                  pw.MemoryImage(imageBytes),
                  width: 200,
                  height: 200,
                )
              else
                pw.Text('Image not found.'),
            ],
          );
        },
      ),
    );
     }
    // Prompt the user to select a save location
    String? savePath;
    try {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF to',
        fileName: 'images.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } catch (e) {
      debugPrint('Error opening file picker: $e');
    }

    if (savePath != null) {
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
      showSuccessNotification(context, "Pdf downloaded successfully");
    } else {
      showErrorNotification(context, "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate PDF')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20), // Add consistent horizontal padding
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 25, width: 30),
                    Padding(
                        padding: EdgeInsets.only(right: 80, bottom: 15),
                        child: Text(
                          "Image count",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        )),
                    SizedBox(
                      width: 250,
                      height: 30,
                      child: TextField(
                        controller: _imageCountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // GridView wrapped inside a flexible container
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 500),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: capturedItems.length,
                    itemBuilder: (context, index) {
                      final item = capturedItems[index];
                      final isSelected = selectedIndices.contains(index);

                      return GestureDetector(
                        onTap: () => toggleSelection(index),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color.fromARGB(255, 69, 75, 71)
                                      : Colors.grey, // Green if selected
                                  width: isSelected
                                      ? 5
                                      : 2, // Thick border if selected
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: item['type'] == 'image'
                                    ? Image.memory(
                                        item['data'],
                                        fit: BoxFit.cover,
                                      )
                                    : item['type'] == 'loading'
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Center(child: Icon(Icons.videocam)),
                              ),
                            ),

                            // Always show a checkmark, but make it visible when selected
                            Positioned.fill(
                              left: 240,
                              bottom: 240,
                              child: Icon(
                                Icons.check_circle,
                                color: isSelected
                                    ? Colors.white
                                    : const Color.fromARGB(255, 105, 102, 102)
                                        .withOpacity(0.5),
                                size: 20, // Large checkmark
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: EdgeInsets.only(right: 50, bottom: 80),
                      child: ElevatedButton(
                        onPressed: () {
                          _createAndSavePdf();
                        },
                        child: Text('Download Pdf'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ) // Space between GridView and Button
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
