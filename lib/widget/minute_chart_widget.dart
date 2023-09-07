import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/minute_chart_renderer.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

import '../common/kline_config.dart';
import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import '../utils/kline_util.dart';
import '../vo/chart_show_data_item_vo.dart';
import '../vo/minute_chart_selected_data_vo.dart';

/// 分时图
class MinuteChartWidget extends StatefulWidget {
  const MinuteChartWidget({
    super.key,
    required this.size,
    required this.minuteChartData,
    this.minuteChartSubjoinData,
    required this.middleNum,
    this.differenceNumbers,
    this.pointWidth,
    this.pointGap,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
  });

  final Size size;

  /// 分时图数据 - 分时数据
  final LineChartVo minuteChartData;

  /// 分时图数据 - 附加数据
  final List<BaseChartVo>? minuteChartSubjoinData;

  /// 中间值
  final double middleNum;

  /// 额外增加的差值：这些数据会加入和 [middleNum] 进行差值比较
  /// 常设值：最高价、最低价
  final List<double>? differenceNumbers;

  final double? pointWidth;
  final double? pointGap;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 十字线选中数据索引流
  final StreamController<int>? selectedChartDataIndexStream;

  @override
  State<MinuteChartWidget> createState() => _MinuteChartWidgetState();
}

class _MinuteChartWidgetState extends State<MinuteChartWidget> {
  /// 分时图显示选中数据流
  final StreamController<MinuteChartSelectedDataVo>
      _minuteChartSelectedDataStream = StreamController();

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    _initSelectedChartData();
    super.initState();
  }

  @override
  void dispose() {
    _minuteChartSelectedDataStream.close();
    super.dispose();
  }

  /// 初始化选中数据
  _initSelectedChartData() {
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      debugPrint("分时选中数据索引：$index");
      if (index == -1) {
        List<ChartShowDataItemVo>? showData =
            BaseChartVo.getLastShowData(widget.minuteChartSubjoinData);
        _minuteChartSelectedDataStream.add(MinuteChartSelectedDataVo(
            overlayData: null, indicatorsData: showData));

        return;
      }

      List<ChartShowDataItemVo>? showData =
          BaseChartVo.getShowDataByIndex(widget.minuteChartSubjoinData, index);
      _minuteChartSelectedDataStream.add(MinuteChartSelectedDataVo(
          overlayData: null, indicatorsData: showData));
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxMinValue = widget.minuteChartData.getMaxMinData();

    return Column(
      children: [
        // 信息栏
        SizedBox(
          height: KlineConfig.showDataSpaceSize,
          child: Row(children: [
            InkWell(
              onTap: () => debugPrint("主图信息栏点击"),
              child: Row(
                children: [
                  Text(
                    KlineCollectionUtil.isEmpty(widget.minuteChartSubjoinData)
                        ? '分时图'
                        : widget.minuteChartSubjoinData!.first.name ?? '分时图',
                    style:
                        const TextStyle(fontSize: KlineConfig.showDataFontSize),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: KlineConfig.showDataIconSize,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<MinuteChartSelectedDataVo>(
                  initialData: MinuteChartSelectedDataVo.getLastShowData(
                      minuteChartData: widget.minuteChartData,
                      minuteChartSubjoinData: widget.minuteChartSubjoinData),
                  stream: _minuteChartSelectedDataStream.stream,
                  builder: (context, snapshot) {
                    var data = snapshot.data;

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: data?.indicatorsData
                              ?.where((element) => element?.value != null)
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Center(
                                      child: Text(
                                        '${e?.name} ${e?.value?.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: e?.color,
                                            fontSize:
                                                KlineConfig.showDataFontSize),
                                      ),
                                    ),
                                  ))
                              .toList() ??
                          [],
                    );
                  }),
            )
          ]),
        ),

        Stack(
          children: [
            RepaintBoundary(
              child: CustomPaint(
                key: _chartKey,
                size: widget.size,
                painter: MinuteChartRenderer(
                    minuteChartVo: widget.minuteChartData,
                    minuteChartSubjoinData: widget.minuteChartSubjoinData,
                    middleNum: widget.middleNum,
                    differenceNumbers: widget.differenceNumbers),
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
    );
  }
}