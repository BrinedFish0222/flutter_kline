import 'package:example_network/main.dart';
import 'package:example_network/vo/response_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/base_chart.dart';
import 'package:flutter_kline/chart/candlestick_chart.dart';
import 'package:flutter_kline/common/chart_data.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/utils/kline_util.dart';
import 'package:flutter_kline/widget/k_chart_widget.dart';

/// 日K网络组件示例
class ExampleDayNetworkWidget extends StatefulWidget {
  const ExampleDayNetworkWidget({
    super.key,
    required this.overlayEntryLocationKey,
  });

  final GlobalKey overlayEntryLocationKey;

  @override
  State<ExampleDayNetworkWidget> createState() =>
      _ExampleDayNetworkWidgetState();
}

class _ExampleDayNetworkWidgetState extends State<ExampleDayNetworkWidget> {
  late KChartDataSource _source;

  @override
  void initState() {
    _source = KChartDataSource(
      originCharts: [
        ChartData(id: '0', name: 'MA', baseCharts: [
          CandlestickChart(data: [], id: 'MA'),
          // ...ExampleLineData.getLineChartMA13(),
          // ExampleBadgeData.badgeChartVo,
        ]),
        /* ChartData(id: '1', name: 'VOL', baseCharts: [
          ExampleVolData.barChartData..minValue = 0,
          ...ExampleVolData.lineChartData,
          ExampleBadgeData.badgeChartVo,
        ]),
        ChartData(id: '2', name: 'RMO', baseCharts: [ExampleRmoData.barChartData..barWidth = 4]),
        ChartData(id: '3', name: 'MACD', baseCharts: ExampleMacdData.macd),
        ChartData(id: '4', name: 'ESS', baseCharts: [
          ExampleEssData.barChartData
            ..barWidth = 2
            ..minValue = 0,
          ExampleEssData.lineChartA,
          ExampleEssData.lineChartB
        ]), */
      ],
    );

    webSocketChannelStream.listen((data) {
      if (data == null) {
        return;
      }

      ResponseResult responseResult = responseResultFromJson(data);
      // KlineUtil.logd('日K initState responseResult type：${responseResult.type}');
      List<BaseChart> dataList = responseResult.parseDayData(type: 'daySingle');
      if (dataList.isEmpty) {
        return;
      }
      KlineUtil.logd('更新日K数据，数据长度：${dataList.first.dataLength}');
      _source.updateData(
          newCharts: [ChartData(id: '0', baseCharts: dataList)], isEnd: true);
      _source.notifyListeners();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KChartWidget(
      source: _source,
      onTapIndicator: (val) {
        KlineUtil.showToast(context: context, text: '指标索引位置：$val');
      },
      overlayEntryLocationKey: widget.overlayEntryLocationKey,
      drawChartCallback: (value) {},
    );
  }
}
