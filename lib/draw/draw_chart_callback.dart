import 'package:flutter_kline/chart/base_chart.dart';

/// 画图结果回调
class DrawChartCallback {
  const DrawChartCallback({
    required this.chart,
    required this.originStartIndex,
  });

  final BaseChart chart;

  /// todo hhg delete
  /// 源数据（蜡烛图）开始索引位置
  final int originStartIndex;
}
