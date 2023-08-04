import 'package:flutter_kline/common/pair.dart';

class NumUtil {
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
}
