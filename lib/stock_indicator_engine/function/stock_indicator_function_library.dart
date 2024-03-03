import 'package:flutter_kline/stock_indicator_engine/function/stock_indicator_function.dart';
import 'package:flutter_kline/utils/kline_util.dart';

/// 股票指标函数库
class StockIndicatorFunctionLibrary {
  static final StockIndicatorFunctionLibrary _instance =
      StockIndicatorFunctionLibrary._internal();

  static const _className = 'StockIndicatorFunctionRegistry';

  StockIndicatorFunctionLibrary._internal();

  factory StockIndicatorFunctionLibrary() {
    return _instance;
  }

  /// 存储股票指标函数的映射
  final List<StockIndicatorFunction> _functions = [];

  /// 注册股票指标函数
  void register(List<StockIndicatorFunction> newFunctions) {
    for (var newFunction in newFunctions) {
      _functions.removeWhere((element) => element.name == newFunction.name);
    }

    _functions.addAll(newFunctions);
  }

  /// 获取注册的股票指标函数
  StockIndicatorFunction? getFunction(String functionName) {
    try {
      return _functions.firstWhere((element) => element.name == functionName);
    } on Exception catch (e) {
      KlineUtil.loge('找不到$functionName函数', name: _className);
      return null;
    }
  }
}
