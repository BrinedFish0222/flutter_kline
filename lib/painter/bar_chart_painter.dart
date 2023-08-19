import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

import '../vo/bar_chart_vo.dart';

/// 柱图
class BarChartPainter extends CustomPainter {
  final BarChartVo barData;
  final double gap;

  BarChartPainter({required this.barData, this.gap = 5});

  @override
  void paint(Canvas canvas, Size size) {
    var barHeightData = barData.data;
    // 柱体宽度 = （总宽度 - 间隔空间）/ 柱体数据长度。
    final barWidth =
        (size.width - (barHeightData.length - 1) * gap) / barHeightData.length;

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
      final left = i * barWidth + (i == 0 ? 0 : i * gap);
      final top = size.height - barHeight;

      final rect = Rect.fromLTRB(left, top, left + barWidth, size.height);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
