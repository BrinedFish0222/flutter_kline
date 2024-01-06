import 'package:flutter/material.dart';

/// 画蜡烛
class CandlestickPainter extends CustomPainter {
  final double open;
  final double close;
  final Color lineColor;
  final Color? rectFillColor;

  const CandlestickPainter({
    required this.open,
    required this.close,
    this.lineColor = Colors.black,
    this.rectFillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = 1;
    if (rectFillColor != null) {
      paint
        ..color = rectFillColor!
        ..style = PaintingStyle.fill;
    }


    canvas.drawRect(Rect.fromLTRB(0, open, size.width, close), paint);

    paint
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    double middleX = size.width / 2;
    double topLine = open > close ? close : open;
    double bottomLine = open > close ? open : close;
    // 最高线
    canvas.drawLine(Offset(middleX, 0), Offset(middleX, topLine), paint);
    // 最低线
    canvas.drawLine(Offset(middleX, bottomLine), Offset(middleX, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CandlestickPainter) {
      return open != oldDelegate.open ||
          close != oldDelegate.close ||
          lineColor != oldDelegate.lineColor ||
          rectFillColor != oldDelegate.rectFillColor;
    }
    return true;
  }
}
