import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/renderer/chart_renderer.dart';
import 'package:flutter_kline/setting/rect_setting.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../chart/base_chart.dart';
import '../chart/line_chart.dart';
import '../common/constants/line_type.dart';
import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';

/// 分时图
class MinuteChartRenderer extends CustomPainter {
  final LineChart minuteChartVo;
  final List<BaseChart>? minuteChartSubjoinData;

  /// 中间值
  final double middleNum;

  /// 额外增加的差值：这些数据会加入和 [middleNum] 进行差值比较
  /// 常设值：最高价、最低价
  final List<double>? differenceNumbers;

  /// 数据点，一天默认有240个时间点
  final int dataNum;

  final Pair<double, double>? maxMinValue;

  const MinuteChartRenderer({
    required this.minuteChartVo,
    this.minuteChartSubjoinData,
    required this.middleNum,
    this.differenceNumbers,
    this.dataNum = KlineConfig.minuteDataNum,
    this.maxMinValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    LineChart minuteChartVo = _initData();
    List<BaseChart>? minuteChartSubjoinData = _initSubData();

    // 统计所有数据的最大最小值
    Pair<double, double> maxMinValue = _computeMaxMinValue();

    // 画矩形
    RectPainter(
      transverseLineNum: 3,
      transverseLineConfigList: [null, RectLineConfig(type: LineType.dotted)],
      maxValue: maxMinValue.left,
      minValue: maxMinValue.right,
      isDrawVerticalLine: true,
      textStyle: const TextStyle(
          color: Colors.grey, fontSize: KlineConfig.rectFontSize),
    ).paint(canvas, size);

    if (KlineCollectionUtil.isNotEmpty(minuteChartSubjoinData)) {
      ChartRenderer(
        chartData: minuteChartSubjoinData!,
        rectSetting: const RectSetting(isShow: false),
        maxMinValue: maxMinValue,

      ).paint(canvas, size);
    }

    LineChartPainter(
      lineChartData: minuteChartVo,
      maxMinValue: maxMinValue,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  LineChart _initData() {
    LineChart minuteChartVo = this.minuteChartVo.copy() as LineChart;

    if (dataNum <= minuteChartVo.data.length) {
      minuteChartVo.data =
          KlineCollectionUtil.lastN(minuteChartVo.data, dataNum) ?? [];
      return minuteChartVo;
    }

    int diff = dataNum - minuteChartVo.data.length;
    for (int i = 0; i < diff; ++i) {
      minuteChartVo.data.add(LineChartData(id: i.toString()));
    }

    return minuteChartVo;
  }

  List<BaseChart<BaseChartData>>? _initSubData() {
    if (minuteChartSubjoinData?.isEmpty ?? true) {
      return null;
    }

    List<BaseChart<BaseChartData>> result = [];
    for (BaseChart subData in minuteChartSubjoinData!) {
      var newSubData = subData.subData(start: 0, end: dataNum);
      result.add(newSubData);
    }
    return result;
  }

  /// 计算最大最小值
  Pair<double, double> _computeMaxMinValue() {
    if (this.maxMinValue != null) {
      return this.maxMinValue!;
    }

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
