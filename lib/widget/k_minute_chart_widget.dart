import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
import 'package:flutter_kline/widget/k_chart_controller.dart';
import 'package:flutter_kline/widget/minute_chart_widget.dart';
import 'package:flutter_kline/widget/sub_chart_widget.dart';

import '../common/kline_config.dart';
import '../common/pair.dart';
import '../utils/kline_collection_util.dart';
import '../utils/kline_date_util.dart';
import '../utils/kline_util.dart';
import '../vo/base_chart_vo.dart';
import '../vo/main_chart_selected_data_vo.dart';
import '../vo/mask_layer.dart';

/// k线分时图
class KMinuteChartWidget extends StatefulWidget {
  const KMinuteChartWidget({
    super.key,
    this.controller,
    required this.source,
    required this.middleNum,
    this.differenceNumbers,
    this.subChartMaskList,
    this.subChartRatio = 0.5,
    required this.onTapIndicator,
    required this.overlayEntryLocationKey,
    this.overlayEntryBuilder,
    this.chartNum,
  }) : assert(chartNum == null || chartNum > 0, "chartNum is null or gt 1");

  final KChartController? controller;

  /// 数据源
  final KChartDataSource source;

  /// 限制图数量，不设置表示等于 [source.originCharts.length]
  /// 值等于空或大于0
  final int? chartNum;

  /// 分时图：中间值
  final double middleNum;

  /// 额外增加的差值：这些数据会加入和 [middleNum] 进行差值比较
  /// 常设值：最高价、最低价
  final List<double>? differenceNumbers;

  /// 副图遮罩
  final List<MaskLayer?>? subChartMaskList;

  /// 副图对于主图的比例
  final double subChartRatio;

  /// 点击股票指标事件
  final void Function(int index) onTapIndicator;

  final GlobalKey? overlayEntryLocationKey;

  /// 悬浮层自定义组件
  final Widget Function(LineChartData)? overlayEntryBuilder;

  @override
  State<KMinuteChartWidget> createState() => _KMinuteChartWidgetState();
}

class _KMinuteChartWidgetState extends State<KMinuteChartWidget> {
  late final KChartController _controller;

  /// 主图size
  late Size _mainChartSize;

  /// 副图size
  late Size _subChartSize;

  /// 十字线流。索引0是主图，其它均是副图。
  late List<StreamController<Pair<double?, double?>>> _crossCurveStreamList;

  /// 数据点宽度
  late double _pointWidth;

  /// 数据点间隔
  late double _pointGap;

  /// 十字线选中数据索引流。
  StreamController<int>? _selectedIndexStream;

  bool _isOnHorizontalDragStart = true;

  // 选中的折线数据
  final StreamController<MainChartSelectedDataVo> _selectedLineChartDataStream =
      StreamController();

  /// 副图遮罩
  // List<MaskLayer?> _subChartMaskList = [];

  /// 点击全局坐标
  Offset? onTapGlobalPointer;

  get _minuteChartSubjoinData {
    int mainChartsLength = widget.source.mainChartBaseChartsShow.length;
    if (mainChartsLength < 1) {
      return null;
    }

    return widget.source.mainChartBaseChartsShow.sublist(1);
  }
  
  /// 副图显示数量
  get _subChartShowLength => widget.chartNum == null ? _subChartData.length : (widget.chartNum! - 1).clamp(0, _subChartData.length);

  @override
  void initState() {
    _controller = widget.controller ?? KChartController(source: widget.source);
    _initCrossCurveStream();
    _initSelectedIndexStream();

    super.initState();
  }

  void _initSelectedIndexStream() {
    _selectedIndexStream = StreamController<int>.broadcast();

    // 增加对悬浮层的操作
    _selectedIndexStream?.stream.listen((index) {
      // 不显示的情况：索引为-1；空数据；索引不存在；索引位置空数据；
      if (index == -1 ||
          KlineCollectionUtil.isEmpty(_minuteChartData.data) ||
          !_minuteChartData.data.hasIndex(index) ||
          _minuteChartData.data[index] == null) {
        _hideCandlestickOverlay();
        return;
      }

      // TODO 202401160117 为何 updateOverlayEntryDataByIndex notifyListeners 会和当前方法进入死循环
      // _controller.updateOverlayEntryDataByIndex(index);
      // TODO 看data是否能用上面的数据
      LineChartData data = _minuteChartData.data[index]!;
      _showCandlestickOverlay(context: context, data: data);
    });
  }

