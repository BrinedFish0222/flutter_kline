import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/common/utils/kline_collection_util.dart';
import 'package:flutter_kline/common/utils/kline_num_util.dart';
import 'package:flutter_kline/common/utils/kline_util.dart';

import '../chart/base_chart.dart';
import '../chart/candlestick_chart.dart';
import 'chart_data.dart';
import 'constants/chart_location.dart';

/// k线图数据源
class KChartDataSource extends ChangeNotifier {
  KChartDataSource({
    this.id = '0',
    required this.originCharts,
    int showDataNum = KlineConfig.showDataDefaultLength,
  }) {
    _showDataNum = showDataNum;
    _resetChartRightmost();
    resetShowData(start: showDataStartIndex);
  }

  String id;

  /// 原始图数据，并非页面显示的数据
  late final List<ChartData> originCharts;

  /// 上一次[originCharts]的长度
  int _dataMaxLengthLast = 0;

  /// 显示的图数据
  final List<ChartData> showCharts = [];

  /// 显示数据量
  late int _showDataNum;

  /// 显示数据的开始索引
  int showDataStartIndex = 0;

  /// 图的位置
  ChartLocation chartLocation = ChartLocation.rightmost;

  /// 上一次更新数据的方向
  ValueNotifier<bool> isEndLast = ValueNotifier(true);

  int get dataMaxLengthLast => _dataMaxLengthLast;

  /// 获取显示图首个时间
  /// 规则：第一张图，找出蜡烛图（没有蜡烛，直接取第一张图），获取对应的首个时间
  DateTime? get showChartStartDateTime {
    BaseChart? chart = _getShowCandlestickChart;
    chart ??= showCharts.first.baseCharts.first;
    return KlineCollectionUtil.first(chart.data)?.dateTime;
  }

  /// 获取显示图最后时间
  /// 规则：第一张图，找出蜡烛图（没有蜡烛，直接取第一张图），获取对应的首个时间
  DateTime? get showChartEndDateTime {
    BaseChart? chart = _getShowCandlestickChart;
    chart ??= showCharts.first.baseCharts.first;
    return KlineCollectionUtil.last(chart.data)?.dateTime;
  }

  /// 根据索引获取显示图的时间
  /// 规则：第一张图，找出蜡烛图（没有蜡烛，直接取第一张图），获取对应的首个时间
  DateTime? showChartDateTimeByIndex(int index) {
    BaseChart? chart = _getShowCandlestickChart;
    chart ??= showCharts.first.baseCharts.first;

    if (!chart.data.hasIndex(index)) {
      return null;
    }

    return chart.data[index]?.dateTime;
  }

  /// 获取显示的蜡烛图
  /// 规则：第一张图，找出蜡烛图
  CandlestickChart? get _getShowCandlestickChart {
    List<BaseChart> firstChart = showCharts.first.baseCharts;
    if (firstChart.isEmpty) {
      return null;
    }

    // 寻找蜡烛图
    List<CandlestickChart> candlestickChart =
        firstChart.whereType<CandlestickChart>().toList();
    if (candlestickChart.isEmpty) {
      return null;
    }

    return candlestickChart.first;
  }

  /// 重置图在最右边
  void _resetChartRightmost() {
    var maxLength = dataMaxLength;
    _resetShowDataStartIndexByEnd(maxLength);

    chartLocation = ChartLocation.rightmost;
  }

  int get showDataNum => _showDataNum;

  ChartData? get mainChartShow => showCharts.isEmpty ? null : showCharts.first;

  List<BaseChart<BaseChartData>> get mainChartBaseCharts =>
      originCharts.isEmpty ? [] : originCharts.first.baseCharts;

  List<BaseChart<BaseChartData>> get mainChartBaseChartsShow =>
      showCharts.isEmpty ? [] : showCharts.first.baseCharts;

  List<ChartData> get subChartsShow {
    if (showCharts.isEmpty || showCharts.length == 1) {
      return [];
    }

    var result = showCharts.sublist(1).toList();
    return result;
  }

  List<List<BaseChart>> get subChartBaseCharts {
    if (originCharts.isEmpty || originCharts.length == 1) {
      return [];
    }

    return originCharts.sublist(1).map((e) => e.baseCharts).toList();
  }

  List<List<BaseChart>> get subChartBaseChartsShow {
    if (showCharts.isEmpty || showCharts.length == 1) {
      return [];
    }

    var result = showCharts.sublist(1).map((e) => e.baseCharts).toList();
    return result;
  }

  set showDataNum(val) => _showDataNum = val;

  /// 更新图位置，优先级：最右 > 最左 > 中间
  void updateChartLocation() {
    BaseChartData? originDataLast = ChartData.lastDataBatch(originCharts);
    BaseChartData? showDataLast = ChartData.lastDataBatch(showCharts);

    if (showDataLast == originDataLast) {
      // 最右
      chartLocation = ChartLocation.rightmost;
      rightmost();
      return;
    }

    BaseChartData? originDataFirst = ChartData.firstDataBatch(originCharts);
    BaseChartData? showDataFirst = ChartData.firstDataBatch(showCharts);

    if (showDataFirst == originDataFirst) {
      // 最左
      chartLocation = ChartLocation.leftmost;
      leftmost();
      return;
    }

    // 中间
    chartLocation = ChartLocation.centre;
    centre();
  }

