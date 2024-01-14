import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/constants/chart_location.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_data.dart';
import 'package:flutter_kline/vo/horizontal_draw_chart_details.dart';
import 'package:flutter_kline/widget/candlestick_show_data_widget.dart';
import 'package:flutter_kline/widget/k_chart_controller.dart';
import 'package:flutter_kline/widget/sub_chart_widget.dart';

import '../common/k_chart_data_source.dart';
import '../common/pair.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/mask_layer.dart';
import '../vo/pointer_info.dart';
import 'kline_gesture_detector.dart';
import 'main_chart_widget.dart';

/// k线图手势操作组件
class KChartWidget extends StatefulWidget {
  const KChartWidget({
    super.key,
    this.controller,
    required this.source,
    this.subChartMaskList,
    this.showDataNum = KlineConfig.showDataDefaultLength,
    required this.onTapIndicator,
    this.dataGapRatio = 3,
    this.subChartRatio = 0.5,
    required this.overlayEntryLocationKey,
    this.overlayEntryBuilder,
    this.realTimePrice,
    this.onHorizontalDragUpdate,
    this.chartNum,
  }) : assert(chartNum == null || chartNum > 0, "chartNum is null or gt 1");

  final KChartController? controller;

  final KChartDataSource source;

  /// 限制图数量，不设置表示等于 [source.originCharts.length]
  /// 值等于空或大于0
  final int? chartNum;

  /// 副图遮罩
  final List<MaskLayer?>? subChartMaskList;

  /// 显示数据数量
  /// 默认范围：[KlineConfig.showDataMinLength], [KlineConfig.showDataMaxLength]
  final int showDataNum;

  /// 数据宽度和空间间隔比
  final double dataGapRatio;

  /// 副图对于主图的比例
  final double subChartRatio;

  /// 点击股票指标事件
  final void Function(int index) onTapIndicator;

  /// 悬浮层位置Key
  final GlobalKey? overlayEntryLocationKey;

  /// 悬浮层自定义组件
  final Widget Function(CandlestickChartData)? overlayEntryBuilder;

  /// TODO 不指定，默认取最后一根数据，但是最后一根数据会有多份，需要考虑怎么处理，或许可以考虑在数据VO中设置启动实时价格的开关
  /// 实时价格
  final double? realTimePrice;

  /// 不推荐使用，推荐使用 [source.leftmost()]、[source.rightmost()]、[source.centre()]
  /// 图滑动时触发，提供图位置（最左、中、最右）
  final void Function(DragUpdateDetails, ChartLocation)? onHorizontalDragUpdate;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
  late KChartController _controller;

  /// 主图size
  late Size _mainChartSize;

  /// 副图size
  late Size _subChartSize;

  /// 十字线流。索引0是主图，其它均是副图。
  late List<StreamController<Pair<double?, double?>>> _crossCurveStreamList;

  /// 十字线选中数据索引流。
  StreamController<int>? _selectedIndexStream;

  /// 十字线是否显示
  // bool _isShowCrossCurve = false;
  bool _isOnHorizontalDragStart = true;

  /// [widget.showDataNum]
  /// 默认范围：[KlineConfig.showDataMinLength], [KlineConfig.showDataMaxLength]
  late int _showDataNum;

  /// 同一时间上一个拖动的x轴坐标
  late double _sameTimeLastHorizontalDragX;

  /// 蜡烛选中数据悬浮层
  // OverlayEntry? _candlestickOverlayEntry;

  /// 副图遮罩
  List<MaskLayer?> _subChartMaskList = [];

  EdgeInsets _chartPadding = EdgeInsets.zero;

  /// 副图显示数量
  get _subChartShowLength => widget.chartNum == null
      ? _subChartData.length
      : (widget.chartNum! - 1).clamp(0, _subChartData.length);

  @override
  void initState() {
    _controller = widget.controller ?? KChartController(source: widget.source);
    _initCrossCurveStream();
    _updateShowDataNum(widget.showDataNum);
    _showDataStartIndex = (widget.source.dataMaxIndex - _showDataNum)
        .clamp(0, widget.source.dataMaxIndex);
    widget.source.resetShowData(startIndex: _showDataStartIndex);
    _initSelectedIndexStream();

    super.initState();
  }

  /// 初始化十字线 StreamController
  void _initCrossCurveStream() {
    _crossCurveStreamList = [];
    _crossCurveStreamList.add(StreamController.broadcast());
    for (int i = 0; i < _subChartData.length; ++i) {
      _crossCurveStreamList.add(StreamController.broadcast());
    }
  }

