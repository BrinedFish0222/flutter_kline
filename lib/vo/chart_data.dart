import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

/// 图数据
class ChartData {
  final String id;
  final String name;

  /// 图数据
  final List<BaseChartVo> baseCharts;

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

    for (BaseChartVo chart in baseCharts) {
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
    List<BaseChartVo>? charts,
  }) {
    return ChartData(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCharts: charts ?? KlineCollectionUtil.sublist(list: this.baseCharts, start: 0) ?? [],
    );
  }


  ChartData subData({required int start, int? end}) {
    List<BaseChartVo> chartsNew = baseCharts.map((e) => e.subData(start: start, end: end)).toList();
    return copyWith(charts: chartsNew);
  }

  /// 第一个存在的图数据
  BaseChartData? firstData() {
    for (BaseChartVo chart in baseCharts) {
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

    for (BaseChartVo chart in baseCharts) {
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

    // 无数据更新
    if (newChart.baseCharts.isEmpty) {
      return;
    }

    for (int i = 0; i < newChart.baseCharts.length; ++i) {
      BaseChartVo newBaseChart = newChart.baseCharts[i];
      if (newBaseChart.id != null) {
        // ID 非空更新逻辑
        _updateBaseChartById(newBaseChart, isEnd: isEnd);
        continue;
      }

      _updateBaseChartByIndex(newBaseChart: newBaseChart, index: i, isEnd: isEnd);
    }

    for (BaseChartVo newBaseChart in newChart.baseCharts) {
      if (newBaseChart.id != null) {
        // ID 非空更新逻辑
        _updateBaseChartById(newBaseChart, isEnd: isEnd);
        continue;
      }


    }
  }

  /// 根据索引位置更新数据
  /// 如果源数据对应索引没有数据，则新增
  /// 如果源数据对应索引有数据，则更新
  /// @param [newBaseChart] 新数据
  /// @param [index] 当前索引
  /// @param [isEnd] 新增数据的位置
  void _updateBaseChartByIndex({required BaseChartVo<BaseChartData> newBaseChart, required int index, required bool isEnd}) {
    bool hasIndex = baseCharts.hasIndex(index);
    if (!hasIndex) {
      isEnd ? baseCharts.add(newBaseChart) : baseCharts.insert(0, newBaseChart);
      return;
    }

    BaseChartVo originBaseChart = baseCharts[index];
    originBaseChart.updateDataBy(newBaseChart);
  }

  /// 根据ID更新基础图数据
  void _updateBaseChartById(BaseChartVo newBaseChart, {bool isEnd = true}) {
    if (newBaseChart.id == null) {
      return;
    }

    BaseChartVo? originBaseChart = KlineCollectionUtil.firstWhere(baseCharts, (element) => element.id == newBaseChart.id);
    if (originBaseChart == null) {
      baseCharts.add(newBaseChart);
      return;
    }

    originBaseChart.updateDataBy(newBaseChart, isEnd: isEnd);
  }






}
