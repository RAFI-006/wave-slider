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
  int _selectedDivision = 3;

  double _selectedVal = 900;

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
                divisions: 5,
                divisionVal: _selectedDivision,
                onDivisionChanged: (int division) {
                  setState(() {
                    _selectedDivision = division;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'selected division : $_selectedDivision',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: double.infinity,
              height: 60,
              child: WaveSlider(
                value: _selectedVal,
                min: 100,
                max: 1000,
                onChanged: (double val) {
                  setState(() {
                    _selectedVal = val;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Val [ 100-1000 ] : $_selectedVal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
