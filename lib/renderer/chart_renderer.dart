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

  /// TODO 目前只有 right 生效。
  final EdgeInsets? margin;
  final double? pointWidth;
  final double? pointGap;

  final Pair<double, double>? maxMinValue;

  /// 实时价格
  final double? realTimePrice;

  const ChartRenderer({
    required this.chartData,
    this.rectSetting = const RectSetting(),
    this.candlestickGapRatio = 3,
    this.margin,
    this.pointWidth,
    this.pointGap,
    this.maxMinValue,
    this.realTimePrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    KlineUtil.logd("KChartRenderer paint run ...");

    Size marginSize =
        margin == null ? size : Size(size.width - margin!.right, size.height);

    Pair<double, double> maxMinValue =
        this.maxMinValue ?? BaseChartVo.maxMinValue(chartData);
    double pointWidth = this.pointWidth ??
        KlineUtil.getPointWidth(
          width: marginSize.width,
          dataLength: chartData.first.dataLength,
          gapRatio: candlestickGapRatio,
        );
    double pointGap = this.pointGap ?? pointWidth / candlestickGapRatio;

    CandlestickChartVo? candlestickChartVo =
        BaseChartVo.getCandlestickChartVo(chartData);

    // 画矩形
    if (rectSetting.isShow) {
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
    }

    for (var data in chartData) {
      if (data is CandlestickChartVo) {
        // 画蜡烛图
        CandlestickChartPainter(
          data: data,
          maxMinHeight: maxMinValue,
          pointWidth: pointWidth,
          pointGap: pointGap,
        ).paint(canvas, marginSize);

        continue;
      }

      // 画线图
      if (data is LineChartVo) {
        LineChartPainter(
          lineChartData: data,
          maxMinValue: maxMinValue,
          pointWidth: pointWidth,
          pointGap: pointGap,
        ).paint(canvas, marginSize);

        continue;
      }

      // 画柱图
      if (data is BarChartVo) {
        BarChartPainter(
          barData: data,
          pointWidth: pointWidth,
          pointGap: pointGap,
          maxMinValue: maxMinValue,
        ).paint(canvas, size);

        continue;
      }
    }

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
