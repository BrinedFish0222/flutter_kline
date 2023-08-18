import 'package:flutter/material.dart';

import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

import '../renderer/line_chart_renderer.dart';

/// 副图组件
class SubChartWidget extends StatefulWidget {
  const SubChartWidget({
    super.key,
    required this.size,
    required this.chartData,
  });

  final Size size;
  final List<BaseChartVo?> chartData;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter:
          LineChartRenderer(chartData: widget.chartData as List<LineChartVo?>),
    );
  }
}
