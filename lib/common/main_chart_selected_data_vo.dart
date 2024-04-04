import 'package:flutter_kline/utils/kline_collection_util.dart';

import '../chart/base_chart.dart';
import '../chart/candlestick_chart.dart';
import 'chart_show_data_item_vo.dart';
import '../chart/line_chart.dart';

class MainChartSelectedDataVo {
  /// 蜡烛数据
  CandlestickChartData? candlestickChartData;

  /// 折线数据
  List<ChartShowDataItemVo?>? lineChartList;

  MainChartSelectedDataVo({this.candlestickChartData, this.lineChartList});

  /// 获取最后显示的数据
  static MainChartSelectedDataVo? getLastShowData(
      {CandlestickChart? candlestickChartVo,
      List<LineChart>? lineChartVoList}) {
    if (candlestickChartVo == null &&
        KlineCollectionUtil.isEmpty(lineChartVoList)) {
      return null;
    }

    MainChartSelectedDataVo result = MainChartSelectedDataVo();
    if (candlestickChartVo != null &&
        KlineCollectionUtil.isNotEmpty(candlestickChartVo.data)) {
      result.candlestickChartData = candlestickChartVo.data.last;
    }
    if (KlineCollectionUtil.isNotEmpty(lineChartVoList)) {
      result.lineChartList = BaseChart.getLastShowData(lineChartVoList);
    }

    return result;
  }
}
