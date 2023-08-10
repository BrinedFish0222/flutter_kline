import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/cross_curve_painter.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/k_chart_renderer_config.dart';
import 'package:flutter_kline/vo/selected_chart_data_stream_vo.dart';

import '../../common/pair.dart';
import '../../renderer/k_chart_renderer.dart';
import '../../vo/candlestick_chart_vo.dart';
import '../../vo/line_chart_vo.dart';

/// k线图手势操作组件
class KChartGestureWidget extends StatefulWidget {
  const KChartGestureWidget(
      {super.key,
      required this.size,
      required this.candlestickChartData,
      this.lineChartData,
      this.showDataNum = 60,
      this.selectedLineChartDataStream,
      this.margin});

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;
  final int showDataNum;

  /// 选中的折线数据流
  final StreamController<SelectedChartDataStreamVo>?
      selectedLineChartDataStream;

  @override
  State<KChartGestureWidget> createState() => _KChartGestureWidgetState();
}

class _KChartGestureWidgetState extends State<KChartGestureWidget> {
  Pair<double?, double?>? _selectedXY;

  /// k线图配置
  final KChartRendererConfig _kChartRendererConfig = KChartRendererConfig();

  /// 十字线刷新句柄
  late void Function(void Function()) _crossCurvePainterState;

  /// 十字线选中数据索引流。
  StreamController<int>? _selectedLineChartDataIndexStream;

  bool _isShowCrossCurve = false;
  bool _isOnHorizontalDragStart = true;

  /// [widget.showDataNum]
  late int _showDataNum;

  /// 显示的蜡烛数据
  List<CandlestickChartVo?> _showCandlestickChartData = [];

  /// 显示的折线数据
  List<LineChartVo?>? _showLineChartData;

  /// 显示数据的开始索引值。
  late int _showDataStartIndex;

  /// 同一时间上一个拖动的x轴坐标
  late double _sameTimeLastHorizontalDragX;

  @override
  void initState() {
    _showDataNum = widget.showDataNum;
    _showDataStartIndex =
        (widget.candlestickChartData.length - widget.showDataNum - 1)
            .clamp(0, widget.candlestickChartData.length - 1);
    _resetShowData();
    _initSelectedLineChartDataIndexStream();

    super.initState();
  }

  @override
  void dispose() {
    _selectedLineChartDataIndexStream?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onHorizontalDragStart: (details) {
        debugPrint("GestureDetector onHorizontalDragStart");
        _sameTimeLastHorizontalDragX = details.localPosition.dx;
        _isOnHorizontalDragStart = true;
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: (details) => _isOnHorizontalDragStart = false,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: Stack(
        children: [
          /// K线图
          RepaintBoundary(
            child: CustomPaint(
              size: widget.size,
              painter: KChartRenderer(
                  candlestickCharData: _showCandlestickChartData,
                  lineChartData: _showLineChartData,
                  margin: widget.margin,
                  config: _kChartRendererConfig),
            ),
          ),

          /// 十字线
          StatefulBuilder(builder: (context, state) {
            _crossCurvePainterState = state;
            return CustomPaint(
              size: widget.size,
              painter: CrossCurvePainter(
                  selectedXY: _selectedXY,
                  margin: widget.margin,
                  selectedDataIndexStream: _selectedLineChartDataIndexStream,
                  pointWidth: _kChartRendererConfig.pointWidth,
                  pointGap: _kChartRendererConfig.pointGap),
            );
          }),
        ],
      ),
    );
  }

  _initSelectedLineChartDataIndexStream() {
    if (widget.selectedLineChartDataStream == null ||
        KlineCollectionUtil.isEmpty(_showLineChartData)) {
      return;
    }

    _selectedLineChartDataIndexStream = StreamController();
    _selectedLineChartDataIndexStream!.stream
        .listen(_selectedLineChartDataIndexStreamListen);
  }

