import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/candlestick_chart_renderer.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_random_util.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<LineChartVo?> _lineChartData = [
    LineChartVo(
        dataList: List.generate(
            300, (index) => KlineRandomUtil.generateRandomDouble(12, 50)),
        color: Colors.red),
    LineChartVo(
        dataList: List.generate(
            300, (index) => KlineRandomUtil.generateRandomDouble(12, 50)),
        color: Colors.transparent)
  ];

  final StreamController<List<LineChartVo?>> _streamController =
      StreamController();

  late Timer _updateDataTimer;

  @override
  void initState() {
    _updateDataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _lineChartData[0]!
          .dataList!
          .add(KlineRandomUtil.generateRandomNumber(12, 50).toDouble());
      _lineChartData[1]!
          .dataList!
          .add(KlineRandomUtil.generateRandomNumber(12, 50).toDouble());
      _streamController.add(_lineChartData);
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    _updateDataTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _buildCustomPaint(),
      ),
    );
  }

  _buildCustomPaint() {
    var size = const Size(800, 300);
    return RepaintBoundary(
      child: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            // 只展示5条数据。
            if (KlineCollectionUtil.isNotEmpty(snapshot.data)) {
              for (var element in snapshot.data!) {
                element!.dataList =
                    KlineCollectionUtil.lastN(element.dataList, 241);
              }
            }

            return CustomPaint(
              size: size,
              painter: CandlestickChartRenderer(lineChartData: snapshot.data!),
            );
          }),
    );
  }
}
