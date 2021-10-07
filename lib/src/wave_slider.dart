import 'package:flutter/material.dart';
import 'package:wave_slider/src/wave_painter.dart';

class WaveSlider extends StatefulWidget {
  /// Creates a wave slider.
  ///
  /// When the state of the slider is changed the widget calls the [onChanged] callback.
  const WaveSlider({
    Key? key,
    this.value = 0.0,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.divisionVal,
    this.onChangeEnd,
    this.onChangeStart,
    this.onChanged,
    this.onDivisionChanged,
    this.color = const Color(0xffe5e8fe),
    this.activeColor = const Color(0xff4863e1),
    this.handleColor = const Color(0xffffffff),
    this.waveGradientColorList,
    this.waveStrokeWidth = 3.0,
    this.sliderPaddingVal = 36,
    this.handleImagePath,
  }) : super(key: key);

  final double value;
  final int? divisionVal;
  final List<Color>? waveGradientColorList;
  final double waveStrokeWidth;
  final Color activeColor;
  final Color handleColor;

  final int? divisions;
  final double min;
  final double max;
  final double sliderPaddingVal;

  final String? handleImagePath;

  /// The color of the slider can be set by specifying a [color] - default is black.
  final Color color;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  ///
  /// Returns a percentage value between 0 and 100 for the current drag position.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts selecting a new value for the slider.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  final ValueChanged<double>? onChangeEnd;

  /// Called when the user is done selecting a new division .
  final ValueChanged<int>? onDivisionChanged;

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
    _dragPercentage = _initialPercentage();
  }

  double _initialPercentage() {
    if (widget.divisions != null && widget.divisionVal != null) {
      if (!(widget.divisionVal! <= widget.divisions!)) {
        throw Exception(
            ' initialDivision : ${widget.divisionVal} should not be granter than divisions');
      }
      final double singleDivisionWidth = 1 / widget.divisions!;
      return singleDivisionWidth * widget.divisionVal!;
    } else {
      if (!(widget.min <= widget.value && widget.min <= widget.max)) {
        throw Exception(
            'value : ${widget.value} not in a range of min and max');
      }

      final double totalDiff = widget.max - widget.min;
      final double givenVal = widget.value - widget.min;

      return givenVal / totalDiff;
    }
  }

  void _handleChanged(double val) {
    if (widget.onChanged != null) {
      final double diff = widget.max - widget.min;
      final double result = (diff * val) + widget.min;
      widget.onChanged!(result);
    }
  }

  void _handleChangeStart(double val) {
    if (widget.onChangeStart != null) {
      widget.onChangeStart!(val);
    }
    _handleChanged(val);
  }

  void _handleChangeEnd(double val) {
    _handleChanged(val);
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
    if (widget.divisions != null) {
      _handleDivisions();
    }
    _handleChangeStart(_dragPercentage);
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(update.globalPosition);
    _updateDragPosition(localOffset);
    if (widget.divisions != null) {
      _handleDivisions();
    }
    _handleChanged(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    if (widget.divisions != null) {
      _handleDivisions();
    }
    setState(() {});
    _handleChangeEnd(_dragPercentage);
  }

  void _handleDivisions() {
    final double singleDivisionWidth = 1 / widget.divisions!;

    final List<double> list = List<double>.generate(
        widget.divisions! + 1, (int i) => singleDivisionWidth * i);

    for (MapEntry<int, double> entry in list.asMap().entries) {
      if (_dragPercentage <= entry.value) {
        /// left and right divisions
        final double rightDivision = list[entry.key];
        final double leftDivision = entry.key == 0 ? 0.0 : list[entry.key - 1];

        final double rightDiff = rightDivision - _dragPercentage;
        final double leftDiff = _dragPercentage - leftDivision;

        if (leftDiff < rightDiff) {
          /// move to left
          _dragPercentage = leftDivision;

          if (widget.onDivisionChanged != null) {
            widget
                .onDivisionChanged!(entry.key == 0 ? entry.key : entry.key - 1);
          }
        } else {
          /// move to right
          _dragPercentage = rightDivision;
          if (widget.onDivisionChanged != null) {
            widget.onDivisionChanged!(entry.key);
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _sliderWidth = constraints.maxWidth;
        _sliderHeight = constraints.maxHeight;

        final double sliderPaddingPercent =
            widget.sliderPaddingVal / _sliderWidth;

        // convert
        final double virtualPercentage = sliderPaddingPercent +
            (_dragPercentage * (1.0 - sliderPaddingPercent * 2));

        return GestureDetector(
          child: Container(
            width: _sliderWidth,
            height: _sliderHeight,
            child: Stack(
              children: [
                Container(
                  width: _sliderWidth,
                  height: _sliderHeight,
                  child: CustomPaint(
                    painter: WavePainter(
                      color: widget.color,
                      sliderPosition: _sliderWidth * virtualPercentage,
                      waveGradientColorList: widget.waveGradientColorList,
                      waveStrokeWidth: widget.waveStrokeWidth,
                      activeColor: widget.activeColor,
                      handleColor: widget.handleColor,
                    ),
                  ),
                ),
                Positioned(
                  left: (_sliderWidth * virtualPercentage) -
                      (_sliderHeight * 0.4),
                  bottom: 0,
                  child: widget.handleImagePath == null
                      ? CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: _sliderHeight * 0.4,
                        )
                      : Image.asset(
                          widget.handleImagePath!,
                          width: _sliderHeight * 0.8,
                          height: _sliderHeight * 0.8,
                        ),
                ),
              ],
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
