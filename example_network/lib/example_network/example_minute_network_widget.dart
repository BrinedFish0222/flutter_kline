import 'dart:async';

import 'package:example_network/main.dart';
import 'package:example_network/vo/response_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/line_chart.dart';
import 'package:flutter_kline/common/chart_data.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/example/example_minute_data.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/widget/k_minute_chart_widget.dart';

class ExampleMinuteNetworkWidget extends StatefulWidget {
  const ExampleMinuteNetworkWidget(
      {super.key, required this.overlayEntryLocationKey});
  final GlobalKey overlayEntryLocationKey;

  @override
  State<ExampleMinuteNetworkWidget> createState() =>
      _ExampleMinuteNetworkWidgetState();
}

class _ExampleMinuteNetworkWidgetState
    extends State<ExampleMinuteNetworkWidget> {
  late StreamSubscription _streamSubscription;
  late KChartDataSource _source;
  final LineChart _vo = LineChart(data: [], id: 'minute');

  @override
  void initState() {
    _source = KChartDataSource(
        showDataNum: KlineConfig.minuteDataNum,
        originCharts: [
          ChartData(id: '0', name: '分时图', baseCharts: [_vo, ...ExampleMinuteData.subDataMinute()]),
          // ChartData(id: '1', name: 'RMO', baseCharts: [ExampleRmoData.barChartDataMinute..barWidth = 4]),
          // ChartData(id: '2', name: 'MACD', baseCharts: ExampleMacdData.macdMinute)
        ]);
    // 监听websocket数据
    _streamSubscription = webSocketChannelStream.listen((data) {
      if (data == null) {
        return;
      }

      ResponseResult responseResult = responseResultFromJson(data);

      /// 分时图全量数据更新
      var lineChartDataList = responseResult.parseMinuteAllData();
      if (lineChartDataList?.isNotEmpty ?? false) {
        _source.updateData(
          newCharts: [
            ChartData(
                id: '0', baseCharts: [LineChart(data: lineChartDataList!, id: 'minute')])
          ],
          isEnd: true,
        );
        _source.notifyListeners();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KMinuteChartWidget(
      source: _source,
      middleNum: 11.39,
      differenceNumbers: const [11.42, 11.36],
      onTapIndicator: (int index) {
        KlineUtil.showToast(context: context, text: '点击指标索引：$index');
      },
      overlayEntryLocationKey: widget.overlayEntryLocationKey,
    );
  }
}
