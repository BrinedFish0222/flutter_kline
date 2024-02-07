import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/painter/volume_profile_painter.dart';
import 'package:flutter_kline/utils/kline_num_util.dart';

import '../painter/cross_curve_painter.dart';
import '../utils/kline_util.dart';
import '../vo/volume_profile_vo.dart';

/// 筹码峰
class VolumeProfileWidget extends StatelessWidget {
  const VolumeProfileWidget({
    super.key,
    this.maxValue,
    this.minValue,
    required this.dataList,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
  });

  final double? maxValue;
  final double? minValue;
  final List<VolumeProfileVo> dataList;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 十字线选中数据索引流
  final StreamController<int>? selectedChartDataIndexStream;

  @override
  Widget build(BuildContext context) {
    final GlobalKey chartKey = GlobalKey();

    Pair<double, double>? maxMinPrice = _getMaxMinPrice(dataList: dataList);
    _fillDataList(dataList: dataList, maxMinPrice: maxMinPrice);
    VolumeProfileVo.sortByPrice(dataList: dataList);

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          RepaintBoundary(
            child: CustomPaint(
              key: chartKey,
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: VolumeProfilePainter(
                dataList: dataList,
                maxValue: maxMinPrice?.left.toDouble() ?? 0,
                minValue: maxMinPrice?.right.toDouble() ?? 0,
              ),
            ),
          ),
          RepaintBoundary(
            child: StreamBuilder(
                stream: crossCurveStream?.stream,
                builder: (context, snapshot) {
                  Pair<double?, double?> selectedXY = Pair(left: null, right: null);
                  if (snapshot.data != null && !snapshot.data!.isNull()) {
                    RenderBox renderBox = chartKey.currentContext!.findRenderObject() as RenderBox;

                    Offset? selectedOffset = snapshot.data == null || snapshot.data!.isNull()
                        ? null
                        : renderBox.globalToLocal(Offset(snapshot.data?.left ?? 0, snapshot.data?.right ?? 0));
                    selectedXY.left = selectedOffset?.dx;
                    selectedXY.right = selectedOffset?.dy;
                  }

                  double? selectedHorizontalValue =
                      KlineUtil.computeSelectedHorizontalValue(maxMinValue: maxMinPrice!, height: constraints.maxHeight, selectedY: selectedXY.right);

                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CrossCurvePainter(
                        selectedXY: selectedXY,
                        pointWidth: constraints.maxHeight / dataList.length,
                        isDrawY: false,
                        isDrawText: false,
                        selectedHorizontalValue: selectedHorizontalValue,
                        selectedDataIndexAxis: Axis.vertical),
                  );
                }),
          )
        ],
      );
    });
  }

  Pair<double, double>? _getMaxMinPrice({required List<VolumeProfileVo> dataList}) {
    Pair<double, double> result;
    if (maxValue != null && minValue != null) {
      result = Pair(left: maxValue!, right: minValue!);
    } else {
      result = KlineNumUtil.maxMinValueDouble(dataList.map((e) => e.price).toList());
    }

    return result;
  }

  /// 填充数据
  void _fillDataList({required List<VolumeProfileVo> dataList, Pair<num, num>? maxMinPrice}) {
    if (dataList.isEmpty || maxMinPrice == null) {
      return;
    }

    for (double i = maxMinPrice.left.toDouble(); i > maxMinPrice.right; i -= 0.1) {
      bool any = dataList.any((element) => element.price == i);
      if (any) {
        continue;
      }

      dataList.add(VolumeProfileVo(price: i));
    }

    KlineUtil.logd("volume profile fill dataList length: ${dataList.length}");
  }
}
