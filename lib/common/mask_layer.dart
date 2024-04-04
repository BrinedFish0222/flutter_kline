import 'package:flutter/material.dart';

/// 遮罩
class MaskLayer {
  /// 遮罩百分比。取值范围 0~1
  double percent;

  /// 显示的组件，不设置则使用默认
  Widget? widget;

  /// 遮罩点击事件
  GestureTapCallback? onTap;

  MaskLayer({this.percent = 0.3, this.widget, this.onTap}) {
    // 处理数值不合规的情况。
    percent = percent < 0 ? 0 : percent;
    percent = percent > 1 ? 1 : percent;
  }
}
