import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/minute_chart_renderer.dart';

import '../chart/base_chart.dart';
import '../common/chart_show_data_item_vo.dart';
import '../chart/line_chart.dart';
import '../common/kline_config.dart';
import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import '../utils/kline_collection_util.dart';
import '../utils/kline_num_util.dart';
import '../utils/kline_util.dart';

/// 分时图
class MinuteChartWidget extends StatefulWidget {
  const MinuteChartWidget({
    super.key,
    required this.size,
    String? name,
    required this.minuteChartData,
    this.minuteChartSubjoinData,
    required this.middleNum,
    this.differenceNumbers,
    this.pointWidth,
    this.pointGap,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
    this.dataNum = KlineConfig.minuteDataNum,
    required this.onTapIndicator,
  }) : name = name ?? '分时图';

  final Size size;

  final String name;

  /// 分时图数据 - 分时数据
  final LineChart minuteChartData;

  /// 分时图数据 - 附加数据
  final List<BaseChart>? minuteChartSubjoinData;

  /// 中间值
  final double middleNum;

  /// 额外增加的差值：这些数据会加入和 [middleNum] 进行差值比较
  /// 常设值：最高价、最低价
  final List<double>? differenceNumbers;

  final double? pointWidth;
  final double? pointGap;

  /// 数据点
  final int dataNum;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 十字线选中数据索引流
  final StreamController<int>? selectedChartDataIndexStream;

  /// 点击股票指标事件
  final void Function() onTapIndicator;

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
      if (index == -1 || (widget.minuteChartSubjoinData?.length ?? 0 - 1) < index) {
        List<ChartShowDataItemVo>? showData =
            BaseChart.getLastShowData(widget.minuteChartSubjoinData);
        _minuteChartSelectedDataStream.add(MinuteChartSelectedDataVo(
            overlayData: null, indicatorsData: showData));

        return;
      }

      List<ChartShowDataItemVo>? showData =
          BaseChart.getShowDataByIndex(widget.minuteChartSubjoinData, index);
      _minuteChartSelectedDataStream.add(MinuteChartSelectedDataVo(
          overlayData: null, indicatorsData: showData));
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxMinValue = _computeMaxMinValue();

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: Column(
        children: [
          // 信息栏
          SizedBox(
            height: KlineConfig.showDataSpaceSize,
            child: Row(children: [
              InkWell(
                onTap: widget.onTapIndicator,
                child: Row(
                  children: [
                    Text(
                      widget.name,
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
    
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        key: _chartKey,
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: MinuteChartRenderer(
                          minuteChartVo: widget.minuteChartData,
                          minuteChartSubjoinData: widget.minuteChartSubjoinData,
                          middleNum: widget.middleNum,
                          differenceNumbers: widget.differenceNumbers,
                          // maxMinValue: maxMinValue,
                        ),
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
                                  pointWidth: widget.pointWidth,
                                  pointGap: widget.pointGap),
                            );
                          }),
                    )
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Pair<double, double> _computeMaxMinValue() {
    var minuteChartVo = widget.minuteChartData;
    var minuteChartSubjoinData = widget.minuteChartSubjoinData;
    var middleNum = widget.middleNum;
    var differenceNumbers = widget.differenceNumbers;
    // 统计所有数据的最大最小值
    Pair<double, double> maxMinValue = Pair.getMaxMinValue([
      minuteChartVo.getMaxMinData(),
      ...minuteChartSubjoinData?.map((e) => e.getMaxMinData()).toList() ?? []
    ], defaultMaxValue: middleNum + 0.1, defaultMinValue: middleNum - 0.1);
    // 找出最大差值
    var maxDifference = KlineNumUtil.findNumberWithMaxDifference(
        [maxMinValue.left, maxMinValue.right, ...differenceNumbers ?? []],
        middleNum);
    double differenceValue = (maxDifference - middleNum).abs();

    maxMinValue.left = middleNum + differenceValue;
    maxMinValue.right = middleNum - differenceValue;

    return maxMinValue;
  }
}


/// 分时图显示的选中数据
class MinuteChartSelectedDataVo {
  /// 悬浮数据
  List<ChartShowDataItemVo?>? overlayData;

  /// 显示的指标数据
  List<ChartShowDataItemVo?>? indicatorsData;

  MinuteChartSelectedDataVo({this.overlayData, this.indicatorsData});

  /// 获取分时最后一根显示的数据
  static MinuteChartSelectedDataVo getLastShowData(
      {required LineChart minuteChartData,
        List<BaseChart>? minuteChartSubjoinData}) {
    MinuteChartSelectedDataVo result = MinuteChartSelectedDataVo();

    var selectedShowData = minuteChartData.getSelectedShowData();
    if (KlineCollectionUtil.isNotEmpty(selectedShowData)) {
      result.overlayData = [minuteChartData.getSelectedShowData()!.last];
    }

    if (KlineCollectionUtil.isEmpty(minuteChartSubjoinData)) {
      return result;
    }

    result.indicatorsData = minuteChartSubjoinData!
        .map((e) => e.getSelectedShowData())
        .where((e) => KlineCollectionUtil.isNotEmpty(e))
        .map((e) => e!.last)
        .toList();

    return result;
  }
}