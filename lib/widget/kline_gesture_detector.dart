import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../common/pair.dart';
import '../vo/pointer_info.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    this.onTap,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.child,
    this.pointWidth = 0,
    this.pointGap = 0,
    required this.totalDataNum,
    required this.maxWidth,
    required this.showDataNum,
    this.isShowCrossCurve = false,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(right: 5);

  /// 数据点宽度
  final double pointWidth;

  /// 数据点间隔
  final double pointGap;

  /// 数据总数量
  final int totalDataNum;

  /// 显示的数据点
  final int showDataNum;

  /// 图的左右间隔
  final EdgeInsets padding;

  /// 显示图的最大宽度
  final double maxWidth;

  /// 是否显示十字线
  final bool isShowCrossCurve;

  final Widget child;

  final void Function(PointerInfo)? onTap;
  final void Function(DragStartDetails)? onHorizontalDragStart;
  final void Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final void Function(DragEndDetails)? onHorizontalDragEnd;

  /// 放大
  final void Function({DragUpdateDetails? details}) onZoomIn;

  /// 缩小
  final void Function({DragUpdateDetails? details}) onZoomOut;

  @override
  State<KlineGestureDetector> createState() => _KlineGestureDetectorState();
}

class _KlineGestureDetectorState extends State<KlineGestureDetector> {
  /// 手指数量
  int pointerCount = 0;

  /// 上一次操作记录点
  PointerInfo? lastPointerInfo;

  /// 双指信息
  final Pair<PointerInfo?, PointerInfo?> doublePointerInfo =
      Pair(left: null, right: null);

  /// 双指前置信息
  final Pair<PointerInfo?, PointerInfo?> doublePointerPreInfo =
      Pair(left: null, right: null);

  /// 双指首个手指空开时间
  int doublePointerFirstPutdownMilliseconds = 0;

  double _horizontalDragThreshold = 0;


  /// 卷轴宽度 卷轴最小宽度，代表最左边
  late double _minScrollWidth;

  /// 卷轴宽度 卷轴最大宽度，代表最右边
  /// 目前固定为0代表最右边
  final double _maxScrollWidth = 0;

  /// 卷轴显示的宽度
  /// [_minScrollWidthShow] 卷轴显示的宽度 左边的宽度
  /// [_maxScrollWidthShow] 卷轴显示的宽度 右边的宽度
  late double _minScrollWidthShow, _maxScrollWidthShow = 0;

  /// 显示的数据范围
  /// [_startDataIndex] 数据开始的索引
  /// [_endDataIndex]   数据结束的索引
  late int _startDataIndex = widget.totalDataNum - 1 - widget.showDataNum,
      _endDataIndex = widget.totalDataNum - 1;

