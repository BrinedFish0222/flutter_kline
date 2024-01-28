import 'package:flutter/material.dart';
import 'package:flutter_kline/constants/direction.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../common/pair.dart';
import '../vo/pointer_info.dart';
import 'k_chart_controller.dart';
import 'kline_gesture_detector_controller.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    required this.controller,
    required this.kChartController,
    required this.child,
    required this.totalDataNum,
  });

  final KlineGestureDetectorController controller;

  final KChartController kChartController;

  /// 数据总数量
  final int totalDataNum;

  final Widget child;

  @override
  State<KlineGestureDetector> createState() => _KlineGestureDetectorState();
}

class _KlineGestureDetectorState extends State<KlineGestureDetector>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;

  late Animation _animation;

  /// 横向拖动速率
  double _primaryVelocity = 0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.decelerate);
    _animationController.addListener(() {
      double dx = _primaryVelocity.abs() * (1 - _animation.value) * 0.02;
      if (dx == 0) {
        return;
      }
      widget.controller.onHorizontalDrawChart(
          widget.controller.horizontalDrawDir == Direction.left ? -dx : dx);
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

        /// 双指缩放
        if (isZoomIn == true) {
          widget.controller.zoomIn();
        } else if (isZoomIn == false) {
          widget.controller.zoomOut();
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
        onTap: () {
          if (_isDoublePointer()) {
            return;
          }

          if (widget.kChartController.isShowCrossCurve) {
            // 取消选中的十字线
            widget.kChartController.hideCrossCurve();
            return;
          }

          if (lastPointerInfo != null) {
            // 显示十字线
            widget.kChartController.showCrossCurve(Offset(
                lastPointerInfo!.globalPosition.dx,
                lastPointerInfo!.globalPosition.dy));
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_isDoublePointer()) {
            return;
          }

          if (widget.kChartController.isShowCrossCurve) {
            // 如果十字线显示的状态，则拖动操作是移动十字线。
            _showCrossCurve(details);
            return;
          }

          widget.kChartController.updateOverlayEntryDataByIndex(-1);
          widget.controller.onHorizontalDrawChart(details.delta.dx);
        },
        onHorizontalDragEnd: (details) {
          if (_isDoublePointer()) {
            return;
          }

          _primaryVelocity = details.primaryVelocity ?? 0;
          _animationController.reset();
          _animationController.forward();
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

          bool isShowCrossCurve = widget.kChartController.isShowCrossCurve;

          if (isShowCrossCurve) {
            _showCrossCurve(details);
            return;
          }

          if (delta.dy < 0) {
            // 单指放大
            // 如果十字线显示的状态，则拖动操作是移动十字线。
            if (isShowCrossCurve) {
              _showCrossCurve(details);
            } else {
              widget.controller.zoomIn();
            }
          } else {
            // 单指缩小
            if (isShowCrossCurve) {
              _showCrossCurve(details);
            } else {
              widget.controller.zoomOut();
            }
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

  /// 显示十字线
  void _showCrossCurve(DragUpdateDetails details) {
    widget.kChartController.showCrossCurve(
        Offset(details.globalPosition.dx, details.globalPosition.dy));
  }
}
