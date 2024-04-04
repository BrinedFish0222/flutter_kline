import 'package:flutter/material.dart';

/// 指示器信息
class PointerInfo {
  int pointer;
  Offset localPosition;
  Offset globalPosition;
  Offset delta;

  /// 是否在顶部
  bool isTop;

  PointerInfo({
    required this.pointer,
    required this.localPosition,
    required this.globalPosition,
    required this.delta,
    this.isTop = true,
  });

  static PointerInfo parse(PointerDownEvent event) {
    return PointerInfo(
        pointer: event.pointer,
        localPosition: event.localPosition,
        globalPosition: event.position,
        delta: event.delta);
  }

  PointerInfo copy() {
    return PointerInfo(
      pointer: pointer,
      localPosition: Offset(localPosition.dx, localPosition.dy),
      globalPosition: Offset(globalPosition.dx, globalPosition.dy),
      delta: Offset(delta.dx, delta.dy),
    );
  }

  @override
  String toString() {
    return "{pointer: $pointer, localPosition: $localPosition}";
  }
}
