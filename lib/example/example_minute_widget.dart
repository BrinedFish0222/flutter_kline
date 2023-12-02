import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';

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
    _source = KChartMinuteDataSource(
        data: KChartDataVo(mainChartData: [
      ExampleMinuteData.lineData2,
      ...ExampleMinuteData.subDataMinute()
    ], subChartData: [
      [ExampleRmoData.barChartDataMinute..barWidth = 4],
      ExampleMacdData.macdMinute,
    ]));
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
            ...List.generate(
                5,
                (index) => Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        color: index % 2 == 0 ? Colors.red : Colors.green,
                        height: 100,
                      ),
                    )).toList(),
          ],
        ),
      ),
    );
  }
}

class KChartMinuteDataSource extends KChartDataSource {
  KChartMinuteDataSource({
    required super.data,
    super.showDataNum = KlineConfig.minuteDataNum,
  });

  @override
  void leftmost() {}

  @override
  void rightmost() {}
}
