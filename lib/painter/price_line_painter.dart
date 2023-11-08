import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/triangle_painter.dart';
import 'package:flutter_kline/utils/kline_util.dart';

/// 价格线
class PriceLinePainter extends CustomPainter {
  /// 价格
  final double price;
  final Pair<double, double> maxMinValue;
  final PriceLinePainterStyle? style;

  const PriceLinePainter(
      {required this.price, required this.maxMinValue, this.style});

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("PriceLinePainter paint");
    // 超出范围，直接结束
    if (price > maxMinValue.left || price < maxMinValue.right) {
      return;
    }

    canvas.save();

    PriceLinePainterStyle style = this.style ?? const PriceLinePainterStyle();
    var paint = Paint()
      ..color = style.color
      ..strokeWidth = style.paintStrokeWidth;

    // 计算y轴位置
    double y = KlineUtil.computeYAxisValue(
      maxMinValue: maxMinValue,
      maxHeight: size.height,
      value: price,
    );

    // 计算有多少段线
    double eachLineWidthAndGap = style.lineGap + style.eachLineWidth;
    int lineCount = (size.width ~/ eachLineWidthAndGap).toInt();
    for (int i = 0; i < lineCount; ++i) {
      canvas.drawLine(Offset(0, y), Offset(style.eachLineWidth, y), paint);
      canvas.translate(eachLineWidthAndGap, 0);
    }

    double triangleSize = 5;
    // 将画图起始点移到对的位置。
    canvas.translate(-1, y - triangleSize / 2);
    TrianglePainter(fillColor: style.color)
        .paint(canvas, Size(triangleSize, triangleSize));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! PriceLinePainter) {
      return true;
    }

    return oldDelegate.price != price ||
        oldDelegate.maxMinValue.left != maxMinValue.left ||
        oldDelegate.maxMinValue.right != maxMinValue.right;
  }
}

/// 价格线样式
class PriceLinePainterStyle {
  /// 颜色
  final Color color;

  /// 画线宽度
  final double paintStrokeWidth;

  /// 每段线宽度
  final double eachLineWidth;

  /// 线间隔
  final double lineGap;

  const PriceLinePainterStyle({
    this.color = KlineConfig.realTimeLineColor,
    this.paintStrokeWidth = 1.0,
    this.eachLineWidth = 4,
    this.lineGap = 1.8,
  });
}
