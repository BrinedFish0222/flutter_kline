import 'package:flutter_kline/utils/kline_num_util.dart';

import '../common/pair.dart';

/// 蜡烛图数据vo
class CandlestickChartVo {
  final double open;
  final double close;
  final double high;
  final double low;

  const CandlestickChartVo(
      {required this.open,
      required this.close,
      required this.high,
      required this.low});

  static Pair<double, double> getHeightRange(
      List<CandlestickChartVo?> candlestickCharData) {
    Pair<double, double> result =
        Pair(left: -double.maxFinite, right: double.maxFinite);

    for (var candlestickData in candlestickCharData) {
      if (candlestickData == null) {
        continue;
      }

      var maxMinValue = KlineNumUtil.maxMinValue([
        candlestickData.open,
        candlestickData.close,
        candlestickData.high,
        candlestickData.low
      ]);

      result.left = result.left < maxMinValue!.left
          ? maxMinValue.left.toDouble()
          : result.left;

      result.right = result.right > maxMinValue.right
          ? maxMinValue.right.toDouble()
          : result.right;
    }

    return result;
  }
}
