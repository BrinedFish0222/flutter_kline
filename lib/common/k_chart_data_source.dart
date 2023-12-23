import 'package:flutter/foundation.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../utils/kline_collection_util.dart';
import '../utils/kline_util.dart';
import '../vo/base_chart_vo.dart';

/// k线图数据源
abstract class KChartDataSource extends ChangeNotifier {
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

  late final KChartDataVo data;

  /// 显示的数据
  final KChartDataVo showData =
      KChartDataVo(mainChartData: [], subChartData: []);
  late int _showDataNum;

  /// 显示数据的开始索引
  int showDataStartIndex = 0;

  int get showDataNum => _showDataNum;

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
    if (startIndex == null) {
      showDataStartIndex = showDataStartIndex;
    } else {
      showDataStartIndex = startIndex;
    }

    int endIndex = (showDataStartIndex + _showDataNum).clamp(0, dataMaxIndex);
    KlineUtil.logd("最后的数据索引：$endIndex");
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
    List<int> subdataLengths =
        data.subChartData.map((e) => BaseChartVo.maxDataLength(e)).toList();

    subdataLengths.add(mainDataMaxLength);
    return KlineNumUtil.maxMinValue(subdataLengths)?.left.toInt() ?? 0;
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
  void leftmost();

  /// 最右时触发
  void rightmost();

  /// 更新数据
  /// [isAddMode] 是否是添加模式
  /// [isEnd] 数据是加到前还是后面
  void updateData({
    required List<BaseChartVo<BaseChartData>> mainChartData,
    required List<List<BaseChartVo<BaseChartData>>> subChartData,
    required bool isAddMode,
    required bool isEnd,
  }) {
    if (isAddMode) {
      _addData(
        mainChartData: mainChartData,
        subChartData: subChartData,
        isEnd: isEnd,
      );
    } else {
      _updateData(
        mainChartData: mainChartData,
        subChartData: subChartData,
        isEnd: isEnd,
      );
    }
  }

  /// 新增数据
  void _addData({
    required List<BaseChartVo<BaseChartData>> mainChartData,
    required List<List<BaseChartVo<BaseChartData>>> subChartData,
    required bool isEnd,
  }) {
    // 主数据
    for (int i = 0; i < mainChartData.length; ++i) {
      List<BaseChartData?> newData = mainChartData[i].data;
      BaseChartVo<BaseChartData> originData = data.mainChartData[i];
      for (var newD in newData) {
        isEnd ? originData.data.add(newD) : originData.data.insert(0, newD);
      }
    }

    // 副数据
    for (int i = 0; i < subChartData.length; ++i) {
      for (int j = 0; j < subChartData[i].length; ++j) {
        var newData = subChartData[i][j].data;
        var originData = data.subChartData[i][j];
        isEnd
            ? originData.data.addAll(newData)
            : originData.data.insertAll(0, newData);
      }
    }
  }

  /// 更新数据
  void _updateData({
    required List<BaseChartVo<BaseChartData>> mainChartData,
    required List<List<BaseChartVo<BaseChartData>>> subChartData,
    required bool isEnd,
  }) {
    // 主数据
    for (int i = 0; i < mainChartData.length; ++i) {
      List<BaseChartData?> newData = mainChartData[i].data;
      var originData = data.mainChartData[i];

      for (BaseChartData? data in newData) {
        var indexWhere =
            originData.data.indexWhere((element) => element?.id == data?.id);
        if (indexWhere == -1) {
          isEnd ? originData.data.add(data) : originData.data.insert(0, data);
          continue;
        }
        newData[indexWhere] = data;
      }
    }

    // 副数据
    for (int i = 0; i < subChartData.length; ++i) {
      for (int j = 0; j < subChartData[i].length; ++j) {
        List<BaseChartData?> newData = subChartData[i][j].data;
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
