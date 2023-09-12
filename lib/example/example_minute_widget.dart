import 'package:flutter/material.dart';

import '../utils/kline_util.dart';
import '../widget/k_minute_chart_widget.dart';
import 'example_macd_data.dart';
import 'example_minute_data.dart';
import 'example_rmo_data.dart';

class ExampleMinuteWidget extends StatelessWidget {
  const ExampleMinuteWidget({super.key, required this.overlayEntryLocationKey});
  final GlobalKey overlayEntryLocationKey;

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
              minuteChartData: ExampleMinuteData.lineData2,
              minuteChartSubjoinData: ExampleMinuteData.subData(),
              middleNum: 11.39,
              differenceNumbers: const [11.48, 11.30],
              subChartData: [
                [ExampleRmoData.barChartData..barWidth = 4],
                ExampleMacdData.macd,
              ],
              onTapIndicator: (int index) {
                KlineUtil.showToast(context: context, text: '点击指标索引：$index');
              },
              overlayEntryLocationKey: overlayEntryLocationKey,
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
