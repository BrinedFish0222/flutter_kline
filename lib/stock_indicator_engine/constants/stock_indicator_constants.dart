

enum StockIndicatorKeys {
  leftBracket(value: '('),
  rightBracket(value: ')'),
  ;

  final String value;

  const StockIndicatorKeys({required this.value});
}

enum StockIndicatorParameterType {

  /// 用户定义
  defined,

  /// 公式中的变量
  variable,
}