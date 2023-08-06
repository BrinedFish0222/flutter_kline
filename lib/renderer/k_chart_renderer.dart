import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_chart_painter.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/k_chart_renderer_config.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

/// K线图渲染器
/// 计算：
///   - 点的宽度
///   - 高度范围
class KChartRenderer extends CustomPainter {
  /// 蜡烛图数据
  final List<CandlestickChartVo?> candlestickCharData;

  /// 折线数据
  final List<LineChartVo?>? lineChartData;

  /// 矩形中间的横线
  final int rectTransverseLineNum;

  /// 数据宽度和空间间隔比
  final double candlestickGapRatio;

  /// TODO 目前只有 right 生效。
  final EdgeInsets? margin;

  final KChartRendererConfig config;

  const KChartRenderer(
      {required this.candlestickCharData,
      this.lineChartData,
      this.rectTransverseLineNum = 2,
      this.candlestickGapRatio = 3,
      this.margin,
      required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("KChartRenderer paint run ...");
    Size marginSize =
        margin == null ? size : Size(size.width - margin!.right, size.height);

    Pair<double, double> heightRange = getHeightRange();
    config.pointWidth = getPointWidth(size: marginSize);
    config.pointGap = config.pointWidth! / candlestickGapRatio;

    // 画矩形
    RectPainter(
            size: size,
            transverseLineNum: rectTransverseLineNum,
            maxValue: heightRange.left,
            minValue: heightRange.right,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(color: Colors.grey, fontSize: 8))
        .paint(canvas, size);

    // 画蜡烛图
    CandlestickChartPainter(
      dataList: candlestickCharData,
      maxMinHeight: heightRange,
      pointWidth: config.pointWidth!,
      pointGap: config.pointGap!,
    ).paint(canvas, marginSize);

    // 画折线
    if (KlineCollectionUtil.isNotEmpty(lineChartData)) {
      LineChartPainter(
              lineChartData: lineChartData!,
              size: size,
              maxMinValue: heightRange)
          .paint(canvas, marginSize);
    }
  }

  /// 获取点宽度
  double getPointWidth({required Size size}) {
    /// 画布长 / (数据数组长度 * 数据宽度和空间间隔比 + 数据数组长度 - 1)
    /// 示例：800 / (50 * 3 + 50 - 1);
    var s = size.width /
        (candlestickGapRatio * candlestickCharData.length +
            candlestickCharData.length -
            1);
    return s * candlestickGapRatio;
  }

  /// 获取高度范围
  Pair<double, double> getHeightRange() {
    Pair<double, double> result =
        CandlestickChartVo.getHeightRange(candlestickCharData);

    lineChartData?.forEach((element) {
      element?.dataList?.forEach((data) {
        result.left = (data.value ?? -double.maxFinite) > result.left
            ? data.value!
            : result.left;
        result.right = (data.value ?? double.maxFinite) < result.right
            ? data.value!
            : result.right;
      });
    });

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
