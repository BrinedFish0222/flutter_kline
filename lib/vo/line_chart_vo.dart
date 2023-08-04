import 'package:flutter/material.dart';

/// 折线图数据
class LineChartVo {
  List<double?>? dataList;
  Color color;

  LineChartVo({required this.dataList, this.color = Colors.black});
}
