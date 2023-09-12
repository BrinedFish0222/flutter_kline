import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';

/// 蜡烛图数据vo
class CandlestickChartVo extends BaseChartVo {
  List<CandlestickChartData?> dataList;

  Pair<double, double>? _maxMinData;

  CandlestickChartVo(
      {super.id,
      super.name,
      super.maxValue,
      super.minValue,
      required this.dataList}) {
    getMaxMinData();
  }

  @override
  BaseChartVo copy() {
    return CandlestickChartVo(
        id: id,
        name: name,
        maxValue: maxValue,
        minValue: minValue,
        dataList:
            KlineCollectionUtil.sublist(list: dataList, startIndex: 0) ?? []);
  }

  @override
  Pair<double, double> getMaxMinData() {
    if (_maxMinData != null) {
      return _maxMinData!;
    }

    if (minValue != null && maxValue != null) {
      _maxMinData = Pair(left: maxValue!, right: minValue!);
      return _maxMinData!;
    }

    var pairList = dataList
        .where((element) => element != null)
        .map((e) =>
            KlineNumUtil.maxMinValueDouble([e!.open, e.close, e.high, e.low]))
        .toList();
    _maxMinData = Pair.getMaxMinValue(pairList);
    _maxMinData?.right = minValue ?? _maxMinData!.right;
    _maxMinData?.left = maxValue ?? _maxMinData!.left;

    return _maxMinData!;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    // 蜡烛图一点要显示四条数据，不适合此方法。
    throw UnimplementedError();
  }

  @override
  BaseChartVo subData({required int start, int? end}) {
    return CandlestickChartVo(
        id: id,
        name: name,
        maxValue: maxValue,
        minValue: minValue,
        dataList: KlineCollectionUtil.sublist(
                list: dataList, startIndex: start, endIndex: end) ??
            []);
  }
}

class CandlestickChartData {
  DateTime dateTime;
  double open;
  double close;
  double high;
  double low;

  CandlestickChartData(
      {required this.dateTime,
      required this.open,
      required this.close,
      required this.high,
      required this.low});
}
