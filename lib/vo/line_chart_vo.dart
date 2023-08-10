import 'package:flutter/material.dart';

import 'candlestick_chart_vo.dart';

/// 折线图数据
class LineChartVo {
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
