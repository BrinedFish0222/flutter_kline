import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/pair.dart';

import '../vo/bar_chart_vo.dart';

/// 柱图
class BarChartPainter extends CustomPainter {
  final BarChartVo barData;
  final double? pointWidth;
  final double pointGap;

  BarChartPainter({required this.barData, this.pointWidth, this.pointGap = 5});

  @override
  void paint(Canvas canvas, Size size) {
    var barHeightData = barData.data;
    // 柱体宽度 = （总宽度 - 间隔空间）/ 柱体数据长度。
    final pointWidth = this.pointWidth ??
        (size.width - (barHeightData.length - 1) * pointGap) /
            barHeightData.length;

    // 柱体最大值
    final maxDataValue = barHeightData
        .map((element) => element.value)
        .reduce((value, element) => value > element ? value : element);

    final paint = Paint()
      ..color = KlineConfig.red
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barHeightData.length; i++) {
      var data = barHeightData[i];
      paint.color = data.color;
      paint.style = data.isFill ? PaintingStyle.fill : PaintingStyle.stroke;

      final barHeight = (data.value / maxDataValue) * size.height;

      // 左边坐标点
      final left = i * pointWidth + (i == 0 ? 0 : i * pointGap);
      final top = size.height - barHeight;
      final right = left + pointWidth;
      Pair<double, double> newLeftRight =
          _resetBarWidth(left: left, right: right);

      final rect = Rect.fromLTRB(
          newLeftRight.left, top, newLeftRight.right, size.height);
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
}
