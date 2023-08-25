import 'package:flutter_kline/common/pair.dart';

class KlineNumUtil {
  /// 提取最大最小值。
  /// @return Pair left 是最大值；Pair right 是最小值。
  static Pair<num, num>? maxMinValue(List<num?>? dataList) {
    if (dataList == null ||
        dataList.isEmpty ||
        dataList.every((element) => element == null)) {
      return null;
    }

    Pair<num, num> result =
        Pair(left: -double.maxFinite, right: double.maxFinite);

    for (var data in dataList) {
      if (data == null) {
        continue;
      }

      if (data > result.left) {
        result.left = data;
      }

      if (data < result.right) {
        result.right = data;
      }
    }

    return result;
  }

  static Pair<double, double>? maxMinValueDouble(List<num?>? dataList) {
    var value = maxMinValue(dataList);
    return Pair(
        left: value?.left.toDouble() ?? -double.maxFinite,
        right: value?.right.toDouble() ?? double.maxFinite);
  }

  /// 格式化数字，返回带单位的结果
  static String formatNumberUnit(double? number) {
    if (number == null || number == 0) {
      return '0';
    } else if (number >= 100000000) {
      double result = number / 100000000.0;
      return '${result.toStringAsFixed(2)}亿';
    } else if (number >= 10000) {
      double result = number / 10000.0;
      return '${result.toStringAsFixed(2)}万';
    } else {
      return number.toStringAsFixed(2);
    }
  }
}
