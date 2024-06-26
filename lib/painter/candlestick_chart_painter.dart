import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/candlestick_painter.dart';

import '../chart/candlestick_chart.dart';

/// 蜡烛图
/// 影响蜡烛图的宽度：自身宽度和下一根蜡烛的间隔距离，1根蜡烛大概等于3个间隔宽度。
class CandlestickChartPainter extends CustomPainter {
  final CandlestickChart data;

  /// 高度范围。左 最高，右 最低。
  final Pair<num, num> maxMinHeight;

  /// 数据点宽度。
  final double pointWidth;

  /// 数据点间隔。
  final double pointGap;

  final Pair<num, num>? maxMinValue;

  const CandlestickChartPainter({
    required this.data,
    required this.maxMinHeight,
    required this.pointWidth,
    required this.pointGap,
    this.maxMinValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    List<CandlestickChartData?> chartData =
        _convertDataToChartData(canvasMaxHeight: size.height);

    int index = 0;

    double pointWidthGap = pointWidth + pointGap;
    CandlestickChartData? lastElement;
    for (var element in chartData) {
      if (element == null) {
        continue;
      }

      double translateY = lastElement == null ? element.high : element.high - lastElement.high;
      canvas.translate(0, translateY);

      Size candlestickSize = Size(pointWidth, element.low - element.high);
      bool isUp =
          data.data[index]!.open > data.data[index]!.close ? false : true;
      CandlestickPainter(
        open: element.open - element.high,
        close: element.close - element.high,
        lineColor: element.color ?? (isUp ? Colors.red : Colors.green),
        rectFillColor: isUp ? null : element.color ?? Colors.green,
      ).paint(canvas, candlestickSize);

      canvas.translate(pointWidthGap, 0);

      index += 1;
      lastElement = element;

    }
  }

  List<CandlestickChartData?> _convertDataToChartData(
      {required double canvasMaxHeight}) {
    // 找出非空数据数组中的最大值和最小值
    Pair<num, num> maxMinValue = maxMinHeight;

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

      return data.copyWith(open: open, close: close, high: high, low: low);
    }).toList();

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
