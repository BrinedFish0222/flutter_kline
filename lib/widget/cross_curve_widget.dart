import 'dart:async';

import 'package:flutter/material.dart';

import '../common/pair.dart';
import '../common/utils/kline_util.dart';
import '../painter/cross_curve_painter.dart';

class CrossCurveWidget extends StatefulWidget {
  const CrossCurveWidget({
    super.key,
    required this.crossCurveStream,
    required this.chartKey,
    required this.size,
    required this.padding,
    required this.pointWidth,
    required this.pointGap,
    required this.maxMinValue,
  });

  /// 十字线流
  final StreamController<Pair<double?, double?>>? crossCurveStream;

  /// 图key
  final GlobalKey chartKey;

  final Size size;
  final EdgeInsets? padding;
  final double? pointWidth;
  final double? pointGap;
  final Pair<double, double> maxMinValue;

  @override
  State<CrossCurveWidget> createState() => _CrossCurveWidgetState();
}

class _CrossCurveWidgetState extends State<CrossCurveWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: StreamBuilder(
          stream: widget.crossCurveStream?.stream,
          builder: (context, snapshot) {
            if (snapshot.data?.isNull() ?? true) {
              return const SizedBox();
            }

            Pair<double?, double?> selectedXY = Pair(left: null, right: null);

            RenderBox? renderBox = widget.chartKey.currentContext
                ?.findRenderObject() as RenderBox?;
            if (snapshot.data != null && !snapshot.data!.isNull()) {
              Offset? selectedOffset = snapshot.data == null ||
                      snapshot.data!.isNull()
                  ? null
                  : renderBox?.globalToLocal(
                      Offset(
                          snapshot.data?.left ?? 0, snapshot.data?.right ?? 0),
                    );
              selectedXY.left = selectedOffset?.dx;
              selectedXY.right = selectedOffset?.dy;
            }

            double? selectedHorizontalValue =
                KlineUtil.computeSelectedHorizontalValue(
              maxMinValue: widget.maxMinValue,
              height: renderBox?.size.height ?? 100,
              selectedY: selectedXY.right,
            );
            return CustomPaint(
              size: widget.size,
              painter: CrossCurvePainter(
                selectedXY: selectedXY,
                padding: widget.padding,
                selectedHorizontalValue: selectedHorizontalValue,
                pointWidth: widget.pointWidth,
                pointGap: widget.pointGap,
              ),
            );
          }),
    );
  }
}
