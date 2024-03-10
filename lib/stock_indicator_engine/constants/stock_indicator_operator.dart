import 'package:flutter_kline/utils/kline_collection_util.dart';

/// 运算符
enum StockIndicatorOperator {
  add(value: '+'),
  sub(value: '-'),
  div(value: '/'),
  mul(value: '*'),
  ;

  final String value;

  const StockIndicatorOperator({required this.value});

  bool get isMul {
    return this == StockIndicatorOperator.mul;
  }

  bool get isDiv {
    return this == StockIndicatorOperator.div;
  }

  static bool isOperator(String value) {
    return StockIndicatorOperator.values
        .any((element) => element.value == value);
  }

  static StockIndicatorOperator? operator(String value) {
    return KlineCollectionUtil.firstWhere(
        StockIndicatorOperator.values, (element) => element.value == value);
  }
}
