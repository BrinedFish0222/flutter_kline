import 'package:flutter/material.dart';

class KlineConfig {
  static const List<Color> kLineColors = [
    Color(0xFF969AA1),
    Color(0xFFC4C049),
    Color(0xFFC845CF),
    Color(0xFF7FB370),
    Color(0xFF50C9DF),
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.pink
  ];

  static const Color red = Colors.red;
  static const Color green = Colors.green;

  /// 实时价格线颜色
  static const Color realTimeLineColor = Color(0xFFE1AC45);
  static const Color realTimeLineColor2 = Color(0xFF666666);

  /// 显示数据 - 空间大小
  static const double showDataSpaceSize = 22;

  /// 显示数据 - 字体大小
  static const double showDataFontSize = 10;

  /// 显示数据 - 图标大小
  static const double showDataIconSize = 12;

  /// 显示数据 = 默认长度
  static const int showDataDefaultLength = 60;

  /// 显示数据 - 最小长度
  static const int showDataMinLength = 10;

  /// 显示数据 - 最大长度
  static const int showDataMaxLength = 90;

  /// 矩形数字大小
  static const double rectFontSize = 8;

  /// 分时图一天数据点
  static const int minuteDataNum = 240;

}
