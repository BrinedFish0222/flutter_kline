import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

import 'chart_show_data_item_vo.dart';

class MainChartSelectedDataVo {
  /// 蜡烛数据
  CandlestickChartData? candlestickChartData;

  /// 折线数据
  List<ChartShowDataItemVo?>? lineChartList;

  MainChartSelectedDataVo({this.candlestickChartData, this.lineChartList});
}
