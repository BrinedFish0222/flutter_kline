import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

import '../common/pair.dart';
import '../vo/candlestick_chart_vo.dart';

class KlineUtil {
  /// TODO 直接改成一个painter
  static Widget noWidget() {
    return const SizedBox();
  }

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

  static DateTime parseIntDateToDateTime(int intDate) {
    var dateStr = intDate.toString();
    int year = int.parse(dateStr.substring(0, 4));
    int month = int.parse(dateStr.substring(4, 6));
    int day = int.parse(dateStr.substring(6, 8));
    return DateTime(year, month, day);
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

  /// 自动分配图高度
  /// [totalHeight] 总高度
  /// [subChartRatio] 副图相对于主图的比例
  /// [subChartNum] 副图数量
  /// 返回结果：左边 主图高度；右边 单个副图高度。
  static Pair<double, double> autoAllotChartHeight(
      {required double totalHeight,
      required double subChartRatio,
      required int subChartNum}) {
    double totalRatio = 1 + subChartRatio * subChartNum;
    double singleHeight = totalHeight / totalRatio;

    return Pair<double, double>(
        left: singleHeight * 1, right: singleHeight * subChartRatio);
  }

  /// 获取点宽度，公式：画布长 / (数据数组长度 * 数据宽度和空间间隔比 + 数据数组长度 - 1) * 数据宽度和空间间隔比
  /// [width] 画布长
  /// [dataLength] 数据数组长度
  /// [gapRatio] 数据宽度和空间间隔比
  static double getPointWidth(
      {required double width,
      required int dataLength,
      required double gapRatio}) {
    if (dataLength == 0) {
      return 0;
    }

    /// 画布长 / (数据数组长度 * 数据宽度和空间间隔比 + 数据数组长度 - 1)
    /// 示例：800 / (50 * 3 + 50 - 1);
    var s = width / (dataLength * gapRatio  + dataLength - 1);
    return s * gapRatio;
  }

  /// 计算y轴值：最大最小值范围差 / 高度 * 选中的y轴高度 + 底数
  /// [maxMinValue] 最大最小值
  /// [selectedY] 选中的y轴
  static double? computeSelectedHorizontalValue(
      {required Pair<double, double> maxMinValue,
      required double height,
      required double? selectedY}) {
    if (selectedY == null) {
      return null;
    }

    return (maxMinValue.left - maxMinValue.right) /
            height *
            (height - selectedY) +
        maxMinValue.right;
  }

  /// 计算最大最小值
  static Pair<double, double> getMaxMinValue(
      {CandlestickChartVo? candlestickCharVo,
      List<BaseChartVo?>? chartDataList}) {
    Pair<double, double> result = candlestickCharVo?.getMaxMinData() ??
        Pair(left: -double.maxFinite, right: double.maxFinite);

    chartDataList?.forEach((element) {
      if (element == null) {
        return;
      }

      var maxMinData = element.getMaxMinData();
      result.left =
          maxMinData.left > result.left ? maxMinData.left : result.left;
      result.right =
          maxMinData.right < result.right ? maxMinData.right : result.right;
    });

    return result;
  }
}
