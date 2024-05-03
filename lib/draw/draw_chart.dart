import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/candlestick_chart.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';

import '../common/pair.dart';

/// 画图类型
enum DrawChartType {
  line,
}

/// 画图
abstract class DrawChart extends StatefulWidget {
  const DrawChart({
    super.key,
    required this.size,
    required this.maxMinValue,
    required this.pointWidth,
    required this.pointGap,
    required this.padding,
    required this.candlestickChart,
    required this.drawChartCallback,
    required this.child,
  });

  final Size size;
  final Pair<double, double> maxMinValue;
  final double pointWidth;
  final double pointGap;
  final EdgeInsets padding;
  final Widget child;
  final CandlestickChart candlestickChart;
  final ValueChanged<DrawChartCallback> drawChartCallback;

  @override
  State<StatefulWidget> createState();
}