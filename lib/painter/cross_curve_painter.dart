import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/cross_curve_text_painter.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../common/pair.dart';

/// 十字线 CrossCurvePainter
class CrossCurvePainter extends CustomPainter {
  /// 选中的x、y
  final Pair<double?, double?>? selectedXY;

  /// 数据点宽度。
  final double? pointWidth;

  /// 数据点间隔。
  final double? pointGap;

  final EdgeInsets padding;

  /// 选中的y轴值
  final double? selectedHorizontalValue;

  final StreamController<int>? selectedDataIndexStream;

  /// 是否画x轴
  final bool isDrawX;

  /// 是否画y轴
  final bool isDrawY;

  /// 是否画十字线文本
  final bool isDrawText;

  final Axis selectedDataIndexAxis;

  const CrossCurvePainter({
    required this.selectedXY,
    this.pointWidth,
    this.pointGap,
    EdgeInsets? padding,
    this.selectedHorizontalValue,
    this.selectedDataIndexStream,
    this.isDrawX = true,
    this.isDrawY = true,
    this.isDrawText = true,
    this.selectedDataIndexAxis = Axis.horizontal,
  }) : padding = padding ?? EdgeInsets.zero;

  @override
  void paint(Canvas canvas, Size size) {
    // x轴空或超出范围，不画
    if (selectedXY == null ||
        (selectedXY!.left != null && selectedXY!.left! > size.width) ||
        (selectedXY!.left != null && selectedXY!.left! < 0)) {
      selectedDataIndexStream?.add(-1);
      return;
    }

    if (padding.left != 0) {
      canvas.translate(padding.left, 0);
    }


    Pair<double?, double?>? newSelectedXY = _computeSelectedX();

    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (newSelectedXY!.left != null && isDrawY) {
      canvas.drawLine(Offset(newSelectedXY.left!, 0),
          Offset(newSelectedXY.left!, size.height), paint);
    }


    if (newSelectedXY.right == null) {
      return;
    }
    bool isOutRange =
        newSelectedXY.right! > size.height || newSelectedXY.right! < 0;
    // 超出范围
    if (isOutRange) {
      // canvas.drawLine(Offset(0, newSelectedXY.right!),
      //     Offset(0, newSelectedXY.right!), paint);
      return;
    }

    // 画线
    if (isDrawX) {
      canvas.drawLine(Offset(0, newSelectedXY.right!),
          Offset(size.width, newSelectedXY.right!), paint);
    }

    if (selectedHorizontalValue == null || newSelectedXY.right == null) {
      // 无显示数据，结束。
      return;
    }

    // 画选中文本
    if (isDrawText) {
      CrossCurveTextPainter(
        text: KlineNumUtil.formatNumberUnit(selectedHorizontalValue),
        offset: Offset(0, newSelectedXY.right!),
      ).paint(canvas, size);
    }

  }

  /// 重新计算选中的x轴。
  /// 让 x 轴处于每个规定好的范围内（蜡烛）。
  Pair<double?, double?>? _computeSelectedX() {
    if (selectedXY == null || pointWidth == null) {
      return selectedXY;
    }

    if (selectedXY!.left == null && selectedDataIndexAxis == Axis.horizontal) {
      return selectedXY;
    }

    if (selectedXY!.right == null && selectedDataIndexAxis == Axis.vertical) {
      return selectedXY;
    }

    double gap = pointGap ?? 0;
    double oldX = selectedDataIndexAxis == Axis.horizontal ? selectedXY!.left! : selectedXY!.right!;
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
