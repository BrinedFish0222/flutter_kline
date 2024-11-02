import 'package:flutter/material.dart';
import 'custom_gesture_detector.dart';
import 'draw_chart.dart';

class DrawCircleChart extends DrawChartWidget {
  const DrawCircleChart({
    super.key,
    required super.config,
    required super.child,
  });

  static const String drawKey = "circle";

  static void register() {
    DrawChartRegister().register(drawKey, (config, child) {
      return DrawCircleChart(config: config, child: child);
    });
  }

  @override
  State<DrawCircleChart> createState() => _DrawCircleChartState();
}

class _DrawCircleChartState extends State<DrawCircleChart> {
  final List<Offset> _list = [];

  @override
  Widget build(BuildContext context) {
    return CustomGestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onHorizontalDragUpdate: (_) {},
      onVerticalDragUpdate: (_) {},
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return CustomPaint(
          size: Size(
            boxConstraints.maxWidth,
            boxConstraints.maxHeight,
          ),
          foregroundPainter: _foregroundPainter,
          child: widget.child,
        );
      }),
    );
  }

  CustomPainter? get _foregroundPainter {
    if (_list.isEmpty) {
      return null;
    }

    return CirclePainter(first: _list.first, last: _list.last);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _list.add(details.localPosition);
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _list.clear();
    _list.add(details.localPosition);
    setState(() {});
  }
}

class CirclePainter extends CustomPainter {
  final Offset first;
  final Offset last;

  const CirclePainter({required this.first, required this.last});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    double radius = last.distance - first.distance;
    canvas.drawCircle(first, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.first != first || oldDelegate.last != last;
  }
}
