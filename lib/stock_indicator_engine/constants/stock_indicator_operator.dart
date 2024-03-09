/// 运算符
enum StockIndicatorOperator {
  add(value: '+'),
  sub(value: '-'),
  div(value: '/'),
  mul(value: '*'),
  ;

  final String value;

  const StockIndicatorOperator({required this.value});

  static bool isOperator(String value) {
    return StockIndicatorOperator.values
        .any((element) => element.value == value);
  }
}
