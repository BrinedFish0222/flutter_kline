import 'package:flutter/material.dart';

/// 图显示数据项
/// 例如：MA的MA13、MA34、MA144，此项不包括MA。
class ChartShowDataItemVo {
  String name;
  double? value;
  Color color;

  ChartShowDataItemVo({this.name = '', this.value, this.color = Colors.black,});

}
