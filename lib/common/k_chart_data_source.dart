import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/constants/chart_location.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../utils/kline_collection_util.dart';
import '../utils/kline_util.dart';
import '../vo/base_chart_vo.dart';

/// k线图数据源
class KChartDataSource extends ChangeNotifier {
  KChartDataSource({
    required this.data,
    int showDataNum = KlineConfig.showDataDefaultLength,
  }) {
    KlineUtil.logd('KChartDataSource 初始化 - 开始');
    _showDataNum = showDataNum;
    showDataStartIndex = (dataMaxIndex - _showDataNum).clamp(0, dataMaxIndex);
    resetShowData(startIndex: showDataStartIndex);
    KlineUtil.logd('KChartDataSource 初始化 - 结束');
  }

  /// 原始数据，并非页面显示的数据
  late final KChartDataVo data;

  /// 显示的数据
  final KChartDataVo showData =
      KChartDataVo(mainChartData: [], subChartData: []);

  /// 显示数据量
  late int _showDataNum;

  /// 显示数据的开始索引
  int showDataStartIndex = 0;

  /// 图的位置
  ChartLocation chartLocation = ChartLocation.rightmost;

  int get showDataNum => _showDataNum;

  set showDataNum(val) => _showDataNum = val;

  /// 更新图位置，优先级：最右 > 最左 > 中间
  void updateChartLocation(DragUpdateDetails details) {
    var showDataLast = showData.lastData();
    var originDataLast = data.lastData();
    if (showDataLast == originDataLast) {
      // 最右
      chartLocation = ChartLocation.rightmost;
      rightmost();
      return;
    }

    var showDataFirst = showData.firstData();
    var originDataFirst = data.firstData();

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
    data.clearMainChartData();
    showData.clearMainChartData();
  }

  /// 清除数据 - 副图
  void clearSubChartData() {
    data.clearSubChartData();
    showData.clearSubChartData();
  }

  /// 重置显示的数据。
  /// 自动适配
  void resetShowData({int? startIndex}) {
    if (startIndex != null) {
      showDataStartIndex = startIndex;
    }

    int endIndex = (showDataStartIndex + _showDataNum).clamp(0, dataMaxIndex);
    // KlineUtil.logd("最后的数据索引：$endIndex");
    showDataStartIndex = (endIndex - _showDataNum).clamp(0, dataMaxIndex);

    showData.mainChartData.clear();
    for (BaseChartVo data in data.mainChartData) {
      var subData = data.subData(start: showDataStartIndex, end: endIndex + 1);
      showData.mainChartData.add(subData);
    }

    if (KlineCollectionUtil.isNotEmpty(data.subChartData)) {
      showData.subChartData.clear();
      for (List<BaseChartVo> dataList in data.subChartData) {
        List<BaseChartVo> newDataList = [];
        for (BaseChartVo data in dataList) {
          newDataList
              .add(data.subData(start: showDataStartIndex, end: endIndex + 1));
        }
        showData.subChartData.add(newDataList);
      }
    }

    notifyListeners();
  }

