import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

enum ChartType {
  /// 空白
  blank,

  /// 线图
  line,
  ;

  static ChartType getType(BaseChartVo? vo) {
    if (vo == null) {
      return ChartType.blank;
    }

    if (vo is LineChartVo) {
      return ChartType.line;
    }

    return ChartType.blank;
  }
}
