import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/sub_chart_renderer.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';

/// 副图组件
class SubChartWidget extends StatefulWidget {
  const SubChartWidget(
      {super.key,
      required this.size,
      required this.name,
      required this.chartData,
      this.selectedChartDataIndexStream});

  final Size size;
  final String name;
  final List<BaseChartVo> chartData;
  final StreamController<int>? selectedChartDataIndexStream;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  final StreamController<List<ChartShowDataItemVo>> _chartShowDataItemsStream =
      StreamController();

  @override
  void initState() {
    // 监听选中的数据索引位置
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      debugPrint("副图触发【监听选中的数据索引位置】监听");
      List<ChartShowDataItemVo> showDataList = [];
      
      for (var data in widget.chartData) {
        var showData =
            KlineCollectionUtil.getByIndex(data.getSelectedShowData(), index, indexMinZeroValue: data.getSelectedShowData()?.last);
        if (showData == null) {
          continue;
        }
        showDataList.add(showData);
      }
      _chartShowDataItemsStream.add(showDataList);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => debugPrint("${widget.name} onTap"),
          child: Row(children: [
            Text(widget.name),
            const Icon(Icons.arrow_drop_down),
            StreamBuilder<List<ChartShowDataItemVo>>(
                initialData: [],
                stream: _chartShowDataItemsStream.stream,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  return Wrap(
                    children: data
                            ?.where((element) => element.value != null)
                            .map((e) => Text(
                                  '${e.name} ${e.value?.toStringAsFixed(2)}   ',
                                  style: TextStyle(color: e.color),
                                ))
                            .toList() ??
                        [],
                  );
                })
          ]),
        ),
        CustomPaint(
          size: widget.size,
          painter: SubChartRenderer(chartData: widget.chartData),
        ),
      ],
    );
  }
}
