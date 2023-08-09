import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

import 'line_chart_vo.dart';

class SelectedChartDataStreamVo {

  /// 蜡烛数据
  CandlestickChartVo? candlestickChartVo;

  /// 折线数据
  List<SelectedLineChartDataStreamVo>? lineChartList;

  SelectedChartDataStreamVo({this.candlestickChartVo, this.lineChartList});
}
