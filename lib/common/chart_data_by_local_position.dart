
import 'package:flutter_kline/common/utils/kline_util.dart';

/// 用于 [KlineUtil.getChartDataByLocalPosition]
class ChartDataByLocalPosition {
  final int index;
  final DateTime dateTime;
  final double value;

  const ChartDataByLocalPosition({
    required this.index,
    required this.dateTime,
    required this.value,
  });
}