  /// 更新UI
  /// 如果图位置是右边，设置显示图数据的开始位置
  @override
  void notifyListeners() {
    if (chartLocation == ChartLocation.rightmost) {
      KlineUtil.logd('KChartDataSource notifyListeners rightmost');
      _resetShowDataStartIndexByEnd(dataMaxLength);
      resetShowData(start: showDataStartIndex);
    }

    super.notifyListeners();
  }

  /// 开始索引位置重置，位置依据end
  _resetShowDataStartIndexByEnd(int end) {
    showDataStartIndex = end - showDataNum;
    if (showDataStartIndex < 0) {
      showDataStartIndex = 0;
    }
  }

  /// 清除图
  /// [index] -1表示清除所有
  void clearCharts({int index = -1}) {
    if (index == -1) {
      originCharts.clear();
      showCharts.clear();
    }

    if (index != -1 && originCharts.hasIndex(index)) {
      originCharts.removeAt(index);
      showCharts.removeAt(index);
    }

    notifyListeners();
  }

  /// 清除数据 - 全部
  /// [index] -1表示清除所有
  void clearChartData({int index = -1}) {
    if (index == -1 || index == 0) {
      _clearMainChartData();
    }

    if (index > 0) {
      _clearSubChartData(index: index - 1);
    }

    notifyListeners();
  }

  /// 清除数据 - 主图
  void _clearMainChartData() {
    if (originCharts.isNotEmpty) {
      originCharts.first.clearChartData();
    }

    _clearShowMainChartData();
  }

  /// 清除数据 - 显示的主图
  void _clearShowMainChartData() {
    if (showCharts.isNotEmpty) {
      showCharts.first.clearChartData();
    }
  }

  /// 清除数据 - 副图
  void _clearSubChartData({int index = -1}) {
    // 按索引清除源数据
    if (index != -1 &&
        originCharts.isNotEmpty &&
        originCharts.hasIndex(index + 1)) {
      originCharts.sublist(1)[index].clearChartData();
    }
    // 按索引清除显示数据
    if (index != -1 &&
        showCharts.isNotEmpty &&
        showCharts.hasIndex(index + 1)) {
      showCharts.sublist(1)[index].clearChartData();
    }

    if (index != -1) {
      return;
    }

    // 清除全部
    if (originCharts.isNotEmpty && originCharts.length != 1) {
      originCharts.sublist(1).forEach((subChart) {
        subChart.clearChartData();
      });
    }

    if (showCharts.isNotEmpty && showCharts.length != 1) {
      showCharts.sublist(1).forEach((subChart) {
        subChart.clearChartData();
      });
    }
  }

  /// 重置显示的数据。
  /// 自动适配
  void resetShowData({int? start}) {
    if (start != null) {
      showDataStartIndex = start;
    }

    var maxLength = dataMaxLength;
    int end = (showDataStartIndex + _showDataNum).clamp(0, maxLength);
    _resetShowDataStartIndexByEnd(end);

    showCharts.clear();
    for (ChartData chartData in originCharts) {
      showCharts.add(chartData.subData(start: showDataStartIndex, end: end));
    }

    updateChartLocation();
    // TODO 不可设置，需要更新调用 [notifyListeners()]
    // notifyListeners();
  }

  /// 数据最大长度
  int get dataMaxLength {
    List<int> maxLengthList = originCharts.map((e) => e.dataMaxLength).toList();
    return KlineNumUtil.maxMinValue(maxLengthList)?.left.toInt() ?? 0;
  }

  /// 数据最大索引位置
  int get dataMaxIndex {
    int maxLength = dataMaxLength;
    if (maxLength == 0) {
      return 0;
    }

    return dataMaxLength - 1;
  }

  /// 最左时触发
  void leftmost() {
    // KlineUtil.logd('图处于最左边');
  }

  /// 最右时触发
  void rightmost() {
    // KlineUtil.logd('图处于最右边');
  }

  /// 中间时触发
  void centre() {
    // KlineUtil.logd('图处于中间');
  }

  /// 更新数据
  /// [isEnd] 数据是加到前还是后面
  void updateData({
    required List<ChartData> newCharts,
    required bool isEnd,
  }) {
    try {
      if (newCharts.isEmpty) {
        return;
      }

      // 记录旧长度
      _dataMaxLengthLast = dataMaxLength;
      isEndLast.value = isEnd;

      // 原副数据为空，直接新增
      if (originCharts.isEmpty) {
        originCharts.addAll(newCharts);
        _resetChartRightmost();
        return;
      }

      // 新数据应该与原数据保持同一个格式，否则表示有的图被替换/移除了
      if (originCharts.length > newCharts.length) {
        originCharts.length = newCharts.length;
      } else if (originCharts.length < newCharts.length) {
        int diffLength = newCharts.length - originCharts.length;
        for (int i = 0; i < diffLength; ++i) {
          originCharts.add(ChartData(
              id: (originCharts.length - 1).toString(), baseCharts: []));
        }
      }

      for (int i = 0; i < newCharts.length; ++i) {
        bool hasOriginChart = originCharts.hasIndex(i);
        if (!hasOriginChart) {
          originCharts.add(newCharts[i]);
          continue;
        }

        if (originCharts[i].id != newCharts[i].id) {
          // 图被替换了，数据直接替换
          originCharts[i] = newCharts[i];
          continue;
        }

        // 同一张图
        originCharts[i].updateDataBy(newCharts[i], isEnd: isEnd);
      }
    } finally {
      isEndLast.notifyListeners();
    }
  }
}
