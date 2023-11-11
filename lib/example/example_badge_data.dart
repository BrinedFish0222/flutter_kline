import 'package:flutter/material.dart';
import 'package:flutter_kline/vo/badge_chart_vo.dart';
import 'package:flutter_kline/widget/bs_point_widget.dart';

class ExampleBadgeData {
  static BadgeChartVo get badgeChartVo {
    return BadgeChartVo(
        data: []
          ..length = 796
          ..addAll([
            BadgeChartData(
              minSize: const Size(20, 50),
              widget: const BsPointWidget.buy(),
            ),
            null,
            null,
            BadgeChartData(
              minSize: const Size(12, 12),
              widget: LayoutBuilder(builder: (context, constraints) {
                double size = constraints.maxWidth > constraints.maxHeight
                    ? constraints.maxHeight
                    : constraints.maxWidth;
                return Container(
                  color: Colors.blue,
                  width: size,
                  height: size,
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
