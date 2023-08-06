import 'package:flutter/material.dart';
import 'package:flutter_kline/widget/gesture/k_chart_gesture_widget.dart';

import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

class KChartWidget extends StatefulWidget {
  const KChartWidget(
      {super.key,
      required this.size,
      required this.candlestickChartData,
      this.lineChartData,
      this.margin,
      this.onTapIndicator});

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;

  /// 点击股票指标事件
  final void Function(int index)? onTapIndicator;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
  /// 蜡烛数据流
  // final StreamController<CandlestickChartVo?> candlestickChartVoStream = StreamController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        InkWell(
          onTap: () => _onTapIndicator(0),
          child: Row(children: const [
            Text('MA'),
            Icon(Icons.arrow_drop_down),
          ]),
        ),
        KChartGestureWidget(
          size: widget.size,
          candlestickChartData: widget.candlestickChartData,
          lineChartData: widget.lineChartData,
          margin: widget.margin,
        )
      ],
    );
  }

  /// 点击指标事件
  void _onTapIndicator(int index) {
    if (widget.onTapIndicator == null) {
      return;
    }

    widget.onTapIndicator!(index);
  }
}
