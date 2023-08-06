import 'package:flutter/material.dart';

import '../common/pair.dart';

/// 十字线 CrossCurvePainter
class CrossCurvePainter extends CustomPainter {
  /// 选中的x、y
  final Pair<double?, double?>? selectedXY;

  /// 数据点宽度。
  final double? pointWidth;

  /// 数据点间隔。
  final double? pointGap;

  /// 图 margin 信息
  final EdgeInsets? margin;

  const CrossCurvePainter(
      {required this.selectedXY, this.pointWidth, this.pointGap, this.margin});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedXY == null) {
      return;
    }

    Pair<double?, double?>? newSelectedXY = _computeSelectedX();

    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    if (newSelectedXY!.left != null) {
      canvas.drawLine(Offset(newSelectedXY.left!, 0),
          Offset(newSelectedXY.left!, size.height), paint);
    }

    if (newSelectedXY.right != null) {
      canvas.drawLine(Offset(0, newSelectedXY.right!),
          Offset(size.width, newSelectedXY.right!), paint);
    }
  }

  /// 重新计算选中的x轴。
  /// 让 x 轴处于每个规定好的范围内（蜡烛）。
  Pair<double?, double?>? _computeSelectedX() {
    if (selectedXY == null) {
      return null;
    }

    if (selectedXY!.left == null || pointWidth == null) {
      return selectedXY;
    }

    double gap = pointGap ?? 0;
    double oldX = selectedXY!.left!;
    double newX =
        oldX ~/ (pointWidth! + gap) * (pointWidth! + gap) + pointWidth! / 2;

    return Pair(left: newX, right: selectedXY?.right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
