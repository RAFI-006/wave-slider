import 'package:flutter/material.dart';
import 'package:wave_slider/wave_slider.dart';

void main() => runApp(MaterialApp(
      home: App(),
    ));

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  double _dragPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: double.infinity,
              height: 60,
              child: WaveSlider(
                color: const Color(0xffe5e8fe),
                activeColor: const Color(0xff4863e1),
                waveGradientColorList: const <Color>[
                  Color(0xffe5e8fe),
                  Color(0xff4863e1),
                  Color(0xffe5e8fe),
                ],
                initialPosition: 0.8,
                onChanged: (double dragUpdate) {
                  setState(() {
                    _dragPercentage = dragUpdate *
                        100; // dragUpdate is a fractional value between 0 and 1
                  });
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Drag percentage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$_dragPercentage',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
