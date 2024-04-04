import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/common/utils/kline_util.dart';
import 'package:flutter_kline/widget/volume_profile_widget.dart';

import 'example_volume_profile_data.dart';

/// 筹码峰
class ExampleVolumeProfileWidget extends StatefulWidget {
  const ExampleVolumeProfileWidget({super.key});

  @override
  State<ExampleVolumeProfileWidget> createState() => _ExampleVolumeProfileWidgetState();
}

class _ExampleVolumeProfileWidgetState extends State<ExampleVolumeProfileWidget> {
  /// 十字线流
  late final StreamController<Pair<double?, double?>> _crossCurveStream;

  /// 十字线选中数据索引流
  late final StreamController<int> _selectedChartDataIndexStream;

  @override
  void initState() {
    _crossCurveStream = StreamController();
    _selectedChartDataIndexStream = StreamController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dataList = ExampleVolumeProfileData.dataList;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: 200,
            // color: Colors.yellow,
            child: GestureDetector(
              onTap: () {
                _crossCurveStream.add(Pair(left: null, right: null));
              },
              onHorizontalDragUpdate: (details) {
                _crossCurveStream.add(Pair(left: details.globalPosition.dx, right: details.globalPosition.dy));
              },
              child: VolumeProfileWidget(
                maxValue: 27.94,
                minValue: 0.07,
                dataList: dataList,
                crossCurveStream: _crossCurveStream,
                selectedChartDataIndexStream: _selectedChartDataIndexStream,
              ),
            ),
          ),

          StreamBuilder<int>(
            stream: _selectedChartDataIndexStream.stream,
            builder: (context, snapshot) {
              KlineUtil.logd("volume profile cross curve selected data: ${snapshot.data}, dataList length: ${dataList.length}");
              int idx = snapshot.data == null || snapshot.data! < 0 ? 0 : snapshot.data!;
              idx = idx > dataList.length - 1 ? dataList.length - 1 : idx;

              return Text(dataList[idx].price.toStringAsFixed(2));
            }
          ),
        ],
      ),
    );
  }
}
