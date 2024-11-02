import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/utils/kline_collection_util.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';
import 'package:flutter_kline/widget/cross_curve_widget.dart';

import '../chart/badge_chart.dart';
import '../chart/base_chart.dart';
import '../chart/line_chart.dart';
import '../common/chart_show_data_item_vo.dart';
import '../common/main_chart_selected_data_vo.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';
import '../draw/draw_chart.dart';
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
    this.drawChartType,
    required this.drawChartCallback,
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

  /// 画图类型
  final DrawChartType? drawChartType;

  /// 画图回调
  final ValueChanged<DrawChartCallback> drawChartCallback;

  @override
  State<MainChartWidget> createState() => _MainChartWidgetState();
}

class _MainChartWidgetState extends State<MainChartWidget> {
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream =
      StreamController.broadcast();

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

    Widget chart = RepaintBoundary(
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
    );
    if (widget.drawChartType == DrawChartType.line &&
        KlineCollectionUtil.isNotEmpty(widget.chartData.first.data)) {
      debugPrint("main_chart_widget drawChartType is not null.");

      DrawChartCreator? creator = DrawChartRegister().getCreatorByKey('line');
      if (creator != null) {
        chart = creator(
          size: widget.size,
          maxMinValue: maxMinValue,
          pointWidth: widget.pointWidth ?? 0,
          pointGap: widget.pointGap ?? 0,
          padding: widget.padding ?? EdgeInsets.zero,
          candlestickChart: KlineUtil.findCandlestickChart(widget.chartData),
          drawChartCallback: widget.drawChartCallback,
          child: chart,
        );
      }
    }

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
              lineChartVoList: widget.chartData.whereType<LineChart>().toList(),
            ),
            name: widget.infoBarName ?? '',
            mainChartSelectedDataStream: _mainChartSelectedDataStream,
            onTap: widget.onTapIndicator,
          ),
          Expanded(
            child: Stack(
              children: [
                chart,

                CrossCurveWidget(
                  crossCurveStream: widget.crossCurveStream,
                  chartKey: _chartKey,
                  size: widget.size,
                  padding: widget.padding,
                  pointWidth: widget.pointWidth,
                  pointGap: widget.pointGap,
                  maxMinValue: maxMinValue,
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
