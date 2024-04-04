import 'package:flutter/material.dart';

import '../chart/vertical_line_chart.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';

/// 竖线 painter
class VerticalLineChartPainter extends CustomPainter {
  VerticalLineChartPainter({
    required this.data,
    required this.maxMinValue,
    required this.pointWidth,
    required this.pointGap,
  });

  VerticalLineChart data;
  Pair<double, double> maxMinValue;
  double pointWidth;
  double pointGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dataLength == 0) {
      return;
    }

    // 生成图数据
    List<VerticalLineChartData?> chartData = _chartData(size: size);

    const Color defaultColor = Colors.black;
    Paint paint = Paint()
      ..color = defaultColor
      ..strokeWidth = 2;

    // 竖线 x轴相等，y轴不等
    for (int j = 0; j < chartData.length; j++) {
      VerticalLineChartData? data = chartData[j];
      if (data == null) {
        continue;
      }

      paint.color = data.color ?? defaultColor;

      double x = KlineUtil.computeXAxis(
        index: j,
        pointWidth: pointWidth,
        pointGap: pointGap,
      );
      canvas.drawLine(Offset(x, data.top), Offset(x, data.bottom), paint);

      paint.color = defaultColor;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is VerticalLineChartPainter) {
      return oldDelegate.data != data ||
          oldDelegate.maxMinValue != maxMinValue ||
          oldDelegate.pointWidth != pointWidth ||
          oldDelegate.pointGap != pointGap;
    }
    return true;
  }

  /// 将真实数据转成图数据
  List<VerticalLineChartData?> _chartData({required Size size}) {
    if (data.dataLength == 0) {
      return [];
    }

    List<VerticalLineChartData?> result = [];
    for (VerticalLineChartData? element in data.data) {
      if (element == null) {
        result.add(null);
        continue;
      }

      result.add(element.copyWith(
        top: KlineUtil.convertDataToChartDataSingle(element.top, size.height,
            maxMinValue: maxMinValue),
        bottom: KlineUtil.convertDataToChartDataSingle(
            element.bottom, size.height,
            maxMinValue: maxMinValue),
      ));
    }

    return result;
  }
}
