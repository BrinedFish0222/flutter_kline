import 'package:flutter/material.dart';
import 'package:flutter_kline/common/chart_show_data_item_vo.dart';
import 'package:flutter_kline/common/pair.dart';
import '../common/utils/kline_num_util.dart';
import '../painter/circle_painter.dart';
import 'base_chart.dart';

/// 圆形图
class CircleChart<E> extends BaseChart<CircleChartData<E>> {
  CircleChart({
    required super.id,
    required super.name,
    required super.maxValue,
    required super.minValue,
    required super.data,
    super.isUserDefine,
  });

  @override
  CircleChart<E> copy() {
    return CircleChart(
      id: id,
      name: name,
      maxValue: maxValue,
      minValue: minValue,
      data: data.sublist(0),
      isUserDefine: isUserDefine,
    );
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
  Pair<double, double> getMaxMinData() {
    if (data.isEmpty) {
      return Pair.defaultMaxMinValue;
    }

    var valueList =
        data.whereType<CircleChartData>().map((e) => e.value).toList();
    Pair<double, double> maxMinValue =
        KlineNumUtil.maxMinValueDouble(valueList);
    return maxMinValue;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    return data
        .map((e) => ChartShowDataItemVo(name: name ?? '', value: e?.value))
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
    CirclePainter(
      chart: this,
      pointWidth: pointWidth,
      pointGap: pointGap,
      maxMinValue: maxMinValue,
      padding: padding,
    ).paint(canvas, size);
  }
}

class CircleChartData<E> extends BaseChartData<E> {
  /// 中心点数值
  final double value;

  /// 左边和右边的间隔数
  final int spaceNumber;

  CircleChartData({
    required super.id,
    required super.dateTime,
    super.extrasData,
    required this.value,
    required this.spaceNumber,
  });
}
