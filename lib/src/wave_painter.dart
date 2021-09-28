import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.color,
  }) {
    wavePainter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    wavePainterGradient = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    fillPainter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  final double sliderPosition;
  final double dragPercentage;

  final Color color;

  late Paint wavePainter;
  late Paint fillPainter;
  late Paint wavePainterGradient;

  /// Previous slider position initialised at the [anchorRadius], which is the start
  double _previousSliderPosition = anchorRadius;

  static const double anchorRadius = 5;

  double? minWaveHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final Size restrictedSize = Size(size.width - anchorRadius, size.height);
    //_paintAnchors(canvas, restrictedSize);
    minWaveHeight = restrictedSize.height * 0.5;
    _paintSlidingWave(canvas, restrictedSize);
  }

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(anchorRadius, size.height), anchorRadius, fillPainter);
    canvas.drawCircle(
        Offset(size.width, size.height), anchorRadius, fillPainter);
  }

  void _paintSlidingWave(Canvas canvas, Size size) {
    final WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);
    _paintWaveLine(canvas, size, line);
  }

  void _paintWaveLine(
      Canvas canvas, Size size, WaveCurveDefinitions waveCurve) {
    final Path path = Path();
    path.moveTo(anchorRadius, size.height);
    path.lineTo(waveCurve.startOfBezier, size.height);
    canvas.drawPath(path, wavePainter);

    final Path wavePath = Path();
    wavePath.moveTo(waveCurve.startOfBezier, size.height);

    wavePath.cubicTo(
        waveCurve.leftControlPoint1,
        size.height,
        waveCurve.leftControlPoint2,
        waveCurve.controlHeight!,
        waveCurve.centerPoint,
        waveCurve.controlHeight!);
    wavePath.cubicTo(
        waveCurve.rightControlPoint1,
        waveCurve.controlHeight!,
        waveCurve.rightControlPoint2,
        size.height,
        waveCurve.endOfBezier,
        size.height);

    wavePainterGradient.shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        Colors.black,
        Colors.teal,
        Colors.black,
      ],
    ).createShader(
      Rect.fromPoints(
        Offset(waveCurve.startOfBezier, size.height),
        Offset(waveCurve.endOfBezier, size.height),
      ),
    );

    canvas.drawPath(wavePath, wavePainterGradient);

    final Path endPath = Path();
    endPath.moveTo(waveCurve.endOfBezier, size.height);
    endPath.lineTo(size.width, size.height);
    canvas.drawPath(endPath, wavePainter);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
    final double controlHeight = size.height - minWaveHeight! - 5;

    const double bendWidth = 20 + 20; //* dragPercentage;
    const double bezierWidth = 20 + 20; // * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = centerPoint - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = centerPoint + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= anchorRadius) ? anchorRadius : startOfBend;
    startOfBezier =
        (startOfBezier <= anchorRadius) ? anchorRadius : startOfBezier;
    endOfBend = (endOfBend > size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier > size.width) ? size.width : endOfBezier;

    final double leftBendControlPoint1 = startOfBend;
    final double leftBendControlPoint2 = startOfBend;
    final double rightBendControlPoint1 = endOfBend;
    final double rightBendControlPoint2 = endOfBend;

    final WaveCurveDefinitions waveCurveDefinitions = WaveCurveDefinitions(
      controlHeight: controlHeight,
      startOfBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftBendControlPoint1,
      leftControlPoint2: leftBendControlPoint2,
      rightControlPoint1: rightBendControlPoint1,
      rightControlPoint2: rightBendControlPoint2,
      centerPoint: centerPoint,
    );

    return waveCurveDefinitions;
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    final double diff = _previousSliderPosition - oldDelegate.sliderPosition;
    if (diff.abs() > 20) {
      _previousSliderPosition = sliderPosition;
    } else {
      _previousSliderPosition = oldDelegate.sliderPosition;
    }
    return true;
  }
}

class WaveCurveDefinitions {
  WaveCurveDefinitions({
    required this.startOfBezier,
    required this.endOfBezier,
    required this.leftControlPoint1,
    required this.leftControlPoint2,
    required this.rightControlPoint1,
    required this.rightControlPoint2,
    required this.controlHeight,
    required this.centerPoint,
  });

  double startOfBezier;
  double endOfBezier;
  double leftControlPoint1;
  double leftControlPoint2;
  double rightControlPoint1;
  double rightControlPoint2;
  double? controlHeight;
  double centerPoint;
}
