import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/sub_chart_renderer.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import 'sub_chart_show_data_widget.dart';

/// 副图组件
class SubChartWidget extends StatefulWidget {
  const SubChartWidget(
      {super.key,
      required this.size,
      required this.name,
      required this.chartData,
      this.pointWidth,
      this.pointGap,
      this.crossCurveStream,
      this.selectedChartDataIndexStream});

  final Size size;
  final String name;
  final List<BaseChartVo> chartData;
  final double? pointWidth;
  final double? pointGap;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  final StreamController<int>? selectedChartDataIndexStream;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  final StreamController<List<ChartShowDataItemVo>> _chartShowDataItemsStream =
      StreamController();

  @override
  void initState() {
    // 监听选中的数据索引位置
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      debugPrint("副图触发【监听选中的数据索引位置】监听");
      List<ChartShowDataItemVo> showDataList = [];

      for (var data in widget.chartData) {
        var showData = KlineCollectionUtil.getByIndex(
            data.getSelectedShowData(), index,
            indexMinZeroValue: data.getSelectedShowData()?.last);
        if (showData == null) {
          continue;
        }
        showDataList.add(showData);
      }
      _chartShowDataItemsStream.add(showDataList);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 信息栏
        SubChartShowDataWidget(
            name: widget.name,
            onTapName: () => debugPrint("副图点击"),
            chartShowDataItemsStream: _chartShowDataItemsStream),
        Stack(
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: widget.size,
                painter: SubChartRenderer(
                    chartData: widget.chartData,
                    pointWidth: widget.pointWidth,
                    pointGap: widget.pointGap),
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
                        pointWidth: widget.pointWidth,
                        pointGap: widget.pointGap,
                        // margin: widget.margin,
                        // selectedDataIndexStream:
                        //     widget.selectedChartDataIndexStream,
                      ),
                    );
                  }),
            )
          ],
        ),
      ],
    );
  }
}
