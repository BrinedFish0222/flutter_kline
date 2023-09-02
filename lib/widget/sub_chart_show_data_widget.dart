import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../vo/chart_show_data_item_vo.dart';

/// 图显示的信息栏
/// 例如：MA  MA13:11.37  MA34:12.15
class SubChartShowDataWidget extends StatelessWidget {
  const SubChartShowDataWidget({
    super.key,
    required this.name,
    required this.onTapName,
    this.initData,
    required this.chartShowDataItemsStream,
  });

  final String name;
  final GestureTapCallback? onTapName;
  final List<ChartShowDataItemVo>? initData;
  final StreamController<List<ChartShowDataItemVo>> chartShowDataItemsStream;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          InkWell(
            onTap: onTapName,
            child: Row(
              children: [
                Text(name),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChartShowDataItemVo>>(
                initialData: initData,
                stream: chartShowDataItemsStream.stream,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: data
                            ?.where((element) => element.value != null)
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Center(
                                    child: Text(
                                      '${e.name} ${KlineNumUtil.formatNumberUnit(e.value)}',
                                      style: TextStyle(color: e.color),
                                    ),
                                  ),
                                ))
                            .toList() ??
                        [],
                  );
                }),
          )
        ]));
  }
}
