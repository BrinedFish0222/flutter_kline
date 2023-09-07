import 'package:flutter_kline/common/pair.dart';

class KlineNumUtil {
  /// 找出和 [target] 相差最多的数
  static double findNumberWithMaxDifference(List<double?> dataList, double target) {
    // 初始化最大差值为负数，确保第一个元素肯定会大于该值
    double maxDifference = -1;
    double result = target;

    for (double? number in dataList) {
      if (number == null) {
        continue;
      }
      double difference = (number - target).abs();
      if (difference > maxDifference) {
        maxDifference = difference;
        result = number;
      }
    }

    return result;
  }

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
    } else if (number >= 100000000 || number <= -100000000) {
      double result = number / 100000000.0;
      return '${result.toStringAsFixed(2)}亿';
    } else if (number >= 10000 || number <= -10000) {
      double result = number / 10000.0;
      return '${result.toStringAsFixed(2)}万';
    } else {
      return number.toStringAsFixed(2);
    }
  }
}
