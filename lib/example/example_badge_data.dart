import 'package:flutter/material.dart';
import 'package:flutter_kline/vo/badge_chart_vo.dart';
import 'package:flutter_kline/widget/bs_point_widget.dart';

class ExampleBadgeData {
  static BadgeChartVo get badgeChartVo {
    List<BadgeChartData?> dataList = [];
    for (int i = 0; i < 796; ++i) {
      dataList.add(null);
    }
    dataList.addAll([
      BadgeChartData(
        minSize: const Size(20, 30),
        widget: const BsPointWidget.buy(),
        invertWidget: const BsPointWidget.buy(invert: true,),
        value: 11.80,
        invertValue: 11.60,
      ),
      null,
      null,
      BadgeChartData(
        minSize: const Size(20, 30),
        widget: const BsPointWidget.sell(),
        invertWidget: const BsPointWidget.sell(invert: true,),
        value: 11.74,
        invertValue: 11.53,
      ),
    ]);

    return BadgeChartVo(data: dataList);
  }

  static BadgeChartVo get volBadgeChartVo {
    List<BadgeChartData?> dataList = [];
    for (int i = 0; i < 796; ++i) {
      dataList.add(null);
    }
    dataList.addAll([
      BadgeChartData(
        minSize: const Size(20, 30),
        widget: const BsPointWidget.buy(),
        invertWidget: const BsPointWidget.buy(invert: true,),
      ),
      null,
      null,
      BadgeChartData(
        minSize: const Size(20, 30),
        widget: const BsPointWidget.sell(),
        invertWidget: const BsPointWidget.sell(invert: true,),
      ),
    ]);

    return BadgeChartVo(data: dataList);
  }
}
