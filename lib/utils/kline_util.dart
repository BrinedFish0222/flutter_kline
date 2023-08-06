import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../common/pair.dart';

class KlineUtil {



  /// TODO 直接改成一个painter
  /// 画蜡烛
  static void drawCandlestick(
      {required Canvas canvas,
      required Rect rect,
      required Paint paint,
      required double top,
      required double bottom,
      Color lineColor = Colors.black,
      Color? rectFillColor}) {
    Color oldColor = paint.color;
    PaintingStyle oldPaintingStyle = paint.style;
    double lineX = rect.left + ((rect.right - rect.left).abs()) / 2;

    paint.color = lineColor;
    if (rectFillColor != null) {
      paint
        ..color = rectFillColor
        ..style = PaintingStyle.fill;
    }
    canvas.drawRect(rect, paint);

    paint
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    double topY = rect.top > rect.bottom ? rect.bottom : rect.top;
    double bottomY = rect.top > rect.bottom ? rect.top : rect.bottom;
    // 最高线
    canvas.drawLine(Offset(lineX, top), Offset(lineX, topY), paint);

    // 最低线
    canvas.drawLine(Offset(lineX, bottom), Offset(lineX, bottomY), paint);

    paint
      ..color = oldColor
      ..style = oldPaintingStyle;
  }

  /// 转换数据为图数据。
  static List<double?> convertDataToChartData(
      List<double?> data, double canvasMaxHeight,
      {Pair<num, num>? maxMinValue}) {
    if (data.isEmpty) {
      return [];
    }

    // 找出非空数据数组中的最大值和最小值
    maxMinValue ??= KlineNumUtil.maxMinValue(data);

    // 计算数据在 maxHeight 范围内的高度比例
    double scaleFactor =
        canvasMaxHeight / (maxMinValue!.left - maxMinValue.right);

    // 遍历数据数组，将每个数据值转换成对应的高度值，
    List<double?> heights = data
        .map((value) => value != null
            ? ((value - maxMinValue!.right) * scaleFactor).toDouble()
            : null)
        .map((e) {
      if (e == null) {
        return null;
      }
      return (e - canvasMaxHeight).abs();
    }).toList();

    return heights;
  }

  static void showToast({required BuildContext context, required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        dismissDirection: DismissDirection.endToStart,
        duration: const Duration(seconds: 2), // 显示时长
      ),
    );
  }
}
