import 'package:example_network/main.dart';
import 'package:example_network/vo/response_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/common/kline_config.dart';
import 'package:flutter_kline/example/example_macd_data.dart';
import 'package:flutter_kline/example/example_rmo_data.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
import 'package:flutter_kline/widget/k_minute_chart_widget.dart';

class ExampleMinuteNetworkWidget extends StatefulWidget {
  const ExampleMinuteNetworkWidget(
      {super.key, required this.candlestickOverlayEntryLocationKey});
  final GlobalKey candlestickOverlayEntryLocationKey;

  @override
  State<ExampleMinuteNetworkWidget> createState() =>
      _ExampleMinuteNetworkWidgetState();
}

class _ExampleMinuteNetworkWidgetState
    extends State<ExampleMinuteNetworkWidget> {
  late KChartDataSource _source;
  final LineChartVo _vo = LineChartVo(data: []);

  @override
  void initState() {
    _source = KChartMinuteDataSource(
        data: KChartDataVo(mainChartData: [
      _vo
    ], subChartData: [
      [ExampleRmoData.barChartDataMinute..barWidth = 4],
      ExampleMacdData.macdMinute,
    ]));
    // 监听websocket数据
    webSocketChannel.stream.listen((data) {
      if (data == null) {
        return;
      }

      ResponseResult responseResult = responseResultFromJson(data);

      /// 分时图单根数据更新
      /* LineChartData? lineChartData = responseResult.parseMinuteData();
      if (lineChartData != null) {
        KlineUtil.logd("分时图数据增加, 数据长度：$lineChartData");
        _source.updateData(
          mainChartData: [
            LineChartVo(data: [lineChartData])
          ],
          subChartData: [],
          isAddMode: true,
          isEnd: true,
        );
        _source.resetShowData(startIndex: 0);
      } */

      /// 分时图全量数据更新
      var lineChartDataList = responseResult.parseMinuteAllData();
      if (lineChartDataList?.isNotEmpty ?? false) {
        _source.clearMainChartData();
        _source.updateData(
          mainChartData: [
            LineChartVo(data: lineChartDataList!)
          ],
          subChartData: [],
          isAddMode: false,
          isEnd: true,
        );
        _source.resetShowData(startIndex: 0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // _minuteChartDataAddStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KMinuteChartWidget(
      size: Size(MediaQuery.of(context).size.width - 20,
          MediaQuery.of(context).size.height * 0.6),
      source: _source,
      // minuteChartSubjoinData: ExampleMinuteData.subData(),
      middleNum: 11.39,
      differenceNumbers: const [11.42, 11.36],
      onTapIndicator: (int index) {
        KlineUtil.showToast(context: context, text: '点击指标索引：$index');
      },
      overlayEntryLocationKey: widget.candlestickOverlayEntryLocationKey,
    );
  }
}

class KChartMinuteDataSource extends KChartDataSource {
  KChartMinuteDataSource({
    required super.data,
    super.showDataNum = KlineConfig.minuteDataNum,
  });

  @override
  void leftmost() {}

  @override
  void rightmost() {}
}
