import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

import '../common/pair.dart';
import 'kline_gesture_detector_controller.dart';

/// k线图控制器
class KChartController extends ChangeNotifier {
  KChartController({required this.source}) {
    updateOverlayEntryDataByIndex(-1);
    source.addListener(_sourceListener);
    _crossCurveIndexStream = StreamController<int>.broadcast();
    _initCrossCurveStream();
  }

  final KChartDataSource source;

  /// 手势控制器
  late KlineGestureDetectorController _gestureDetectorController;

  /// 显示十字线
  bool _isShowCrossCurve = false;

  /// 十字线全局坐标
  Offset crossCurveGlobalPosition = const Offset(0, 0);

  /// 十字线流。索引0是主图，其它均是副图。
  late List<StreamController<Pair<double?, double?>>> _crossCurveStreams;

  /// 十字线选中数据索引流。
  late StreamController<int> _crossCurveIndexStream;

  /// 悬浮层数据
  /// 不显示悬浮层是，默认是最后一根
  BaseChartData? overlayEntryData;

  /// 数据悬浮层
  OverlayEntry? overlayEntry;

  bool get isShowCrossCurve => _isShowCrossCurve;

  StreamController<int> get crossCurveIndexStream => _crossCurveIndexStream;

  List<StreamController<Pair<double?, double?>>> get crossCurveStreams =>
      _crossCurveStreams;

  set gestureDetectorController(controller) =>
      _gestureDetectorController = controller;

  /// 初始化十字线流
  void _initCrossCurveStream() {
    _crossCurveStreams = [];
    for (int i = 0; i < source.originCharts.length; ++i) {
      _crossCurveStreams.add(StreamController.broadcast());
    }
  }

  @override
  void dispose() {
    for (var con in crossCurveStreams) {
      con.close();
    }

    _crossCurveIndexStream.close();
    super.dispose();
  }

  /// 显示十字线
  /// [offset] 全局Position
  void showCrossCurve(Offset offset) {
    isShowCrossCurve = true;
    crossCurveGlobalPosition = offset;

    for (var element in crossCurveStreams) {
      element.add(Pair(left: offset.dx, right: offset.dy));
    }

    // compute dataIndex
    double pointGap = _gestureDetectorController.pointGap;
    double pointWidth = _gestureDetectorController.pointWidth;
    GlobalKey chartKey = _gestureDetectorController.chartKey;
    RenderBox renderBox =
        chartKey.currentContext!.findRenderObject() as RenderBox;
    Offset localOffset = renderBox.globalToLocal(offset);
    int dataIndex = localOffset.dx ~/ (pointWidth + pointGap);
    dataIndex = dataIndex < source.showDataNum ? dataIndex : -1;
    _crossCurveIndexStream.add(dataIndex);


    notifyListeners();
  }

  /// 隐藏十字线
  void hideCrossCurve() {
    isShowCrossCurve = false;
    for (var element in crossCurveStreams) {
      element.add(Pair(left: null, right: null));
    }

    hideOverlayEntry();
    _crossCurveIndexStream.add(-1);

    notifyListeners();
  }

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
      KlineUtil.logd('index $index', name: 'updateOverlayEntryDataByIndex');
      if (index == -1 || index >= source.showCharts.length) {
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
