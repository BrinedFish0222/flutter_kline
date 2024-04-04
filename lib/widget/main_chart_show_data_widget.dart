import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chart_show_data_item_vo.dart';
import '../common/main_chart_selected_data_vo.dart';
import '../common/kline_config.dart';

/// 主图信息栏
class MainChartShowDataWidget extends StatelessWidget {
  const MainChartShowDataWidget({
    super.key,
    required this.name,
    required StreamController<MainChartSelectedDataVo>
        mainChartSelectedDataStream,
    this.initData,
    required this.onTap,
  }) : _mainChartSelectedDataStream = mainChartSelectedDataStream;

  final String name;
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream;
  final MainChartSelectedDataVo? initData;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KlineConfig.showDataSpaceSize,
      child: Row(children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: KlineConfig.showDataFontSize),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: KlineConfig.showDataIconSize,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<MainChartSelectedDataVo>(
              initialData: initData,
              stream: _mainChartSelectedDataStream.stream,
              builder: (context, snapshot) {
                List<ChartShowDataItemVo>? data = snapshot.data?.lineChartList
                    ?.where((element) => element?.value != null)
                    .map((e) => e!)
                    .toList();

                if (data == null || data.isEmpty) {
                  return const SizedBox();
                }

                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: data
                      .map(
                        (e) => _ShowDataItemWidget(e),
                      )
                      .toList(),
                );
              }),
        )
      ]),
    );
  }
}

class _ShowDataItemWidget extends StatelessWidget {
  const _ShowDataItemWidget(
    this.item,
  );

  final ChartShowDataItemVo item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Center(
        child: Text(
          '${item.name} ${item.value?.toStringAsFixed(2)}',
          style: TextStyle(
            color: item.color,
            fontSize: KlineConfig.showDataFontSize,
          ),
        ),
      ),
    );
  }
}
