import 'package:flutter/material.dart';

import '../common/pair.dart';
import '../common/utils/kline_collection_util.dart';
import '../common/utils/kline_num_util.dart';
import '../painter/line_chart_painter.dart';
import 'base_chart.dart';
import 'candlestick_chart.dart';
import '../common/chart_show_data_item_vo.dart';

/// 折线图
class LineChart<E> extends BaseChart<LineChartData<E>> {
  Color color;

  /// 渐变色，空表示不显示
  Gradient? gradient;

  List<ChartShowDataItemVo?>? _selectedShowData;
  Pair<double, double>? _maxMinData;

  LineChart({
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
  BaseChart copy() {
    var newDataList = data.map((e) => e).toList();
    return LineChart(
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
  static Pair<double, double> getHeightRange(List<LineChart?> lineChartData) {
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

  @override
  void paint({
    required Canvas canvas,
    required Size size,
    required Pair<double, double> maxMinValue,
    required double pointWidth,
    required double pointGap,
    required EdgeInsets padding,
  }) {
    LineChartPainter(
      lineChartData: this,
      maxMinValue: maxMinValue,
      pointWidth: pointWidth,
      pointGap: pointGap,
    ).paint(canvas, size);
  }
}

class LineChartData<E> extends BaseChartData<E> {
  double? value;

  LineChartData({
    required super.id,
    super.dateTime,
    this.value,
    super.extrasData,
  });
}

class SelectedLineChartDataStreamVo {
  String? name;
  Color color;
  double? value;

  /// 对应的蜡烛图数据
  CandlestickChart? candlestickChartVo;

  SelectedLineChartDataStreamVo(
      {this.name, required this.color, this.value, this.candlestickChartVo});
}
