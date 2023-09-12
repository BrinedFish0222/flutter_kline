import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/sub_chart_renderer.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';
import 'package:flutter_kline/vo/mask_layer.dart';
import 'package:flutter_kline/widget/mask_layer_widget.dart';

import '../common/pair.dart';
import '../painter/cross_curve_painter.dart';
import 'sub_chart_show_data_widget.dart';

/// 副图组件
class SubChartWidget extends StatefulWidget {
  const SubChartWidget({
    super.key,
    required this.size,
    required this.name,
    required this.chartData,
    this.pointWidth,
    this.pointGap,
    this.maskLayer,
    this.crossCurveStream,
    this.selectedChartDataIndexStream,
    required this.onTapIndicator,
  });

  final Size size;
  final String name;
  final List<BaseChartVo> chartData;
  final double? pointWidth;
  final double? pointGap;
  final MaskLayer? maskLayer;

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  final StreamController<int>? selectedChartDataIndexStream;

  /// 点击股票指标事件
  final void Function() onTapIndicator;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  final StreamController<List<ChartShowDataItemVo>> _chartShowDataItemsStream =
      StreamController();

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    // 监听选中的数据索引位置
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      debugPrint("副图触发【监听选中的数据索引位置】监听");
      List<ChartShowDataItemVo> showDataList = [];

      for (var data in widget.chartData) {
        var selectedShowData = data.getSelectedShowData();
        var showData = KlineCollectionUtil.getByIndex(
          selectedShowData,
          index,
          indexMinZeroValue: KlineCollectionUtil.last(selectedShowData),
        );
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
    // 统计高度范围
    Pair<double, double> heightRange = Pair.getMaxMinValue(
        widget.chartData.map((e) => e.getMaxMinData()).toList());

    return SizedBox(
      width: widget.size.width,
      child: Column(
        children: [
          // 信息栏
          SubChartShowDataWidget(
            initData: BaseChartVo.getLastShowData(widget.chartData),
            name: widget.name,
            onTapName: widget.onTapIndicator,
            chartShowDataItemsStream: _chartShowDataItemsStream,
          ),
          Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  key: _chartKey,
                  size: widget.size,
                  painter: SubChartRenderer(
                      chartData: widget.chartData,
                      pointWidth: widget.pointWidth,
                      pointGap: widget.pointGap,
                      heightRange: heightRange),
                ),
              ),
              RepaintBoundary(
                child: StreamBuilder(
                    stream: widget.crossCurveStream?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const SizedBox();
                      }

                      RenderBox renderBox = _chartKey.currentContext!
                          .findRenderObject() as RenderBox;
                      var selectedXY = renderBox.globalToLocal(Offset(
                          snapshot.data?.left ?? 0, snapshot.data?.right ?? 0));

                      double? selectedHorizontalValue =
                          KlineUtil.computeSelectedHorizontalValue(
                              maxMinValue: heightRange,
                              height: widget.size.height,
                              selectedY: selectedXY.dy);

                      debugPrint("副图十字线绘制，选中的横轴值：$selectedHorizontalValue");
                      return CustomPaint(
                        size: widget.size,
                        painter: CrossCurvePainter(
                            selectedXY:
                                Pair(left: selectedXY.dx, right: selectedXY.dy),
                            pointWidth: widget.pointWidth,
                            pointGap: widget.pointGap,
                            selectedHorizontalValue: selectedHorizontalValue),
                      );
                    }),
              ),

              /// 遮罩层
              if (widget.maskLayer != null && widget.maskLayer?.percent != 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: MaskLayerWidget(
                    width: widget.size.width * widget.maskLayer!.percent,
                    height: widget.size.height,
                    onTap: widget.maskLayer?.onTap,
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
