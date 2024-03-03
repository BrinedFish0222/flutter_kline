/// 指标函数规范
abstract class StockIndicatorFunction {
  const StockIndicatorFunction({
    required this.name,
    this.desc = '',
  });

  final String name;
  final String desc;
}
