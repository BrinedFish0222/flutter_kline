import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';
import 'base_chart_vo.dart';
import 'candlestick_chart_vo.dart';

/// 折线图数据
class LineChartVo<E> extends BaseChartVo<LineChartData<E>> {
  Color color;

  /// 渐变色，空表示不显示
  Gradient? gradient;

  List<ChartShowDataItemVo?>? _selectedShowData;
  Pair<double, double>? _maxMinData;

  LineChartVo({
    required super.id,
    super.name,
    super.maxValue,
    super.minValue,
    required super.data,
    this.color = Colors.black,
    this.gradient,
  }) {
    getSelectedShowData();
  }

  @override
  BaseChartVo copy() {
    var newDataList = data.map((e) => e).toList();
    return LineChartVo(
      id: id,
      name: name,
      color: color,
      data: newDataList,
      minValue: minValue,
      maxValue: maxValue,
      gradient: gradient,
    );
  }

  /// result: left maxValue; right minValue
  static Pair<double, double> getHeightRange(List<LineChartVo?> lineChartData) {
    Pair<double, double> result =
        Pair(left: -double.maxFinite, right: double.maxFinite);

    for (var element in lineChartData) {
      if (element == null) {
        continue;
      }

      for (var data in element.data) {
        result.left = (data?.value ?? -double.maxFinite) > result.left
            ? data!.value!
            : result.left;
        result.right = (data!.value ?? double.maxFinite) < result.right
            ? data.value!
            : result.right;
      }
    }

    return result;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    if (KlineCollectionUtil.isNotEmpty(_selectedShowData)) {
      return _selectedShowData;
    }

    return data
        .map((e) => ChartShowDataItemVo(
            name: name ?? '', value: e?.value, color: color))
        .toList();
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

    _maxMinData =
        KlineNumUtil.maxMinValueDouble(data.map((e) => e?.value).toList());

    _maxMinData!.right = minValue ?? _maxMinData!.right;
    _maxMinData!.left = maxValue ?? _maxMinData!.left;

    return _maxMinData!;
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
    return true;
  }
}

class LineChartData<E> extends BaseChartData<E> {
  DateTime? dateTime;

  double? value;

  LineChartData({
    required super.id,
    this.dateTime,
    this.value,
    super.extrasData,
  });
}

class SelectedLineChartDataStreamVo {
  String? name;
  Color color;
  double? value;

  /// 对应的蜡烛图数据
  CandlestickChartVo? candlestickChartVo;

  SelectedLineChartDataStreamVo(
      {this.name, required this.color, this.value, this.candlestickChartVo});
}
