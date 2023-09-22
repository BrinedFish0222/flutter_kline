import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

/// 三角形
class TrianglePainter extends CustomPainter {
  final Color fillColor;

  const TrianglePainter({this.fillColor = KlineConfig.realTimeLineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.save();
    canvas.translate(0, size.height);
    canvas.rotate(-90 * 3.1415927 / 180);

    canvas.drawPath(path, paint);
    // paint.color = Colors.black;
    // canvas.drawRect(Offset.zero & size, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
