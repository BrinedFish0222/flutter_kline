import 'package:flutter/material.dart';
import 'package:flutter_kline/common/kline_config.dart';

import '../chart/candlestick_chart.dart';
import '../common/utils/kline_date_util.dart';

/// 蜡烛图显示数据
class CandlestickShowDataWidget extends StatelessWidget {
  const CandlestickShowDataWidget({
    super.key,
    required this.vo,
    this.builder,
  });

  final CandlestickChartData vo;

  final double _leftPadding = 10;

  final Widget Function(CandlestickChartData data)? builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      color: const Color(0xFFF5F5F5),
      child: builder == null ? _defaultWidget : builder!(vo),
    );
  }

  Widget get _defaultWidget {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _leftPadding,
        ),
        Expanded(
          child: Text(
            KlineDateUtil.formatDate(date: vo.dateTime),
            style: const TextStyle(
                color: Colors.black, fontSize: KlineConfig.showDataFontSize),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '开 ${vo.open.toStringAsFixed(2)}',
                style:
                const TextStyle(fontSize: KlineConfig.showDataFontSize),
              ),
              Text('收 ${vo.close.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: KlineConfig.showDataFontSize)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('高 ${vo.high.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: KlineConfig.showDataFontSize)),
              Text('低 ${vo.low.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: KlineConfig.showDataFontSize)),
            ],
          ),
        ),
        SizedBox(
          width: _leftPadding,
        ),
      ],
    );
  }
}
