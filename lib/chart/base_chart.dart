import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

import '../common/pair.dart';
import '../common/utils/kline_collection_util.dart';
import '../common/utils/kline_num_util.dart';
import 'bar_chart.dart';
import 'candlestick_chart.dart';
import '../common/chart_show_data_item_vo.dart';

/// 图数据基类
abstract class BaseChart<T extends BaseChartData> {
  String id;
  String? name;

  /// 最大值
  double? maxValue;

  /// 最小值
  /// 柱图如果不支持负数，设置成0。
  double? minValue;

  List<T?> data = [];

  /// 是否是用户自定义的画线。
  bool isUserDefine;

  BaseChart({
    required this.id,
    this.name,
    this.maxValue,
    this.minValue,
    required this.data,
    this.isUserDefine = false,
  });

  /// 画图
  void paint({
    required Canvas canvas,
    required Size size,
    required Pair<double, double> maxMinValue,
    required double pointWidth,
    required double pointGap,
    required EdgeInsets padding,
  });

  /// 更新数据
  void updateDataBy(BaseChart newBaseChart, {bool isEnd = true}) {
    if (newBaseChart.data.isEmpty) {
      return;
    }

    for (int i = 0; i < newBaseChart.data.length; ++i) {
      BaseChartData? newData = newBaseChart.data[i];
      if (newData == null) {
        isEnd ? data.add(null) : data.insert(0, null);
        continue;
      }

      _updateDataById(newData, isEnd: isEnd);
    }
  }

  /// 根据ID更新数据
  void _updateDataById(BaseChartData newData, {required bool isEnd}) {
    bool replaceWhereFlag = KlineCollectionUtil.replaceWhere(
        dataList: data, test: (d) => d?.id == newData.id, element: newData);
    if (replaceWhereFlag) {
      return;
    }

    if (newData is T) {
      data.add(newData);
    }
  }

  int get dataIndex => dataLength - 1;

  /// 获取整个图**所有**选中显示的数据集合
  List<ChartShowDataItemVo?>? getSelectedShowData();

  /// 是否是可选中显示的数据
  bool isSelectedShowData() {
    return true;
  }

  /// 获取最大最小值。
  /// 左  最大值；右 最小值。
  Pair<double, double> getMaxMinData();

  /// 子数据
  BaseChart subData({required int start, int? end}) {
    var newVo = copy();
    if (end != null && end > newVo.data.length) {
      var maxLength = end - newVo.data.length;
      for (int i = 0; i < maxLength; ++i) {
        newVo.data.add(null);
      }
    }
    newVo.data = newVo.data.sublist(start, end);
    return newVo;
  }

  /// 复制
  BaseChart copy();

  int get dataLength;

  /// 根据index获取数据值
  double? getDataMaxValueByIndex(int index);

  /// 获取最后一根显示的数据
  static List<ChartShowDataItemVo>? getLastShowData(List<BaseChart>? voList) {
    if (KlineCollectionUtil.isEmpty(voList)) {
      return null;
    }

    return getSelectedShowDataByIndex(chartData: voList!, index: -1)
        ?.where((e) => e != null)
        .cast<ChartShowDataItemVo>()
        .toList();
  }

  static List<ChartShowDataItemVo>? getShowDataByIndex(
      List<BaseChart>? voList, int index) {
    if (KlineCollectionUtil.isEmpty(voList)) {
      return null;
    }

    return voList!
        .where((e) => KlineCollectionUtil.isNotEmpty(e.getSelectedShowData()))
        .map((e) => e.getSelectedShowData()![index])
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  static Pair<double, double> maxMinValue(List<BaseChart> dataList) {
    var hasBarChart = dataList.any((element) => element is BarChart);

    dataList.map((e) {
      var maxMinData = e.getMaxMinData();
      return maxMinData;
    }).toList();

    var result =
        Pair.getMaxMinValue(dataList.map((e) => e.getMaxMinData()).toList());
    if (hasBarChart && result.right > 0) {
      result.right = 0;
    }

    if (result.left == -double.maxFinite && result.right == double.maxFinite) {
      result = KlineConfig.defaultMaxMinValue;
    }

    return result;
  }

  /// 获取蜡烛图数据
  static CandlestickChart? getCandlestickChartVo(List<BaseChart> dataList) {
    bool hasCandlestick =
        dataList.any((element) => element is CandlestickChart);
    if (!hasCandlestick) {
      return null;
    }

    return dataList.firstWhere((element) => element is CandlestickChart)
        as CandlestickChart;
  }

  /// 根据索引获取数据
  /// [index] 如果是-1，则是最后一个。
  static List<ChartShowDataItemVo?>? getSelectedShowDataByIndex({
    required List<BaseChart<BaseChartData>> chartData,
    required int index,
  }) {
    bool isLast = index == -1;
    return chartData.where((element) => element.isSelectedShowData()).map((e) {
      try {
        return isLast
            ? e.getSelectedShowData()?.last
            : e.getSelectedShowData()?[index];
      } catch (e) {
        return null;
      }
    }).toList();
  }

  /// 最大数据长度
  static int maxDataLength(List<BaseChart<BaseChartData>> mainChartData) {
    var dataLengths = mainChartData.map((e) => e.dataLength).toList();
    return KlineNumUtil.maxMinValue(dataLengths)?.left.toInt() ?? 0;
  }

  /// 自动补全数据
  BaseChart<BaseChartData> autoCompleteData({
    required int maxLength,
    required int currentIndex,
  }) {
    var newVo = copy();
    newVo.data.clear();
    for (int i = 0; i < maxLength; ++i) {
      newVo.data.add(null);
    }

    newVo.data.replaceRange(currentIndex, currentIndex + this.data.length, this.data);
    return newVo;
  }
}

/// 图基础数据
/// 使用场景：一根线上一个点的信息
abstract class BaseChartData<T> {
  String id;
  DateTime dateTime;
  Color? color;
  T? extrasData;

  BaseChartData({
    required this.id,
    DateTime? dateTime,
    this.color,
    this.extrasData,
  }) : dateTime = dateTime ?? DateTime.now();
}
