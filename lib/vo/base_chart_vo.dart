import '../common/pair.dart';

/// 图数据基类
abstract class BaseChartVo {
  String? id;
  String? name;

  BaseChartVo({this.id, this.name});

  /// 获取显示的数据
  List<double?>? getShowData();

  /// 获取最大最小值。
  /// 左  最大值；右 最小值。
  Pair<double, double> getMaxMinData();

  /// 子数据
  BaseChartVo subData({required int start, int? end});
}
