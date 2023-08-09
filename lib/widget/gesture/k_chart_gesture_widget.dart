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

  @override
  void initState() {
    _showDataNum = widget.showDataNum;
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
      onHorizontalDragStart: (details) => _isOnHorizontalDragStart = true,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: (details) => _isOnHorizontalDragStart = false,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: Stack(
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: widget.size,
              painter: KChartRenderer(
                  candlestickCharData: widget.candlestickChartData,
                  lineChartData: widget.lineChartData,
                  margin: widget.margin,
                  config: _kChartRendererConfig),
            ),
          ),
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

  _resetShowData() {
    _showCandlestickChartData =
        KlineCollectionUtil.lastN(widget.candlestickChartData, _showDataNum)!;
    if (KlineCollectionUtil.isNotEmpty(widget.lineChartData)) {
      _showLineChartData =
          KlineCollectionUtil.lastN(widget.lineChartData, _showDataNum);
    }
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
    debugPrint("_onHorizontalDragUpdate execute");
    if (_isShowCrossCurve) {
      _selectedXY =
          Pair(left: details.localPosition.dx, right: details.localPosition.dy);
      _crossCurvePainterState(() {});
    }
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
