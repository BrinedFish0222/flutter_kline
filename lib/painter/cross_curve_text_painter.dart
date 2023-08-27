import 'package:flutter/material.dart';

/// 十字线文本
class CrossCurveTextPainter extends CustomPainter {
  /// 文本
  final String text;
  final TextStyle textStyle;
  /// 显示的位置
  final Offset offset;
  final Color backgroundColor;

  const CrossCurveTextPainter(
      {required this.text,
      this.textStyle = const TextStyle(fontSize: 9, color: Colors.white),
      required this.offset,
      this.backgroundColor = const Color(0xFFA3E1FF)});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    var textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr)
      ..layout();

    RRect rect = _computeRRect(textPainter: textPainter);
    canvas.drawRRect(rect, paint);
    // (rect.top - rect.bottom) / 2 为了让文本处于矩形范围中间。
    textPainter.paint(canvas, Offset(offset.dx, offset.dy + (rect.top - rect.bottom) / 2));
  }

  /// 计算矩形范围
  RRect _computeRRect({required TextPainter textPainter}) {
    // textPainter.height / 2 是为了让矩形处于 y 轴中间。
    double top = offset.dy - textPainter.height / 2;
    double bottom = offset.dy + textPainter.height / 2;

    return RRect.fromLTRBR(
        offset.dx,
        top,
        offset.dx + textPainter.width,
        bottom,
        const Radius.circular(2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
