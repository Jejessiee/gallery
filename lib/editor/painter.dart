import 'package:flutter/material.dart';
import 'models.dart';

class AnnotationPainter extends CustomPainter {
  final List<AnnotationStroke> strokes;

  AnnotationPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint = Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != Offset.zero && stroke.points[i + 1] != Offset.zero) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) => oldDelegate.strokes != strokes;
}