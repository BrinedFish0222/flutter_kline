import 'dart:async';

import 'package:flutter/material.dart';

import '../vo/selected_chart_data_stream_vo.dart';

/// 主图信息栏
class MainChartShowDataWidget extends StatelessWidget {
  const MainChartShowDataWidget({
    super.key,
    required this.name,
    required StreamController<MainChartSelectedDataVo>
        mainChartSelectedDataStream,
  }) : _mainChartSelectedDataStream = mainChartSelectedDataStream;

  final String name;
  final StreamController<MainChartSelectedDataVo> _mainChartSelectedDataStream;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(children: [
        InkWell(
          onTap: () => debugPrint("主图信息栏点击"),
          child: Row(
            children: [
              Text(name),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<MainChartSelectedDataVo>(
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
                                    style: TextStyle(color: e?.color),
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