  @override
  void initState() {
    KlineUtil.logd('KlineGestureDetector initState');
    _resetMinScrollWidth();
    // 卷轴显示左范围初始值：最右范围 - 最大显示范围
    _minScrollWidthShow = _maxScrollWidthShow - widget.maxWidth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    KlineUtil.logd('KlineGestureDetector build');
    return Listener(
      onPointerDown: (event) {
        pointerCount += 1;
        var currentPointer = PointerInfo.parse(event);
        lastPointerInfo = currentPointer.copy();
        // 保存首个点信息
        if (doublePointerInfo.left == null) {
          doublePointerInfo.left = currentPointer;
          doublePointerPreInfo.left = doublePointerInfo.left?.copy();
          return;
        }

        // 分配好左右指位置
        if (doublePointerInfo.left!.localPosition.dx > event.localPosition.dx) {
          // 换位
          doublePointerInfo.right = doublePointerInfo.left;
          doublePointerPreInfo.right = doublePointerInfo.right?.copy();
          doublePointerInfo.left = currentPointer;
          doublePointerPreInfo.left = doublePointerInfo.left?.copy();
        } else {
          doublePointerInfo.right = currentPointer;
          doublePointerPreInfo.right = doublePointerInfo.right?.copy();
        }

        _computePointerTopBottom();
      },
      onPointerMove: (event) {
        // 记录双指当前信息。
        if (doublePointerInfo.left?.pointer == event.pointer) {
          doublePointerInfo.left?.localPosition = event.localPosition;
        } else if (doublePointerInfo.right?.pointer == event.pointer) {
          doublePointerInfo.right?.localPosition = event.localPosition;
        }

        // 判断缩放，执行操作
        bool? isZoomIn = _isZoomIn(event);
        if (isZoomIn == true) {
          widget.onZoomIn();
        } else if (isZoomIn == false) {
          widget.onZoomOut();
        }
        // 记录当前执行成功的双指缩放点
        if (isZoomIn != null &&
            event.pointer == doublePointerPreInfo.left?.pointer) {
          doublePointerPreInfo.left?.localPosition =
              Offset(event.localPosition.dx, event.localPosition.dy);
        }
      },
      onPointerUp: (event) {
        if (pointerCount == 2) {
          // 记录双指首次松开时间
          doublePointerFirstPutdownMilliseconds =
              DateTime.now().millisecondsSinceEpoch;
        }

        _undoPointer(pointer: event.pointer);
        pointerCount -= 1;
      },
      onPointerCancel: (event) {
        _undoPointer(pointer: event.pointer);
        pointerCount -= 1;
      },
      child: GestureDetector(
        onTap: widget.onTap == null
            ? null
            : () {
                if (_isDoublePointer() || lastPointerInfo == null) {
                  return;
                }
                widget.onTap!(lastPointerInfo!);
              },
        onHorizontalDragStart: (details) {
          if (_isDoublePointer() || widget.onHorizontalDragStart == null) {
            return;
          }

          widget.onHorizontalDragStart!(details);
        },
        onHorizontalDragUpdate: (details) {
          _horizontalDragThreshold += (details.delta.dx).abs();

          KlineUtil.logd('onHorizontalDragUpdate _horizontalDragThreshold $_horizontalDragThreshold ...');
          // 达到横向拖动阈值才放行
          if (!widget.isShowCrossCurve && widget.showDataNum < 26 && _horizontalDragThreshold < 120 / (widget.showDataNum + 1)) {
            KlineUtil.logd('未达到横向拖动阈值，拦截');
            return;
          }
          _horizontalDragThreshold = 0;

          if (_isDoublePointer()) {
            return;
          }
          KlineUtil.logd("单指水平移动");
          if (widget.onHorizontalDragUpdate != null) {
            widget.onHorizontalDragUpdate!(details);
          }
        },
        onHorizontalDragEnd: (details) {
          if (_isDoublePointer() || widget.onHorizontalDragEnd == null) {
            return;
          }

          widget.onHorizontalDragEnd!(details);
        },
        onVerticalDragUpdate: (details) {
          if (_isDoublePointer()) {
            return;
          }
          var delta = details.delta;
          KlineUtil.logd('单指放大小：delta $delta');
          if (delta.dy == 0) {
            return;
          }

          if (delta.dy < 0) {
            KlineUtil.logd("单指放大");
            widget.onZoomIn(details: details);
          } else {
            KlineUtil.logd("单指缩小");
            widget.onZoomOut(details: details);
          }
        },
        child: widget.child,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant KlineGestureDetector oldWidget) {
    double lastMinScrollWidth = _minScrollWidth;
    _resetMinScrollWidth();

    // 如果卷轴显示区域目前在最右边，则不做任何变动
    if (_endDataIndex == widget.totalDataNum - 1) {
      // 重新计算最右边
      
    }

    KlineUtil.logd('KlineGestureDetector didUpdateWidget, dataNum ${widget.totalDataNum}, _minScrollWidth $_minScrollWidth');
    super.didUpdateWidget(oldWidget);
  }

  /// 重置卷轴最小宽度
  void _resetMinScrollWidth() {
    _minScrollWidth = -(widget.totalDataNum * (widget.pointGap + widget.pointWidth) + widget.padding.right);
  }

  ///  释放点信息
  void _undoPointer({required int pointer}) {
    if (doublePointerInfo.left?.pointer == pointer) {
      doublePointerInfo.left = null;
      doublePointerInfo.left = doublePointerInfo.right;
    } else if (doublePointerInfo.right?.pointer == pointer) {
      doublePointerInfo.right = null;
    }
  }

  /// 计算双指位置：哪个是上、哪个是下
  void _computePointerTopBottom() {
    if (doublePointerInfo.left == null || doublePointerInfo.right == null) {
      throw Exception('条件不满足计算双指位置');
    }

    doublePointerInfo.left!.isTop = doublePointerInfo.left!.localPosition.dy <
        doublePointerInfo.right!.localPosition.dy;
    doublePointerInfo.right!.isTop =
        doublePointerInfo.left!.isTop ? false : true;
  }

  /// 是否双指
  bool _isDoublePointer() {
    if (pointerCount == 2 ||
        DateTime.now().millisecondsSinceEpoch -
                doublePointerFirstPutdownMilliseconds <
            100) {
      return true;
    }

    return false;
  }

  /// 是否放大
  bool? _isZoomIn(PointerMoveEvent event) {
    if (pointerCount != 2 ||
        doublePointerInfo.left == null ||
        doublePointerInfo.right == null) {
      return null;
    }

    if (event.pointer == doublePointerInfo.left?.pointer &&
        doublePointerInfo.left!.localPosition.dx !=
            doublePointerPreInfo.left?.localPosition.dx) {
      return doublePointerInfo.left!.localPosition.dx <
          doublePointerPreInfo.left!.localPosition.dx;
    }

    return null;
  }
}