  _selectedLineChartDataIndexStreamListen(int index) {
    if (widget.selectedLineChartDataStream == null ||
        KlineCollectionUtil.isEmpty(_showLineChartData)) {
      return;
    }

    if (index <= -1) {
      widget.selectedLineChartDataStream!.add(SelectedChartDataStreamVo());
      return;
    }

    SelectedChartDataStreamVo vo = SelectedChartDataStreamVo(lineChartList: []);
    vo.candlestickChartVo =
        KlineCollectionUtil.getByIndex(_showCandlestickChartData, index);
    for (var lineData in _showLineChartData!) {
      if (lineData == null) {
        continue;
      }

      LineChartData? indexData =
          KlineCollectionUtil.getByIndex(lineData.dataList, index);
      if (indexData == null) {
        continue;
      }
      vo.lineChartList!.add(SelectedLineChartDataStreamVo(
          color: lineData.color, name: lineData.name, value: indexData.value));
    }
    widget.selectedLineChartDataStream!.add(vo);
  }

  /// 重置显示的数据。
  /// 自动适配
  _resetShowData({int? startIndex}) {
    if (startIndex == null) {
      _showDataStartIndex =
          (widget.candlestickChartData.length - widget.showDataNum - 1)
              .clamp(0, widget.candlestickChartData.length - 1);
    } else {
      _showDataStartIndex = startIndex;
    }

    int endIndex = (_showDataStartIndex + widget.showDataNum)
        .clamp(0, widget.candlestickChartData.length - 1);

    _showDataStartIndex = (endIndex - widget.showDataNum)
        .clamp(0, widget.candlestickChartData.length);

    _showCandlestickChartData = KlineCollectionUtil.sublist(
            list: widget.candlestickChartData,
            startIndex: _showDataStartIndex,
            endIndex: endIndex) ??
        [];

    if (KlineCollectionUtil.isNotEmpty(widget.lineChartData)) {
      _showLineChartData = [];
      for (LineChartVo? element in widget.lineChartData!) {
        if (element == null) {
          _showLineChartData!.add(element);
          continue;
        }

        var newVo = element.copy();
        newVo.dataList =
            element.dataList?.sublist(_showDataStartIndex, endIndex);
        _showLineChartData?.add(newVo);
      }
    }

    setState(() {});
  }

  /// 长按移动事件
  _onLongPressMoveUpdate(details) {
    _selectedXY =
        Pair(left: details.localPosition.dx, right: details.localPosition.dy);
    _isShowCrossCurve = true;
    _crossCurvePainterState(() {});
  }

  /// 拖动事件
  _onHorizontalDragUpdate(DragUpdateDetails details) {
    debugPrint(
        "_onHorizontalDragUpdate execute, _isShowCrossCurve: $_isShowCrossCurve, dx: ${details.localPosition.dx}, dy: ${details.localPosition.dy}");

    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_isShowCrossCurve) {
      _selectedXY =
          Pair(left: details.localPosition.dx, right: details.localPosition.dy);
      _crossCurvePainterState(() {});

      return;
    }

    // 滑动更新数据。
    var dx = details.localPosition.dx;
    if (_sameTimeLastHorizontalDragX > dx) {
      _resetShowData(startIndex: _showDataStartIndex + 1);
    } else {
      _resetShowData(startIndex: _showDataStartIndex - 1);
    }

    _sameTimeLastHorizontalDragX = dx;
  }

  _onTapDown(TapDownDetails detail) {
    debugPrint(
        "点击x：${detail.localPosition.dx}, 点击y：${detail.localPosition.dy}");

    if (_selectedXY != null) {
      _selectedXY = null;
      // 恢复默认最后一根k线的数据
      if (KlineCollectionUtil.isNotEmpty(_showLineChartData)) {
        _selectedLineChartDataIndexStreamListen(_showLineChartData!.length - 1);
      }

      _isShowCrossCurve = _isOnHorizontalDragStart ? _isShowCrossCurve : false;
      _crossCurvePainterState(() {});
      return;
    }

    _selectedXY =
        Pair(left: detail.localPosition.dx, right: detail.localPosition.dy);
    _isShowCrossCurve = true;

    _crossCurvePainterState(() {});
  }
}
