import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_painter.dart';
import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

/// 蜡烛图
/// 影响蜡烛图的宽度：自身宽度和下一根蜡烛的间隔距离，1根蜡烛大概等于3个间隔宽度。
class CandlestickChartPainter extends CustomPainter {
  final CandlestickChartVo data;

  /// 高度范围。左 最高，右 最低。
  final Pair<num, num> maxMinHeight;

  /// 数据点宽度。
  final double pointWidth;

  /// 数据点间隔。
  final double pointGap;

  final Pair<num, num>? maxMinValue;

  const CandlestickChartPainter(
      {required this.data,
      required this.maxMinHeight,
      required this.pointWidth,
      required this.pointGap,
      this.maxMinValue});

  @override
  void paint(Canvas canvas, Size size) {
    List<CandlestickChartData?> chartData =
        convertDataToChartData(canvasMaxHeight: size.height);

    int index = 0;
    double x = 0;
    for (var element in chartData) {
      if (element == null) {
        continue;
      }

      bool isUp =
          data.data[index]!.open > data.data[index]!.close ? false : true;
      CandlestickPainter(
        rect: Rect.fromLTRB(x, element.open, x + pointWidth, element.close),
        top: element.high,
        bottom: element.low,
        lineColor: isUp ? Colors.red : Colors.green,
        rectFillColor: isUp ? null : Colors.green,
      ).paint(canvas, size);

      index += 1;
      x = x + pointWidth + pointGap;
    }
  }

  List<CandlestickChartData?> convertDataToChartData(
      {required double canvasMaxHeight}) {
    // 找出非空数据数组中的最大值和最小值
    Pair<num, num> maxMinValue = this.maxMinValue ?? data.getMaxMinData();

    // 计算数据在 maxHeight 范围内的高度比例
    double scaleFactor =
        canvasMaxHeight / ((maxMinValue.left - maxMinValue.right).abs());

    // 遍历数据数组，将每个数据值转换成对应的高度值，
    List<CandlestickChartData?> result =
        data.data.where((element) => element != null).map((data) {
      double open =
          ((data!.open - maxMinValue.right) * scaleFactor - canvasMaxHeight)
              .abs()
              .toDouble();
      double close =
          ((data.close - maxMinValue.right) * scaleFactor - canvasMaxHeight)
              .abs()
              .toDouble();
      double high =
          ((data.high - maxMinValue.right) * scaleFactor - canvasMaxHeight)
              .abs()
              .toDouble();
      double low =
          ((data.low - maxMinValue.right) * scaleFactor - canvasMaxHeight)
              .abs()
              .toDouble();

      return CandlestickChartData(
          dateTime: data.dateTime,
          open: open,
          close: close,
          high: high,
          low: low);
    }).toList();

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
