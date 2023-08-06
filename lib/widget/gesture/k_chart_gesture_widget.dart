import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/cross_curve_painter.dart';
import 'package:flutter_kline/vo/k_chart_renderer_config.dart';

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
      this.selectedDataIndexStream,
      this.margin});

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;
  final StreamController<int>? selectedDataIndexStream;

  @override
  State<KChartGestureWidget> createState() => _KChartGestureWidgetState();
}

class _KChartGestureWidgetState extends State<KChartGestureWidget> {
  Pair<double?, double?>? _selectedXY;

  /// k线图配置
  final KChartRendererConfig _kChartRendererConfig = KChartRendererConfig();

  /// 十字线刷新句柄
  late void Function(void Function()) _crossCurvePainterState;

  bool _isShowCrossCurve = false;
  bool _isOnHorizontalDragStart = true;

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
                  selectedDataIndexStream: widget.selectedDataIndexStream,
                  pointWidth: _kChartRendererConfig.pointWidth,
                  pointGap: _kChartRendererConfig.pointGap),
            );
          }),
        ],
      ),
    );
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
      widget.selectedDataIndexStream
          ?.add((widget.candlestickChartData.length - 1));
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
