import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/draw/draw_chart.dart';

import '../chart/line_chart.dart';
import '../common/utils/kline_num_util.dart';
import '../common/utils/kline_util.dart';
import 'gradient_chart_painter.dart';

/// 折线图
class LineChartPainter extends CustomPainter with DrawChartPainter {
  final LineChart lineChartData;
  final double? pointWidth;
  final double pointGap;
  final Pair<double, double>? maxMinValue;

  LineChartPainter({
    required this.lineChartData,
    this.pointWidth,
    this.pointGap = 0,
    this.maxMinValue,
  });

  final List<Path> _paths = [];

  /// 初始化：最大最小值。
  Pair<double, double> _initMaxMinValue() {
    if (this.maxMinValue != null) {
      return this.maxMinValue!;
    }

    Pair<double, double> maxMinValue = KlineNumUtil.maxMinValueDouble(
        lineChartData.data.map((e) => e?.value).toList());

    return maxMinValue;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (lineChartData.data.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    Pair<double, double> maxMinValue = _initMaxMinValue();
    // 数据点宽度，和 [lineChartData] 一一对应。
    double pointWidth =
        (this.pointWidth ?? size.width / lineChartData.dataLength);

    paint.color = lineChartData.color;

    var values = lineChartData.data.map((e) => e?.value).toList();
    List<double?> dys = KlineUtil.convertDataToChartData(
      values,
      size.height,
      maxMinValue: maxMinValue,
    );

    Path path = Path();
    bool hasData = false;
    for (int j = 0; j < dys.length; j++) {
      double? dy = dys[j];
      if (dy == null) {
        if (hasData) break;
        continue;
      }

      var dx = KlineUtil.computeXAxis(
          index: j, pointWidth: pointWidth, pointGap: pointGap);
      if (hasData) {
        path.lineTo(dx, dy);
      } else {
        path.moveTo(dx, dy);
      }
      hasData = true;
    }
    _paths.add(path);
    canvas.drawPath(path, paint);

    if (lineChartData.gradient != null) {
      GradientChartPainter(
        gradient: lineChartData.gradient!,
        heightList: dys,
        pointWidth: pointWidth,
        pointGap: pointGap,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  List<Path> get chartPaths => _paths;
}
