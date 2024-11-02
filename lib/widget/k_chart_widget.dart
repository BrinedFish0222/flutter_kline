import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/utils/kline_collection_util.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';
import 'package:flutter_kline/widget/candlestick_show_data_widget.dart';
import 'package:flutter_kline/widget/k_chart_controller.dart';
import 'package:flutter_kline/widget/sub_chart_widget.dart';

import '../chart/base_chart.dart';
import '../chart/candlestick_chart.dart';
import '../common/chart_data.dart';
import '../common/constants/chart_location.dart';
import '../common/k_chart_data_source.dart';
import '../common/mask_layer.dart';
import '../common/pair.dart';
import '../common/utils/kline_util.dart';
import 'kline_gesture_detector.dart';
import 'kline_gesture_detector_controller.dart';
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
    this.drawChartType = "",
    required this.drawChartCallback,
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

  /// 画图类型
  final String drawChartType;

  /// 画图回调
  final ValueChanged<DrawChartCallback> drawChartCallback;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
  final GlobalKey _chartKey = GlobalKey();

  late KChartController _controller;

  /// 主图size
  late Size _mainChartSize;

  /// 副图size
  late Size _subChartSize;

  /// [widget.showDataNum]
  /// 默认范围：[KlineConfig.showDataMinLength], [KlineConfig.showDataMaxLength]
  late int _showDataNum;

  KlineGestureDetectorController? _gestureDetectorController;

  StreamController<int> get _selectedIndexStream =>
      _controller.crossCurveIndexStream;

  List<StreamController<Pair<double?, double?>>> get _crossCurveStreamList =>
      _controller.crossCurveStreams;

  KlineGestureDetectorController get gestureDetectorController =>
      _gestureDetectorController!;

  /// 副图显示数量
  get _subChartShowLength => widget.chartNum == null
      ? _subChartData.length
      : (widget.chartNum! - 1).clamp(0, _subChartData.length);

  @override
  void initState() {
    _controller = widget.controller ?? KChartController(source: widget.source);
    _updateShowDataNum(widget.showDataNum);
    _showDataStartIndex = (widget.source.dataMaxIndex - _showDataNum)
        .clamp(0, widget.source.dataMaxIndex);
    widget.source.resetShowData(start: _showDataStartIndex);
    _initSelectedIndexStream();

    super.initState();
  }

  @override
  void dispose() {
    _hideCandlestickOverlay();

    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _computeLayout(constraints);

      _gestureDetectorController ??= KlineGestureDetectorController(
        chartKey: _chartKey,
        screenMaxWidth: _mainChartSize.width,
        source: widget.source,
      );
      _controller.gestureDetectorController = _gestureDetectorController;

      return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return ListenableBuilder(
                listenable: widget.source,
                builder: (context, _) {
                  /// 副图显示的数据
                  List<ChartData> subChartsShow = widget.source.subChartsShow;
                  int subChartsShowLength = _subChartShowLength;

                  widget.source.resetShowData(start: _showDataStartIndex);

                  Widget mainChart = MainChartWidget(
                    key: _chartKey,
                    chartData: _showMainChartData,
                    size: _mainChartSize,
                    infoBarName: widget.source.mainChartShow?.name ?? '无指标',
                    padding: gestureDetectorController.padding,
                    pointWidth: gestureDetectorController.pointWidth,
                    pointGap: gestureDetectorController.pointGap,
                    crossCurveStream: _getCrossCurveStreamByIndex(0),
                    selectedChartDataIndexStream: _selectedIndexStream,
                    drawChartType: widget.drawChartType,
                    onTapIndicator: () {
                      widget.onTapIndicator(0);
                    },
                    realTimePrice: widget.realTimePrice,
                    drawChartCallback: widget.drawChartCallback,
                  );
                  if (widget.drawChartType.isEmpty) {
                    mainChart = KlineGestureDetector(
                      controller: gestureDetectorController,
                      kChartController: _controller,
                      totalDataNum: widget.source.dataMaxLength,
                      child: mainChart,
                    );
                  }

                  return Column(
                    children: [
                      /// 主图
                      mainChart,

                      /// 副图
                      for (int i = 0; i < subChartsShowLength; ++i)
                        GestureDetector(
                          onTapDown: (details) => _controller.hideCrossCurve(),
                          child: SizedBox.fromSize(
                            size: _subChartSize,
                            child: SubChartWidget(
                              size: _subChartSize,
                              name: subChartsShow[i].name,
                              chartData: subChartsShow[i].baseCharts,
                              pointWidth: gestureDetectorController.pointWidth,
                              pointGap: gestureDetectorController.pointGap,
                              padding: gestureDetectorController.padding,
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
                });
          });
    });
  }

  @override
  void didUpdateWidget(covariant KChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }


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
    // 处理悬浮层。
    _selectedIndexStream.stream.listen((index) {
      _controller.updateOverlayEntryDataByIndex(index);
      if (index == -1) {
        _hideCandlestickOverlay();
        return;
      }

      var candlestickChartVo =
          BaseChart.getCandlestickChartVo(_showMainChartData);

      var vo = candlestickChartVo?.data[index];
      if (vo == null) {
        _hideCandlestickOverlay();
        return;
      }

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

  List<List<BaseChart>> get _subChartData => widget.source.subChartBaseCharts;

  List<BaseChart<BaseChartData>> get _showMainChartData =>
      widget.source.mainChartBaseChartsShow;

  /// 显示数据的开始索引值。
  int get _showDataStartIndex => widget.source.showDataStartIndex;

  set _showDataStartIndex(int index) =>
      widget.source.showDataStartIndex = index;
}
