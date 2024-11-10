import 'dart:math';

import 'package:flutter/material.dart';

import '../chart/circle_chart.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';
import '../draw/draw_chart.dart';

class CirclePainter extends CustomPainter with DrawChartPainter {
  final CircleChart chart;
  final double pointWidth;
  final double pointGap;
  final Pair<double, double> maxMinValue;
  final EdgeInsets padding;

  CirclePainter({
    required this.chart,
    required this.pointWidth,
    required this.pointGap,
    required this.maxMinValue,
    required this.padding,
  });

  final List<Path> _paths = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (chart.dataLength == 0) {
      return;
    }

    size = Size(size.width - padding.left - padding.right, size.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), paint);

    int index = -1;
    double width = pointWidth + pointGap;
    for (var data in chart.data) {
      index += 1;
      if (data == null) continue;

      double? dy = KlineUtil.convertDataToChartData(
        [data.value],
        size.height,
        maxMinValue: maxMinValue,
      )[0];
      if (dy == null) continue;

      double dx = index * width;
      double radius = width * data.spaceNumber;

      Path path = Path();
      path.addArc(
          Rect.fromCircle(center: Offset(dx, dy), radius: radius), 0, 2 * pi);

      _paths.add(path);
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return true;
  }

  @override
  List<Path> get chartPaths => _paths;
}
