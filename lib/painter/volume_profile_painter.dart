import 'package:flutter/material.dart';

import '../common/volume_profile.dart';


/// 筹码峰
class VolumeProfilePainter extends CustomPainter {
  const VolumeProfilePainter({required this.maxValue, required this.minValue, required this.dataList});

  /// 右边值数量
  static const int rightTextNum = 5;

  final double maxValue;
  final double minValue;
  final List<VolumeProfile> dataList;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRightText(canvas, size);
    _drawColumn(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  /// 画右边值文本
  void _drawRightText(Canvas canvas, Size size) {
    TextStyle textStyle = const TextStyle(fontSize: 8, color: Colors.grey);

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: maxValue.toStringAsFixed(2), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, 0));

    // 计算一份文本占用的高度空间
    double textSpaceHeight = size.height / rightTextNum;

    // 画中间值
    for (int i = 0; i < (rightTextNum - 2); ++i) {
      double y = (i + 1) * (textPainter.height + textSpaceHeight);
      int index = y ~/ (size.height / dataList.length);

      textPainter.text = TextSpan(text: dataList[index].price.toStringAsFixed(2), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - textPainter.width, y - textPainter.height / 2));
    }

    textPainter.text = TextSpan(text: minValue.toStringAsFixed(2), style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, size.height - textPainter.height));
  }

  /// 画资金柱体
  void _drawColumn(Canvas canvas, Size size) {
    if (dataList.isEmpty) {
      return;
    }

    // 柱高
    double columnHeight = size.height / dataList.length;
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red
      ..strokeWidth = 1;

    double top = 0;
    double bottom = columnHeight;
    for (var data in dataList) {
      paint.color = data.color;
      double right = (size.width - 4) * (data.percent.clamp(0, 1));
      canvas.drawRect(Rect.fromLTRB(0, top, right, bottom), paint);

      top += columnHeight;
      bottom += columnHeight;
    }
  }
}
