import 'dart:math';

import 'package:flutter/material.dart';

import '../chart/badge_chart.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    super.key,
    required this.badgeChartVo,
    this.pointWidth,
    this.pointGap = 0,
    required this.maxMinValue,
    this.padding = EdgeInsets.zero,
  });

  final BadgeChart badgeChartVo;
  final double? pointWidth;
  final double pointGap;
  final Pair<double, double> maxMinValue;
  final EdgeInsets padding;

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
              if (badgeChartVo.data[i] != null)
                _BadgePositionedWidget(
                  index: i,
                  pointWidth: pointWidth ?? secPointWidth,
                  pointGap: pointGap,
                  badgeChartData: badgeChartVo.data[i]!,
                  maxHeight: constraints.maxHeight,
                  maxMinValue: maxMinValue,
                  padding: padding,
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
    this.padding = EdgeInsets.zero,
  });

  final int index;
  final double pointWidth;
  final double pointGap;
  final double maxHeight;
  final BadgeChartData badgeChartData;
  final Pair<double, double> maxMinValue;
  final EdgeInsets padding;

  Size _getSize({required double yAxis}) {
    double width = pointWidth;
    double height = pointWidth * badgeChartData.highMultiple;
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
    // 判断是否需要颠倒
    bool invert = badgeChartData.invert(maxMinValue: maxMinValue);
    double? autoValue = invert ? badgeChartData.invertValue : badgeChartData.value;

    // TODO 目前只支持 padding bottom
    // 高度
    var yAxis = KlineUtil.computeYAxis(
      maxHeight: maxHeight,
      maxMinValue: maxMinValue,
      value: autoValue ?? 0,
    );

    Size size = _getSize(yAxis: yAxis);

    if (invert) {
      yAxis = (yAxis - badgeChartData.padding.bottom)
          .clamp(0, maxHeight - size.height)
          .toDouble();
    } else {
      yAxis = (yAxis - size.height - badgeChartData.padding.bottom)
          .clamp(0, maxHeight - size.height)
          .toDouble();
    }

    var xAxis =
        (pointWidth + pointGap) * index - ((size.width - pointWidth) / 2) + padding.left;


    Widget? badge = invert ? badgeChartData.invertWidget : badgeChartData.widget;
    if (invert && badgeChartData.invertWidget == null && badgeChartData.widget != null) {
      badge = Transform(
        transform: Matrix4.rotationX(pi),
        child: badgeChartData.widget,
      );
    }

    return Positioned(
      left: xAxis,
      top: yAxis,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: badge,
      ),
    );
  }
}
