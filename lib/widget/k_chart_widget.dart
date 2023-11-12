import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/widget/candlestick_show_data_widget.dart';
import 'package:flutter_kline/widget/sub_chart_widget.dart';

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
    required this.size,
    required this.mainChartData,
    // required this.candlestickChartData,
    // this.lineChartData,
    required this.subChartData,
    this.subChartMaskList,
    this.showDataNum = 60,
    this.margin,
    required this.onTapIndicator,
    this.dataGapRatio = 3,
    this.subChartRatio = 0.5,
    required this.overlayEntryLocationKey,
    this.realTimePrice,
  });

  final Size size;

  final List<BaseChartVo> mainChartData;
  // final CandlestickChartVo candlestickChartData;
  // final List<LineChartVo?>? lineChartData;

  /// 副图数据
  final List<List<BaseChartVo>> subChartData;

  /// 副图遮罩
  final List<MaskLayer?>? subChartMaskList;
  final EdgeInsets? margin;

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
  final GlobalKey overlayEntryLocationKey;

  /// 实时价格
  final double? realTimePrice;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
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
  bool _isShowCrossCurve = false;
  bool _isOnHorizontalDragStart = true;

  /// [widget.showDataNum]
  /// 默认范围：[KlineConfig.showDataMinLength], [KlineConfig.showDataMaxLength]
  late int _showDataNum;

  /// 等于：widget.candlestickChartData.dataList.length - 1
  late int _originCandlestickDataMaxIndex;

  /// 显示的主图数据
  List<BaseChartVo> _showMainChartData = [];

  /// 显示的蜡烛数据
  // CandlestickChartVo? _showCandlestickChartData;

  /// 显示的折线数据
  // List<LineChartVo>? _showLineChartData;

  List<List<BaseChartVo>> _showSubChartData = [];

  /// 显示数据的开始索引值。
  late int _showDataStartIndex;

  /// 同一时间上一个拖动的x轴坐标
  late double _sameTimeLastHorizontalDragX;

  /// 蜡烛选中数据悬浮层
  OverlayEntry? _candlestickOverlayEntry;

  /// 副图遮罩
  List<MaskLayer?> _subChartMaskList = [];

  @override
  void initState() {
    _originCandlestickDataMaxIndex = widget.mainChartData.first.dataLength - 1;
    _initSubChartMaskList();

    _initCrossCurveStream();
    _updateShowDataNum(widget.showDataNum);
    _showDataStartIndex = (_originCandlestickDataMaxIndex - _showDataNum)
        .clamp(0, _originCandlestickDataMaxIndex);
    _resetShowData();
    _initSelectedIndexStream();

    super.initState();
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
                KlineGestureDetector(
                  pointWidth: _pointWidth,
                  pointGap: _pointGap,
                  onTap: _onTap,
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: (details) =>
                      _isOnHorizontalDragStart = false,
                  onZoomIn: () {
                    int endIndex = (_showDataStartIndex + _showDataNum)
                        .clamp(0, _originCandlestickDataMaxIndex);
                    _onZoom(endIndex: endIndex, zoomIn: true);
                  },
                  onZoomOut: () {
                    int endIndex = (_showDataStartIndex + _showDataNum)
                        .clamp(0, _originCandlestickDataMaxIndex);
                    _onZoom(endIndex: endIndex, zoomIn: false);
                  },
                  child: MainChartWidget(
                    chartData: _showMainChartData,
                    size: _mainChartSize,
                    infoBarName: widget.mainChartData
                        .firstWhere((element) => element.isSelectedShowData())
                        .name,
                    margin: widget.margin,
                    pointWidth: _pointWidth,
                    pointGap: _pointGap,
                    crossCurveStream: _crossCurveStreamList[0],
                    selectedChartDataIndexStream: _selectedIndexStream,
                    onTapIndicator: () {
                      widget.onTapIndicator(0);
                    },
                    realTimePrice: widget.realTimePrice,
                  ),
                ),
                for (int i = 0; i < _showSubChartData.length; ++i)
                  GestureDetector(
                    onTapDown: (details) => _cancelCrossCurve(),
                    child: SizedBox.fromSize(
                      size: _subChartSize,
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
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// 更新显示的数据数量
  /// 同步：[_horizontalDragThreshold] 横向拖动阈值
  void _updateShowDataNum(int showDataNum) {
    _showDataNum = showDataNum;
  }

  void _onTap(PointerInfo pointerInfo) {
    debugPrint("k_chart_widget _onTap");
    // 取消选中的十字线
    if (_cancelCrossCurve()) {
      return;
    }

    _resetCrossCurve(Pair(
        left: pointerInfo.globalPosition.dx,
        right: pointerInfo.globalPosition.dy));
  }

  void _onHorizontalDragStart(details) {
    debugPrint("GestureDetector onHorizontalDragStart");
    _sameTimeLastHorizontalDragX = details.localPosition.dx;
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

    _pointWidth = KlineUtil.getPointWidth(
        width: width - (widget.margin?.right ?? 0),
        dataLength: _showMainChartData.first.dataLength,
        gapRatio: widget.dataGapRatio);
    _pointGap = _pointWidth / widget.dataGapRatio;
  }

  /// 获取蜡烛浮层地址
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
    return Pair(left: 0, right: 0);
  }

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
          child: CandlestickShowDataWidget(vo: vo),
        ),
      ),
    );

    Overlay.of(context).insert(_candlestickOverlayEntry!);
  }

  void _hideCandlestickOverlay() {
    _candlestickOverlayEntry?.remove();
    _candlestickOverlayEntry = null;
  }

  _initSelectedIndexStream() {
    if (_showMainChartData.isEmpty) {
      return;
    }

    _selectedIndexStream = StreamController<int>.broadcast();
    // 处理悬浮层。
    _selectedIndexStream?.stream.listen((index) {
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
      var overlayLocation = _getCandlestickOverlayLocation();
      _showCandlestickOverlay(
          context: context, left: 0, top: overlayLocation.right, vo: vo);
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
        (endIndex - _showDataNum).clamp(0, _originCandlestickDataMaxIndex);
    debugPrint("最后的数据索引： _onZoom to _resetShowData");
    _resetShowData(startIndex: startIndex);
  }

  /// 重置显示的数据。
  /// 自动适配
  _resetShowData({int? startIndex}) {
    if (startIndex == null) {
      _showDataStartIndex = (_originCandlestickDataMaxIndex - _showDataNum)
          .clamp(0, _originCandlestickDataMaxIndex);
    } else {
      _showDataStartIndex = startIndex;
    }

    int endIndex = (_showDataStartIndex + _showDataNum)
        .clamp(0, _originCandlestickDataMaxIndex);
    debugPrint("最后的数据索引：$endIndex");
    _showDataStartIndex =
        (endIndex - _showDataNum).clamp(0, _originCandlestickDataMaxIndex);

    _showMainChartData = [];
    for (BaseChartVo data in widget.mainChartData) {
      var subData = data.subData(start: _showDataStartIndex, end: endIndex + 1);
      _showMainChartData.add(subData);
    }

    if (KlineCollectionUtil.isNotEmpty(widget.subChartData)) {
      _showSubChartData = [];
      for (List<BaseChartVo> dataList in widget.subChartData) {
        List<BaseChartVo> newDataList = [];
        for (BaseChartVo data in dataList) {
          newDataList
              .add(data.subData(start: _showDataStartIndex, end: endIndex + 1));
        }
        _showSubChartData.add(newDataList);
      }
    }

    setState(() {});
  }

  /// 长按移动事件
  _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    debugPrint(
        "_onLongPressMoveUpdate, dx: ${details.localPosition.dx}, dy ${details.localPosition.dy}");

    _resetCrossCurve(Pair(
        left: details.globalPosition.dx, right: details.globalPosition.dy));
  }

  /// 拖动事件
  _onHorizontalDragUpdate(DragUpdateDetails details) {
    debugPrint("k线图横向滑动");
    // 如果十字线显示的状态，则拖动操作是移动十字线。
    if (_isShowCrossCurve) {
      _resetCrossCurve(Pair(
          left: details.globalPosition.dx, right: details.globalPosition.dy));
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

  /// 取消十字线
  bool _cancelCrossCurve() {
    if (!(_isShowCrossCurve ||
        (_isShowCrossCurve && !_isOnHorizontalDragStart))) {
      return false;
    }

    _resetCrossCurve(null);
    _hideCandlestickOverlay();

    _selectedIndexStream?.add(-1);
    return true;
  }

  /// 重置十字线位置
  void _resetCrossCurve(Pair<double?, double?>? crossCurveXY) {
    _isShowCrossCurve = crossCurveXY != null;

    for (var element in _crossCurveStreamList) {
      element.add(crossCurveXY ?? Pair(left: null, right: null));
    }
  }
}
