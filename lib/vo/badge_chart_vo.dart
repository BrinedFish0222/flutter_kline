import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import 'base_chart_vo.dart';

class BadgeChartVo<E> extends BaseChartVo<BadgeChartData<E>> {
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
        if (data?.value != null) {
          continue;
        }

        double? maxValue = KlineNumUtil.maxMinValue(
            chartData.map((e) => e.getDataMaxValueByIndex(i)).toList())
            ?.left
            .toDouble();
        data?.value = maxValue;
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
    if (data.isEmpty) {
      return Pair.defaultMaxMinValue;
    }

    if (maxValue != null && minValue != null) {
      return Pair<double, double>(left: maxValue!, right: minValue!);
    }

    List<num> valueList = [];
    for (BadgeChartData? d in data) {
      if (d == null) {
        continue;
      }

      if (d.value != null) {
        valueList.add(d.value!);
      }

      if (d.maxValue != null) {
        valueList.add(d.maxValue!);
      }

      if (d.minValue != null) {
        valueList.add(d.minValue!);
      }
    }


    Pair<double, double> maxMinValue = KlineNumUtil.maxMinValueDouble(valueList);
    if (maxValue != null) {
      maxMinValue.left = maxValue!;
    }
    if (minValue != null) {
      maxMinValue.right = minValue!;
    }

    return maxMinValue;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    return [];
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

/// <E> 是扩展数据
class BadgeChartData<E> extends BaseChartData<E> {
  static const EdgeInsets defaultPadding = EdgeInsets.only(bottom: 0);

  /// 显示的组件，没有则不显示
  Widget? widget;

  /// 默认值：[defaultPadding]
  EdgeInsets padding;

  /// 最小大小
  Size? minSize;

  /// 决定 badge 在图中的高度位置。
  /// 如果[value]为空，会默认设置为当前y轴数据点最大值
  double? value;

  /// 是否颠倒
  final bool invert;

  /// 最大值
  double? maxValue;

  /// 最小值
  double? minValue;

  BadgeChartData({
    super.id,
    required this.widget,
    this.padding = defaultPadding,
    this.minSize,
    this.value,
    super.extrasData,
    this.invert = false,
    this.maxValue,
    this.minValue,
  });
}
