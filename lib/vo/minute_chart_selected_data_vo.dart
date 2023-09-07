import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

import 'package:flutter_kline/vo/line_chart_vo.dart';

import 'chart_show_data_item_vo.dart';

/// 分时图显示的选中数据
class MinuteChartSelectedDataVo {
  /// 悬浮数据
  List<ChartShowDataItemVo?>? overlayData;

  /// 显示的指标数据
  List<ChartShowDataItemVo?>? indicatorsData;

  MinuteChartSelectedDataVo({this.overlayData, this.indicatorsData});

  /// 获取分时最后一根显示的数据
  static MinuteChartSelectedDataVo getLastShowData(
      {required LineChartVo minuteChartData,
      List<BaseChartVo>? minuteChartSubjoinData}) {
    MinuteChartSelectedDataVo result = MinuteChartSelectedDataVo();

    var selectedShowData = minuteChartData.getSelectedShowData();
    if (KlineCollectionUtil.isNotEmpty(selectedShowData)) {
      result.overlayData = [minuteChartData.getSelectedShowData()!.last];
    }

    if (KlineCollectionUtil.isEmpty(minuteChartSubjoinData)) {
      return result;
    }

    result.indicatorsData = minuteChartSubjoinData!
        .map((e) => e.getSelectedShowData())
        .where((e) => KlineCollectionUtil.isNotEmpty(e))
        .map((e) => e!.last)
        .toList();

    return result;
  }
}
