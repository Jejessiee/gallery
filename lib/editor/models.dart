import 'package:flutter/material.dart';
import 'dart:ui';

enum DrawMode {view, marker, freehand, erase}

class AnnotationStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  AnnotationStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}