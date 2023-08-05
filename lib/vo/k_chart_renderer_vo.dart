import 'package:flutter_kline/vo/candlestick_chart_vo.dart';

import 'line_chart_vo.dart';

class KChartRendererVo {
  final List<CandlestickChartVo?> candlestickChartData;

  final List<LineChartVo?>? lineChartData;

  const KChartRendererVo(
      {required this.candlestickChartData, this.lineChartData});
}
