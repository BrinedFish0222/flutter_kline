import 'package:flutter/material.dart';
import 'package:flutter_kline/vo/vertical_line_chart_vo.dart';

class ExampleVerticalLineData {
  static VerticalLineChartVo get verticalLine {
    List<VerticalLineChartData?> dataList = [];
    for (int i = 0; i < 800; ++i) {
      dataList.add(null);
    }
    dataList[795] = VerticalLineChartData(id: '795', top: 12.5, bottom: 12, color: Colors.blue);

    return VerticalLineChartVo(id: 'verticalLineChartVo', data: dataList, );
  }
}