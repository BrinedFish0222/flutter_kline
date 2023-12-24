import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/constants/chart_location.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_data.dart';

import '../utils/kline_collection_util.dart';
import '../utils/kline_util.dart';

/// k线图数据源
class KChartDataSource extends ChangeNotifier {
  KChartDataSource({
    required this.originCharts,
    int showDataNum = KlineConfig.showDataDefaultLength,
  }) {
    KlineUtil.logd('KChartDataSource 初始化 - 开始');
    _showDataNum = showDataNum;
    var maxIndex = dataMaxIndex;
    showDataStartIndex = (maxIndex - _showDataNum).clamp(0, maxIndex);
    resetShowData(startIndex: showDataStartIndex);
    KlineUtil.logd('KChartDataSource 初始化 - 结束');
  }

  /// 原始图数据，并非页面显示的数据
  late final List<ChartData> originCharts;

  /// 显示的图数据
  final List<ChartData> showCharts = [];

  /// 显示数据量
  late int _showDataNum;

  /// 显示数据的开始索引
  int showDataStartIndex = 0;

  /// 图的位置
  ChartLocation chartLocation = ChartLocation.rightmost;

  int get showDataNum => _showDataNum;

  ChartData? get mainChartShow => showCharts.isEmpty ? null : showCharts.first;

  List<BaseChartVo<BaseChartData>> get mainChartBaseCharts => originCharts.isEmpty ? [] : originCharts.first.baseCharts;

  List<BaseChartVo<BaseChartData>> get mainChartBaseChartsShow => showCharts.isEmpty ? [] : showCharts.first.baseCharts;

  List<ChartData> get subChartsShow {
    if (showCharts.isEmpty || showCharts.length == 1) {
      return [];
    }

    var result = showCharts.sublist(1).toList();
    return result;
  }

  List<List<BaseChartVo>> get subChartBaseCharts {
    if (originCharts.isEmpty || originCharts.length == 1) {
      return [];
    }

    return originCharts.sublist(1).map((e) => e.baseCharts).toList();
  }

  List<List<BaseChartVo>> get subChartBaseChartsShow {
    if (showCharts.isEmpty || showCharts.length == 1) {
      return [];
    }

    var result = showCharts.sublist(1).map((e) => e.baseCharts).toList();
    return result;
  }

  set showDataNum(val) => _showDataNum = val;

  /// 更新图位置，优先级：最右 > 最左 > 中间
  void updateChartLocation(DragUpdateDetails details) {
    // var showDataLast = showData.lastData();
    // var originDataLast = data.lastData();

    BaseChartData? originDataLast = ChartData.lastDataBatch(originCharts);
    BaseChartData? showDataLast = ChartData.lastDataBatch(showCharts);

    if (showDataLast == originDataLast) {
      // 最右
      chartLocation = ChartLocation.rightmost;
      rightmost();
      return;
    }

    // var showDataFirst = showData.firstData();
    // var originDataFirst = data.firstData();

    BaseChartData? originDataFirst = ChartData.firstDataBatch(originCharts);
    BaseChartData? showDataFirst = ChartData.firstDataBatch(showCharts);

    if (showDataFirst == originDataFirst)  {
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
      showDataStartIndex = (dataMaxIndex - _showDataNum).clamp(0, dataMaxIndex);
      resetShowData(startIndex: showDataStartIndex);
    }

    super.notifyListeners();
  }

  /// 清除数据 - 全部
  void clearChartData() {
    clearMainChartData();
    clearSubChartData();
  }

  /// 清除数据 - 主图
  void clearMainChartData() {
    if (originCharts.isNotEmpty) {
      originCharts.first.clearChartData();
    }

    clearShowMainChartData();
  }

  /// 清除数据 - 显示的主图
  void clearShowMainChartData() {
    if (showCharts.isNotEmpty) {
      showCharts.first.clearChartData();
    }
  }

  /// 清除数据 - 副图
  void clearSubChartData() {
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
  void resetShowData({int? startIndex}) {
    if (startIndex != null) {
      showDataStartIndex = startIndex;
    }

    int endIndex = (showDataStartIndex + _showDataNum).clamp(0, dataMaxIndex);
    showDataStartIndex = (endIndex - _showDataNum).clamp(0, dataMaxIndex);

    showCharts.clear();
    for (ChartData chartData in originCharts) {
      showCharts.add(chartData.subData(start: showDataStartIndex, end: endIndex + 1));
    }

    // 不可设置，需要更新调用 [notifyListeners()]
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
    KlineUtil.logd('图处于最左边');
  }

  /// 最右时触发
  void rightmost() {
    KlineUtil.logd('图处于最右边');
  }

  /// 中间时触发
  void centre() {
    KlineUtil.logd('图处于中间');
  }

  /// 更新数据
  /// [isEnd] 数据是加到前还是后面
  void updateData({
    required List<ChartData> newCharts,
    required bool isEnd,
  }) {
    if (newCharts.isEmpty) {
      return;
    }

    // 原副数据为空，直接新增
    if (originCharts.isEmpty) {
      originCharts.addAll(newCharts);
      return;
    }

    for (ChartData chart in newCharts) {
      // 源数据
      ChartData? originChart = KlineCollectionUtil.firstWhere(originCharts, (element) => element.id == chart.id);

      // 不包含图，直接添加
      if (originChart == null) {
        originCharts.add(chart);
        continue;
      }

      originChart.updateDataBy(chart, isEnd: isEnd);
    }
  }


}