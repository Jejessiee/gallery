import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';
import 'painter.dart';
import 'toolbar.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final GlobalKey _repaintKey = GlobalKey();
  List<AnnotationStroke> strokes = [];
  List<Offset> currentPoints = [];
  DrawMode mode = DrawMode.view;
  Color color = Colors.red;
  double strokeWidth = 3.0;
  XFile? image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  Future<void> _saveImage() async {
    // Ambil widget boundary
    final boundary =
    _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // Render ke gambar PNG
    final ui.Image img = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Simpan sementara ke file
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    // Simpan ke galeri (menggunakan saveFile!)
    final result = await ImageGallerySaver.saveFile(file.path);
    debugPrint('Save result: $result');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to Gallery!')),
    );
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (mode == DrawMode.view) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);

    setState(() {
      if (mode == DrawMode.erase) {
        // hapus garis yang dekat posisi
        strokes.removeWhere(
              (s) =>
              s.points.any((p) => (p - localPos).distance < strokeWidth * 2),
        );
      } else {
        currentPoints.add(localPos);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (mode == DrawMode.view || mode == DrawMode.erase) return;
    setState(() {
      strokes.add(
        AnnotationStroke(
          points: List.from(currentPoints),
          color: color,
          strokeWidth: strokeWidth,
        ),
      );
      currentPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Zoom & Annotate'),
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo),
          ),
          IconButton(
            onPressed: _saveImage,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanUpdate: (d) => _onPanUpdate(d, constraints),
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        if (image != null)
                          InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 5.0,
                            child: Image.file(
                              File(image!.path),
                              fit: BoxFit.contain,
                              width: constraints.maxWidth,
                            ),
                          )
                        else
                          const Center(
                            child: Text('Tap photo icon to pick an image'),
                          ),
                        CustomPaint(
                          size: Size.infinite,
                          painter: AnnotationPainter(
                            strokes: [
                              ...strokes,
                              if (currentPoints.isNotEmpty)
                                AnnotationStroke(
                                  points: currentPoints,
                                  color: color,
                                  strokeWidth: strokeWidth,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          EditorToolbar(
            mode: mode,
            color: color,
            strokeWidth: strokeWidth,
            onModeChanged: (m) => setState(() => mode = m),
            onColorChanged: (c) => setState(() => color = c),
            onStrokeWidthChanged: (w) => setState(() => strokeWidth = w),
          ),
        ],
      ),
    );
  }
}
