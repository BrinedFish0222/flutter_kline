import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../constants/direction.dart';

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
    _pointWidth = pointWidthGap * KlineConfig.pointWidthRatio;
    _pointGap = pointWidthGap * (1 - KlineConfig.pointWidthRatio);

    _padding = EdgeInsets.only(
        left: scrollWidthShow - pointWidthGap * source.showDataNum);
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

  /// 滑动方向
  Direction _horizontalDrawDir = Direction.right;

  Direction get horizontalDrawDir => _horizontalDrawDir;

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

  /// 缩小
  void zoomOut({int zoomValue = 1}) {
    _zoom(zoomValue: zoomValue, isIn: false);
  }

  /// 放大
  void zoomIn({int zoomValue = 1}) {
    _zoom(zoomValue: zoomValue, isIn: true);
  }

  /// 放大、缩小
  void _zoom({int zoomValue = 1, required bool isIn}) {
    int showDataNum = source.showDataNum;
    var dataMaxIndex = source.dataMaxIndex;

    int endIndex =
        (source.showDataStartIndex + showDataNum).clamp(0, dataMaxIndex);
    if (showDataNum == KlineConfig.showDataMinLength && isIn) {
      return;
    }

    if (showDataNum == KlineConfig.showDataMaxLength && !isIn) {
      return;
    }

    int showDataNumOld = showDataNum;
    showDataNum = (isIn ? (showDataNum - zoomValue) : (showDataNum + zoomValue))
        .clamp(KlineConfig.showDataMinLength, KlineConfig.showDataMaxLength);
    // 真正的放大数量
    zoomValue = showDataNumOld - showDataNum;

    // 重新计算卷轴信息
    double pointWidthGapOld = _pointWidth + _pointGap;
    double pointWidthGap = screenMaxWidth / showDataNum;
    _pointWidth = pointWidthGap * KlineConfig.pointWidthRatio;
    _pointGap = pointWidthGap * (1 - KlineConfig.pointWidthRatio);
    double multiple = (pointWidthGap - pointWidthGapOld) / pointWidthGapOld;
    _minScrollWidth = _minScrollWidth * (1 + multiple);
    _maxScrollWidth = _maxScrollWidth * (1 + multiple);

    int startIndex = (endIndex - showDataNum).clamp(0, dataMaxIndex);
    source.showDataNum = showDataNum;
    source.resetShowData(start: startIndex);

    _updateScrollWidthShowByStartDataIndex(
      startIndex: startIndex,
      showDataNum: showDataNum,
      pointerWidthGap: pointWidthGap,
    );

    source.notifyListeners();
    notifyListeners();
  }

  /// 横向滑动画图请求
  /// 返回值空表示不满足触发条件
  void onHorizontalDrawChart(double dx) {
    KlineUtil.logd('horizontal update dx $dx ============');
    // 数据不足一屏幕，中断画图请求
    if (_minScrollWidth.abs() <= screenMaxWidth) {
      KlineUtil.logd("横向滑动画图请求 数据不足一屏幕中断");
      return;
    }

    // 是否是左滑动
    bool leftDir = dx > 0;
    _horizontalDrawDir = leftDir ? Direction.right : Direction.left;
    if (leftDir && _minScrollWidthShow == _minScrollWidth) {
      // 左边滑动尽头结束
      KlineUtil.logd("横向滑动画图请求 左边尽头中断");
      return;
    }
    if (!leftDir && _maxScrollWidthShow == _maxScrollWidth) {
      // 右边滑动尽头结束
      KlineUtil.logd("横向滑动画图请求 右边尽头中断");
      return;
    }

    // 这一帧滑动的dx可能超过界限了，需要进行矫正
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
    int startIndex;
    int endIndex;
    var dataMaxLength = source.dataMaxLength;
    if (_maxScrollWidthShow >= _maxScrollWidth) {
      // 最右边，单独处理
      startIndex =
          (dataMaxLength - source.showDataNum).clamp(0, dataMaxLength - 1);
      endIndex = startIndex + source.showDataNum - 1;
    } else {
      startIndex = (_minScrollWidthShow - _minScrollWidth) ~/ pointGapWidth;
      endIndex = startIndex + source.showDataNum - 1;
      int dataMaxIndex = source.dataMaxIndex;
      if (endIndex > dataMaxIndex) {
        endIndex = dataMaxIndex;
        startIndex = dataMaxIndex - source.showDataNum + 1;
      }
    }

    double leftPadding = pointGapWidth -
        double.parse(((_minScrollWidthShow - scrollWidth) % pointGapWidth)
            .toStringAsFixed(2));
    if (leftPadding >= pointGapWidth) {
      leftPadding = 0;
    }
    _padding = EdgeInsets.only(left: leftPadding);
    source.resetShowData(start: startIndex);
    source.notifyListeners();
  }

  /// 根据[startIndex]更新卷轴显示区域值
  /// @param [startIndex] 数据显示的起始索引位置
  void _updateScrollWidthShowByStartDataIndex({
    required int startIndex,
    required int showDataNum,
    required double pointerWidthGap,
  }) {
    int end = startIndex + showDataNum + 1;

    _minScrollWidthShow =
        end * pointerWidthGap + _minScrollWidth - screenMaxWidth;
    _maxScrollWidthShow = _minScrollWidthShow + screenMaxWidth;
  }
}
