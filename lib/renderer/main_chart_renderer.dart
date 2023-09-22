import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_chart_painter.dart';
import 'package:flutter_kline/painter/price_line_painter.dart';
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

  final Pair<double, double>? maxMinValue;

  /// 实时价格
  final double? realTimePrice;

  const MainChartRenderer({
    required this.candlestickCharData,
    this.lineChartData,
    this.rectTransverseLineNum = 2,
    this.candlestickGapRatio = 3,
    this.margin,
    this.pointWidth,
    this.pointGap,
    this.maxMinValue,
    this.realTimePrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("KChartRenderer paint run ...");
    Size marginSize =
        margin == null ? size : Size(size.width - margin!.right, size.height);

    Pair<double, double> maxMinValue = this.maxMinValue ??
        KlineUtil.getMaxMinValue(
            candlestickCharVo: candlestickCharData,
            chartDataList: lineChartData);
    double pointWidth = this.pointWidth ??
        KlineUtil.getPointWidth(
            width: marginSize.width,
            dataLength: candlestickCharData.dataList.length,
            gapRatio: candlestickGapRatio);
    double pointGap = this.pointGap ?? pointWidth / candlestickGapRatio;

    // 画矩形
    RectPainter(
      transverseLineNum: rectTransverseLineNum,
      maxValue: maxMinValue.left,
      minValue: maxMinValue.right,
      isDrawVerticalLine: true,
      textStyle: const TextStyle(
          color: Colors.grey, fontSize: KlineConfig.rectFontSize),
    ).paint(canvas, size);

    // 画蜡烛图
    CandlestickChartPainter(
      data: candlestickCharData,
      maxMinHeight: maxMinValue,
      pointWidth: pointWidth,
      pointGap: pointGap,
    ).paint(canvas, marginSize);

    // 画折线
    if (KlineCollectionUtil.isNotEmpty(lineChartData)) {
      LineChartPainter(
              lineChartData: lineChartData!,
              maxMinValue: maxMinValue,
              pointWidth: pointWidth,
              pointGap: pointGap)
          .paint(canvas, marginSize);
    }

    // 实时价格线
    if (realTimePrice != null) {
      bool isRealTime =
          candlestickCharData.dataList.last?.close == realTimePrice;
      PriceLinePainter(
        price: realTimePrice!,
        maxMinValue: maxMinValue,
        style: isRealTime
            ? const PriceLinePainterStyle()
            : const PriceLinePainterStyle(
                color: KlineConfig.realTimeLineColor2),
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
