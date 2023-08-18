import 'package:flutter/material.dart';

import '../common/pair.dart';
import 'base_chart_vo.dart';
import 'candlestick_chart_vo.dart';

/// 折线图数据
class LineChartVo extends BaseChartVo {
  String? id;
  String? name;
  List<LineChartData>? dataList;
  Color color;

  LineChartVo(
      {this.id, this.name, required this.dataList, this.color = Colors.black});

  LineChartVo copy() {
    var newDataList = dataList?.map((e) => e).toList();
    return LineChartVo(dataList: newDataList, id: id, name: name, color: color);
  }

  /// result: left maxValue; right minValue
  static Pair<double, double> getHeightRange(List<LineChartVo?> lineChartData) {
    Pair<double, double> result = Pair(left: -double.maxFinite, right: double.maxFinite);

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
