import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

import 'gradient_chart_painter.dart';

/// 折线图
class LineChartPainter extends CustomPainter {
  final LineChartVo lineChartData;
  final double? pointWidth;
  final double pointGap;
  final Pair<double, double>? maxMinValue;

  const LineChartPainter({
    required this.lineChartData,
    this.pointWidth,
    this.pointGap = 0,
    this.maxMinValue,
  });

  /// 初始化：最大最小值。
  Pair<double, double> _initMaxMinValue() {
    if (this.maxMinValue != null) {
      return this.maxMinValue!;
    }

    Pair<double, double> maxMinValue = KlineNumUtil.maxMinValueDouble(
        lineChartData.data.map((e) => e.value).toList());

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

    var convertDataList = KlineUtil.convertDataToChartData(
      lineChartData.data.map((e) => e.value).toList(),
      size.height,
      maxMinValue: maxMinValue,
    );

    double? lastX;
    double? lastY;
    for (int j = 0; j < convertDataList.length; j++) {
      double? data = convertDataList[j];
      if (data == null) {
        continue;
      }

      lastX ??= KlineUtil.computeXAxis(
          index: j, pointWidth: pointWidth, pointGap: pointGap);
      lastY ??= data;

      double x = KlineUtil.computeXAxis(
          index: j, pointWidth: pointWidth, pointGap: pointGap);
      double y = data;

      canvas.drawLine(Offset(lastX, lastY), Offset(x, y), paint);
      lastX = x;
      lastY = y;
    }

    if (lineChartData.gradient != null) {
      GradientChartPainter(
        gradient: lineChartData.gradient!,
        heightList: convertDataList,
        pointWidth: pointWidth,
        pointGap: pointGap,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
