import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

/// 矩形设置
class RectConfig {
  /// 是否显示
  final bool isShow;

  /// 矩形中间的横线
  final int transverseLineNum;

  final Color color;

  final double fontSize;

  const RectConfig({
    this.isShow = true,
    this.transverseLineNum = 2,
    this.color = Colors.grey,
    this.fontSize = KlineConfig.rectFontSize,
  });
}
