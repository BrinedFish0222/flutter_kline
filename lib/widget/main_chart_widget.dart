import 'dart:async';

import 'package:flutter/material.dart';

import '../chart/badge_chart.dart';
import '../chart/base_chart.dart';
import '../common/chart_show_data_item_vo.dart';
import '../chart/line_chart.dart';
import '../common/main_chart_selected_data_vo.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';
import '../painter/cross_curve_painter.dart';
import '../renderer/chart_renderer.dart';
import 'badge_widget.dart';
import 'main_chart_show_data_widget.dart';

class MainChartWidget extends StatefulWidget {
  const MainChartWidget({
    super.key,
    required this.size,
    this.padding,
    required this.chartData,
    this.infoBarName,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
    this.pointWidth,
    this.pointGap,
    this.candlestickGapRatio,
    required this.onTapIndicator,
    this.realTimePrice,
  });

  final Size size;
  final EdgeInsets? padding;

  /// 信息栏名称
  final String? infoBarName;

  final List<BaseChart> chartData;

  final double? pointWidth;
  final double? pointGap;
  final double? candlestickGapRatio;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 十字线选中数据索引流
  final StreamController<int>? selectedChartDataIndexStream;

  /// 点击股票指标事件
  final void Function() onTapIndicator;

  /// 实时价格
  final double? realTimePrice;

  @override
  State<MainChartWidget> createState() => _MainChartWidgetState();
}

class _MainChartWidgetState extends State<MainChartWidget> {
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream =
      StreamController();

  final GlobalKey _chartKey = GlobalKey();

  List<BadgeChart> _badgeList = [];

  @override
  void initState() {
    BadgeChart.initDataValue(widget.chartData);
    _initSelectedChartData();
    super.initState();
  }

  /// 初始化选中数据
  _initSelectedChartData() {
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      List<ChartShowDataItemVo?>? lineShowData =
          BaseChart.getSelectedShowDataByIndex(
        chartData: widget.chartData,
        index: index,
      );

      _mainChartSelectedDataStream.add(MainChartSelectedDataVo(
        candlestickChartData: null,
        lineChartList: lineShowData,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxMinValue = BaseChart.maxMinValue(widget.chartData);

    _badgeList = widget.chartData.whereType<BadgeChart>().toList();

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: Column(
        children: [
          // 信息栏
          MainChartShowDataWidget(
            initData: MainChartSelectedDataVo.getLastShowData(
              candlestickChartVo:
                  BaseChart.getCandlestickChartVo(widget.chartData),
              lineChartVoList:
                  widget.chartData.whereType<LineChart>().toList(),
            ),
            name: widget.infoBarName ?? '',
            mainChartSelectedDataStream: _mainChartSelectedDataStream,
            onTap: widget.onTapIndicator,
          ),
          Expanded(
            child: Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    key: _chartKey,
                    size: widget.size,
                    painter: ChartRenderer(
                      chartData: widget.chartData,
                      padding: widget.padding,
                      pointWidth: widget.pointWidth,
                      pointGap: widget.pointGap,
                      maxMinValue: maxMinValue,
                      candlestickGapRatio: widget.candlestickGapRatio ?? 3,
                      realTimePrice: widget.realTimePrice,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: StreamBuilder(
                      stream: widget.crossCurveStream?.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data?.isNull() ?? true) {
                          return const SizedBox();
                        }

                        Pair<double?, double?> selectedXY =
                            Pair(left: null, right: null);

                        RenderBox renderBox = _chartKey.currentContext!
                            .findRenderObject() as RenderBox;
                        if (snapshot.data != null && !snapshot.data!.isNull()) {
                          Offset? selectedOffset =
                              snapshot.data == null || snapshot.data!.isNull()
                                  ? null
                                  : renderBox.globalToLocal(
                                      Offset(snapshot.data?.left ?? 0,
                                          snapshot.data?.right ?? 0),
                                    );
                          selectedXY.left = selectedOffset?.dx;
                          selectedXY.right = selectedOffset?.dy;
                        }

                        double? selectedHorizontalValue =
                            KlineUtil.computeSelectedHorizontalValue(
                          maxMinValue: maxMinValue,
                          height: renderBox.size.height,
                          selectedY: selectedXY.right,
                        );

                        return CustomPaint(
                          size: widget.size,
                          painter: CrossCurvePainter(
                              selectedXY: selectedXY,
                              padding: widget.padding,
                              selectedHorizontalValue: selectedHorizontalValue,
                              pointWidth: widget.pointWidth,
                              pointGap: widget.pointGap),
                        );
                      }),
                ),

                /// badge
                for (BadgeChart vo in _badgeList)
                  BadgeWidget(
                    badgeChartVo: vo,
                    padding: widget.padding ?? EdgeInsets.zero,
                    pointWidth: widget.pointWidth,
                    pointGap: widget.pointGap ?? 0,
                    maxMinValue: maxMinValue,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
