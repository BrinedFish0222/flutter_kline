import 'package:flutter/material.dart';
import 'package:flutter_kline/chart/circle_chart.dart';
import '../common/chart_data_by_local_position.dart';
import '../common/utils/kline_util.dart';
import '../painter/circle_painter.dart';
import 'custom_gesture_detector.dart';
import 'draw_chart.dart';
import 'draw_chart_callback.dart';

class DrawCircleChart extends DrawChartWidget {
  const DrawCircleChart({
    super.key,
    required super.config,
    required super.child,
  });

  static const String drawKey = "circle";

  static void register() {
    DrawChartRegister().register(drawKey, (config, child) {
      return DrawCircleChart(config: config, child: child);
    });
  }

  @override
  State<DrawCircleChart> createState() => _DrawCircleChartState();
}

class _DrawCircleChartState extends State<DrawCircleChart> {
  final List<Offset> _localPositions = [];
  late final CircleChart _chart;

  @override
  void initState() {
    List<CircleChartData?> dataList = [];
    var dataLength = widget.config.candlestickChart.data.length;
    for (int i = 0; i < dataLength; ++i) {
      dataList.add(null);
    }

    _chart = CircleChart(
      id: "",
      name: "",
      isUserDefine: true,
      maxValue: null,
      minValue: null,
      data: dataList,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomGestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onHorizontalDragUpdate: (_) {},
      onVerticalDragUpdate: (_) {},
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return CustomPaint(
          size: Size(
            boxConstraints.maxWidth,
            boxConstraints.maxHeight,
          ),
          foregroundPainter: _foregroundPainter,
          child: widget.child,
        );
      }),
    );
  }

  CustomPainter? get _foregroundPainter {
    if (_localPositions.isEmpty) {
      return null;
    }

    return CirclePainter(
      chart: _chart,
      pointWidth: widget.config.pointWidth,
      pointGap: widget.config.pointGap,
      maxMinValue: widget.config.maxMinValue,
      padding: widget.config.padding,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _addData(details.localPosition);
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _localPositions.clear();
    _addData(details.localPosition);
    setState(() {});
  }

  void _addData(Offset localPosition) {
    _localPositions.add(localPosition);

    if (_localPositions.isEmpty || _localPositions.length == 1) {
      return;
    }

    ChartDataByLocalPosition firstData = KlineUtil.getChartDataByLocalPosition(
      localPosition: _localPositions.first,
      canvasSize: widget.config.size,
      maxMinValue: widget.config.maxMinValue,
      pointWidth: widget.config.pointWidth,
      pointGap: widget.config.pointGap,
      padding: widget.config.padding,
      candlestickChart: widget.config.candlestickChart,
    );

    ChartDataByLocalPosition lastData = KlineUtil.getChartDataByLocalPosition(
      localPosition: _localPositions.last,
      canvasSize: widget.config.size,
      maxMinValue: widget.config.maxMinValue,
      pointWidth: widget.config.pointWidth,
      pointGap: widget.config.pointGap,
      padding: widget.config.padding,
      candlestickChart: widget.config.candlestickChart,
    );

    CircleChartData currentLineChartData = CircleChartData(
      id: firstData.dateTime.toString(),
      dateTime: firstData.dateTime,
      value: firstData.value,
      spaceNumber: lastData.index - firstData.index,
    );

    _chart.data[firstData.index] = currentLineChartData;
  }

  void _onPanEnd(DragEndDetails details) {
    widget.config.drawChartCallback(DrawChartCallback(
        chart: _chart, originStartIndex: 0));
  }
}

