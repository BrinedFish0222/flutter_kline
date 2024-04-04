import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';

import '../chart/bar_chart.dart';


/// 柱图
class BarChartPainter extends CustomPainter {
  final BarChart barData;
  final double? pointWidth;
  final double pointGap;

  /// 高度范围
  final Pair<double, double>? maxMinValue;

  BarChartPainter({
    required this.barData,
    this.pointWidth,
    this.pointGap = 5,
    this.maxMinValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var barHeightData = barData.data;
    // 柱体宽度 = （总宽度 - 间隔空间）/ 柱体数据长度。
    final pointWidth = this.pointWidth ??
        (size.width - (barHeightData.length - 1) * pointGap) /
            barHeightData.length;

    // 数据最低值
    double minDataValue = maxMinValue?.right ?? barData.getMaxMinData().right;
    if (minDataValue > 0) {
      minDataValue = 0;
    }
    // 数据份额
    final dataShare = _getDataShare();

    // 所有数据都是0的情况
    if (dataShare == 0) {
      return;
    }

    // 数据图高度份额
    final dataChartHeightShare = size.height / dataShare;

    final paint = Paint()
      ..color = KlineConfig.red
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barHeightData.length; i++) {
      BarChartData? data = barHeightData[i];
      if (data == null) {
        continue;
      }

      paint.color = data.color ?? Colors.black;
      paint.style = data.isFill ? PaintingStyle.fill : PaintingStyle.stroke;

      // 左边坐标点
      final left = i * pointWidth + (i == 0 ? 0 : i * pointGap);
      final top =
          size.height - dataChartHeightShare * (data.value - minDataValue);
      final right = left + pointWidth;
      final bottom = size.height - dataChartHeightShare * (0 - minDataValue);
      Pair<double, double> newLeftRight =
          _resetBarWidth(left: left, right: right);

      final rect = Rect.fromLTRB(newLeftRight.left, top < 0 ? 0 : top,
          newLeftRight.right, bottom < 0 ? 0 : bottom);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  /// 重置柱体宽度
  Pair<double, double> _resetBarWidth(
      {required double left, required double right}) {
    double? barWidth = barData.barWidth;
    if (barWidth == null) {
      return Pair(left: left, right: right);
    }

    double oldWidth = right - left;
    if (barWidth >= oldWidth) {
      return Pair(left: left, right: right);
    }

    double differenceWidth = (oldWidth - barWidth) / 2;
    return Pair(left: left + differenceWidth, right: right - differenceWidth);
  }

  /// 获取数据份额
  double _getDataShare() {
    late double result;
    if (maxMinValue != null) {
      result = (maxMinValue?.left ?? 0) - (maxMinValue?.right ?? 0);
    } else {
      var maxMinData = barData.getMaxMinData();
      return maxMinData.left - maxMinData.right;
    }

    return result;
  }
}
