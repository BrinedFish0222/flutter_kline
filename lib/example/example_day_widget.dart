import 'package:flutter/material.dart';
import 'package:flutter_kline/example/example_badge_data.dart';
import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

import '../common/k_chart_data_source.dart';
import '../utils/kline_util.dart';
import '../vo/bar_chart_vo.dart';
import '../widget/k_chart_widget.dart';
import 'example_candlestick_data.dart';
import 'example_ess_data.dart';
import 'example_line_data.dart';
import 'example_macd_data.dart';
import 'example_rmo_data.dart';
import 'example_vol_data.dart';

class ExampleDayWidget extends StatefulWidget {
  const ExampleDayWidget({super.key, required this.overlayEntryLocationKey});

  final GlobalKey overlayEntryLocationKey;

  @override
  State<ExampleDayWidget> createState() => _ExampleDayWidgetState();
}

class _ExampleDayWidgetState extends State<ExampleDayWidget> {
  late KChartDataSource source;

  @override
  void initState() {
    var candlestickData = ExampleCandlestickData.getCandlestickData();

    source = KChartDayDataSource(
        data: KChartDataVo(mainChartData: [
      candlestickData,
      ...ExampleLineData.getLineChartMA13(),
      ExampleBadgeData.badgeChartVo,
    ], subChartData: [
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
    ]));

    Future.delayed(const Duration(seconds: 2), () {
      source.updateData(
        mainChartData: [
          CandlestickChartVo(
            data: [
              candlestickData.data[candlestickData.data.length - 1],
              candlestickData.data[candlestickData.data.length - 1],
            ],
          )
        ],
        subChartData: [],
        isAddMode: true,
        isEnd: true,
      );
      source.resetShowData(startIndex: source.showDataStartIndex + 2);
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      source.notifyListeners();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height * 0.6);
    BarChartVo barChartVo = ExampleVolData.barChartData..barWidth = 2;
    for (var element in barChartVo.data) {
      element?.isFill = true;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView(
        children: [
          KChartWidget(
            showDataNum: 30,
            size: size,
            source: source,
            realTimePrice: 11.56,
            onTapIndicator: (index) {
              KlineUtil.showToast(context: context, text: '点击指标索引：$index');
            },
            margin: const EdgeInsets.all(5),
            /* subChartMaskList: [
              null,
              MaskLayer(percent: 0.3),
              // MaskLayer(percent: 0.8)
            ], */
            overlayEntryLocationKey: widget.overlayEntryLocationKey,
            leftmost: () {
              KlineUtil.showToast(context: context, text: '移动到最左边');
            },
            rightmost: () {
              KlineUtil.showToast(context: context, text: '移动到最右边');
            },
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

class KChartDayDataSource extends KChartDataSource {
  KChartDayDataSource({required super.data});

  @override
  void leftmost() {}

  @override
  void rightmost() {}
}
