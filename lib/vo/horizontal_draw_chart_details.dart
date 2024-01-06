import 'package:flutter/material.dart';

/// 横向滑动画图请求
class HorizontalDrawChartDetails {
  /// 数据开始索引
  final int startIndex;

  /// 数据结束索引
  final int endIndex;

  /// chart padding
  final EdgeInsets padding;

  final DragUpdateDetails details;

  const HorizontalDrawChartDetails({
    required this.startIndex,
    required this.endIndex,
    required this.padding,
    required this.details,
  });

  @override
  String toString() {
    return 'HorizontalDrawChartDetails{startIndex: $startIndex, endIndex: $endIndex, padding: $padding}';
  }
}
