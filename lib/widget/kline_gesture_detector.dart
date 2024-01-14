import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/horizontal_draw_chart_details.dart';

import '../common/pair.dart';
import '../vo/pointer_info.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    required this.controller,
    this.onTap,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDrawChart,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.child,
    required this.totalDataNum,
    this.isShowCrossCurve = false,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(right: 5);

  final KlineGestureDetectorController controller;

  /// 数据总数量
  final int totalDataNum;

  /// 图的左右间隔
  @Deprecated("目前暂不支持")
  final EdgeInsets padding;

  /// 是否显示十字线
  final bool isShowCrossCurve;

  final Widget child;

  final void Function(PointerInfo)? onTap;
  final void Function(DragStartDetails)? onHorizontalDragStart;
  final void Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final void Function(DragEndDetails)? onHorizontalDragEnd;

  /// 画图请求，横向滑动时触发
  final void Function(HorizontalDrawChartDetails)? onHorizontalDrawChart;

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
          if (_isDoublePointer()) {
            return;
          }
          KlineUtil.logd("单指水平移动");
          if (widget.onHorizontalDragUpdate != null) {
            widget.onHorizontalDragUpdate!(details);
          }

          if (widget.onHorizontalDrawChart == null) {
            return;
          }

          HorizontalDrawChartDetails? horizontalDrawChartDetails =
              widget.controller.onHorizontalDrawChart(details);
          if (horizontalDrawChartDetails == null) {
            return;
          }

          widget.onHorizontalDrawChart!(horizontalDrawChartDetails);
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

  double get screenMaxWidth => widget.controller.screenMaxWidth;
}

/// 手势控制器
class KlineGestureDetectorController extends ChangeNotifier {
  KlineGestureDetectorController({
    required double screenMaxWidth,
    required KChartDataSource source,
  })  : _screenMaxWidth = screenMaxWidth,
        _source = source {
    var dataMaxLength = source.dataMaxLength;
    // 初始化卷轴总长度
    _minScrollWidth = -(dataMaxLength / source.showDataNum * screenMaxWidth);
    // 卷轴显示左范围初始值：最右范围 - 最大显示范围
    _minScrollWidthShow = _maxScrollWidthShow - screenMaxWidth;

    double pointWidthGap = _minScrollWidth.abs() / dataMaxLength;
    _pointWidth = pointWidthGap * .8;
    _pointGap = pointWidthGap * .2;

    _padding = EdgeInsets.only(left: scrollWidthShow - pointWidthGap * source.showDataNum);
    _initScrollListener();
  }

  /// 初始化卷轴监听
  void _initScrollListener() {
    source.isEndLast.addListener(() {
      // 右增数据，加大卷轴最大值；左增数据，加大卷轴最小值
      int diffNum = source.dataMaxLength - source.dataMaxLengthLast;
      double diffWidth = diffNum * (_pointWidth + _pointGap);
      bool isEnd = source.isEndLast.value;
      if (isEnd) {
        _maxScrollWidth += diffWidth;
      } else {
        _minScrollWidth -= diffWidth;
      }
    });
  }

  /// 显示图的最大宽度
  final double _screenMaxWidth;

  /// 数据源
  final KChartDataSource _source;

  /// 数据点宽度
  late double _pointWidth;

  /// 数据点间隔
  late double _pointGap;

  /// 卷轴宽度
  /// [_minScrollWidth] 卷轴最小宽度，代表最左边
  /// [_maxScrollWidth] 卷轴最大宽度，代表最右边，默认是0
  late double _minScrollWidth, _maxScrollWidth = 0;

  /// 卷轴显示的宽度，范围在 [_minScrollWidth] 和 [_maxScrollWidth] 之间
  /// [_minScrollWidthShow] 卷轴显示的宽度 左边的宽度
  /// [_maxScrollWidthShow] 卷轴显示的宽度 右边的宽度
  late double _minScrollWidthShow, _maxScrollWidthShow = 0;

  late EdgeInsets _padding;

  EdgeInsets get padding => _padding;

  double get screenMaxWidth => _screenMaxWidth;

  KChartDataSource get source => _source;

  double get pointWidth => _pointWidth;

  double get pointGap => _pointGap;

  double get minScrollWidth => _minScrollWidth;

  double get maxScrollWidth => _maxScrollWidth;

  double get minScrollWidthShow => _minScrollWidthShow;

  double get maxScrollWidthShow => _maxScrollWidthShow;

  /// 总宽度
  double get scrollWidth => maxScrollWidth - minScrollWidth;

  /// 显示的宽度
  double get scrollWidthShow => _maxScrollWidthShow - _minScrollWidthShow;



  /// 横向滑动画图请求
  /// 返回值空表示不满足触发条件
  HorizontalDrawChartDetails? onHorizontalDrawChart(DragUpdateDetails details) {
    // 数据不足一屏幕，中断画图请求
    if (_minScrollWidth.abs() <= screenMaxWidth) {
      KlineUtil.logd("横向滑动画图请求 数据不足一屏幕中断");
      return null;
    }

    // 是否是左滑动
    bool leftDir = details.delta.dx > 0;
    if (leftDir && _minScrollWidthShow == _minScrollWidth) {
      // 左边滑动尽头结束
      KlineUtil.logd("横向滑动画图请求 左边尽头中断");
      return null;
    }
    if (!leftDir && _maxScrollWidthShow == _maxScrollWidth) {
      // 右边滑动尽头结束
      KlineUtil.logd("横向滑动画图请求 右边尽头中断");
      return null;
    }

    // 这一帧滑动的dx可能超过界限了，需要进行矫正
    double dx = details.delta.dx;
    _minScrollWidthShow = _minScrollWidthShow - dx;
    _maxScrollWidthShow = _maxScrollWidthShow - dx;

    if (_maxScrollWidthShow > _maxScrollWidth) {
      // 最右边
      _maxScrollWidthShow = _maxScrollWidth;
      _minScrollWidthShow = _maxScrollWidthShow - screenMaxWidth;
    } else if (_minScrollWidthShow < _minScrollWidth) {
      // 最左边
      _minScrollWidthShow = _minScrollWidth;
      _maxScrollWidthShow = _minScrollWidthShow + screenMaxWidth;
    }

    double pointGapWidth = pointWidth + pointGap;
    int startIndex = (_minScrollWidthShow - _minScrollWidth) ~/ pointGapWidth;
    int endIndex = startIndex + source.showDataNum;
    int dataMaxIndex = source.dataMaxIndex;
    if (endIndex > dataMaxIndex) {
      endIndex = dataMaxIndex;
      startIndex = dataMaxIndex - source.showDataNum;
    }

    double leftPadding = pointGapWidth - (_minScrollWidthShow - scrollWidth) % pointGapWidth;
    _padding = EdgeInsets.only(left: leftPadding);

    HorizontalDrawChartDetails horizontalDrawChartDetails =
        HorizontalDrawChartDetails(
      startIndex: startIndex,
      endIndex: endIndex,
      padding: padding,
      details: details,
    );

    return horizontalDrawChartDetails;
  }
}
