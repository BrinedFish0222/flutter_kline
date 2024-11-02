import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/candlestick_chart.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';

import '../common/pair.dart';
import 'draw_line_chart.dart';

typedef DrawChartCreator = DrawChart Function({
  required Size size,
  required Pair<double, double> maxMinValue,
  required double pointWidth,
  required double pointGap,
  required EdgeInsets padding,
  required Widget child,
  required CandlestickChart candlestickChart,
  required ValueChanged<DrawChartCallback> drawChartCallback,
});

/// 画图类型
enum DrawChartType {

  /// 无样式
  none,

  /// 编辑模式
  edit,

  /// 线图
  line,

  ;

  bool get isNone {
    return this == none;
  }

  bool get isNoneOrEdit {
    return this == none || this == edit;
  }

}

/// 画图注册器
class DrawChartRegister {
  static final DrawChartRegister _instance = DrawChartRegister._internal();
  DrawChartRegister._internal();
  factory DrawChartRegister() => _instance;
  
  final Map<String, DrawChartCreator> _data = {};
  
  /// 初始化，注册已存在的画图组件
  void init() {
    DrawLineChart.register();
  }
  
  void register(String key, DrawChartCreator creator) => _data[key] = creator;
  
  DrawChartCreator? getCreatorByKey(String key) => _data[key];

  
  
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