import 'package:flutter_kline/chart/base_chart.dart';

/// 画图结果回调
class DrawChartCallback {
  const DrawChartCallback({
    required this.chart,
    required this.originStartIndex,
  });

  final BaseChart chart;
  final int originStartIndex;
}
