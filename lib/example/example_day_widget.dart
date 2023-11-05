import 'package:flutter/material.dart';
import 'package:flutter_kline/example/example_badge_data.dart';

import '../utils/kline_util.dart';
import '../vo/bar_chart_vo.dart';
import '../vo/mask_layer.dart';
import '../widget/k_chart_widget.dart';
import 'example_candlestick_data.dart';
import 'example_ess_data.dart';
import 'example_line_data.dart';
import 'example_macd_data.dart';
import 'example_rmo_data.dart';
import 'example_vol_data.dart';

class ExampleDayWidget extends StatelessWidget {
  const ExampleDayWidget({
    super.key,
    required this.overlayEntryLocationKey,
  });
  final GlobalKey overlayEntryLocationKey;

  @override
  Widget build(BuildContext context) {
    var size = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height * 0.6);
    BarChartVo barChartVo = ExampleVolData.barChartData..barWidth = 2;
    for (var element in barChartVo.data) {
      element.isFill = true;
    }

    var candlestickData = ExampleCandlestickData.getCandlestickData();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView(
        children: [
          KChartWidget(
            showDataNum: 30,
            size: size,
            mainChartData: [
              candlestickData,
              ...ExampleLineData.getLineChartMA13(),
              ExampleBadgeData.badgeChartVo,
            ],
            realTimePrice: candlestickData.dataList.last?.close,
            onTapIndicator: (index) {
              KlineUtil.showToast(context: context, text: '点击指标索引：$index');
            },
            margin: const EdgeInsets.all(5),
            subChartData: [
              [
                ExampleVolData.barChartData..minValue = 0,
                ...ExampleVolData.lineChartData,
                ExampleBadgeData.badgeChartVo,
              ],
              [ExampleRmoData.barChartData..barWidth = 4],
              ExampleMacdData.macd,
              [
                ExampleEssData.barChartData
                  ..barWidth = 2
                  ..minValue = 0,
                ExampleEssData.lineChartA,
                ExampleEssData.lineChartB
              ],
            ],
            subChartMaskList: [
              null,
              MaskLayer(percent: 0.3),
              // MaskLayer(percent: 0.8)
            ],
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
    );
  }
}
