import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
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

  // 选中的数据索引
  final StreamController<int> _selectedDataIndexStream = StreamController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        InkWell(
          onTap: () => _onTapIndicator(0),
          child: Row(children: [
            const Text('MA'),
            const Icon(Icons.arrow_drop_down),
            StreamBuilder(
                initialData: widget.lineChartData == null
                    ? -1
                    : widget.lineChartData!.length - 1,
                stream: _selectedDataIndexStream.stream,
                builder: (context, snapshot) {
                  var data = snapshot.data;
                  if (data == -1 ||
                      KlineCollectionUtil.isEmpty(widget.lineChartData)) {
                    return KlineUtil.noWidget();
                  }

                  return Row(
                    children: [
                      const Text('A: '),
                      Text(
                          '${widget.lineChartData![0]!.dataList![data!].value?.toStringAsFixed(2)}'),
                    ],
                  );
                })
          ]),
        ),
        KChartGestureWidget(
          size: widget.size,
          candlestickChartData: widget.candlestickChartData,
          lineChartData: widget.lineChartData,
          margin: widget.margin,
          selectedDataIndexStream: _selectedDataIndexStream,
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
