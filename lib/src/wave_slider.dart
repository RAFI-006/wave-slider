import 'package:flutter/material.dart';
import 'package:wave_slider/src/wave_painter.dart';

class WaveSlider extends StatefulWidget {
  /// Creates a wave slider.
  ///
  /// When the state of the slider is changed the widget calls the [onChanged] callback.
  const WaveSlider({
    this.color = Colors.black,
    this.activeColor = Colors.black,
    this.initialPosition = 0.5,
    this.onChangeEnd,
    this.onChangeStart,
    required this.onChanged,
    this.waveGradientColorList,
    this.waveStrokeWidth = 3.0,
  });

  final double initialPosition;
  final List<Color>? waveGradientColorList;
  final double waveStrokeWidth;
  final Color activeColor;

  /// The color of the slider can be set by specifying a [color] - default is black.
  final Color color;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  ///
  /// Returns a percentage value between 0 and 100 for the current drag position.
  final ValueChanged<double> onChanged;

  /// Called when the user starts selecting a new value for the slider.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  final ValueChanged<double>? onChangeEnd;

  @override
  _WaveSliderState createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  double _dragPercentage = 0.0;
  double _sliderWidth = 0;
  double _sliderHeight = 0;

  @override
  void initState() {
    super.initState();
    _dragPercentage = widget.initialPosition;
  }

  void _handleChanged(double val) {
    widget.onChanged(val);
  }

  void _handleChangeStart(double val) {
    if (widget.onChangeStart != null) {
      widget.onChangeStart!(val);
    }
    widget.onChanged(val);
  }

  void _handleChangeEnd(double val) {
    widget.onChanged(val);
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(val);
    }
  }

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0.0;
    if (val.dx <= 0.0) {
      newDragPosition = 0.0;
    } else if (val.dx >= _sliderWidth) {
      newDragPosition = _sliderWidth;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / _sliderWidth;
    });
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(start.globalPosition);
    _updateDragPosition(localOffset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(update.globalPosition);
    _updateDragPosition(localOffset);
    _handleChanged(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    setState(() {});
    _handleChangeEnd(_dragPercentage);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _sliderWidth = constraints.maxWidth;
        _sliderHeight = constraints.maxHeight;
        return GestureDetector(
          child: Container(
            width: _sliderWidth,
            height: _sliderHeight,
            child: CustomPaint(
              painter: WavePainter(
                color: widget.color,
                sliderPosition: _sliderWidth * _dragPercentage,
                dragPercentage: _dragPercentage,
                waveGradientColorList: widget.waveGradientColorList,
                waveStrokeWidth: widget.waveStrokeWidth,
                activeColor: widget.activeColor,
              ),
            ),
          ),
          onHorizontalDragStart: (DragStartDetails start) =>
              _onDragStart(context, start),
          onHorizontalDragUpdate: (DragUpdateDetails update) =>
              _onDragUpdate(context, update),
          onHorizontalDragEnd: (DragEndDetails end) => _onDragEnd(context, end),
        );
      },
    );
  }
}
