import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/candlestick_chart.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';
import 'package:flutter_kline/draw/draw_circle_chart.dart';

import '../common/pair.dart';
import 'draw_line_chart.dart';

typedef DrawChartCreator = DrawChartWidget Function(DrawChartConfig config, Widget child);

// 画图点击选中默认增大范围
const Size kDrawChartClickSelectedIncreaseRange = Size(8, 8);

/// 画图注册器
class DrawChartRegister {
  static final DrawChartRegister _instance = DrawChartRegister._internal();
  DrawChartRegister._internal();
  factory DrawChartRegister() => _instance;
  
  final Map<String, DrawChartCreator> _data = {};
  
  /// 初始化，注册已存在的画图组件
  void init() {
    DrawLineChart.register();
    DrawCircleChart.register();
  }
  
  void register(String key, DrawChartCreator creator) => _data[key] = creator;
  
  DrawChartCreator? getCreatorByKey(String key) => _data[key];

  
  
}

mixin DrawChartPainter {
  List<Path> get chartPaths;
}

/// 画图
abstract class DrawChartWidget extends StatefulWidget {
  const DrawChartWidget({
    super.key,
    required this.config,
    required this.child,
  });

 
  final DrawChartConfig config;
  final Widget child;

  @override
  State<StatefulWidget> createState();
}


class DrawChartConfig {
  const DrawChartConfig({
    required this.size,
    required this.maxMinValue,
    required this.pointWidth,
    required this.pointGap,
    required this.padding,
    required this.candlestickChart,
    required this.drawChartCallback,
  });

  final Size size;
  final Pair<double, double> maxMinValue;
  final double pointWidth;
  final double pointGap;
  final EdgeInsets padding;
  final CandlestickChart candlestickChart;
  final ValueChanged<DrawChartCallback> drawChartCallback;
}
