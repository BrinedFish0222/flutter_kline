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

  Size _getSize({required double yAxis}) {
    double width = pointWidth;
    double height = pointWidth;
    if (badgeChartData.minSize != null) {
      width = badgeChartData.minSize!.width > width
          ? badgeChartData.minSize!.width
          : width;
      height = badgeChartData.minSize!.height > height
          ? badgeChartData.minSize!.height
          : height;
    }

    // 如果组件高度大于定位y轴高度，则使用最小那个高度
    height = height > yAxis ? yAxis : height;
    width = width > height ? height * (2 / 3) : width;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    // TODO 目前只支持 padding bottom
    // 高度
    var yAxis = KlineUtil.computeYAxis(
      maxHeight: maxHeight,
      maxMinValue: maxMinValue,
      value: badgeChartData.value ?? 0,
    );

    Size size = _getSize(yAxis: yAxis);

    yAxis = (yAxis - size.height - badgeChartData.padding.bottom)
        .clamp(0, maxHeight - size.height)
        .toDouble();

    var xAxis =
        (pointWidth + pointGap) * index - ((size.width - pointWidth) / 2);

    return Positioned(
      left: xAxis,
      top: yAxis,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: badgeChartData.widget,
      ),
    );
  }
}
