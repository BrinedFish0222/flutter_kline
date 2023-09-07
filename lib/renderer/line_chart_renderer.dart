import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/line_chart_vo.dart';

/// 线图
class LineChartRenderer extends CustomPainter {
  final List<LineChartVo?> chartData;

  const LineChartRenderer({required this.chartData});

  @override
  void paint(Canvas canvas, Size size) {
    var heightRange = LineChartVo.getHeightRange(chartData);

    // 画矩形
    RectPainter(
            size: size,
            transverseLineNum: 0,
            maxValue: heightRange.left,
            minValue: heightRange.right,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(
                color: Colors.grey, fontSize: KlineConfig.rectFontSize))
        .paint(canvas, size);
    LineChartPainter(lineChartData: chartData).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
