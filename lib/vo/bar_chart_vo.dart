import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

import '../painter/bar_chart_painter.dart';

class BarChartVo<E> extends BaseChartVo<BarChartData<E>> {
  /// 柱体宽度
  double? barWidth;

  List<ChartShowDataItemVo?>? _selectedShowData;
  Pair<double, double>? _maxMinData;

  BarChartVo({
    required super.id,
    super.name,
    super.maxValue,
    super.minValue,
    this.barWidth,
    required super.data,
  }) {
    getSelectedShowData();
  }

  @override
  void paint({
    required Canvas canvas,
    required Size size,
    required Pair<double, double> maxMinValue,
    required double pointWidth,
    required double pointGap,
    required EdgeInsets padding,
  }) {
    BarChartPainter(
      barData: this,
      pointWidth: pointWidth,
      pointGap: pointGap,
      maxMinValue: maxMinValue,
    ).paint(canvas, size);
  }

  @override
  BaseChartVo copy() {
    List<BarChartData<E>?> newData = [];
    if (data.isNotEmpty) {
      newData = data.sublist(0);
    }
    return BarChartVo(
      id: id,
      name: name,
      maxValue: maxValue,
      minValue: minValue,
      barWidth: barWidth,
      data: newData,
    );
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    if (KlineCollectionUtil.isNotEmpty(_selectedShowData)) {
      return _selectedShowData;
    }

    return data
        .map((e) => ChartShowDataItemVo(
              name: name ?? '',
              value: e?.value,
              color: e?.color ?? Colors.black,
            ))
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

    Pair<double, double> maxMinValue =
        KlineNumUtil.maxMinValueDouble(data.map((e) => e?.value).toList());

    double max = maxValue ?? maxMinValue.left;
    double min = minValue ?? maxMinValue.right;

    _maxMinData = Pair<double, double>(left: max, right: min);
    return _maxMinData!;
  }

  @override
  int get dataLength => data.length;

  @override
  double? getDataMaxValueByIndex(int index) {
    if (index >= dataLength) {
      return null;
    }

    return (data[index])?.value;
  }

  @override
  bool isSelectedShowData() {
    return true;
  }
}

class BarChartData<E> extends BaseChartData<E> {
  double value;
  bool isFill;

  BarChartData({
    required super.id,
    this.value = 0,
    this.isFill = false,
    super.color = Colors.black,
    super.extrasData,
  });
}
