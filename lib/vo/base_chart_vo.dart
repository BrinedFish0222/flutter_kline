import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';

/// 图数据基类
abstract class BaseChartVo {
  String? id;
  String? name;

  BaseChartVo({this.id, this.name});

  /// 获取整个图**所有**选中显示的数据集合
  List<ChartShowDataItemVo?>? getSelectedShowData();

  /// 获取最大最小值。
  /// 左  最大值；右 最小值。
  Pair<double, double> getMaxMinData();

  /// 子数据
  BaseChartVo subData({required int start, int? end});
}