  /// 数据最大长度
  int get dataMaxLength {
    int mainDataMaxLength = BaseChartVo.maxDataLength(data.mainChartData);
    List<int> subDataLengths =
        data.subChartData.map((e) => BaseChartVo.maxDataLength(e)).toList();

    subDataLengths.add(mainDataMaxLength);
    return KlineNumUtil.maxMinValue(subDataLengths)?.left.toInt() ?? 0;
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
    required List<BaseChartVo<BaseChartData>> mainCharts,
    required List<List<BaseChartVo<BaseChartData>>> subCharts,
    required bool isEnd,
  }) {
    // 主数据
    _updateMainChart(mainCharts: mainCharts, isEnd: isEnd);
    // 副数据
    _updateSubChart(subCharts: subCharts, isEnd: isEnd);
  }

  /// 更新副图数据
  void _updateSubChart({
    required List<List<BaseChartVo<BaseChartData>>> subCharts,
    required bool isEnd,
  }) {
    if (data.subChartData.isEmpty) {
      // 原副数据为空，直接新增
      data.subChartData.addAll(subCharts);
      return;
    }

    for (int i = 0; i < subCharts.length; ++i) {
      // 是否包含副图
      bool hasSubChart = data.subChartData.hasIndex(i);
      if (!hasSubChart) {
        // 不包含副图，直接添加
        data.subChartData[i] = subCharts[i];
        continue;
      }

      for (int j = 0; j < subCharts[i].length; ++j) {
        bool hasSubChartChild = data.subChartData[i].hasIndex(i);
        if (!hasSubChartChild) {
          // 不包含副图子数据，直接添加
          data.subChartData[i][j] = subCharts[i][j];
          continue;
        }

        List<BaseChartData?> newData = subCharts[i][j].data;
        BaseChartVo<BaseChartData> originData = data.subChartData[i][j];

        for (BaseChartData? data in newData) {
          int indexWhere =
              originData.data.indexWhere((element) => element?.id == data?.id);
          if (indexWhere == -1) {
            isEnd ? originData.data.add(data) : originData.data.insert(0, data);
            continue;
          }
          newData[indexWhere] = data;
        }
      }
    }
  }

  /// 更新主图数据
  void _updateMainChart({
    required List<BaseChartVo<BaseChartData>> mainCharts,
    required bool isEnd,
  }) {
    if (data.mainChartData.isEmpty) {
      // 原主数据为空，直接新增
      data.mainChartData.addAll(mainCharts);
      return;
    }

    for (int i = 0; i < mainCharts.length; ++i) {
      bool hasMainChart = data.mainChartData.hasIndex(i);
      if (hasMainChart) {
        // 原主数据不为空，有对应索引的数据
        List<BaseChartData?> newDataList = mainCharts[i].data;
        BaseChartVo<BaseChartData> originVo = data.mainChartData[i];
        for (BaseChartData? data in newDataList) {
          int indexWhere =
              originVo.data.indexWhere((element) => element?.id == data?.id);
          if (indexWhere == -1) {
            isEnd ? originVo.data.add(data) : originVo.data.insert(0, data);
            continue;
          }
          originVo.data[indexWhere] = data;
        }
      } else {
        // 原主数据不为空，但没有对应索引的数据
        data.mainChartData[i] = mainCharts[i];
      }
    }
  }

}

class KChartDataVo {
  /// 主图数据
  final List<BaseChartVo<BaseChartData>> mainChartData;

  /// 副图数据
  final List<List<BaseChartVo<BaseChartData>>> subChartData;

  KChartDataVo({
    required this.mainChartData,
    required this.subChartData,
  });

  /// 首个图数据
  BaseChartData? firstData() {
    // 找出第一个存在的图数据
    for (BaseChartVo mainChart in mainChartData) {
      if (mainChart.data.isEmpty) {
        continue;
      }

      return mainChart.data.first;
    }

    for (List<BaseChartVo<BaseChartData>> subChart in subChartData) {
      for (BaseChartVo<BaseChartData> subChartChild in subChart) {
        if (subChartChild.data.isEmpty) {
          continue;
        }

        return subChartChild.data.first;
      }
    }

    return null;
  }

  /// 最后图数据
  BaseChartData? lastData() {
    BaseChartData? result;
    int currentMaxIndex = 0;
    for (BaseChartVo mainChart in mainChartData) {
      if (mainChart.data.isEmpty || mainChart.dataLength - 1 < currentMaxIndex) {
        continue;
      }

      result = mainChart.data.last;
    }

    for (List<BaseChartVo<BaseChartData>> subChart in subChartData) {
      for (BaseChartVo<BaseChartData> subChartChild in subChart) {
        if (subChartChild.data.isEmpty || subChartChild.dataLength - 1 < currentMaxIndex) {
          continue;
        }

        result = subChartChild.data.last;
      }
    }


    return result;
  }

  /// 清理数据
  void clearChartData() {
    clearMainChartData();
    clearSubChartData();
  }

  void clearMainChartData() {
    for (BaseChartVo<BaseChartData> mainChart in mainChartData) {
      mainChart.data.clear();
    }
  }

  void clearSubChartData() {
    for (List<BaseChartVo<BaseChartData>> subCharts in subChartData) {
      for (BaseChartVo<BaseChartData> subChart in subCharts) {
        subChart.data.clear();
      }
    }
  }
}
