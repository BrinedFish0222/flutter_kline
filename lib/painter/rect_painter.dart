import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/exts/canvas_ext.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../common/constants/line_type.dart';


/// 矩形背景图
class RectPainter extends CustomPainter {
  /// 中间的横线数量
  final int transverseLineNum;

  /// 中间线配置
  final List<RectLineConfig?>? transverseLineConfigList;
  final Color lineColor;
  final double lineWidth;
  final TextStyle? textStyle;
  final double? maxValue;
  final double? minValue;

  /// 是否画竖线
  final bool isDrawVerticalLine;

  /// 是否显示最低值文本
  final bool showMinValueText;

  RectPainter({
    this.transverseLineNum = 2,
    this.transverseLineConfigList,
    this.isDrawVerticalLine = false,
    this.lineColor = Colors.grey,
    this.lineWidth = 0.1,
    this.textStyle,
    this.maxValue,
    this.minValue,
    this.showMinValueText = true,
  }) : assert(
            !((maxValue != null && minValue == null) ||
                (maxValue == null && minValue != null)),
            "maxValue和minValue必须二者同时为空或不为空");

  late Canvas _canvas;
  late Paint _painter;

  /// 行高:横线的间距
  double _transverseLineHeight = 0;

  /// 横线文本值
  List<double> _transverseLineTextValues = [];

  _init({required Canvas canvas, required Size size}) {
    _canvas = canvas;
    _painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = lineWidth;

    _transverseLineHeight = size.height / (transverseLineNum + 1);

    _initTransverseLineTextValues();
  }

  /// 初始化：横线文本值。
  void _initTransverseLineTextValues() {
    if (this.maxValue == null) {
      return;
    }

    // 定义最大最小值，默认是最小是0，最大是1。
    double minValue = this.minValue ?? double.maxFinite;
    double maxValue = this.maxValue ?? -double.maxFinite;

    if (maxValue == -double.maxFinite && minValue == double.maxFinite) {
      maxValue = KlineConfig.defaultMaxMinValue.left;
      minValue = KlineConfig.defaultMaxMinValue.right;
    } else {
      if (maxValue == -double.maxFinite) {
        maxValue = minValue == double.maxFinite ? 1 : minValue + 1;
      }
      if (minValue == double.maxFinite) {
        minValue = maxValue - 1;
      }
    }


    double value = (maxValue - minValue) / (transverseLineNum + 1);

    _transverseLineTextValues.add(minValue);
    for (int i = 0; i < transverseLineNum; ++i) {
      _transverseLineTextValues.add(minValue + value * (i + 1));
    }

    _transverseLineTextValues.add(maxValue);
    _transverseLineTextValues = _transverseLineTextValues.reversed.toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _init(canvas: canvas, size: size);
    List<RectLineConfig> transverseLineConfigList = _initTransverseLineConfig();

    // 绘制矩形边框
    Rect rect = Offset.zero & size;
    canvas.drawRect(rect, _painter);

    _drawVerticalLine(size: size);
    _drawTransverseLine(
        transverseLineConfigList: transverseLineConfigList, size: size);
  }

  /// 绘制竖线
  void _drawVerticalLine({required Size size}) {
    if (!isDrawVerticalLine) {
      return;
    }

    double verticalWidth = size.width / (transverseLineNum + 1);
    for (int i = 1; i <= transverseLineNum + 1; i++) {
      double x = i * verticalWidth;
      _canvas.drawLine(Offset(x, 0), Offset(x, size.height), _painter);
    }
  }

  // 绘制横线和文本数字
  void _drawTransverseLine({
    required List<RectLineConfig> transverseLineConfigList,
    required Size size,
  }) {
    double leftPadding = 2;
    TextStyle fontTextStyle = textStyle ??
        TextStyle(color: lineColor, fontSize: KlineConfig.rectFontSize);

    // 绘制第一根线文字
    if (_transverseLineTextValues.isNotEmpty) {
      TextPainter firstTextPainter = TextPainter(
        text: TextSpan(
          text: KlineNumUtil.formatNumberUnit(_transverseLineTextValues[0]),
          style: fontTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      firstTextPainter.layout();
      firstTextPainter.paint(_canvas, Offset(leftPadding, 2));
    }

    // 绘制中间和最后的线和文字。
    Color oldColor = _painter.color;
    for (int i = 1; i <= transverseLineNum + 1; i++) {
      double y = i * _transverseLineHeight;
      RectLineConfig transverseLineConfig = transverseLineConfigList[i - 1];
      _painter.color = transverseLineConfig.color;

      // 根据实际情况画实线还是虚线
      if (transverseLineConfig.type == LineType.dotted) {
        _canvas.drawDottedLine(Offset(0, y), Offset(size.width, y), _painter,
            dottedLineLength: transverseLineConfig.dottedLineLength,
            dottedLineSpace: transverseLineConfig.dottedLineSpace);
      } else {
        _canvas.drawLine(Offset(0, y), Offset(size.width, y), _painter);
      }

      _painter.color = oldColor;

      if (_transverseLineTextValues.isEmpty) {
        continue;
      }

      // 检测是否需要画最后一根线的文本
      if (i == transverseLineNum + 1 && !showMinValueText) {
        continue;
      }

      TextSpan span = TextSpan(
        text: KlineNumUtil.formatNumberUnit(_transverseLineTextValues[i]),
        style: fontTextStyle,
      );

      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      tp.paint(_canvas, Offset(leftPadding, y - tp.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  /// 初始化横线样式
  List<RectLineConfig> _initTransverseLineConfig() {
    List<RectLineConfig> result = [];
    if (KlineCollectionUtil.isNotEmpty(transverseLineConfigList)) {
      result.addAll(transverseLineConfigList!.map((e) => e ?? RectLineConfig()));
    }

    if (result.length >= transverseLineNum) {
      return result..add(RectLineConfig());
    }

    for (int i = 0; i < (transverseLineNum - result.length + 4); ++i) {
      result.add(RectLineConfig());
    }

    return result;
  }
}


/// 矩形线配置
class RectLineConfig {
  LineType type;
  Color color;

  /// 虚线长度
  double dottedLineLength;

  /// 虚线间隔
  double dottedLineSpace;

  RectLineConfig(
      {this.type = LineType.full,
        this.color = Colors.black,
        this.dottedLineLength = 2,
        this.dottedLineSpace = 2});
}
