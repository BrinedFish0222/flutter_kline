import 'package:flutter_kline/stock_indicator_engine/stock_indicator_constants.dart';

/// 指标参数
class StockIndicatorParameter {
  final StockIndicatorParameterType type;
  final String name;
  final double value;

  StockIndicatorParameter({
    this.type = StockIndicatorParameterType.defined,
    required this.name,
    this.value = 0,
  });

  @override
  String toString() {
    return 'StockIndicatorParameter{name: $name, value: $value}';
  }
}

/// 测试公式结果
class TestFormulaResult {
  final bool success;
  final String message;

  const TestFormulaResult({
    required this.success,
    required this.message,
  });

  const TestFormulaResult.success({
    this.success = true,
    this.message = '测试通过',
  });

  const TestFormulaResult.fail({
    this.success = false,
    this.message = '公式错误',
  });

  @override
  String toString() {
    return 'TestFormulaResult{success: $success, message: $message}';
  }
}
