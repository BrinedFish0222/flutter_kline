import 'dart:async';

import 'package:flutter/material.dart';

import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import '../renderer/main_chart_renderer.dart';
import '../utils/kline_util.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/chart_show_data_item_vo.dart';
import '../vo/line_chart_vo.dart';
import '../vo/main_chart_selected_data_vo.dart';
import 'main_chart_show_data_widget.dart';

class MainChartWidget extends StatefulWidget {
  const MainChartWidget({
    super.key,
    required this.size,
    this.margin,
    required this.candlestickChartData,
    this.lineChartData,
    this.lineChartName,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
    this.pointWidth,
    this.pointGap,
    this.candlestickGapRatio,
    required this.onTapIndicator,
  });

  final Size size;
  final EdgeInsets? margin;
  final CandlestickChartVo? candlestickChartData;
  final String? lineChartName;
  final List<LineChartVo>? lineChartData;

  final double? pointWidth;
  final double? pointGap;
  final double? candlestickGapRatio;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 十字线选中数据索引流
  final StreamController<int>? selectedChartDataIndexStream;

  /// 点击股票指标事件
  final void Function() onTapIndicator;

  @override
  State<MainChartWidget> createState() => _MainChartWidgetState();
}

class _MainChartWidgetState extends State<MainChartWidget> {
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream =
      StreamController();

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    _initSelectedChartData();
    super.initState();
  }

  /// 初始化选中数据
  _initSelectedChartData() {
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      if (index == -1) {
        List<ChartShowDataItemVo?>? lineShowData = widget.lineChartData
            ?.map((e) => e.getSelectedShowData()?.last)
            .toList();

        return _mainChartSelectedDataStream.add(MainChartSelectedDataVo(
            candlestickChartData: null, lineChartList: lineShowData));
      }

      List<ChartShowDataItemVo?>? lineShowData = widget.lineChartData
          ?.map((e) => e.getSelectedShowData()?[index])
          .toList();
      _mainChartSelectedDataStream.add(MainChartSelectedDataVo(
          candlestickChartData: null, lineChartList: lineShowData));
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxMinValue = KlineUtil.getMaxMinValue(
        candlestickCharVo: widget.candlestickChartData,
        chartDataList: widget.lineChartData);
    widget.selectedChartDataIndexStream?.add(-1);

    return SizedBox(
      width: widget.size.width,
      child: Column(
        children: [
          // 信息栏
          MainChartShowDataWidget(
            initData: MainChartSelectedDataVo.getLastShowData(
                candlestickChartVo: widget.candlestickChartData,
                lineChartVoList: widget.lineChartData),
            name: widget.lineChartName ?? '',
            mainChartSelectedDataStream: _mainChartSelectedDataStream,
            onTap: widget.onTapIndicator,
          ),
          Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  key: _chartKey,
                  size: widget.size,
                  painter: MainChartRenderer(
                      candlestickCharData: widget.candlestickChartData!,
                      lineChartData: widget.lineChartData,
                      margin: widget.margin,
                      pointWidth: widget.pointWidth,
                      pointGap: widget.pointGap,
                      maxMinValue: maxMinValue,
                      candlestickGapRatio: widget.candlestickGapRatio ?? 3),
                ),
              ),
              RepaintBoundary(
                child: StreamBuilder(
                    stream: widget.crossCurveStream?.stream,
                    builder: (context, snapshot) {
                      Pair<double?, double?> selectedXY =
                          Pair(left: null, right: null);
                      if (snapshot.data != null && !snapshot.data!.isNull()) {
                        RenderBox renderBox = _chartKey.currentContext!
                            .findRenderObject() as RenderBox;

                        Offset? selectedOffset =
                            snapshot.data == null || snapshot.data!.isNull()
                                ? null
                                : renderBox.globalToLocal(Offset(
                                    snapshot.data?.left ?? 0,
                                    snapshot.data?.right ?? 0));
                        selectedXY.left = selectedOffset?.dx;
                        selectedXY.right = selectedOffset?.dy;
                      }

                      double? selectedHorizontalValue =
                          KlineUtil.computeSelectedHorizontalValue(
                              maxMinValue: maxMinValue,
                              height: widget.size.height,
                              selectedY: selectedXY.right);

                      return CustomPaint(
                        size: widget.size,
                        painter: CrossCurvePainter(
                            selectedXY: selectedXY,
                            margin: widget.margin,
                            selectedHorizontalValue: selectedHorizontalValue,
                            selectedDataIndexStream:
                                widget.selectedChartDataIndexStream,
                            pointWidth: widget.pointWidth,
                            pointGap: widget.pointGap),
                      );
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }
}
