import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  WavePainter({
    required this.sliderPosition,
    this.color = Colors.black,
    this.activeColor = Colors.black,
    this.handleColor = Colors.white,
    this.waveGradientColorList,
    this.waveStrokeWidth = 3.0,
  }) {
    wavePainter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = waveStrokeWidth;

    trackballPainter = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    trianglePainter = Paint()
      ..color = handleColor
      ..strokeWidth = waveStrokeWidth
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    if (waveGradientColorList == null || waveGradientColorList!.isEmpty) {
      waveGradientColorList = const <Color>[
        Color(0xffe5e8fe),
        Color(0xff7E75E4),
        Color(0xffe5e8fe),
      ];
    }

    wavePainterGradient = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = waveStrokeWidth;
  }

  final double sliderPosition;

  final Color color;
  final Color activeColor;
  final Color handleColor;
  late List<Color>? waveGradientColorList;

  late Paint wavePainter;
  late Paint trackballPainter;
  late Paint wavePainterGradient;
  late Paint trianglePainter;
  final double waveStrokeWidth;

  /// Previous slider position initialised at the [anchorRadius], which is the start
  double _previousSliderPosition = anchorRadius;

  static const double anchorRadius = 0;

  double? minWaveHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final Size restrictedSize = Size(size.width - anchorRadius, size.height);
    // _paintAnchors(canvas, restrictedSize);
    minWaveHeight = restrictedSize.height * 0.5;
    _paintSlidingWave(canvas, restrictedSize);
  }

  // void _paintAnchors(Canvas canvas, Size size) {
  //   canvas.drawCircle(
  //       Offset(anchorRadius, size.height), anchorRadius, trackballPainter);
  //   canvas.drawCircle(
  //       Offset(size.width, size.height), anchorRadius, trackballPainter);
  // }

  void _paintSlidingWave(Canvas canvas, Size size) {
    final Size _size = Size(size.width, size.height * 0.65);

    final WaveCurveDefinitions line = _calculateWaveLineDefinitions(_size);
    _paintWaveLine(canvas, _size, line);
    //_paintTrackball(canvas, _size, waveCurve: line);
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

    wavePainterGradient.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: waveGradientColorList!,
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

  void _paintTrackball(Canvas canvas, Size size,
      {required WaveCurveDefinitions waveCurve}) {
    double? centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;
    centerPoint = waveCurve.centerPoint;

    final double indicatorSize = size.height * 0.6;

    final Offset point = Offset(centerPoint, indicatorSize * 1.5);

    canvas.drawCircle(
      point,
      indicatorSize,
      trackballPainter,
    );

    final double triangleSideLength = indicatorSize * 0.6;

    /// left triangle
    final Path leftTriangle = Path();
    leftTriangle.moveTo(point.dx, point.dy);
    leftTriangle.relativeMoveTo(
        triangleSideLength * -0.1, triangleSideLength / -2);
    leftTriangle.relativeLineTo(0, triangleSideLength);
    leftTriangle.relativeLineTo(
        triangleSideLength * -1, triangleSideLength / -2);
    leftTriangle.relativeLineTo(
        triangleSideLength * 1, triangleSideLength / -2);
    canvas.drawPath(leftTriangle, trianglePainter);

    /// right triangle
    final Path rightTriangle = Path();
    rightTriangle.moveTo(point.dx, point.dy);
    rightTriangle.relativeMoveTo(
        triangleSideLength * 0.1, triangleSideLength / -2);
    rightTriangle.relativeLineTo(0, triangleSideLength);
    rightTriangle.relativeLineTo(
        triangleSideLength * 1, triangleSideLength / -2);
    rightTriangle.relativeLineTo(
        triangleSideLength * -1, triangleSideLength / -2);
    canvas.drawPath(rightTriangle, trianglePainter);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
    final double controlHeight = size.height - size.height;

    final double bendWidth = size.height * 1.6; //* dragPercentage;
    final double bezierWidth = size.height * 0.8; // * dragPercentage;

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
