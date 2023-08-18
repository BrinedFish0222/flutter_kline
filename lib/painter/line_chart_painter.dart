import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

/// 折线图
class LineChartPainter extends CustomPainter {
  final List<LineChartVo?> lineChartData;
  final double? pointWidth;
  final Pair<double, double>? maxMinValue;

  LineChartPainter({
    required this.lineChartData,
    this.pointWidth,
    this.maxMinValue,
  });

  // ignore: unused_field
  final String _logPre = "折线图：";
  late Canvas _canvas;
  late Paint _painter;

  double _maxValue = -double.maxFinite;
  double _minValue = double.maxFinite;

  /// 数据点宽度，和 [lineChartData] 一一对应。
  double _pointWidth = 0;

  _init({required Canvas canvas, required Size size}) {
    _canvas = canvas;
    _painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    _initMaxMinValue();

    if (lineChartData.isNotEmpty) {
      _pointWidth = pointWidth ??
          size.width / (lineChartData.first!.dataList!.length - 1);
    }
  }

  /// 初始化：最大最小值。
  _initMaxMinValue() {
    if (maxMinValue != null) {
      _maxValue = maxMinValue!.left;
      _minValue = maxMinValue!.right;
      return;
    }

    for (var dataVo in lineChartData) {
      Pair<num, num>? maxMinValue = KlineNumUtil.maxMinValue(
          dataVo?.dataList?.map((e) => e.value).toList());
      if (maxMinValue == null) {
        continue;
      }

      if (_maxValue < maxMinValue.left) {
        _maxValue = maxMinValue.left.toDouble();
      }

      if (_minValue > maxMinValue.right) {
        _minValue = maxMinValue.right.toDouble();
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (lineChartData.isEmpty) {
      return;
    }

    _init(canvas: canvas, size: size);

    for (LineChartVo? lineChartVo in lineChartData) {
      if (lineChartVo == null ||
          KlineCollectionUtil.isEmpty(lineChartVo.dataList)) {
        continue;
      }

      _painter.color = lineChartVo.color;

      var convertDataList = KlineUtil.convertDataToChartData(
          lineChartVo.dataList!.map((e) => e.value).toList(), size.height,
          maxMinValue: maxMinValue);

      double? lastX;
      double? lastY;
      for (int j = 0; j < convertDataList.length; j++) {
        double? data = convertDataList[j];
        if (data == null) {
          continue;
        }

        lastX ??= j * _pointWidth;
        lastY ??= data;

        double x = j * _pointWidth;
        double y = data;

        _canvas.drawLine(Offset(lastX, lastY), Offset(x, y), _painter);
        lastX = x;
        lastY = y;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
