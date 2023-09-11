import 'dart:async';

import 'package:example_network/main.dart';
import 'package:example_network/vo/response_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/example/example_macd_data.dart';
import 'package:flutter_kline/example/example_rmo_data.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
import 'package:flutter_kline/widget/k_minute_chart_widget.dart';

class ExampleMinuteNetworkWidget extends StatefulWidget {
  const ExampleMinuteNetworkWidget({super.key});

  @override
  State<ExampleMinuteNetworkWidget> createState() =>
      _ExampleMinuteNetworkWidgetState();
}

class _ExampleMinuteNetworkWidgetState
    extends State<ExampleMinuteNetworkWidget> {
  final LineChartVo _vo = LineChartVo(dataList: []);

  final StreamController<LineChartData> _minuteChartDataAddStream =
      StreamController();

  @override
  void initState() {
    // 监听websocket数据
    webSocketChannel.stream.listen((data) {
      if (data == null) {
        return;
      }

      ResponseResult responseResult = responseResultFromJson(data);
      LineChartData? lineChartData = responseResult.parseMinuteData();
      if (lineChartData != null) {
        debugPrint("分时图数据增加, 数据长度：$lineChartData");
        _minuteChartDataAddStream.add(lineChartData);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // _minuteChartDataAddStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KMinuteChartWidget(
      size: Size(MediaQuery.of(context).size.width - 20,
          MediaQuery.of(context).size.height * 0.6),
      minuteChartData: _vo,
      minuteChartDataAddStream: _minuteChartDataAddStream,
      // minuteChartSubjoinData: ExampleMinuteData.subData(),
      middleNum: 11.39,
      differenceNumbers: const [11.42, 11.36],
      subChartData: [
        [ExampleRmoData.barChartData..barWidth = 4],
        ExampleMacdData.macd,
      ],
      onTapIndicator: (int index) {
        KlineUtil.showToast(context: context, text: '点击指标索引：$index');
      },
    );
  }
}
