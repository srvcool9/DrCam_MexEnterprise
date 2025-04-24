import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImagePreviewPage extends StatefulWidget {
  final Uint8List imageData;
  final void Function(Uint8List editedImage) onSave;

  const ImagePreviewPage({
    super.key,
    required this.imageData,
    required this.onSave,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  List<DrawnLine> _lines = [];
  DrawnLine? _currentLine;
  Color _selectedColor = Colors.red;
  double _strokeWidth = 4.0;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.memory(
                    widget.imageData,
                    fit: BoxFit.contain,
                  ),
                ),

                // Drawing Area
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset point = box.globalToLocal(details.globalPosition);
                      _currentLine =
                          DrawnLine([point], _selectedColor, _strokeWidth);
                    },
                    onPanUpdate: (details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset point = box.globalToLocal(details.globalPosition);
                      setState(() {
                        _currentLine?.points.add(point);
                      });
                    },
                    onPanEnd: (_) {
                      setState(() {
                        if (_currentLine != null) {
                          _lines.add(_currentLine!);
                        }
                        _currentLine = null;
                      });
                    },
                    child: CustomPaint(
                      painter: DrawingPainter(_lines, _currentLine),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Color & Undo Controls (Left-Aligned Vertical)
          Positioned(
            top: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorButton(Colors.red),
                const SizedBox(height: 12),
                _buildColorButton(Colors.green),
                const SizedBox(height: 12),
                _buildColorButton(Colors.blue),
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {
                    setState(() {
                      if (_lines.isNotEmpty) _lines.removeLast();
                    });
                  },
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.black),
                  tooltip: "Save Image",
                  onPressed: _saveEditedImage,
                ),
              ],
            ),
          ),
        ],
      ),

      // Save Button
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(Icons.edit, color: color),
      ),
    );
  }

  Future<void> _saveEditedImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final editedBytes = byteData.buffer.asUint8List();
        widget.onSave(editedBytes); // Return edited image
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving image: $e");
    }
  }
}

// Data model
class DrawnLine {
  List<Offset> points;
  Color color;
  double strokeWidth;

  DrawnLine(this.points, this.color, this.strokeWidth);
}

// Custom Painter
class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter(this.lines, this.currentLine);

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in [...lines, if (currentLine != null) currentLine!]) {
      Paint paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
