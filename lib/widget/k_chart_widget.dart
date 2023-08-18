import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/cross_curve_painter.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/k_chart_renderer_config.dart';
import 'package:flutter_kline/vo/selected_chart_data_stream_vo.dart';
import 'package:flutter_kline/widget/sub_chart_widget.dart';

import '../common/pair.dart';
import '../renderer/k_chart_renderer.dart';
import '../utils/kline_util.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

/// k线图手势操作组件
class KChartWidget extends StatefulWidget {
  const KChartWidget(
      {super.key,
      required this.size,
      required this.candlestickChartData,
      this.lineChartData,
      this.showDataNum = 60,
      this.margin,
      this.onTapIndicator});

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;
  final int showDataNum;

  /// 点击股票指标事件
  final void Function(int index)? onTapIndicator;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
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

  /// 最后一根选中的折线数据
  List<SelectedLineChartDataStreamVo>? _lastSelectedLineChartData;

  // 选中的折线数据
  final StreamController<SelectedChartDataStreamVo>
      _selectedLineChartDataStream = StreamController();

  /// 蜡烛数据流
  final StreamController<CandlestickChartVo?> _candlestickChartVoStream =
      StreamController();

  /// 蜡烛选中数据悬浮层
  OverlayEntry? _candlestickOverlayEntry;

  @override
  void initState() {
    _showDataNum = widget.showDataNum;
    _showDataStartIndex =
        (widget.candlestickChartData.length - _showDataNum - 1)
            .clamp(0, widget.candlestickChartData.length - 1);
    _resetShowData();
    _initSelectedLineChartDataIndexStream();

    _selectedLineChartDataIndexStream?.stream.listen((index) {
      if (index == -1) {
        return;
      }
      _candlestickChartVoStream.add(_showCandlestickChartData[index]);
    });

    _candlestickChartVoStream.stream.listen((event) {
      debugPrint("_candlestickChartVoStream listen run ....");
      if (event == null) {
        debugPrint("_candlestickChartVoStream listen run, even is null ....");
        _hideCandlestickOverlay();
        return;
      }

      debugPrint("_candlestickChartVoStream listen run, even is not null ....");
      var overlayLocation = _getCandlestickOverlayLocation();
      _showCandlestickOverlay(
          context: context,
          left: 0,
          top: overlayLocation.right - 50,
          vo: event);
    });

    super.initState();
  }

  @override
  void dispose() {
    _selectedLineChartDataIndexStream?.close();
    _candlestickChartVoStream.close();
    _selectedLineChartDataStream.close();
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
      child: Column(
        children: [
          /// 信息栏
          InkWell(
            onTap: () => _onTapIndicator(0),
            child: Row(children: [
              const Text('MA'),
              const Icon(Icons.arrow_drop_down),
              StreamBuilder<SelectedChartDataStreamVo>(
                  initialData: SelectedChartDataStreamVo(
                      lineChartList: _lastSelectedLineChartData),
                  stream: _selectedLineChartDataStream.stream,
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (KlineCollectionUtil.isEmpty(widget.lineChartData)) {
                      return KlineUtil.noWidget();
                    }

                    _candlestickChartVoStream.add(data?.candlestickChartVo);

                    return Wrap(
                      children: data?.lineChartList
                              ?.where((element) => element.value != null)
                              .map((e) => Text(
                                    '${e.name} ${e.value?.toStringAsFixed(2)}   ',
                                    style: TextStyle(color: e.color),
                                  ))
                              .toList() ??
                          [],
                    );
                  })
            ]),
          ),
          Stack(
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
                      selectedDataIndexStream:
                          _selectedLineChartDataIndexStream,
                      pointWidth: _kChartRendererConfig.pointWidth,
                      pointGap: _kChartRendererConfig.pointGap),
                );
              }),
            ],
          ),
          InkWell(
            onTap: () => _onTapIndicator(1),
            child: Container(
              height: 10,
              color: Colors.yellow,
            ),
          ),
          SubChartWidget(
            size: widget.size,
            chartData: _showLineChartData ?? [],
          ),
        ],
      ),
    );
  }

  /// 获取蜡烛浮层地址
  Pair<double, double> _getCandlestickOverlayLocation() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 获取组件在页面中的位置信息
      Offset offset = renderBox.localToGlobal(Offset.zero);
      double x = offset.dx; // X坐标
      double y = offset.dy; // Y坐标
      return Pair(left: x, right: y);
    }
    return Pair(left: 0, right: 0);
  }

  void _showCandlestickOverlay(
      {required BuildContext context,
      required double left,
      required double top,
      required CandlestickChartVo vo}) {
    if (_candlestickOverlayEntry != null) {
      _candlestickOverlayEntry?.remove();
    }

    // 创建OverlayEntry并将其添加到Overlay中
    _candlestickOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Colors.grey,
            child: Center(
              child: Text(
                'open ${vo.open.toStringAsFixed(2)}, close ${vo.close.toStringAsFixed(2)}, high ${vo.high.toStringAsFixed(2)}, low ${vo.low.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_candlestickOverlayEntry!);
  }

  void _hideCandlestickOverlay() {
    _candlestickOverlayEntry?.remove();
    _candlestickOverlayEntry = null;
    debugPrint("hide overlay execute ... ");
  }

  /// 点击指标事件
  void _onTapIndicator(int index) {
    if (widget.onTapIndicator == null) {
      return;
    }

    widget.onTapIndicator!(index);
  }

  _initSelectedLineChartDataIndexStream() {
    if (KlineCollectionUtil.isEmpty(_showLineChartData)) {
      return;
    }

    _selectedLineChartDataIndexStream = StreamController<int>.broadcast();
    _selectedLineChartDataIndexStream!.stream
        .listen(_selectedLineChartDataIndexStreamListen);
  }

  _selectedLineChartDataIndexStreamListen(int index) {
    if (KlineCollectionUtil.isEmpty(_showLineChartData)) {
      return;
    }

    if (index <= -1) {
      _selectedLineChartDataStream.add(SelectedChartDataStreamVo());
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
    _selectedLineChartDataStream.add(vo);
  }

  /// 重置显示的数据。
  /// 自动适配
  _resetShowData({int? startIndex}) {
    if (startIndex == null) {
      _showDataStartIndex =
          (widget.candlestickChartData.length - _showDataNum - 1)
              .clamp(0, widget.candlestickChartData.length - 1);
    } else {
      _showDataStartIndex = startIndex;
    }

    int endIndex = (_showDataStartIndex + _showDataNum)
        .clamp(0, widget.candlestickChartData.length - 1);

    _showDataStartIndex =
        (endIndex - _showDataNum).clamp(0, widget.candlestickChartData.length);

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
