import 'package:flutter/material.dart';

/// 画蜡烛
class CandlestickPainter extends CustomPainter {
  final Rect rect;
  final double top;
  final double bottom;
  final Color lineColor;
  final Color? rectFillColor;

  const CandlestickPainter({
    required this.rect,
    required this.top,
    required this.bottom,
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

    double lineX = rect.left + ((rect.right - rect.left).abs()) / 2;
    canvas.drawRect(rect, paint);

    paint
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    double topY = rect.top > rect.bottom ? rect.bottom : rect.top;
    double bottomY = rect.top > rect.bottom ? rect.top : rect.bottom;
    // 最高线
    canvas.drawLine(Offset(lineX, top), Offset(lineX, topY), paint);
    // 最低线
    canvas.drawLine(Offset(lineX, bottom), Offset(lineX, bottomY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
