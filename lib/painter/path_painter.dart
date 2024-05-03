import 'package:flutter/material.dart';

/// 路径图
class PathPainter extends CustomPainter {
  const PathPainter({required this.offsets});

  final List<Offset> offsets;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    if (offsets.isEmpty) {
      return;
    }

    Path path = Path();
    path.moveTo(offsets.first.dx, offsets.first.dy);

    for (Offset offset in offsets) {
      if (offset.dy > size.height || offset.dy < 0) {
        continue;
      }
      path.lineTo(offset.dx, offset.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
