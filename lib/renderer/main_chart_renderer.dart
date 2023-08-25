import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_chart_painter.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

/// 主图渲染器
class MainChartRenderer extends CustomPainter {
  /// 蜡烛图数据
  final CandlestickChartVo candlestickCharData;

  /// 折线数据
  final List<LineChartVo?>? lineChartData;

  /// 矩形中间的横线
  final int rectTransverseLineNum;

  /// 数据宽度和空间间隔比
  final double candlestickGapRatio;

  /// TODO 目前只有 right 生效。
  final EdgeInsets? margin;
  final double? pointWidth;
  final double? pointGap;

  const MainChartRenderer({
    required this.candlestickCharData,
    this.lineChartData,
    this.rectTransverseLineNum = 2,
    this.candlestickGapRatio = 3,
    this.margin,
    this.pointWidth,
    this.pointGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("KChartRenderer paint run ...");
    Size marginSize =
        margin == null ? size : Size(size.width - margin!.right, size.height);

    Pair<double, double> heightRange = getHeightRange();
    double pointWidth = this.pointWidth ??
        KlineUtil.getPointWidth(
            width: marginSize.width,
            dataLength: candlestickCharData.dataList.length,
            gapRatio: candlestickGapRatio);
    double pointGap = this.pointGap ?? pointWidth / candlestickGapRatio;

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
      data: candlestickCharData,
      maxMinHeight: heightRange,
      pointWidth: pointWidth,
      pointGap: pointGap,
    ).paint(canvas, marginSize);

    // 画折线
    if (KlineCollectionUtil.isNotEmpty(lineChartData)) {
      LineChartPainter(
              lineChartData: lineChartData!,
              maxMinValue: heightRange,
              pointWidth: pointWidth,
              pointGap: pointGap)
          .paint(canvas, marginSize);
    }
  }

  /// 获取高度范围
  Pair<double, double> getHeightRange() {
    Pair<double, double> result = candlestickCharData.getMaxMinData();

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
