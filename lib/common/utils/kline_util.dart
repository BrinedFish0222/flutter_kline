import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../../chart/base_chart.dart';
import '../../chart/candlestick_chart.dart';
import '../pair.dart';
import 'kline_num_util.dart';

class KlineUtil {
  static void logd(String text, {String name = ''}) {
    if (kReleaseMode) {
      return;
    }
    developer.log(text, name: name);
  }

  static void loge(String text, {String name = ''}) {
    /*if (kReleaseMode) {
      return;
    }*/
    developer.log(text, name: name);
  }

  /// 转换数据为图数据。
  static double? convertDataToChartDataSingle(
      double? data, double canvasMaxHeight,
      {Pair<double, double>? maxMinValue}) {
    if (data == null) {
      return null;
    }

    // 找出非空数据数组中的最大值和最小值
    maxMinValue ??= Pair(left: data + 1, right: data - 1);

    // 计算数据在 maxHeight 范围内的高度比例
    double scaleFactor =
        canvasMaxHeight / (maxMinValue.left - maxMinValue.right);

    // 遍历数据数组，将每个数据值转换成对应的高度值，
    return ((data - maxMinValue.right) * scaleFactor - canvasMaxHeight).abs();
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
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    var s = width / (dataLength * gapRatio + dataLength - 1);
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

  /// 计算y轴值：高度 - 高度 / 最大最小值范围差  * 值
  /// [maxMinValue] 最大最小值
  /// [maxHeight] 高度
  /// [value] 值
  static double computeYAxis({
    required Pair<double, double> maxMinValue,
    required double maxHeight,
    required double value,
  }) {
    return maxHeight -
        maxHeight /
            (maxMinValue.left - maxMinValue.right) *
            (value - maxMinValue.right);
  }

  /// 计算x轴值：[pointWidth] * [index]
  /// [index] 索引位置
  /// [pointWidth] 每个元素宽度
  static double computeXAxis({
    required int index,
    required double pointWidth,
    required double pointGap,
  }) {
    return index * pointWidth + index * pointGap + pointWidth / 2;
  }

  /// 计算最大最小值
  static Pair<double, double> getMaxMinValue(
      {CandlestickChart? candlestickCharVo,
      List<BaseChart?>? chartDataList}) {
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

extension DragUpdateDetailsExt on DragUpdateDetails {
  /// 是否左移
  bool get isLeftMove {
    return delta.dx > 0;
  }

  /// 是否右移
  bool get isRightMove {
    return delta.dx < 0;
  }
}
