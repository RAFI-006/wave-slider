import 'package:example/painter.dart';
import 'package:flutter/material.dart';

class WaveWidget extends StatelessWidget {
  const WaveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 50,
      child: CustomPaint(
        painter: Painter(color: Colors.black),
      ),
    );
  }
}
