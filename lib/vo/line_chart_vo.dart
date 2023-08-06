import 'package:flutter/material.dart';

/// 折线图数据
class LineChartVo {
  String? id;
  String? name;
  List<LineChartData>? dataList;
  Color color;

  LineChartVo(
      {this.id, this.name, required this.dataList, this.color = Colors.black});
}

class LineChartData {
  DateTime? dateTime;

  double? value;

  LineChartData({this.dateTime, this.value});
}
