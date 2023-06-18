import 'package:flutter/material.dart';

class DemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("size: widget ${size.width}, height ${size.height}");
    canvas.save(); // 保存画布状态

    Rect rect = Offset.zero & size;

    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = Colors.pink;

    canvas.drawRect(rect, paint);

    paint = paint
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    Path circlePath = Path();
    circlePath.addOval(Rect.fromCircle(center: rect.bottomLeft, radius: 30));

    canvas.clipPath(circlePath); // 裁剪画布为圆的路径范围

    canvas.drawCircle(rect.bottomLeft, 30, paint);
    canvas.restore(); // 恢复画布状态
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
