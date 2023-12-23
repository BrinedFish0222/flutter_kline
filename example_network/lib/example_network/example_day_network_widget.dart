import 'package:example_network/main.dart';
import 'package:example_network/vo/response_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kline/common/k_chart_data_source.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
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
      data: KChartDataVo(
        mainChartData: [],
        subChartData: [],
      ),
    );

    webSocketChannelStream.listen((data) {
      if (data == null) {
        return;
      }

      ResponseResult responseResult = responseResultFromJson(data);
      KlineUtil.logd('日K initState responseResult type：${responseResult.type}');
      List<BaseChartVo> dataList = responseResult.parseDayAllData();
      if (dataList.isEmpty) {
        return;
      }
      KlineUtil.logd('更新日K数据，数据长度：${dataList.first.dataLength}');
      _source.updateData(mainChartData: dataList, subChartData: [], isAddMode: false, isEnd: true);
      _source.notifyListeners();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KChartWidget(
      size: Size(
        MediaQuery.of(context).size.width,
        200,
      ),
      source: _source,
      onTapIndicator: (val) {
        KlineUtil.showToast(context: context, text: '指标索引位置：$val');
      },
      overlayEntryLocationKey: widget.overlayEntryLocationKey,
    );
  }
}
