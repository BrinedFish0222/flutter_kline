import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/chart_renderer.dart';
import 'package:flutter_kline/setting/rect_setting.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/badge_chart_vo.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/chart_show_data_item_vo.dart';
import 'package:flutter_kline/vo/mask_layer.dart';
import 'package:flutter_kline/widget/badge_widget.dart';
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
    this.padding = EdgeInsets.zero,
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

  final EdgeInsets padding;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  final StreamController<List<ChartShowDataItemVo>> _chartShowDataItemsStream =
      StreamController();

  final GlobalKey _chartKey = GlobalKey();
  List<BadgeChartVo> _badgeChartVoList = [];

  @override
  void initState() {
    BadgeChartVo.initDataValue(widget.chartData);
    _initSelectedIndexListen();

    super.initState();
  }

  /// 初始化：监听选中的数据索引位置
  void _initSelectedIndexListen() {
    widget.selectedChartDataIndexStream?.stream.listen((index) {
      KlineUtil.logd("副图触发【监听选中的数据索引位置】监听");
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
  }

  @override
  Widget build(BuildContext context) {
    // 统计高度范围
    Pair<double, double> maxMinValue = Pair.getMaxMinValue(
        widget.chartData.map((e) => e.getMaxMinData()).toList());

    _badgeChartVoList = widget.chartData.whereType<BadgeChartVo>().toList();

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Column(
          children: [
            // 信息栏
            SubChartShowDataWidget(
              initData: BaseChartVo.getLastShowData(widget.chartData),
              name: widget.name,
              onTapName: widget.onTapIndicator,
              chartShowDataItemsStream: _chartShowDataItemsStream,
            ),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      KlineUtil.logd("sub chart total height ${widget.size.height}, single height ${constraints.maxHeight}");
                      return RepaintBoundary(
                        child: CustomPaint(
                          key: _chartKey,
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: ChartRenderer(
                              chartData: widget.chartData,
                              pointWidth: widget.pointWidth,
                              pointGap: widget.pointGap,
                              maxMinValue: maxMinValue,
                              padding: widget.padding,
                              rectSetting: const RectSetting(transverseLineNum: 0)),
                        ),
                      );
                    }
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
                              snapshot.data?.left ?? 0,
                              snapshot.data?.right ?? 0));

                          double? selectedHorizontalValue =
                              KlineUtil.computeSelectedHorizontalValue(
                                  maxMinValue: maxMinValue,
                                  height: renderBox.size.height,
                                  selectedY: selectedXY.dy);

                          KlineUtil.logd("副图十字线绘制，选中的横轴值：$selectedHorizontalValue");
                          return CustomPaint(
                            size: widget.size,
                            painter: CrossCurvePainter(
                                selectedXY: Pair(
                                    left: selectedXY.dx, right: selectedXY.dy),
                                pointWidth: widget.pointWidth,
                                pointGap: widget.pointGap,
                                padding: null,
                                selectedHorizontalValue: selectedHorizontalValue),
                          );
                        }),
                  ),

                  /// badge
                  for (BadgeChartVo vo in _badgeChartVoList)
                    BadgeWidget(
                      badgeChartVo: vo,
                      pointWidth: widget.pointWidth,
                      pointGap: widget.pointGap ?? 0,
                      maxMinValue: maxMinValue,
                      padding: widget.padding,
                    ),

                  /// 遮罩层
                  if (widget.maskLayer != null && widget.maskLayer?.percent != 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaskLayerWidget(
                        maskLayer: widget.maskLayer!,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
