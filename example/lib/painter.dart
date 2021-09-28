import 'dart:ui';

import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  Painter({
    required this.color,
  }) {
    wavePainter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    fillPainter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  final Color color;

  late Paint wavePainter;
  late Paint fillPainter;

  static const double anchorRadius = 5;

  double? minWaveHeight;
  late double maxWaveHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final Size restrictedSize = Size(size.width - anchorRadius, size.height);
    // _paintAnchors(canvas, restrictedSize);

    final Path path = Path();

    path.moveTo(0, 50);
    path.lineTo(50, 50);

    path.cubicTo(50, 50, 130, 20, 100, 25);
    path.moveTo(150, 50);
    path.lineTo(400, 50);
    //path.c

    canvas.drawPath(path, wavePainter);
  }

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(anchorRadius, size.height), anchorRadius, fillPainter);
    canvas.drawCircle(
        Offset(size.width, size.height), anchorRadius, fillPainter);
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return true;
  }
}
