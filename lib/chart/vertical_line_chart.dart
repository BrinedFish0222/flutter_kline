import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';

import '../common/utils/kline_num_util.dart';
import '../painter/vertical_line_chart_painter.dart';
import 'base_chart.dart';
import '../common/chart_show_data_item_vo.dart';

/// 竖线
class VerticalLineChart<E> extends BaseChart<VerticalLineChartData<E>> {
  VerticalLineChart({
    required super.id,
    required super.data,
    super.name,
    super.maxValue,
    super.minValue,
  });

  VerticalLineChart<E> copyWith({
    String? id,
    List<VerticalLineChartData<E>?>? data,
    String? name,
    double? maxValue,
    double? minValue,
  }) {
    return VerticalLineChart<E>(
      id: id ?? this.id,
      data: data ?? this.data,
      name: name ?? this.name,
      maxValue: maxValue ?? this.maxValue,
      minValue: minValue ?? this.minValue,
    );
  }

  @override
  BaseChart<BaseChartData> copy() {
    return copyWith();
  }

  @override
  int get dataLength => data.length;

  @override
  double? getDataMaxValueByIndex(int index) {
    if (data.isEmpty) {
      return null;
    }

    return data[index]?.top;
  }

  @override
  Pair<double, double> getMaxMinData() {
    Pair<double, double> result = Pair.defaultMaxMinValue;
    if (data.isNotEmpty) {
      var valueList = data
          .where((element) => element != null)
          .map((e) => [e!.top, e.bottom])
          .reduce((e1, e2) => e1..addAll(e2))
          .toList();
      result = KlineNumUtil.maxMinValueDouble(valueList);
    }

    return result;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    if (data.isEmpty) {
      return null;
    }

    return data
        .map((e) => ChartShowDataItemVo(name: name ?? '', value: e?.top))
        .toList();
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
    VerticalLineChartPainter(
      data: this,
      maxMinValue: maxMinValue,
      pointWidth: pointWidth,
      pointGap: pointGap,
    ).paint(canvas, size);
  }
}

class VerticalLineChartData<E> extends BaseChartData<E> {
  double top;
  double bottom;

  VerticalLineChartData({
    required super.id,
    super.dateTime,
    required this.top,
    required this.bottom,
    super.color,
    super.extrasData,
  });

  VerticalLineChartData copyWith({
    double? top,
    double? bottom,
    Color? color,
  }) {
    return VerticalLineChartData(
      id: id,
      dateTime: dateTime,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      extrasData: extrasData,
      color: color ?? this.color,
    );
  }
}
