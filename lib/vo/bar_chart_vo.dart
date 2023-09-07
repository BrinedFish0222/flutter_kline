import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

class BarChartVo extends BaseChartVo {
  /// 柱体宽度
  double? barWidth;
  List<BarChartData> data;
  List<ChartShowDataItemVo?>? _selectedShowData;
  Pair<double, double>? _maxMinData;

  BarChartVo(
      {super.id,
      super.name,
      super.maxValue,
      super.minValue,
      this.barWidth,
      required this.data}) {
    getSelectedShowData();
  }

  @override
  BaseChartVo copy() {
    return BarChartVo(
        id: id,
        name: name,
        maxValue: maxValue,
        minValue: minValue,
        barWidth: barWidth,
        data: KlineCollectionUtil.sublist(list: data, startIndex: 0) ?? []);
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    if (KlineCollectionUtil.isNotEmpty(_selectedShowData)) {
      return _selectedShowData;
    }

    return data
        .map((e) => ChartShowDataItemVo(
            name: name ?? '', value: e.value, color: e.color))
        .toList();
  }

  @override
  Pair<double, double> getMaxMinData() {
    if (_maxMinData != null) {
      return _maxMinData!;
    }

    double max = maxValue ??
        data
            .map((e) => e.value)
            .reduce((value, element) => value > element ? value : element);
    double min = minValue ??
        data
            .map((e) => e.value)
            .reduce((value, element) => value < element ? value : element);

    _maxMinData = Pair<double, double>(left: max, right: min);
    return _maxMinData!;
  }

  @override
  BaseChartVo subData({required int start, int? end}) {
    return BarChartVo(
        id: id,
        name: name,
        barWidth: barWidth,
        maxValue: maxValue,
        minValue: minValue,
        data: KlineCollectionUtil.sublist(
                list: data, startIndex: start, endIndex: end) ??
            []);
  }
}

class BarChartData {
  double value;
  bool isFill;
  Color color;

  BarChartData(
      {required this.value, this.isFill = false, this.color = Colors.black});
}
