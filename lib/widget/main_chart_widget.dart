import 'dart:async';

import 'package:flutter/material.dart';

import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import '../renderer/main_chart_renderer.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/chart_show_data_item_vo.dart';
import '../vo/line_chart_vo.dart';
import '../vo/selected_chart_data_stream_vo.dart';
import 'main_chart_show_data_widget.dart';

class MainChartWidget extends StatefulWidget {
  const MainChartWidget(
      {super.key,
      required this.size,
      this.margin,
      required this.candlestickChartData,
      this.lineChartData,
      this.lineChartName,
      this.crossCurveStream,
      this.selectedChartDataIndexStream,
      this.pointWidth,
      this.pointGap,
      this.candlestickGapRatio});

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

  @override
  State<MainChartWidget> createState() => _MainChartWidgetState();
}

class _MainChartWidgetState extends State<MainChartWidget> {
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream =
      StreamController();

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
    return Column(
      children: [
        // 信息栏
        MainChartShowDataWidget(
          name: widget.lineChartName ?? 'MA',
          mainChartSelectedDataStream: _mainChartSelectedDataStream,
        ),
        Stack(
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: widget.size,
                painter: MainChartRenderer(
                    candlestickCharData: widget.candlestickChartData!,
                    lineChartData: widget.lineChartData,
                    margin: widget.margin,
                    pointWidth: widget.pointWidth,
                    pointGap: widget.pointGap,
                    candlestickGapRatio: widget.candlestickGapRatio ?? 3),
              ),
            ),
            RepaintBoundary(
              child: StreamBuilder(
                  stream: widget.crossCurveStream?.stream,
                  builder: (context, snapshot) {
                    return CustomPaint(
                      size: widget.size,
                      painter: CrossCurvePainter(
                          selectedXY: snapshot.data,
                          margin: widget.margin,
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
    );
  }
}
