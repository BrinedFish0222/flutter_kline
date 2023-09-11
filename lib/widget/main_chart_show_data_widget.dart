import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_util.dart';

import '../common/kline_config.dart';
import '../vo/main_chart_selected_data_vo.dart';

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
                var data = snapshot.data;

                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: data?.lineChartList
                          ?.where((element) => element?.value != null)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Center(
                                  child: Text(
                                    '${e?.name} ${e?.value?.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: e?.color,
                                        fontSize: KlineConfig.showDataFontSize),
                                  ),
                                ),
                              ))
                          .toList() ??
                      [],
                );
              }),
        )
      ]),
    );
  }
}
