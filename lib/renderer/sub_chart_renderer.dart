import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
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
  final double? pointWidth;
  final double? pointGap;
  final Pair<double, double>? heightRange;

  /// 是否画矩形
  final bool isDrawRect;

  const SubChartRenderer({
    required this.chartData,
    this.pointWidth,
    this.pointGap,
    this.heightRange,
    this.isDrawRect = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    bool hasBarChart = _hasBarChart;
    Pair<double, double> heightRange =
        _computeHeightRange(hasBarChart: hasBarChart);
    // 提取线图
    var lineChartData = chartData.whereType<LineChartVo>().toList();

    // 画矩形
    if (isDrawRect) {
      RectPainter(
        transverseLineNum: 0,
        maxValue: heightRange.left,
        minValue: heightRange.right,
        isDrawVerticalLine: true,
        textStyle: const TextStyle(
            color: Colors.grey, fontSize: KlineConfig.rectFontSize),
      ).paint(canvas, size);
    }

    for (var data in chartData) {
      // 线图无需再画
      if (data is LineChartVo) {
        continue;
      }

      // 画柱图
      if (data is BarChartVo) {
        BarChartPainter(
          barData: data,
          pointWidth: pointWidth,
          pointGap: pointGap ?? 5,
          heightRange: heightRange,
        ).paint(canvas, size);
        continue;
      }
    }

    // 统一画线图
    if (lineChartData.isNotEmpty) {
      LineChartPainter(
        lineChartData: lineChartData,
        maxMinValue: heightRange,
        pointWidth: pointWidth,
        pointGap: pointGap ?? 0,
      ).paint(canvas, size);
    }
  }

  /// 统计高度范围
  /// [hasBarChart] 是否有柱图
  Pair<double, double> _computeHeightRange({required bool hasBarChart}) {
    var result = heightRange ??
        Pair.getMaxMinValue(chartData.map((e) => e.getMaxMinData()).toList());
    if (hasBarChart && result.right > 0) {
      result.right = 0;
    }
    return result;
  }

  /// 判断是否有柱图
  bool get _hasBarChart {
    for (var element in chartData) {
      if (element is BarChartVo) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
