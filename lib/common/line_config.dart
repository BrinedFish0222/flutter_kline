
import 'package:flutter/material.dart';

import 'constants/line_type.dart';

/// 线配置
class LineConfig {
  LineType type;
  Color color;

  /// 虚线长度
  double dottedLineLength;

  /// 虚线间隔
  double dottedLineSpace;

  LineConfig(
      {this.type = LineType.full,
        this.color = Colors.black,
        this.dottedLineLength = 2,
        this.dottedLineSpace = 2});
}