  int get _showDataNum => widget.source.showDataNum;

  LineChartVo get _minuteChartData {
    BaseChartVo? firstLineChart = KlineCollectionUtil.firstWhere(widget.source.mainChartBaseChartsShow, (element) => element is LineChartVo);
    if (firstLineChart == null) {
      return LineChartVo(data: []);
    }
    return firstLineChart as LineChartVo;
  }


  /// 初始化十字线 StreamController
  void _initCrossCurveStream() {
    _crossCurveStreamList = [];
    _crossCurveStreamList.add(StreamController());
    for (int i = 0; i < _subChartData.length; ++i) {
      _crossCurveStreamList.add(StreamController());
    }
  }

  List<List<BaseChartVo<BaseChartData>>> get _subChartData => widget.source.subChartBaseCharts;

  @override
  void dispose() {
    _hideCandlestickOverlay();
    _selectedIndexStream?.close();
    _selectedLineChartDataStream.close();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GestureDetector(
          onLongPressStart: _globalOnLongPressStart,
          onLongPressMoveUpdate: _globalOnLongPressMoveUpdate,
          onHorizontalDragUpdate: _controller.isShowCrossCurve ? _globalOnHorizontalDragUpdate : null,
          onVerticalDragUpdate: _controller.isShowCrossCurve ? _globalOnHorizontalDragUpdate : null,
          child: AnimatedBuilder(
              animation: widget.source,
              builder: (context, _) {
                /// 副图显示数据
                var subChartsShow = widget.source.subChartsShow;
                int subChartsShowLength = _subChartShowLength;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    _computeLayout(constraints);
                    return Column(
                      children: [
                        Listener(
                          // 记录点击的位置
                          onPointerDown: (event) => onTapGlobalPointer =
                              Offset(event.position.dx, event.position.dy),
                          child: GestureDetector(
                            onTap: _onTap,
                            onHorizontalDragStart:
                                _controller.isShowCrossCurve ? _onHorizontalDragStart : null,
                            onHorizontalDragUpdate:
                                _controller.isShowCrossCurve ? _onHorizontalDragUpdate : null,
                            onHorizontalDragEnd: _controller.isShowCrossCurve
                                ? (details) =>
                                    _isOnHorizontalDragStart = false
                                : null,
                            child: MinuteChartWidget(
                              size: _mainChartSize,
                              name: widget.source.mainChartShow?.name,
                              minuteChartData: _minuteChartData,
                              minuteChartSubjoinData: _minuteChartSubjoinData,
                              middleNum: widget.middleNum,
                              differenceNumbers: widget.differenceNumbers,
                              pointWidth: _pointWidth,
                              pointGap: _pointGap,
                              crossCurveStream: _crossCurveStreamList[0],
                              selectedChartDataIndexStream:
                                  _selectedIndexStream,
                              dataNum: _showDataNum,
                              onTapIndicator: () {
                                widget.onTapIndicator(0);
                              },
                            ),
                          ),
                        ),
                        for (int i = 0; i < subChartsShowLength; ++i)
                          SizedBox.fromSize(
                            size: _subChartSize,
                            child: GestureDetector(
                              onTapDown: (details) => _cancelCrossCurve(),
                              child: SubChartWidget(
                                size: _subChartSize,
                                name: subChartsShow[i].name,
                                chartData: subChartsShow[i].baseCharts,
                                pointWidth: _pointWidth,
                                pointGap: _pointGap,
                                maskLayer: _getSubChartMaskByIndex(i),
                                crossCurveStream: _getCrossCurveStreamByIndex(i + 1),
                                selectedChartDataIndexStream: _selectedIndexStream,
                                onTapIndicator: () {
                                  widget.onTapIndicator(i + 1);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                );
              }),
        );
      }
    );
  }

  @override
  void didUpdateWidget(covariant KMinuteChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _globalOnHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_controller.isShowCrossCurve) {
      return;
    }

    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  MaskLayer? _getSubChartMaskByIndex(int index) {
    bool hasMaskLayer = widget.subChartMaskList?.hasIndex(index) ?? false;
    return hasMaskLayer ? widget.subChartMaskList![index] : null;
  }

  /// 根据索引获取十字线流
  StreamController<Pair<double?, double?>> _getCrossCurveStreamByIndex(int index) {
    bool hasStream = _crossCurveStreamList.hasIndex(index);
    if (hasStream) {
      return _crossCurveStreamList[index];
    }

    StreamController<Pair<double?, double?>> streamController = StreamController.broadcast();
    _crossCurveStreamList.add(streamController);

    return streamController;
  }

  void _onTap() {
    // 取消十字线
    bool isCancel = _cancelCrossCurve();
    if (isCancel) {
      return;
    }

    _resetCrossCurve(
        Pair(left: onTapGlobalPointer?.dx, right: onTapGlobalPointer?.dy));
  }

  void _onHorizontalDragStart(details) {
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
      subChartNum: _subChartShowLength,
    );
    _mainChartSize = Size(width, heightPair.left);
    _subChartSize = Size(width, heightPair.right);

    _pointWidth = width / _showDataNum;
    _pointGap = 0;
  }

  /// 获取蜡烛浮层地址
  /// @return left 是x轴，right 是y轴
  Pair<double, double>? _getCandlestickOverlayLocation() {
    if (widget.overlayEntryLocationKey == null) {
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
    return Pair(left: 0, right: 100);
  }

  void _showCandlestickOverlay(
      {required BuildContext context,
      double left = 0,
      double? top,
      required LineChartData data}) {
    Pair<double, double>? overlayLocation = _getCandlestickOverlayLocation();
    if (overlayLocation == null) {
      return;
    }

    top ??= overlayLocation.right;
    if (_controller.overlayEntry != null) {
      _controller.overlayEntry?.remove();
    }

    // 创建OverlayEntry并将其添加到Overlay中
    _controller.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            color: const Color(0xFFF5F5F5),
            child: _overlayEntryWidget(data),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_controller.overlayEntry!);
  }

  /// 悬浮层组件
  Widget _overlayEntryWidget(LineChartData data) {
    if (widget.overlayEntryBuilder != null) {
      return widget.overlayEntryBuilder!(data);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
        ),
        Text(KlineDateUtil.formatTime(dateTime: data.dateTime),
            style: const TextStyle(
                fontSize: KlineConfig.showDataFontSize)),
        const SizedBox(
          width: 10,
        ),
        Text('价 ${data.value ?? 0}',
            style: const TextStyle(
                fontSize: KlineConfig.showDataFontSize)),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }

  void _hideCandlestickOverlay() {
    _controller.hideOverlayEntry();
  }

  /// 长按移动事件
  _globalOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  /// 拖动事件
  _onHorizontalDragUpdate(DragUpdateDetails details) {
    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_controller.isShowCrossCurve) {
      _resetCrossCurve(Pair(
          left: details.globalPosition.dx, right: details.globalPosition.dy));
      return;
    }
  }

  /// 取消十字线
  bool _cancelCrossCurve() {
    if (!(_controller.isShowCrossCurve ||
        (_controller.isShowCrossCurve && !_isOnHorizontalDragStart))) {
      setState(() {});
      return false;
    }

    _resetCrossCurve(null);
    _selectedIndexStream?.add(-1);
    _hideCandlestickOverlay();
    setState(() {});
    return true;
  }

  /// 重置十字线位置
  void _resetCrossCurve(Pair<double?, double?>? crossCurveXY) {
    _controller.isShowCrossCurve = crossCurveXY != null;

    for (var element in _crossCurveStreamList) {
      element.add(crossCurveXY ?? Pair(left: null, right: null));
    }
  }

  void _globalOnLongPressStart(LongPressStartDetails details) {
    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }
}
