import 'package:flutter/material.dart';
import 'package:flutter_kline/example/example_macd_data.dart';
import 'package:flutter_kline/example/example_minute_data.dart';
import 'package:flutter_kline/example/example_rmo_data.dart';
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

  @override
  Widget build(BuildContext context) {
    return KMinuteChartWidget(
      size: Size(MediaQuery.of(context).size.width - 20,
          MediaQuery.of(context).size.height * 0.6),
      minuteChartData: _vo,
      // minuteChartSubjoinData: ExampleMinuteData.generateLineData(),
      middleNum: 11.39,
      differenceNumbers: const [11.48, 11.30],
      subChartData: [
        [ExampleRmoData.barChartData..barWidth = 4],
        ExampleMacdData.macd,
      ],
    );
  }
}
