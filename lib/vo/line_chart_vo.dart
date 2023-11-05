import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../common/pair.dart';
import 'base_chart_vo.dart';
import 'candlestick_chart_vo.dart';

/// 折线图数据
class LineChartVo extends BaseChartVo {
  List<LineChartData>? dataList;
  Color color;

  List<ChartShowDataItemVo?>? _selectedShowData;
  Pair<double, double>? _maxMinData;

  LineChartVo(
      {super.id,
      super.name,
      super.maxValue,
      super.minValue,
      required this.dataList,
      this.color = Colors.black}) {
    getSelectedShowData();
  }

  @override
  BaseChartVo copy() {
    var newDataList = dataList?.map((e) => e).toList();
    return LineChartVo(
        dataList: newDataList,
        id: id,
        name: name,
        color: color,
        minValue: minValue,
        maxValue: maxValue);
  }

  /// result: left maxValue; right minValue
  static Pair<double, double> getHeightRange(List<LineChartVo?> lineChartData) {
    Pair<double, double> result =
        Pair(left: -double.maxFinite, right: double.maxFinite);

    for (var element in lineChartData) {
      element?.dataList?.forEach((data) {
        result.left = (data.value ?? -double.maxFinite) > result.left
            ? data.value!
            : result.left;
        result.right = (data.value ?? double.maxFinite) < result.right
            ? data.value!
            : result.right;
      });
    }

    return result;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    if (KlineCollectionUtil.isNotEmpty(_selectedShowData)) {
      return _selectedShowData;
    }

    return dataList
        ?.map((e) =>
            ChartShowDataItemVo(name: name ?? '', value: e.value, color: color))
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
        KlineNumUtil.maxMinValueDouble(dataList?.map((e) => e.value).toList());

    _maxMinData!.right = minValue ?? _maxMinData!.right;
    _maxMinData!.left = maxValue ?? _maxMinData!.left;

    return _maxMinData!;
  }

  @override
  BaseChartVo subData({required int start, int? end}) {
    return LineChartVo(
        id: id,
        name: name,
        maxValue: maxValue,
        minValue: minValue,
        dataList:
            KlineCollectionUtil.sublist(list: dataList, start: start, end: end),
        color: color);
  }

  @override
  int get dataLength => dataList?.length ?? 0;

  @override
  double? getDataMaxValueByIndex(int index) {
    if (index >= dataLength) {
      return null;
    }

    return dataList![index].value;
  }

  @override
  bool isSelectedShowData() {
    return true;
  }
}

class LineChartData {
  DateTime? dateTime;

  double? value;

  LineChartData({this.dateTime, this.value});
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
