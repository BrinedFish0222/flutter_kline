import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/utils/collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/utils/num_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

/// 折线图
class LineChartPainter extends CustomPainter {
  final Size size;
  final List<LineChartVo?> lineChartData;

  /// TODO lineChartData校验每一项长度都相等。
  LineChartPainter({
    required this.size,
    required this.lineChartData,
  });

  final String _logPre = "折线图：";
  late Canvas _canvas;
  late Paint _painter;

  double _maxValue = -double.maxFinite;
  double _minValue = double.maxFinite;

  /// 数据点宽度，和 [lineChartData] 一一对应。
  double _pointWidth = 0;
  double _pointHeight = 0;

  _init({required Canvas canvas}) {
    _canvas = canvas;
    _painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    _initMaxMinValue();
    _initPointWidthHeight();

    debugPrint(
        "$_logPre _maxValue $_maxValue, _minValue $_minValue, size.width ${size.width}, _pointWidth $_pointWidth");
  }

  /// 初始化数据点宽高
  _initPointWidthHeight() {
    if (CollectionUtil.isEmpty(lineChartData)) {
      return;
    }

    _pointWidth = size.width / lineChartData.first!.dataList!.length;
  }

  /// 初始化：最大最小值。
  _initMaxMinValue() {
    for (var dataVo in lineChartData) {
      Pair<num, num>? maxMinValue = NumUtil.maxMinValue(dataVo?.dataList);
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

    _init(canvas: canvas);

    for (LineChartVo? lineChartVo in lineChartData) {
      if (lineChartVo == null || CollectionUtil.isEmpty(lineChartVo.dataList)) {
        continue;
      }

      _painter.color = lineChartVo.color;

      var convertDataList =
          KlineUtil.convertDataToChartData(lineChartVo.dataList!, size.height);

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
