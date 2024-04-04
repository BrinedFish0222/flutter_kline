import 'package:flutter/material.dart';

extension CanvasExt on Canvas {
  /// 画虚线
  /// 注意：目前仅支持同一y轴高度的虚线
  void drawDottedLine(Offset p1, Offset p2, Paint paint,
      {double dottedLineLength = 2, double dottedLineSpace = 2}) {
    int dottedLineNum =
        (p2.dx - p1.dx) ~/ (dottedLineLength + dottedLineSpace);
    double x = 0;
    for (int i = 0; i < dottedLineNum; ++i) {
      x = i * (dottedLineLength + dottedLineSpace);
      drawLine(Offset(x, p1.dy), Offset(x + dottedLineLength, p2.dy), paint);
    }
  }
}
