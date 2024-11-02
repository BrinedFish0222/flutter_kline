import 'package:example/widget/draw_mode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/base_chart.dart';
import 'package:flutter_kline/common/chart_data.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/utils/kline_util.dart';
import 'package:flutter_kline/common/widget/color_block_widget.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';
import 'package:flutter_kline/widget/bottom_date_widget.dart';
import 'package:flutter_kline/widget/k_chart_controller.dart';
import 'package:flutter_kline/widget/k_chart_widget.dart';
import 'package:flutter_kline/widget/k_line_chart_widget.dart';

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

class _ExampleDayWidgetState extends State<ExampleDayWidget>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey _chartKey = GlobalKey();

  late KChartController _controller;
  late KChartDataSource _source;

  DrawChartType _drawMode = DrawChartType.none;

  @override
  void initState() {
    var candlestickData = ExampleCandlestickData.getCandlestickData();

    _source = KChartDataSource(originCharts: [
      ChartData(id: '0', name: 'MA', baseCharts: [
        candlestickData,
        ...ExampleLineData.getLineChartMA13(),
        ExampleBadgeData.badgeChartVo,
        // ExampleVerticalLineData.verticalLine,
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
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: ListView(
        children: [
          Column(
            children: [
              DrawModeWidget(
                drawMode: _drawMode,
                onPressed: _drawModeBtnEven,
              ),
              KChartWidget(
                key: _chartKey,
                controller: _controller,
                showDataNum: 30,
                source: _source,
                realTimePrice: 11.56,
                drawChartType: _drawMode.isNoneOrEdit ? "" : _drawMode.name,
                onTapIndicator: (index) {
                  KlineUtil.showToast(context: context, text: '点击指标索引：$index');
                },
                subChartMaskList: const [
                  null,
                  // MaskLayer(percent: 0.3),
                  // MaskLayer(percent: 0.8)
                ],
                overlayEntryLocationKey: widget.overlayEntryLocationKey,
                onHorizontalDragUpdate: (details, location) {
                  KlineUtil.logd('移动的位置：$location');
                },
                drawChartCallback: _drawChartCallback,
              ),
              SizedBox(
                height: 12,
                // color: Colors.yellow,
                child: StreamBuilder<int>(
                    stream: _controller.crossCurveIndexStream.stream,
                    builder: (context, snapshot) {
                      DateTime? currentDate;
                      if (_controller.isShowCrossCurve) {
                        currentDate = _controller.source
                            .showChartDateTimeByIndex(snapshot.data ?? 0);
                      }

                      return ListenableBuilder(
                          listenable: _controller.source,
                          builder: (context, _) {
                            double leftPadding =
                                _controller.crossCurveGlobalPosition.dx;
                            RenderObject? renderBox =
                                _chartKey.currentContext?.findRenderObject();
                            if (renderBox != null && renderBox is RenderBox) {
                              try {
                                leftPadding = renderBox
                                    .globalToLocal(
                                        _controller.crossCurveGlobalPosition)
                                    .dx;
                              } catch (e) {
                                KlineUtil.loge(e.toString());
                              }
                            }

                            return BottomDateWidget(
                              startDate:
                                  _controller.source.showChartStartDateTime,
                              endDate: _controller.source.showChartEndDateTime,
                              periodNumber: _controller.source.showDataNum,
                              currentDateLeftPadding: leftPadding,
                              currentDate: currentDate,
                            );
                          });
                    }),
              )
            ],
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

  /// 画图回调
  void _drawChartCallback(DrawChartCallback value) {
    BaseChart data = value.chart.autoCompleteData(
      maxLength: _source.dataMaxLength,
      currentIndex: _source.showDataStartIndex,
    );
    _source.originCharts.first.baseCharts.add(data);
    _drawMode = DrawChartType.edit;
    setState(() {});
  }

  /// 画线按钮事件
  void _drawModeBtnEven(DrawChartType type) {
    _drawMode = type;
    _controller.hideCrossCurve();
    _controller.hideOverlayEntry();
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}



enum DrawChartType {

  /// 无样式
  none,

  /// 编辑模式
  edit,

  /// 线图
  line,

  circle,
  ;

  bool get isNone {
    return this == none;
  }

  bool get isNoneOrEdit {
    return this == none || this == edit;
  }

}