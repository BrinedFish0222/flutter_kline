import 'package:flutter/material.dart';

/// k线图控制器
class KChartController extends ChangeNotifier {

  /// 显示十字线
  bool _isShowCrossCurve = false;

  /// 数据悬浮层
  OverlayEntry? overlayEntry;

  bool get isShowCrossCurve => _isShowCrossCurve;

  set isShowCrossCurve(bool showCrossCurve) {
    _isShowCrossCurve = showCrossCurve;
    notifyListeners();
  }

  /// 隐藏悬浮窗
  void hideOverlayEntry() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

}