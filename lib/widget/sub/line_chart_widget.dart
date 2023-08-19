import 'package:flutter/material.dart';

import '../../renderer/line_chart_renderer.dart';
import '../../vo/line_chart_vo.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget(
      {super.key, required this.size, required this.chartData});

  final Size size;
  final List<LineChartVo?> chartData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => debugPrint("line chart widget onTap"),
          child: Container(
            height: 10,
            color: Colors.yellow,
          ),
        ),
        CustomPaint(
          size: size,
          painter: LineChartRenderer(chartData: chartData),
        ),
      ],
    );
  }
}
