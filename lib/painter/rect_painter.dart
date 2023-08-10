import 'package:flutter/material.dart';

/// 矩形背景图
class RectPainter extends CustomPainter {
  final Size size;

  /// 中间的横线数量
  final int transverseLineNum;
  final Color lineColor;
  final double lineWidth;
  final TextStyle? textStyle;
  final double? maxValue;
  final double? minValue;

  /// 是否画竖线
  final bool isDrawVerticalLine;

  RectPainter(
      {required this.size,
      this.transverseLineNum = 2,
      this.isDrawVerticalLine = false,
      this.lineColor = Colors.grey,
      this.lineWidth = 0.1,
      this.textStyle,
      this.maxValue,
      this.minValue})
      : assert(
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
    if (maxValue == null) {
      return;
    }

    double value = (maxValue! - minValue!) / (transverseLineNum + 1);

    _transverseLineTextValues.add(minValue!);
    for (int i = 0; i < transverseLineNum; ++i) {
      _transverseLineTextValues.add(minValue! + value * (i + 1));
    }

    _transverseLineTextValues.add(maxValue!);
    _transverseLineTextValues = _transverseLineTextValues.reversed.toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("绘制矩形。。。");
    _init(canvas: canvas, size: size);

    // 绘制矩形边框
    Rect rect = Offset.zero & this.size;
    canvas.drawRect(rect, _painter);

    _drawVerticalLine();
    _drawTransverseLine();
  }

  /// 绘制竖线
  void _drawVerticalLine() {
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
  void _drawTransverseLine() {
    double leftPadding = 2;
    TextStyle fontTextStyle =
        textStyle ?? TextStyle(color: lineColor, fontSize: 8);

    // 绘制第一根线文字
    if (_transverseLineTextValues.isNotEmpty) {
      TextPainter firstTextPainter = TextPainter(
        text: TextSpan(
          text: _transverseLineTextValues[0].toStringAsFixed(2),
          style: fontTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      firstTextPainter.layout();
      firstTextPainter.paint(_canvas, Offset(leftPadding, 2));
    }

    // 绘制中间和最后的线和文字。
    for (int i = 1; i <= transverseLineNum + 1; i++) {
      double y = i * _transverseLineHeight;
      _canvas.drawLine(Offset(0, y), Offset(size.width, y), _painter);

      if (_transverseLineTextValues.isEmpty) {
        continue;
      }

      TextSpan span = TextSpan(
        text: _transverseLineTextValues[i].toStringAsFixed(2),
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
}
