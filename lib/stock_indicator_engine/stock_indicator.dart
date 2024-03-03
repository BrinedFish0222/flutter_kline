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
