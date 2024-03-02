/// 指标
class StockIndicator {
  /// 参数
  final List<StockIndicatorParameter> parameters;

  /// 公式
  final String formula;

  const StockIndicator({
    this.parameters = const [],
    required this.formula,
  });
}

/// 指标参数
class StockIndicatorParameter {
  final String name;
  final double max;
  final double min;
  final double def;

  const StockIndicatorParameter({
    required this.name,
    this.max = 0,
    this.min = 0,
    this.def = 0,
  });
}
