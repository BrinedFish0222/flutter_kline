import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_chart_painter.dart';
import 'package:flutter_kline/painter/price_line_painter.dart';
import 'package:flutter_kline/setting/rect_setting.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../painter/bar_chart_painter.dart';
import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/bar_chart_vo.dart';
import '../vo/base_chart_vo.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

/// 图渲染器
class ChartRenderer extends CustomPainter {
  /// 图数据
  final List<BaseChartVo> chartData;

  /// 矩形设置
  final RectSetting rectSetting;

  /// 数据宽度和空间间隔比
  final double candlestickGapRatio;

  final EdgeInsets padding;
  final double? pointWidth;
  final double? pointGap;

  final Pair<double, double>? maxMinValue;

  /// 实时价格
  final double? realTimePrice;

  const ChartRenderer({
    required this.chartData,
    this.rectSetting = const RectSetting(),
    this.candlestickGapRatio = 3,
    EdgeInsets? padding,
    this.pointWidth,
    this.pointGap,
    this.maxMinValue,
    this.realTimePrice,
  }) : padding = padding ?? EdgeInsets.zero;

  @override
  void paint(Canvas canvas, Size size) {
    Size paddingSize =
        Size(size.width - padding.right - padding.left, size.height);

    Pair<double, double> maxMinValue =
        this.maxMinValue ?? BaseChartVo.maxMinValue(chartData);
    double pointWidth = this.pointWidth ??
        KlineUtil.getPointWidth(
          width: paddingSize.width,
          dataLength: chartData.first.dataLength,
          gapRatio: candlestickGapRatio,
        );
    double pointGap = this.pointGap ?? pointWidth / candlestickGapRatio;

    CandlestickChartVo? candlestickChartVo =
        BaseChartVo.getCandlestickChartVo(chartData);

    // 画矩形
    if (rectSetting.isShow) {
      canvas.save();
      RectPainter(
        transverseLineNum: rectSetting.transverseLineNum,
        maxValue: maxMinValue.left,
        minValue: maxMinValue.right,
        isDrawVerticalLine: true,
        textStyle: TextStyle(
          color: rectSetting.color,
          fontSize: KlineConfig.rectFontSize,
        ),
      ).paint(canvas, size);
      canvas.restore();
    }

    // 画完矩形，将画笔移到对应的画图起点
    canvas.translate(padding.left, 0);
    for (var data in chartData) {
      data.paint(
        canvas: canvas,
        size: paddingSize,
        maxMinValue: maxMinValue,
        pointWidth: pointWidth,
        pointGap: pointGap,
        padding: padding,
      );
    }

    // 将画笔移回原位
    canvas.translate(-padding.left, 0);
    // 实时价格线
    if (realTimePrice != null && candlestickChartVo != null) {
      bool isRealTime = candlestickChartVo.data.last?.close == realTimePrice;
      PriceLinePainter(
        price: realTimePrice!,
        maxMinValue: maxMinValue,
        style: isRealTime
            ? const PriceLinePainterStyle()
            : const PriceLinePainterStyle(
                color: KlineConfig.realTimeLineColor2,
              ),
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
