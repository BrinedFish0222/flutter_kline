import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/vertical_line_chart.dart';

class ExampleVerticalLineData {
  static VerticalLineChart get verticalLine {
    List<VerticalLineChartData?> dataList = [];
    for (int i = 0; i < 800; ++i) {
      dataList.add(null);
    }
    dataList[795] = VerticalLineChartData(id: '795', top: 12.5, bottom: 12, color: Colors.blue);

    return VerticalLineChart(id: 'verticalLineChartVo', data: dataList, );
  }
}