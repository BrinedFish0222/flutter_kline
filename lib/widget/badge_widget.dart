import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/badge_chart_vo.dart';

import '../common/pair.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    super.key,
    required this.badgeChartVo,
    this.pointWidth,
    this.pointGap = 0,
    required this.maxMinValue,
  });

  final BadgeChartVo badgeChartVo;
  final double? pointWidth;
  final double pointGap;
  final Pair<double, double> maxMinValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var secPointWidth = constraints.maxWidth / badgeChartVo.data.length;
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Stack(
          children: [
            for (int i = 0; i < badgeChartVo.data.length; ++i)
              badgeChartVo.data[i] == null
                  ? const SizedBox()
                  : _BadgePositionedWidget(
                      index: i,
                      pointWidth: pointWidth ?? secPointWidth,
                      pointGap: pointGap,
                      badgeChartData: badgeChartVo.data[i]!,
                      maxHeight: constraints.maxHeight,
                      maxMinValue: maxMinValue,
                    ),
          ],
        ),
      );
    });
  }
}

class _BadgePositionedWidget extends StatelessWidget {
  const _BadgePositionedWidget({
    required this.index,
    required this.pointWidth,
    // ignore: unused_element
    this.pointGap = 0,
    required this.badgeChartData,
    required this.maxMinValue,
    required this.maxHeight,
  });

  final int index;
  final double pointWidth;
  final double pointGap;
  final double maxHeight;
  final BadgeChartData badgeChartData;
  final Pair<double, double> maxMinValue;

  @override
  Widget build(BuildContext context) {
    // TODO 目前只支持 padding bottom
    // 高度
    var yAxisValue = KlineUtil.computeYAxisValue(
      maxHeight: maxHeight,
      maxMinValue: maxMinValue,
      value: badgeChartData.value ?? 0,
    );
    yAxisValue = (yAxisValue - pointWidth / 2 - badgeChartData.padding.bottom)
        .clamp(0, maxHeight - pointWidth)
        .toDouble();

    var xAxisValue = (pointWidth + pointGap) * index;
    return Positioned(
      left: xAxisValue,
      top: yAxisValue,
      child: SizedBox(
        width: pointWidth,
        height: pointWidth,
        child: badgeChartData.widget,
      ),
    );
  }
}