  @override
  void dispose() {
    _hideCandlestickOverlay();
    _selectedIndexStream?.close();
    for (var con in _crossCurveStreamList) {
      con.close();
    }

    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _computeLayout(constraints);
      KlineGestureDetectorController gestureDetectorController =
          KlineGestureDetectorController(
              screenMaxWidth: _mainChartSize.width, source: widget.source);
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return GestureDetector(
              onLongPressStart: _globalOnLongPressStart,
              onLongPressMoveUpdate: _globalOnLongPressMoveUpdate,
              onHorizontalDragUpdate:
                  _isShowCrossCurve ? _globalOnHorizontalDragUpdate : null,
              onVerticalDragUpdate:
                  _isShowCrossCurve ? _globalOnHorizontalDragUpdate : null,

              /// TODO 原使用 ListenableBuilder，改成 AnimatedBuilder 是为了兼容旧版本sdk 3.7.7
              child: AnimatedBuilder(
                  animation: widget.source,
                  builder: (context, _) {
                    KlineUtil.logd(
                        "KChartWidget ValueListenableBuilder run ...");

                    /// 副图显示的数据
                    List<ChartData> subChartsShow = widget.source.subChartsShow;
                    int subChartsShowLength = _subChartShowLength;

                    widget.source
                        .resetShowData(startIndex: _showDataStartIndex);
                    return Column(
                      children: [
                        /// 主图
                        KlineGestureDetector(
                          controller: gestureDetectorController,
                          isShowCrossCurve: _isShowCrossCurve,
                          onTap: _onTap,
                          totalDataNum: widget.source.dataMaxLength,
                          onHorizontalDragStart: _onHorizontalDragStart,
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: (details) =>
                              _isOnHorizontalDragStart = false,
                          onHorizontalDrawChart: _onHorizontalDrawChart,
                          onZoomIn: ({DragUpdateDetails? details}) {
                            // TODO 临时屏蔽放大缩小
                            return;

                            // 如果十字线显示的状态，则拖动操作是移动十字线。
                            if (_isShowCrossCurve && details != null) {
                              _resetCrossCurve(Pair(
                                  left: details.globalPosition.dx,
                                  right: details.globalPosition.dy));
                              return;
                            }

                            int endIndex = (_showDataStartIndex + _showDataNum)
                                .clamp(0, widget.source.dataMaxIndex);
                            _onZoom(endIndex: endIndex, zoomIn: true);
                          },
                          onZoomOut: ({DragUpdateDetails? details}) {
                            // TODO 临时屏蔽放大缩小
                            return;

                            // 如果十字线显示的状态，则拖动操作是移动十字线。
                            if (_isShowCrossCurve && details != null) {
                              _resetCrossCurve(Pair(
                                  left: details.globalPosition.dx,
                                  right: details.globalPosition.dy));
                              return;
                            }

                            int endIndex = (_showDataStartIndex + _showDataNum)
                                .clamp(0, widget.source.dataMaxIndex);
                            _onZoom(endIndex: endIndex, zoomIn: false);
                          },
                          child: MainChartWidget(
                            chartData: _showMainChartData,
                            size: _mainChartSize,
                            infoBarName:
                                widget.source.mainChartShow?.name ?? '无指标',
                            padding: _chartPadding,
                            pointWidth: gestureDetectorController.pointWidth,
                            pointGap: gestureDetectorController.pointGap,
                            crossCurveStream: _getCrossCurveStreamByIndex(0),
                            selectedChartDataIndexStream: _selectedIndexStream,
                            onTapIndicator: () {
                              widget.onTapIndicator(0);
                            },
                            realTimePrice: widget.realTimePrice,
                          ),
                        ),

                        /// 副图
                        for (int i = 0; i < subChartsShowLength; ++i)
                          GestureDetector(
                            onTapDown: (details) => _cancelCrossCurve(),
                            child: SizedBox.fromSize(
                              size: _subChartSize,
                              child: SubChartWidget(
                                size: _subChartSize,
                                name: subChartsShow[i].name,
                                chartData: subChartsShow[i].baseCharts,
                                pointWidth: gestureDetectorController.pointWidth,
                                pointGap: gestureDetectorController.pointGap,
                                padding: _chartPadding,
                                maskLayer: _getSubChartMaskByIndex(i),
                                crossCurveStream:
                                    _getCrossCurveStreamByIndex(i + 1),
                                selectedChartDataIndexStream:
                                    _selectedIndexStream,
                                onTapIndicator: () {
                                  widget.onTapIndicator(i + 1);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
            );
          });
    });
  }

  @override
  void didUpdateWidget(covariant KChartWidget oldWidget) {
    KlineUtil.logd('k_chart_widget didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  bool get _isShowCrossCurve => _controller.isShowCrossCurve;

  /// 根据索引获取十字线流
  StreamController<Pair<double?, double?>> _getCrossCurveStreamByIndex(
      int index) {
    bool hasStream = _crossCurveStreamList.hasIndex(index);
    if (hasStream) {
      return _crossCurveStreamList[index];
    }

    StreamController<Pair<double?, double?>> streamController =
        StreamController.broadcast();
    _crossCurveStreamList.add(streamController);

    return streamController;
  }

  MaskLayer? _getSubChartMaskByIndex(int index) {
    bool hasMaskLayer = widget.subChartMaskList?.hasIndex(index) ?? false;
    return hasMaskLayer ? widget.subChartMaskList![index] : null;
  }

  /// 更新显示的数据数量
  /// 同步：[_horizontalDragThreshold] 横向拖动阈值
  void _updateShowDataNum(int showDataNum) {
    _showDataNum = showDataNum;
  }

  void _onTap(PointerInfo pointerInfo) {
    KlineUtil.logd("k_chart_widget _onTap");
    // 取消选中的十字线
    if (_cancelCrossCurve()) {
      setState(() {});
      return;
    }

    _resetCrossCurve(Pair(
        left: pointerInfo.globalPosition.dx,
        right: pointerInfo.globalPosition.dy));
    setState(() {});
  }

  void _onHorizontalDragStart(details) {
    KlineUtil.logd("GestureDetector onHorizontalDragStart");
    _sameTimeLastHorizontalDragX = details.localPosition.dx;
    _isOnHorizontalDragStart = true;
  }

  /// 重算布局
  void _computeLayout(BoxConstraints constraints) {
    Size defaultSize = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height * 0.6);

    double width = constraints.maxWidth != double.infinity
        ? constraints.maxWidth - 1
        : defaultSize.width - 1;
    double height = constraints.maxHeight != double.infinity
        ? constraints.maxHeight
        : defaultSize.height;

    Pair<double, double> heightPair = KlineUtil.autoAllotChartHeight(
        totalHeight: height,
        subChartRatio: widget.subChartRatio,
        subChartNum: _subChartShowLength);
    _mainChartSize = Size(width, heightPair.left);
    _subChartSize = Size(width, heightPair.right);
  }

  /// 获取蜡烛浮层地址
  Pair<double, double>? _getCandlestickOverlayLocation() {
    if (widget.overlayEntryLocationKey == null) {
      // 没有key，不显示
      return null;
    }

    RenderBox? renderBox = widget.overlayEntryLocationKey!.currentContext
        ?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 获取组件在页面中的位置信息
      Offset offset = renderBox.localToGlobal(Offset.zero);
      double x = offset.dx; // X坐标
      double y = offset.dy; // Y坐标
      return Pair(left: x, right: y);
    }
    return Pair(left: 0, right: 0);
  }

  OverlayEntry? get _candlestickOverlayEntry => _controller.overlayEntry;

  set _candlestickOverlayEntry(OverlayEntry? overlayEntry) =>
      _controller.overlayEntry = overlayEntry;

  void _showCandlestickOverlay({
    required BuildContext context,
    required double left,
    required double top,
    required CandlestickChartData vo,
  }) {
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
          child: CandlestickShowDataWidget(
              vo: vo, builder: widget.overlayEntryBuilder),
        ),
      ),
    );

    Overlay.of(context).insert(_candlestickOverlayEntry!);
  }

  void _hideCandlestickOverlay() {
    _controller.hideOverlayEntry();
  }

  _initSelectedIndexStream() {
    /*if (_showMainChartData.isEmpty) {
      return;
    }*/

    _selectedIndexStream = StreamController<int>.broadcast();
    // 处理悬浮层。
    _selectedIndexStream?.stream.listen((index) {
      KlineUtil.logd('触发悬浮层监听');
      if (index == -1) {
        _hideCandlestickOverlay();
        return;
      }
      var candlestickChartVo =
          BaseChartVo.getCandlestickChartVo(_showMainChartData);

      var vo = candlestickChartVo?.data[index];
      if (vo == null) {
        _hideCandlestickOverlay();
        return;
      }

      _controller.updateOverlayEntryDataByIndex(index);

      Pair<double, double>? overlayLocation = _getCandlestickOverlayLocation();
      if (overlayLocation == null) {
        return;
      }
      _showCandlestickOverlay(
        context: context,
        left: 0,
        top: overlayLocation.right,
        vo: vo,
      );
    });
  }

  /// 放大缩小
  /// [endIndex] 结束索引位置
  /// [zoomIn] 是否放大
  _onZoom({required int endIndex, required bool zoomIn}) {
    if (_showDataNum == KlineConfig.showDataMinLength && zoomIn) {
      return;
    }

    if (_showDataNum == KlineConfig.showDataMaxLength && !zoomIn) {
      return;
    }

    int addVal = zoomIn ? -1 : 1;
    _updateShowDataNum((_showDataNum + addVal)
        .clamp(KlineConfig.showDataMinLength, KlineConfig.showDataMaxLength));
    int startIndex =
        (endIndex - _showDataNum).clamp(0, widget.source.dataMaxIndex);
    KlineUtil.logd("最后的数据索引： _onZoom to _resetShowData");
    widget.source.showDataNum = _showDataNum;
    widget.source.resetShowData(startIndex: startIndex);
    widget.source.notifyListeners();
  }

  List<List<BaseChartVo>> get _subChartData => widget.source.subChartBaseCharts;

  List<BaseChartVo<BaseChartData>> get _showMainChartData =>
      widget.source.mainChartBaseChartsShow;

  /// 显示数据的开始索引值。
  int get _showDataStartIndex => widget.source.showDataStartIndex;

  set _showDataStartIndex(int index) =>
      widget.source.showDataStartIndex = index;

  _globalOnLongPressStart(LongPressStartDetails details) {
    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  /// 长按移动事件
  _globalOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    KlineUtil.logd(
        "_onLongPressMoveUpdate, dx: ${details.localPosition.dx}, dy ${details.localPosition.dy}");

    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  void _onHorizontalDrawChart(
      HorizontalDrawChartDetails horizontalDrawChartDetails) {
    KlineUtil.logd("k线图横向滑动");
    var details = horizontalDrawChartDetails.details;
    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_isShowCrossCurve) {
      _resetCrossCurve(Pair(
          left: details.globalPosition.dx, right: details.globalPosition.dy));
      return;
    }

    // 滑动更新数据。
    var dx = details.localPosition.dx;
    widget.source
        .resetShowData(startIndex: horizontalDrawChartDetails.startIndex);
    _chartPadding = horizontalDrawChartDetails.padding;

    // 图位置
    _chartLocation(details);

    _sameTimeLastHorizontalDragX = dx;
    _controller.updateOverlayEntryDataByIndex(-1);
    widget.source.notifyListeners();
  }

  /// 拖动事件
  _onHorizontalDragUpdate(DragUpdateDetails details) {
    return;

    KlineUtil.logd("k线图横向滑动");
    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_isShowCrossCurve) {
      _resetCrossCurve(Pair(
          left: details.globalPosition.dx, right: details.globalPosition.dy));
      return;
    }

    // 滑动更新数据。
    var dx = details.localPosition.dx;
    if (_sameTimeLastHorizontalDragX > dx) {
      widget.source.resetShowData(startIndex: _showDataStartIndex + 1);
    } else {
      widget.source.resetShowData(startIndex: _showDataStartIndex - 1);
    }

    // 图位置
    _chartLocation(details);

    _sameTimeLastHorizontalDragX = dx;
    _controller.updateOverlayEntryDataByIndex(-1);
    widget.source.notifyListeners();
  }

  /// 取消十字线
  bool _cancelCrossCurve() {
    if (!(_isShowCrossCurve ||
        (_isShowCrossCurve && !_isOnHorizontalDragStart))) {
      return false;
    }

    _resetCrossCurve(null);
    _hideCandlestickOverlay();

    KlineUtil.logd('取消十字线，传输-1');
    _selectedIndexStream?.add(-1);
    return true;
  }

  /// 重置十字线位置
  void _resetCrossCurve(Pair<double?, double?>? crossCurveXY) {
    _controller.isShowCrossCurve = crossCurveXY != null;

    for (var element in _crossCurveStreamList) {
      element.add(crossCurveXY ?? Pair(left: null, right: null));
    }
  }

  /// 图位置
  void _chartLocation(DragUpdateDetails details) {
    widget.source.updateChartLocation(details);
    if (widget.onHorizontalDragUpdate == null) {
      return;
    }

    widget.onHorizontalDragUpdate!(details, widget.source.chartLocation);
  }

  void _globalOnHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isShowCrossCurve) {
      return;
    }

    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }
}
