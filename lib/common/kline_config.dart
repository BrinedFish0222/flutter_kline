import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';

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
  static const int showDataDefaultLength = 40;

  /// 显示数据 - 最小长度
  static const int showDataMinLength = 10;

  /// 显示数据 - 最大长度
  static const int showDataMaxLength = 90;

  /// 矩形数字大小
  static const double rectFontSize = 8;

  /// 分时图一天数据点
  static const int minuteDataNum = 240;

  /// 默认数据最大最小值
  static final Pair<double, double> defaultMaxMinValue = Pair(left: 1, right: 0);

  /// 数据点像素占比
  static const double pointWidthRatio = .8;

  /// 横向滑动动画值
  static const double horizontalDragAnimationValue = 2;

}
