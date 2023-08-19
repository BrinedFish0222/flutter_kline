import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

class BarChartVo extends BaseChartVo {
  List<BarChartData> data;

  BarChartVo({super.id, super.name, required this.data});
  
  @override
  List<double?>? getShowData() {
    return data.map((e) => e.value).toList();
  }

  @override
  Pair<double, double> getMaxMinData() {
    double max = data.map((e) => e.value).reduce((value, element) => value > element ? value : element);
    // double min = data.map((e) => e.value).reduce((value, element) => value < element ? value : element);
    return Pair<double, double>(left: max, right: 0);
  }
  
  @override
  BaseChartVo subData({required int start, int? end}) {
    return BarChartVo(id: id, name: name, data: data.sublist(start, end));
  }
}

class BarChartData {
  double value;
  bool isFill;
  Color? color;

  BarChartData({required this.value, this.isFill = false, this.color});
}
