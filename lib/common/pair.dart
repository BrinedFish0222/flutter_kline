class Pair<L, R> {
  L left;
  R right;

  Pair({required this.left, required this.right});

  static Pair<double, double> get defaultMaxMinValue {
    return Pair(left: -double.maxFinite, right: double.maxFinite);
  }

  bool isNull() {
    return left == null && right == null;
  }

  bool isNotNull() {
    return !isNull();
  }

  static Pair<double, double> getMaxMinValue(
      List<Pair<double, double>?> dataList,
      {double? defaultMaxValue,
      double? defaultMinValue}) {
    Pair<double, double> maxMinValue =
        Pair(left: -double.maxFinite, right: double.maxFinite);
    for (Pair<double, double>? data in dataList) {
      if (data != null) {
        if (maxMinValue.left < data.left) {
          maxMinValue.left = data.left;
        }
        if (maxMinValue.right > data.right) {
          maxMinValue.right = data.right;
        }
      }
    }

    if (defaultMaxValue != null && maxMinValue.left == -double.maxFinite) {
      maxMinValue.left = defaultMaxValue;
    }

    if (defaultMinValue != null && maxMinValue.right == double.maxFinite) {
      maxMinValue.right = defaultMinValue;
    }

    return maxMinValue;
  }
}
