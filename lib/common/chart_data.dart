
import 'package:flutter_kline/common/utils/kline_collection_util.dart';

import '../chart/base_chart.dart';

/// 图数据
class ChartData {
  final String id;
  final String name;

  /// 图数据
  final List<BaseChart> baseCharts;

  const ChartData({
    required this.id,
    this.name = '无指标',
    required this.baseCharts,
  });

  int get dataMaxLength => dataMaxIndex + 1;

  int get dataMaxIndex {
    int currentMaxIndex = -1;
    if (baseCharts.isEmpty) {
      return currentMaxIndex;
    }

    for (BaseChart chart in baseCharts) {
      if (chart.data.isEmpty) {
        continue;
      }

      if (chart.dataIndex <= currentMaxIndex) {
        continue;
      }

      currentMaxIndex = chart.dataIndex;
    }

    return currentMaxIndex;
  }

  ChartData copyWith({
    String? id,
    String? name,
    List<BaseChart>? charts,
  }) {
    return ChartData(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCharts: charts ?? KlineCollectionUtil.sublist(list: baseCharts, start: 0) ?? [],
    );
  }


  ChartData subData({required int start, int? end}) {
    List<BaseChart> chartsNew = baseCharts.map((e) => e.subData(start: start, end: end)).toList();
    return copyWith(charts: chartsNew);
  }

  /// 第一个存在的图数据
  BaseChartData? firstData() {
    for (BaseChart chart in baseCharts) {
      if (chart.data.isEmpty || chart.data.first == null) {
        continue;
      }

      return chart.data.first;
    }

    return null;
  }

  /// @see [firstData]
  static BaseChartData? firstDataBatch(List<ChartData>? dataList) {
    if (dataList == null || dataList.isEmpty) {
      return null;
    }

    int currentMaxIndex = 0;
    BaseChartData? result;
    for (ChartData data in dataList) {
      int maxIndex = data.dataMaxIndex;
      if (maxIndex < currentMaxIndex) {
        continue;
      }

      result = data.firstData();
    }

    return result;
  }


  /// 图最后的数据
  BaseChartData? lastData() {
    BaseChartData? result;
    int currentMaxIndex = 0;

    for (BaseChart chart in baseCharts) {
      if (chart.data.isEmpty || chart.dataLength - 1 < currentMaxIndex) {
        continue;
      }

      result = chart.data.last;
      currentMaxIndex = chart.dataLength - 1;
    }

    return result;
  }


  static BaseChartData? lastDataBatch(List<ChartData>? dataList) {
    if (dataList == null || dataList.isEmpty) {
      return null;
    }

    int currentMaxIndex = 0;
    BaseChartData? result;
    for (ChartData data in dataList) {
      int maxIndex = data.dataMaxIndex;
      if (maxIndex < currentMaxIndex) {
        continue;
      }

      result = data.lastData();
    }

    return result;
  }


  /// 清理数据
  void clearChartData() {
    if (baseCharts.isEmpty) {
      return;
    }

    for (var chart in baseCharts) {
      chart.data.clear();
    }
  }

  /// 更新数据
  void updateDataBy(ChartData newChart, {bool isEnd = true}) {
    if (newChart.id != id) {
      return;
    }

    // 清空数据
    if (newChart.baseCharts.isEmpty) {
      baseCharts.clear();
      return;
    }

    for (BaseChart newBaseChart in newChart.baseCharts) {
      _updateBaseChartById(newBaseChart, isEnd: isEnd);
    }
  }


  /// 根据ID更新基础图数据
  void _updateBaseChartById(BaseChart newBaseChart, {bool isEnd = true}) {
    BaseChart? originBaseChart = KlineCollectionUtil.firstWhere(baseCharts, (element) => element.id == newBaseChart.id);
    if (originBaseChart == null) {
      baseCharts.add(newBaseChart);
      return;
    }

    originBaseChart.updateDataBy(newBaseChart, isEnd: isEnd);
  }






}
