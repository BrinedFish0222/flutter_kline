import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

import 'chart_show_data_item_vo.dart';
import 'line_chart_vo.dart';

class MainChartSelectedDataVo {
  /// 蜡烛数据
  CandlestickChartData? candlestickChartData;

  /// 折线数据
  List<ChartShowDataItemVo?>? lineChartList;

  MainChartSelectedDataVo({this.candlestickChartData, this.lineChartList});

  /// 获取最后显示的数据
  static MainChartSelectedDataVo? getLastShowData(
      {CandlestickChartVo? candlestickChartVo,
      List<LineChartVo>? lineChartVoList}) {
    if (candlestickChartVo == null &&
        KlineCollectionUtil.isEmpty(lineChartVoList)) {
      return null;
    }

    MainChartSelectedDataVo result = MainChartSelectedDataVo();
    if (candlestickChartVo != null &&
        KlineCollectionUtil.isNotEmpty(candlestickChartVo.dataList)) {
      result.candlestickChartData = candlestickChartVo.dataList.last;
    }
    if (KlineCollectionUtil.isNotEmpty(lineChartVoList)) {
      result.lineChartList = BaseChartVo.getLastShowData(lineChartVoList);
    }

    return result;
  }
}
