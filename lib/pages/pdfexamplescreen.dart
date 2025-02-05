import 'dart:io';
import 'dart:typed_data';
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
  Future<void> _createAndSavePdf() async {
    // Create a PDF document
    final pdf = pw.Document();

    // Load an image from assets
    Uint8List? imageBytes;
    try {
      final ByteData imageData = await rootBundle.load('assets/logo.png');
      imageBytes = imageData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading image: $e');
      imageBytes = null; // Fallback to null if image loading fails
    }

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PDF with Images and Content',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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

    // Prompt the user to select a save location
    String? savePath;
    try {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF to',
        fileName: 'example.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } catch (e) {
      debugPrint('Error opening file picker: $e');
    }

    if (savePath != null) {
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $savePath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save operation canceled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _createAndSavePdf,
          child: const Text('Generate and Save PDF'),
        ),
      ),
    );
  }
}
