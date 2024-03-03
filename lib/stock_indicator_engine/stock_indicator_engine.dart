import 'package:flutter_kline/stock_indicator_engine/stock_indicator.dart';

import '../vo/base_chart_vo.dart';

/// 股票指标引擎
class StockIndicatorEngine {
  StockIndicatorEngine({
    required this.formula,
    this.parameters = const [],
  });

  /// 公式
  final String formula;

  /// 参数
  final List<StockIndicatorParameter> parameters;
}
