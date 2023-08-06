import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/pair.dart';
import '../../renderer/k_chart_renderer.dart';
import '../../vo/candlestick_chart_vo.dart';
import '../../vo/line_chart_vo.dart';

/// k线图手势操作组件
class KChartGestureWidget extends StatefulWidget {
  const KChartGestureWidget(
      {super.key,
      required this.size,
      required this.candlestickChartData,
      this.lineChartData,
      this.margin});

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;

  @override
  State<KChartGestureWidget> createState() => _KChartGestureWidgetState();
}

class _KChartGestureWidgetState extends State<KChartGestureWidget> {
  Pair<double?, double?>? _selectedXY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: CustomPaint(
        size: widget.size,
        painter: KChartRenderer(
            candlestickCharData: widget.candlestickChartData,
            lineChartData: widget.lineChartData,
            margin: widget.margin,
            selectedXY: _selectedXY),
      ),
    );
  }

  _onTapDown(TapDownDetails detail) {
    debugPrint(
        "点击x：${detail.localPosition.dx}, 点击y：${detail.localPosition.dy}");
    _selectedXY =
        Pair(left: detail.localPosition.dx, right: detail.localPosition.dy);

    setState(() {});
  }
}
