import 'package:flutter/material.dart';
import 'package:flutter_kline/vo/badge_chart_vo.dart';

class ExampleBadgeData {
  static BadgeChartVo get badgeChartVo {
    return BadgeChartVo(
        data: []
          ..length = 796
          ..addAll([
            BadgeChartData(
              widget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  color: Colors.red,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Center(
                    child: Text(
                      "买",
                      style: TextStyle(
                        fontSize: constraints.maxWidth / 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
            null,
            null,
            BadgeChartData(
              widget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  color: Colors.blue,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Center(
                    child: Text(
                      "卖",
                      style: TextStyle(
                        fontSize: constraints.maxWidth / 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ]));
  }
}
