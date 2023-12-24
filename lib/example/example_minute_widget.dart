import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/widget/color_block_widget.dart';
import 'package:flutter_kline/vo/chart_data.dart';

import '../utils/kline_util.dart';
import '../widget/k_minute_chart_widget.dart';
import 'example_macd_data.dart';
import 'example_minute_data.dart';
import 'example_rmo_data.dart';

class ExampleMinuteWidget extends StatefulWidget {
  const ExampleMinuteWidget({super.key, required this.overlayEntryLocationKey});
  final GlobalKey overlayEntryLocationKey;

  @override
  State<ExampleMinuteWidget> createState() => _ExampleMinuteWidgetState();
}

class _ExampleMinuteWidgetState extends State<ExampleMinuteWidget> {
  late KChartDataSource _source;

  @override
  void initState() {
    List<ChartData> charts = [
      ChartData(id: '0', baseCharts: [
        ExampleMinuteData.lineData2,
        ...ExampleMinuteData.subDataMinute()
      ]),
      ChartData(
          id: '1',
          baseCharts: [ExampleRmoData.barChartDataMinute..barWidth = 4]),
      ChartData(id: '2', baseCharts: ExampleMacdData.macdMinute),
    ];

    _source = KChartDataSource(showDataNum: KlineConfig.minuteDataNum, originCharts: charts);
    super.initState();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: ListView(
          children: [
            KMinuteChartWidget(
              size: Size(MediaQuery.of(context).size.width - 20,
                  MediaQuery.of(context).size.height * 0.6),
              source: _source,
              middleNum: 11.39,
              differenceNumbers: const [11.48, 11.30],
              onTapIndicator: (int index) {
                KlineUtil.showToast(context: context, text: '点击指标索引：$index');
              },
              overlayEntryLocationKey: widget.overlayEntryLocationKey,
            ),

            const ColorBlockWidget(),
          ],
        ),
      ),
    );
  }
}
