import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/bar_chart_painter.dart';
import 'package:flutter_kline/vo/bar_chart_vo.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/line_chart_vo.dart';

/// 副图
class SubChartRenderer extends CustomPainter {
  final List<BaseChartVo> chartData;

  const SubChartRenderer({required this.chartData});

  @override
  void paint(Canvas canvas, Size size) {
    // 统计高度范围
    Pair<double, double> heightRange =
        Pair.getMaxMinValue(chartData.map((e) => e.getMaxMinData()).toList());
    // 提取线图
    var lineChartData = chartData.whereType<LineChartVo>().toList();

    // 画矩形
    RectPainter(
            size: size,
            transverseLineNum: 0,
            maxValue: heightRange.left,
            minValue: heightRange.right,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(color: Colors.grey, fontSize: 8))
        .paint(canvas, size);

    // 统一画线图
    if (lineChartData.isNotEmpty) {
      LineChartPainter(lineChartData: lineChartData, maxMinValue: heightRange).paint(canvas, size);
    }

    for (var data in chartData) {
      // 线图无需再画
      if (data is LineChartVo) {
        continue;
      }

      // 画柱图
      if (data is BarChartVo) {
        BarChartPainter(barData: data).paint(canvas, size);
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
