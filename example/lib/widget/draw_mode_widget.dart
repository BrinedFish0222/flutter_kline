import 'package:flutter/material.dart';

/// 画线模式组件
class DrawModeWidget extends StatelessWidget {
  const DrawModeWidget({
    super.key,
    required this.drawMode,
    required this.onPressed,
  });

  /// 是否处于画线模式
  final bool drawMode;

  /// 按钮事件
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final String textContent = drawMode ? "画线中" : "画线";
    return ElevatedButton(onPressed: onPressed, child: Text(textContent));
  }
}
