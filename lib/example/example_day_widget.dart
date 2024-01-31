import 'package:flutter/material.dart';
import 'package:flutter_kline/common/widget/color_block_widget.dart';
import 'package:flutter_kline/vo/chart_data.dart';
import 'package:flutter_kline/vo/mask_layer.dart';
import 'package:flutter_kline/widget/k_line_chart_widget.dart';

import '../common/k_chart_data_source.dart';
import '../utils/kline_util.dart';
import '../vo/bar_chart_vo.dart';
import '../widget/k_chart_widget.dart';
import 'example_badge_data.dart';
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
  late KChartDataSource _source;

  @override
  void initState() {
    KlineUtil.logd('ExampleDayWidget initState ...');
    var candlestickData = ExampleCandlestickData.getCandlestickData();

    _source = KChartDataSource(originCharts: [
      ChartData(id: '0', name: 'MA', baseCharts: [
        candlestickData,
        ...ExampleLineData.getLineChartMA13(),
        ExampleBadgeData.badgeChartVo,
      ]),
      ChartData(id: '1', name: 'VOL', baseCharts: [
        ExampleVolData.barChartData..minValue = 0,
        ...ExampleVolData.lineChartData,
        ExampleBadgeData.volBadgeChartVo,
      ]),
      ChartData(
          id: '2',
          name: 'RMO',
          baseCharts: [ExampleRmoData.barChartData..barWidth = 4]),
      ChartData(id: '3', name: 'MACD', baseCharts: ExampleMacdData.macd),
      ChartData(id: '4', name: 'ESS', baseCharts: [
        ExampleEssData.barChartData
          // ..barWidth = 2
          ..minValue = 0,
        ExampleEssData.lineChartA,
        ExampleEssData.lineChartB
      ])
    ]);

    super.initState();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BarChartVo barChartVo = ExampleVolData.barChartData..barWidth = 2;
    for (var element in barChartVo.data) {
      element?.isFill = true;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: ListView(
        children: [
          KChartWidget(
            showDataNum: 30,
            source: _source,
            realTimePrice: 11.56,
            onTapIndicator: (index) {
              KlineUtil.showToast(context: context, text: '点击指标索引：$index');
            },
            subChartMaskList: [
              null,
              MaskLayer(percent: 0.3),
              // MaskLayer(percent: 0.8)
            ],
            overlayEntryLocationKey: widget.overlayEntryLocationKey,
            onHorizontalDragUpdate: (details, location) {
              KlineUtil.logd('移动的位置：$location');
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            width: 300,
            child: KLineChartWidget(
              chart: ExampleVolData.lineChartData.first
                ..color = Colors.blue
                ..gradient = const LinearGradient(colors: [
                  Colors.blue,
                  Colors.transparent,
                ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .5,
                child: Stack(
                  children: [
                    KLineChartWidget(
                      chart: ExampleVolData.lineChartData.first
                        ..color = Colors.red
                        ..gradient = const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                    ),
                    KLineChartWidget(
                      chart: ExampleVolData.lineChartData.last
                        ..color = Colors.yellow
                        ..gradient = const LinearGradient(
                          colors: [
                            Colors.yellow,
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const ColorBlockWidget(),
        ],
      ),
    );
  }
}
