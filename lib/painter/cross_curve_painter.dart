import 'dart:async';

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

  final StreamController<int>? selectedDataIndexStream;

  const CrossCurvePainter(
      {required this.selectedXY,
      this.pointWidth,
      this.pointGap,
      this.margin,
      this.selectedDataIndexStream});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedXY == null) {
      return;
    }

    /// x轴超出范围不画
    if (selectedXY!.left != null && selectedXY!.left! > size.width) {
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

    debugPrint("newSelectedXY.right: ${newSelectedXY.right}");
    if (newSelectedXY.right != null) {
      bool isOutRange =
          newSelectedXY.right! > size.height || newSelectedXY.right! < 0;
      if (isOutRange) {
        canvas.drawLine(Offset(0, newSelectedXY.right!),
            Offset(0, newSelectedXY.right!), paint);
      } else {
        canvas.drawLine(Offset(0, newSelectedXY.right!),
            Offset(size.width, newSelectedXY.right!), paint);
      }
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
    int dataIndex = oldX ~/ (pointWidth! + gap);
    double newX = dataIndex * (pointWidth! + gap) + pointWidth! / 2;

    // 通知选中的k线变了
    selectedDataIndexStream?.add(dataIndex);
    return Pair(left: newX, right: selectedXY?.right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
