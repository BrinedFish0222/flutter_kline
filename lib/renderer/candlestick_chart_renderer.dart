import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';

import '../painter/line_chart_painter.dart';
import '../painter/rect_painter.dart';
import '../vo/line_chart_vo.dart';

/// 蜡烛图
class CandlestickChartRenderer extends CustomPainter {
  final List<LineChartVo?>? lineChartData;

  /// 矩形中间的横线
  final int rectTransverseLineNum;

  const CandlestickChartRenderer(
      {this.lineChartData, this.rectTransverseLineNum = 2});

  @override
  void paint(Canvas canvas, Size size) {
    Pair<double, double> rectRange = getRectRange();

    // 画矩形
    RectPainter(
            size: size,
            transverseLineNum: rectTransverseLineNum,
            maxValue: rectRange.left,
            minValue: rectRange.right,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(color: Colors.grey, fontSize: 8))
        .paint(canvas, size);

    // 画折线
    if (KlineCollectionUtil.isNotEmpty(lineChartData)) {
      LineChartPainter(lineChartData: lineChartData!, size: size)
          .paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  /// 获取矩形的范围
  Pair<double, double> getRectRange() {
    Pair<double, double> result =
        Pair(left: -double.maxFinite, right: double.maxFinite);

    lineChartData?.forEach((element) {
      element?.dataList?.forEach((data) {
        result.left =
            (data ?? -double.maxFinite) > result.left ? data! : result.left;
        result.right =
            (data ?? double.maxFinite) < result.right ? data! : result.right;
      });
    });

    return result;
  }
}
