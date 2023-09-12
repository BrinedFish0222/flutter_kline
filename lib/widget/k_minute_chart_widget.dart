import 'dart:async';

import 'package:flutter/material.dart';
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
    required this.minuteChartData,
    this.minuteChartSubjoinData,
    this.minuteChartDataAddStream,
    required this.middleNum,
    this.differenceNumbers,
    this.dataNum = KlineConfig.minuteDataNum,
    required this.subChartData,
    this.subChartMaskList,
    this.subChartRatio = 0.5,
    required this.onTapIndicator,
  });

  final Size size;

  /// 分时数据
  final LineChartVo minuteChartData;

  final List<BaseChartVo>? minuteChartSubjoinData;

  /// [minuteChartData] 追加数据流
  final StreamController<LineChartData>? minuteChartDataAddStream;

  /// 中间值
  final double middleNum;

  /// 额外增加的差值：这些数据会加入和 [middleNum] 进行差值比较
  /// 常设值：最高价、最低价
  final List<double>? differenceNumbers;

  /// 数据点，一天默认有240个时间点
  final int dataNum;

  /// 副图数据
  final List<List<BaseChartVo>> subChartData;

  /// 副图遮罩
  final List<MaskLayer?>? subChartMaskList;

  /// 副图对于主图的比例
  final double subChartRatio;

  /// 点击股票指标事件
  final void Function(int index) onTapIndicator;

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

  final List<List<BaseChartVo>> _showSubChartData = [];

  // 选中的折线数据
  final StreamController<MainChartSelectedDataVo> _selectedLineChartDataStream =
      StreamController();

  /// 蜡烛选中数据悬浮层
  OverlayEntry? _candlestickOverlayEntry;

  /// 副图遮罩
  List<MaskLayer?> _subChartMaskList = [];

  late LineChartVo _minuteChartData;

  /// 点击全局坐标
  Offset? onTapGlobalPointer;

  @override
  void initState() {
    _minuteChartData = widget.minuteChartData.copy() as LineChartVo;
    _initSubChartMaskList();
    _initSubChartData();
    _initCrossCurveStream();
    _initSelectedIndexStream();

    super.initState();
  }

  void _initSelectedIndexStream() {
    _selectedIndexStream = StreamController<int>.broadcast();

    // 增加对悬浮层的操作
    _selectedIndexStream?.stream.listen((index) {
      if (index == -1 ||
          KlineCollectionUtil.isEmpty(_minuteChartData.dataList)) {
        _hideCandlestickOverlay();
        return;
      }

      LineChartData data = _minuteChartData.dataList![index];
      _showCandlestickOverlay(context: context, data: data);
    });
  }

  void _initSubChartData() {
    for (var subData in widget.subChartData) {
      var showDataList =
          subData.map((e) => e.subData(start: 0, end: widget.dataNum)).toList();

      _showSubChartData.add(showDataList);
    }
  }

  /// 初始化副图遮罩列表
  void _initSubChartMaskList() {
    if (KlineCollectionUtil.isNotEmpty(widget.subChartMaskList)) {
      _subChartMaskList = widget.subChartMaskList!;
    }

    _subChartMaskList.length = widget.subChartData.length;
  }

  /// 初始化十字线 StreamController
  void _initCrossCurveStream() {
    _crossCurveStreamList = [];
    _crossCurveStreamList.add(StreamController());
    for (int i = 0; i < widget.subChartData.length; ++i) {
      _crossCurveStreamList.add(StreamController());
    }
  }

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
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: LayoutBuilder(builder: (context, constraints) {
        _computeLayout(constraints);
        return Stack(
          children: [
            Column(
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
                              ? (details) => _isOnHorizontalDragStart = false
                              : null,
                          child: MinuteChartWidget(
                            size: _mainChartSize,
                            minuteChartData: _minuteChartData,
                            minuteChartSubjoinData:
                                widget.minuteChartSubjoinData,
                            minuteChartDataAddStream:
                                widget.minuteChartDataAddStream,
                            middleNum: widget.middleNum,
                            differenceNumbers: widget.differenceNumbers,
                            pointWidth: _pointWidth,
                            pointGap: _pointGap,
                            crossCurveStream: _crossCurveStreamList[0],
                            selectedChartDataIndexStream: _selectedIndexStream,
                            dataNum: widget.dataNum,
                            onTapIndicator: () {
                              widget.onTapIndicator(0);
                            },
                          ),
                        );
                      }),
                ),
                for (int i = 0; i < _showSubChartData.length; ++i)
                  GestureDetector(
                    onTapDown: (details) => _cancelCrossCurve(),
                    child: SubChartWidget(
                      size: _subChartSize,
                      name: _showSubChartData[i].first.name ?? '',
                      chartData: _showSubChartData[i],
                      pointWidth: _pointWidth,
                      pointGap: _pointGap,
                      maskLayer: _subChartMaskList[i],
                      crossCurveStream: _crossCurveStreamList[i + 1],
                      selectedChartDataIndexStream: _selectedIndexStream,
                      onTapIndicator: () {
                        widget.onTapIndicator(i + 1);
                      },
                    ),
                  ),
              ],
            ),
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
        subChartNum: widget.subChartData.length);
    _mainChartSize = Size(width, heightPair.left);
    _subChartSize = Size(width, heightPair.right);

    _pointWidth = width / widget.dataNum;
    _pointGap = 0;
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
      double left = 0,
      double? top,
      required LineChartData data}) {
    top ??= _getCandlestickOverlayLocation().right - 50;
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
}
