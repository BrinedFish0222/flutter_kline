import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import 'base_chart_vo.dart';

class BadgeChartVo<E> extends BaseChartVo<BadgeChartData<E>?> {

  BadgeChartVo({
    super.id,
    super.name,
    super.maxValue,
    super.minValue,
    required super.data,
  });

  /// 初始化 [data] 的 value
  /// 默认是同一列最大值
  static void initDataValue(List<BaseChartVo> chartData) {
    if (chartData.isEmpty) {
      return;
    }

    List<BadgeChartVo> badgeList = chartData.whereType<BadgeChartVo>().toList();
    if (badgeList.isEmpty) {
      return;
    }

    for (BadgeChartVo badge in badgeList) {
      for (int i = 0; i < badge.dataLength; ++i) {
        BadgeChartData? data = badge.data[i];
        if (data == null || data.value != null) {
          continue;
        }

        double? maxValue = KlineNumUtil.maxMinValue(
                chartData.map((e) => e.getDataMaxValueByIndex(i)).toList())
            ?.left
            .toDouble();
        data.value = maxValue;
      }
    }
  }

  @override
  BaseChartVo copy() {
    return BadgeChartVo(
      id: id,
      name: name,
      maxValue: maxValue,
      minValue: minValue,
      data: data.sublist(0),
    );
  }

  @override
  Pair<double, double> getMaxMinData() {
    var everyNull = data.every((element) => element == null);
    if (everyNull) {
      return Pair.defaultMaxMinValue;
    }

    List<num> valueList = data
        .where((element) => element != null && element.value != null)
        .map((e) => e!.value!)
        .cast<num>()
        .toList();

    var maxMinValue = KlineNumUtil.maxMinValueDouble(valueList);
    return maxMinValue;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    return [];
  }

  @override
  BaseChartVo subData({required int start, int? end}) {
    var newVo = copy() as BadgeChartVo;
    newVo.data = newVo.data.sublist(start, end);
    return newVo;
  }

  @override
  int get dataLength => data.length;

  @override
  double? getDataMaxValueByIndex(int index) {
    if (index >= dataLength) {
      return null;
    }
    return data[index]?.value;
  }

  @override
  bool isSelectedShowData() {
    return false;
  }
}

class BadgeChartData<E> extends BaseChartData<E> {
  static const EdgeInsets defaultPadding = EdgeInsets.only(bottom: 10);

  Widget widget;

  /// 默认值：[defaultPadding]
  EdgeInsets padding;

  /// 决定 badge 在图中的高度位置。
  /// 默认情况不需要指定，会根据实际情况生成对应的值。
  double? value;

  BadgeChartData({
    required this.widget,
    this.padding = defaultPadding,
    this.value,
    super.extrasData,
  });
}
