import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/candlestick_chart_painter.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../common/pair.dart';
import 'base_chart.dart';
import '../common/chart_show_data_item_vo.dart';

/// 蜡烛图
class CandlestickChart<E> extends BaseChart<CandlestickChartData<E>> {
  CandlestickChart({
    required super.id,
    super.name,
    super.maxValue,
    super.minValue,
    required super.data,
  }) {
    getMaxMinData();
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
    // 画蜡烛图
    canvas.save();
    CandlestickChartPainter(
      data: this,
      maxMinHeight: maxMinValue,
      pointWidth: pointWidth,
      pointGap: pointGap,
    ).paint(canvas, size);
    canvas.restore();
  }

  @override
  BaseChart copy() {
    return CandlestickChart(
      id: id,
      name: name,
      maxValue: maxValue,
      minValue: minValue,
      data: data.isEmpty ? [] : data.sublist(0),
    );
  }

  @override
  Pair<double, double> getMaxMinData() {
    if (minValue != null && maxValue != null) {
      return Pair(left: maxValue!, right: minValue!);
    }

    var pairList = data
        .where((e) => e != null)
        .map((e) => KlineNumUtil.maxMinValueDouble(
            [e?.open, e?.close, e?.high, e?.low]))
        .toList();

    Pair<double, double> maxMinData = Pair.getMaxMinValue(pairList);
    maxMinData.right = minValue ?? maxMinData.right;
    maxMinData.left = maxValue ?? maxMinData.left;

    return maxMinData;
  }

  @override
  List<ChartShowDataItemVo?>? getSelectedShowData() {
    // 蜡烛图一点要显示四条数据，不适合此方法。
    return [];
  }

  @override
  int get dataLength => data.length;

  @override
  double? getDataMaxValueByIndex(int index) {
    if (index >= dataLength) {
      return null;
    }

    var singleData = data[index];
    var maxMinValue = KlineNumUtil.maxMinValueDouble([
      singleData?.close,
      singleData?.open,
      singleData?.low,
      singleData?.high,
    ]);

    return maxMinValue.left;
  }

  @override
  bool isSelectedShowData() {
    return false;
  }
}

class CandlestickChartData<E> extends BaseChartData<E> {
  double open;
  double close;
  double high;
  double low;

  CandlestickChartData({
    required super.id,
    required super.dateTime,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    super.color,
    super.extrasData,
  });

  CandlestickChartData copyWith({
    String? id,
    DateTime? dateTime,
    double? open,
    double? close,
    double? high,
    double? low,
    Color? color,
    Map<String, dynamic>? extrasData,
  }) {
    return CandlestickChartData(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      open: open ?? this.open,
      close: close ?? this.close,
      high: high ?? this.high,
      low: low ?? this.low,
      color: color ?? this.color,
      extrasData: extrasData ?? this.extrasData,
    );
  }
}
