import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/widget/color_block_widget.dart';
import 'package:flutter_kline/widget/k_chart_controller.dart';

import '../common/chart_data.dart';
import '../common/mask_layer.dart';
import '../common/utils/kline_date_util.dart';
import '../common/utils/kline_util.dart';
import '../widget/bottom_date_widget.dart';
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
  final GlobalKey _chartKey = GlobalKey();

  late KChartDataSource _source;
  late KChartController _controller;

  @override
  void initState() {
    List<ChartData> charts = [
      ChartData(id: '0', name: '分时图', baseCharts: [
        ExampleMinuteData.lineData2,
        ...ExampleMinuteData.subDataMinute()
      ]),
      ChartData(
          id: '1',
          name: 'RMO',
          baseCharts: [ExampleRmoData.barChartDataMinute..barWidth = 4]),
      ChartData(id: '2', name: 'MACD', baseCharts: ExampleMacdData.macdMinute),
    ];

    _source = KChartDataSource(
        showDataNum: KlineConfig.minuteDataNum, originCharts: charts);
    _controller = KChartController(source: _source);

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
            Column(
              children: [
                KMinuteChartWidget(
                  key: _chartKey,
                  controller: _controller,
                  source: _source,
                  middleNum: 11.39,
                  differenceNumbers: const [11.48, 11.30],
                  subChartMaskList: [
                    null,
                    MaskLayer(
                        widget: Container(
                      color: Colors.blue,
                    )),
                  ],
                  onTapIndicator: (int index) {
                    KlineUtil.showToast(
                        context: context, text: '点击指标索引：$index');
                  },
                  overlayEntryLocationKey: widget.overlayEntryLocationKey,
                ),
                SizedBox(
                  height: 12,
                  width: double.infinity,
                  child: StreamBuilder<int>(
                      stream: _controller.crossCurveIndexStream.stream,
                      builder: (context, snapshot) {
                        DateTime? currentDate;
                        if (_controller.isShowCrossCurve) {
                          currentDate = _controller.source
                              .showChartDateTimeByIndex(snapshot.data ?? 0);
                        }

                        double leftPadding = _controller.crossCurveGlobalPosition.dx;
                        RenderObject? renderBox = _chartKey.currentContext?.findRenderObject();
                        if (renderBox != null && renderBox is RenderBox) {
                          try {
                            leftPadding = renderBox.globalToLocal(_controller.crossCurveGlobalPosition).dx;
                          } catch (e) {
                            KlineUtil.loge(e.toString());
                          }
                        }


                        return BottomDateWidget(
                          startDate:
                              _controller.source.showChartStartDateTime,
                          endDate:
                              _controller.source.showChartEndDateTime,
                          periodNumber: _controller.source.showDataNum,
                          currentDateLeftPadding: leftPadding,
                          currentDate: currentDate,
                          formatType: DateTimeFormatType.time,
                        );
                      }),
                ),
              ],
            ),
            const ColorBlockWidget(),
          ],
        ),
      ),
    );
  }
}
