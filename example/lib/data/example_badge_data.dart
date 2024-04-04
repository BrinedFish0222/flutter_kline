import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/badge_chart.dart';
import 'package:flutter_kline/widget/bs_point_widget.dart';


class ExampleBadgeData {
  static BadgeChart get badgeChartVo {
    List<BadgeChartData?> dataList = [];
    for (int i = 0; i < 794; ++i) {
      dataList.add(null);
    }
    dataList.addAll([
      BadgeChartData(
        id: '20230811',
        minSize: const Size(20, 30),
        widget: const BsPointWidget.buy(),
        invertWidget: const BsPointWidget.buy(invert: true,),
        value: 12.7,
        invertValue: 11.89,
      ),
      null,
      BadgeChartData(
        id: '20230815',
        minSize: const Size(20, 30),
        widget: const BsPointWidget.buy(),
        invertWidget: const BsPointWidget.buy(invert: true,),
        value: 11.80,
        invertValue: 11.60,
      ),
      null,
      null,
      BadgeChartData(
        id: '20230818',
        minSize: const Size(20, 30),
        widget: const BsPointWidget.sell(),
        invertWidget: const BsPointWidget.sell(invert: true,),
        value: 11.74,
        invertValue: 11.53,
      ),
    ]);

    return BadgeChart(id: 'BadgeChartVo', data: dataList);
  }

  static BadgeChart get volBadgeChartVo {
    List<BadgeChartData?> dataList = [];
    for (int i = 0; i < 796; ++i) {
      dataList.add(null);
    }
    dataList.addAll([
      BadgeChartData(
        id: '20230815',
        minSize: const Size(20, 30),
        widget: const BsPointWidget.buy(),
        invertWidget: const BsPointWidget.buy(invert: true,),
      ),
      null,
      null,
      BadgeChartData(
        id: '20230818',
        minSize: const Size(20, 30),
        widget: const BsPointWidget.sell(),
        invertWidget: const BsPointWidget.sell(invert: true,),
      ),
    ]);

    return BadgeChart(id: "BadgeChartVo", data: dataList);
  }
}
