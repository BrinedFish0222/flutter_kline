import 'package:flutter/material.dart';
import 'package:flutter_kline/draw/draw_chart_callback.dart';
import 'package:flutter_kline/painter/line_chart_painter.dart';

import '../chart/line_chart.dart';
import '../common/chart_data_by_local_position.dart';
import '../common/utils/kline_util.dart';
import 'custom_gesture_detector.dart';
import 'draw_chart.dart';

/// 画线 - 线图
class DrawLineChart extends DrawChartWidget {
  const DrawLineChart({
    super.key,
    required super.config,
    required super.child,
  });
  
  static const String drawKey = "line";
  
  static void register() {
    DrawChartRegister().register(drawKey, (config, child) {
      return DrawLineChart(config: config, child: child);
    });
  }

  @override
  State<DrawLineChart> createState() => _DrawLineChartState();
}

class _DrawLineChartState extends State<DrawLineChart> {
  late final LineChart _lineChart;
  LineChartData? _originData;
  int _originStartIndex = 0;

  @override
  void initState() {
    KlineUtil.logd("start time: ${widget.config.candlestickChart.data.first?.dateTime} ");
    KlineUtil.logd("end time: ${widget.config.candlestickChart.data.last?.dateTime} ");
    List<LineChartData> dataList = [];
    for (var cdata in widget.config.candlestickChart.data) {
      dataList.add(LineChartData(
          id: cdata?.dateTime.toString() ?? '', dateTime: cdata?.dateTime));
    }

    // 当前是用户画线功能，指定 isUserDefine 为 true
    _lineChart = LineChart(id: "", isUserDefine: true, data: dataList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomGestureDetector(
      onPanStart: (details) {
        for (var element in _lineChart.data) {
          element?.value = null;
        }
        _addData(details.localPosition);
      },
      onPanUpdate: (details) {
        _addData(details.localPosition);
        setState(() {});
      },
      onPanEnd: (details) {
        widget.config.drawChartCallback(DrawChartCallback(
            chart: _lineChart, originStartIndex: _originStartIndex));
      },
      onHorizontalDragUpdate: (d) {
        // debugPrint("CustomGestureDetector onHorizontalDragUpdate");
      },
      onVerticalDragUpdate: (d) {
        // debugPrint("CustomGestureDetector onVerticalDragUpdate");
      },
      // onVerticalDragUpdate: (d) {},
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return CustomPaint(
          size: Size(
            boxConstraints.maxWidth,
            boxConstraints.maxHeight,
          ),
          foregroundPainter: LineChartPainter(
            lineChartData: _lineChart,
            pointWidth: widget.config.pointWidth,
            pointGap: widget.config.pointGap,
            maxMinValue: widget.config.maxMinValue,
          ),
          child: widget.child,
        );
      }),
    );
  }

  /// 添加数据，将坐标点数据转为图数据
  void _addData(Offset localPosition) {
    // 将点位数据转为图数据
    ChartDataByLocalPosition data = KlineUtil.getChartDataByLocalPosition(
      localPosition: localPosition,
      canvasSize: widget.config.size,
      maxMinValue: widget.config.maxMinValue,
      pointWidth: widget.config.pointWidth,
      pointGap: widget.config.pointGap,
      padding: widget.config.padding,
      candlestickChart: widget.config.candlestickChart,
    );

    LineChartData currentLineChartData = LineChartData(
      id: data.dateTime.toString(),
      dateTime: data.dateTime,
      value: data.value,
    );

    if (_originData == null) {
      _originData = currentLineChartData;
      var oriData = _lineChart.data
          .firstWhere((element) => element?.dateTime == _originData?.dateTime);
      oriData?.value = _originData?.value;
      _originStartIndex = data.index;
      return;
    }

    // 删除大于当前图数据的额外数据，原点除外
    // 存储数据进入_lineChartData
    if (currentLineChartData.dateTime.isBefore(_originData!.dateTime)) {
      // 当前时间点在原点前
      // 删除原点后方所有数据，删除当前点前方所有数据
      for (var lineData in _lineChart.data) {
        if (lineData == null) {
          continue;
        }
        if (lineData.dateTime.isBefore(currentLineChartData.dateTime) ||
            lineData.dateTime.isAfter(_originData!.dateTime)) {
          lineData.value = null;
          continue;
        }

        lineData.value ??= currentLineChartData.value;
      }
    } else if (currentLineChartData.dateTime.isAfter(_originData!.dateTime)) {
      // 当前时间点在原点后
      // 删除原点前方所有数据，删除当前点后方所有数据
      for (var lineData in _lineChart.data) {
        if (lineData == null) {
          continue;
        }
        if (lineData.dateTime.isBefore(_originData!.dateTime) ||
            lineData.dateTime.isAfter(currentLineChartData.dateTime)) {
          lineData.value = null;
          continue;
        }

        lineData.value ??= currentLineChartData.value;
      }
    } else {
      // 同一天，清除非原点的所有数据
      for (var lineData in _lineChart.data) {
        if (lineData == null || lineData.dateTime == _originData?.dateTime) {
          continue;
        }

        lineData.value = null;
      }
    }
  }
}

