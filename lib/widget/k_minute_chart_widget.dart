import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
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
    required this.size,
    required this.source,
    required this.middleNum,
    this.differenceNumbers,
    this.subChartMaskList,
    this.subChartRatio = 0.5,
    required this.onTapIndicator,
    required this.overlayEntryLocationKey,
  });

  final Size size;

  /// 数据源
  final KChartDataSource source;

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

  final GlobalKey overlayEntryLocationKey;

  @override
  State<KMinuteChartWidget> createState() => _KMinuteChartWidgetState();
}

class _KMinuteChartWidgetState extends State<KMinuteChartWidget> {
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

  /// 十字线是否显示
  final ValueNotifier<bool> _isShowCrossCurve = ValueNotifier(false);

  bool _isOnHorizontalDragStart = true;

  // 选中的折线数据
  final StreamController<MainChartSelectedDataVo> _selectedLineChartDataStream =
      StreamController();

  /// 蜡烛选中数据悬浮层
  OverlayEntry? _candlestickOverlayEntry;

  /// 副图遮罩
  List<MaskLayer?> _subChartMaskList = [];

  /// 点击全局坐标
  Offset? onTapGlobalPointer;

  @override
  void initState() {
    _initSubChartMaskList();
    _initCrossCurveStream();
    _initSelectedIndexStream();

    super.initState();
  }

  void _initSelectedIndexStream() {
    _selectedIndexStream = StreamController<int>.broadcast();

    // 增加对悬浮层的操作
    _selectedIndexStream?.stream.listen((index) {
      if (index == -1 ||
          KlineCollectionUtil.isEmpty(_minuteChartData.data) ||
          _minuteChartData.data.hasIndex(index)) {
        _hideCandlestickOverlay();
        return;
      }

      LineChartData data = _minuteChartData.data[index]!;
      _showCandlestickOverlay(context: context, data: data);
    });
  }

  /// 初始化副图遮罩列表
  void _initSubChartMaskList() {
    if (KlineCollectionUtil.isNotEmpty(widget.subChartMaskList)) {
      _subChartMaskList = widget.subChartMaskList!;
    }

    _subChartMaskList.length = _showDataNum;
  }

  int get _showDataNum => widget.source.showDataNum;

  LineChartVo get _minuteChartData =>
      widget.source.showData.mainChartData.first as LineChartVo;

  List<List<BaseChartVo>> get _showSubChartData =>
      widget.source.showData.subChartData;

  /// 初始化十字线 StreamController
  void _initCrossCurveStream() {
    _crossCurveStreamList = [];
    _crossCurveStreamList.add(StreamController());
    for (int i = 0; i < _subChartData.length; ++i) {
      _crossCurveStreamList.add(StreamController());
    }
  }

  List<List<BaseChartVo<BaseChartData>>> get _subChartData =>
      widget.source.data.subChartData;

  @override
  void dispose() {
    _hideCandlestickOverlay();
    _selectedIndexStream?.close();
    _selectedLineChartDataStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: LayoutBuilder(builder: (context, constraints) {
        _computeLayout(constraints);
        return Stack(
          children: [
            /// 数据源更新
            ListenableBuilder(
                listenable: widget.source,
                builder: (context, _) {
                  return Column(
                    children: [
                      Listener(
                        // 记录点击的位置
                        onPointerDown: (event) => onTapGlobalPointer =
                            Offset(event.position.dx, event.position.dy),
                        child: ValueListenableBuilder(
                            valueListenable: _isShowCrossCurve,
                            builder: (context, data, _) {
                              return GestureDetector(
                                onTap: _onTap,
                                onHorizontalDragStart:
                                    data ? _onHorizontalDragStart : null,
                                onHorizontalDragUpdate:
                                    data ? _onHorizontalDragUpdate : null,
                                onHorizontalDragEnd: data
                                    ? (details) =>
                                        _isOnHorizontalDragStart = false
                                    : null,
                                child: MinuteChartWidget(
                                  size: _mainChartSize,
                                  minuteChartData: _minuteChartData,
                                  minuteChartSubjoinData: widget
                                      .source.showData.mainChartData
                                      .sublist(1),
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
                              );
                            }),
                      ),
                      for (int i = 0; i < _showSubChartData.length; ++i)
                        SizedBox.fromSize(
                          size: _subChartSize,
                          child: GestureDetector(
                            onTapDown: (details) => _cancelCrossCurve(),
                            child: SubChartWidget(
                              size: _subChartSize,
                              name: _showSubChartData[i].first.name ?? '',
                              chartData: _showSubChartData[i],
                              pointWidth: _pointWidth,
                              pointGap: _pointGap,
                              maskLayer: _subChartMaskList[i],
                              crossCurveStream: _crossCurveStreamList[i + 1],
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
          ],
        );
      }),
    );
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
    double width = widget.size.width > constraints.maxWidth
        ? constraints.maxWidth - 1
        : widget.size.width - 1;

    Pair<double, double> heightPair = KlineUtil.autoAllotChartHeight(
        totalHeight: widget.size.height,
        subChartRatio: widget.subChartRatio,
        subChartNum: _subChartData.length);
    _mainChartSize = Size(width, heightPair.left);
    _subChartSize = Size(width, heightPair.right);

    _pointWidth = width / _showDataNum;
    _pointGap = 0;
  }

  /// 获取蜡烛浮层地址
  /// @return left 是x轴，right 是y轴
  Pair<double, double> _getCandlestickOverlayLocation() {
    RenderBox? renderBox = widget.overlayEntryLocationKey.currentContext
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
    top ??= _getCandlestickOverlayLocation().right;
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
            height: 40,
            color: const Color(0xFFF5F5F5),
            child: Row(
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
  }

  /// 长按移动事件
  _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  /// 拖动事件
  _onHorizontalDragUpdate(DragUpdateDetails details) {
    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_isShowCrossCurve.value) {
      _resetCrossCurve(Pair(
          left: details.globalPosition.dx, right: details.globalPosition.dy));
      return;
    }
  }

  /// 取消十字线
  bool _cancelCrossCurve() {
    if (!(_isShowCrossCurve.value ||
        (_isShowCrossCurve.value && !_isOnHorizontalDragStart))) {
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
    _isShowCrossCurve.value = crossCurveXY != null;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    _isShowCrossCurve.notifyListeners();

    for (var element in _crossCurveStreamList) {
      element.add(crossCurveXY ?? Pair(left: null, right: null));
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }
}
