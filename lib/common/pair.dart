class Pair<L, R> {
  L left;
  R right;

  Pair({required this.left, required this.right});

  static Pair<double, double> getMaxMinValue(
      List<Pair<double, double>?> dataList) {
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
    return maxMinValue;
  }
}
