import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

/// k线图控制器
class KChartController extends ChangeNotifier {
  KChartController({required this.source}) {
    updateOverlayEntryDataByIndex(-1);
    source.addListener(_sourceListener);
  }

  final KChartDataSource source;

  /// 显示十字线
  bool _isShowCrossCurve = false;

  /// 十字线全局坐标
  Offset crossCurveGlobalPosition = const Offset(0, 0);

  /// 悬浮层数据
  /// 不显示悬浮层是，默认是最后一根
  BaseChartData? overlayEntryData;

  /// 数据悬浮层
  OverlayEntry? overlayEntry;

  bool get isShowCrossCurve => _isShowCrossCurve;

  set isShowCrossCurve(bool showCrossCurve) {
    _isShowCrossCurve = showCrossCurve;
    notifyListeners();
  }

  /// 数据源监听
  void _sourceListener() {
    if (overlayEntryData != null) {
      return;
    }

    updateOverlayEntryDataByIndex(-1);
  }

  /// 隐藏悬浮窗
  void hideOverlayEntry() {
    overlayEntry?.remove();
    overlayEntry = null;

    try {
      updateOverlayEntryDataByIndex(-1);
    } on Exception catch (e) {
      KlineUtil.loge(e.toString());
    }
  }

  /// 根据索引更新悬浮层数据
  /// [index] 等于-1，表示设置当前显示的最后一根数据
  void updateOverlayEntryDataByIndex(int index) {
    try {
      if (index == -1) {
        overlayEntryData = source.showCharts.first.baseCharts.first.data.last;
        return;
      }

      overlayEntryData = source.showCharts.first.baseCharts.first.data[index];
      notifyListeners();
    } on Exception catch (e) {
      KlineUtil.loge(e.toString());
    } on Error catch (e) {
      KlineUtil.loge(e.toString());
    }
  }
}
