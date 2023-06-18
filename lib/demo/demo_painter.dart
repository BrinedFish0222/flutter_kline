import 'package:flutter/material.dart';

class DemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("size: widget ${size.width}, height ${size.height}");
    Rect rect = Offset.zero & size;

    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(rect.bottomLeft, 30, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
