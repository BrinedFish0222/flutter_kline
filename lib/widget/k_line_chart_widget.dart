import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/line_chart_painter.dart';

import '../chart/line_chart.dart';

/// 线图组件
class KLineChartWidget extends StatelessWidget {
  const KLineChartWidget({
    super.key,
    required this.chart,
  });

  final LineChart chart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: LineChartPainter(lineChartData: chart),
      );
    });
  }
}
