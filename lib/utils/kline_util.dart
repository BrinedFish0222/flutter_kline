import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

class KlineUtil {
  /// 转换数据为图数据。
  static List<double?> convertDataToChartData(
      List<double?> data, double maxHeight) {
    if (data.isEmpty) {
      return [];
    }

    // 找出非空数据数组中的最大值和最小值
    var maxMinValue = KlineNumUtil.maxMinValue(data);

    // 计算数据在 maxHeight 范围内的高度比例
    double scaleFactor = maxHeight / (maxMinValue!.left - maxMinValue.right);

    // 遍历数据数组，将每个数据值转换成对应的高度值，
    List<double?> heights = data
        .map((value) => value != null
            ? ((value - maxMinValue.right) * scaleFactor).toDouble()
            : null)
        .map((e) {
      if (e == null) {
        return null;
      }
      return (e - 300).abs();
    }).toList();

    debugPrint("convertDataList: $heights");
    return heights;
  }
}
