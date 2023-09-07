import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';

/// 图数据基类
abstract class BaseChartVo {
  String? id;
  String? name;

  /// 最大值
  double? maxValue;

  /// 最小值
  /// 柱图如果不支持负数，设置成0。
  double? minValue;

  BaseChartVo({this.id, this.name, this.maxValue, this.minValue});

  /// 获取整个图**所有**选中显示的数据集合
  List<ChartShowDataItemVo?>? getSelectedShowData();

  /// 获取最大最小值。
  /// 左  最大值；右 最小值。
  Pair<double, double> getMaxMinData();

  /// 子数据
  BaseChartVo subData({required int start, int? end});

  /// 复制
  BaseChartVo copy();

  /// 获取最后一根显示的数据
  static List<ChartShowDataItemVo>? getLastShowData(List<BaseChartVo>? voList) {
    if (KlineCollectionUtil.isEmpty(voList)) {
      return null;
    }

    return voList!
        .where((e) => KlineCollectionUtil.isNotEmpty(e.getSelectedShowData()))
        .map((e) => e.getSelectedShowData()!.last!)
        .toList();
  }

  static List<ChartShowDataItemVo>? getShowDataByIndex(
      List<BaseChartVo>? voList, int index) {
    if (KlineCollectionUtil.isEmpty(voList)) {
      return null;
    }

    return voList!
        .where((e) => KlineCollectionUtil.isNotEmpty(e.getSelectedShowData()))
        .map((e) => e.getSelectedShowData()![index])
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }
}
