import 'package:flutter/material.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/line_chart_vo.dart';

/// 蜡烛图
class CandlestickChartRenderer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    RectPainter(
            size: size,
            transverseLineNum: 2,
            maxValue: 50,
            minValue: 12,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(color: Colors.grey, fontSize: 8))
        .paint(canvas, size);

    LineChartPainter(lineChartData: [
      LineChartVo(dataList: [12, 50, 50, 12, 22, 45, 42])
    ], size: size)
        .paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
