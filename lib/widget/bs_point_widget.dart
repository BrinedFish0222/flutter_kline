import 'dart:math';

import 'package:flutter/material.dart';

/// 买卖点
class BsPointWidget extends StatelessWidget {
  const BsPointWidget({
    super.key,
    required this.text,
    this.singleDottedLineHeight = 3,
    this.color = Colors.red,
    this.invert = false,
  });

  const BsPointWidget.buy({
    super.key,
    this.text = '买',
    this.singleDottedLineHeight = 3,
    this.color = Colors.red,
    this.invert = false,
  });

  const BsPointWidget.sell({
    super.key,
    this.text = '卖',
    this.singleDottedLineHeight = 3,
    this.color = Colors.green,
    this.invert = false,
  });

  final String text;
  final Color color;

  /// 单根虚线高度
  final double singleDottedLineHeight;

  /// 是否颠倒
  final bool invert;

  @override
  Widget build(BuildContext context) {
    int rotation = invert ? 1 : 0;
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth =
          constraints.maxWidth == double.infinity ? 30 : constraints.maxWidth;
      double maxHeight = constraints.maxHeight == double.infinity
          ? maxWidth * 2
          : constraints.maxHeight;

      // 买卖点容器大小
      double fontBox = maxWidth * (2 / 3);
      // 小圆大小
      double smallCircleSize = maxWidth * (1 / 4);
      // 虚线padding
      double dottedLinePadding = singleDottedLineHeight * 0.4;
      // 虚线数量
      int dottedLineNum = (maxHeight - fontBox - smallCircleSize) ~/
          (singleDottedLineHeight + 2 * dottedLinePadding);

      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(pi * rotation),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(fontBox / 4)),
              ),
              height: fontBox,
              width: fontBox,
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(3.14 * rotation),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: fontBox * (2 / 3),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            /// 生成竖线
            ...List.generate(
              dottedLineNum,
              (index) => Padding(
                padding: EdgeInsets.symmetric(vertical: dottedLinePadding),
                child: Container(
                  width: 1.0,
                  height: singleDottedLineHeight,
                  color: color,
                ),
              ),
            ),

            /// 小圆
            Container(
              decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.all(Radius.circular(smallCircleSize))),
              height: smallCircleSize,
              width: smallCircleSize,
            ),
          ],
        ),
      );
    });
  }
}
