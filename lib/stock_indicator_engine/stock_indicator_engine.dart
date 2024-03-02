
import 'package:flutter_kline/stock_indicator_engine/stock_indicator.dart';

import '../vo/base_chart_vo.dart';

/// 股票指标引擎
class StockIndicatorEngine {
  static final StockIndicatorEngine _instance = StockIndicatorEngine._internal();

  StockIndicatorEngine._internal();

  factory StockIndicatorEngine() {
    return _instance;
  }

  List<BaseChartVo> run(StockIndicator stockIndicator) {
    // TODO 尚未实现
    throw Exception("尚未实现");
  }

}


